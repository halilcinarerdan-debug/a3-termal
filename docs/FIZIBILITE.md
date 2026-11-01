# Fizibilite: ne yapılabilir, ne yapılamaz, ne doğrulanmalı

Bu doküman, modun **neden bazı istekleri kısmen karşıladığını** açıklar. BI wiki ve Bohemia forumu geliştirme
ortamının ağında kapalı; şu wiki sayfaları kullanıcı tarafından yapıştırıldı ve buraya yansıtıldı:
`setVehicleTIPars`, `getVehicleTIPars`, `Thermal Imaging Maps`, `currentVisionMode`, `ppEffectAdjust`,
`setParticleClass`. Bunlarla doğrulananlar ✅ ile işaretlidir; geri kalanı "doğrulanmadı"dır ve oyunda ya da
resmi dokümanla sınanmalıdır.

## 0. Güncelleme (0.3.0): oyun içi gözleme göre öncelik değişti

Oyun içi ekran görüntülerinden (Zeus kamerası) çıkanlar:
- **Asker yakın planı çok iyi**: yüz/boyun sıcak, kask ve tişört daha serin, yumuşak geçişler. Anatomik üniforma TI
  haritası projesi (§3) bu yüzden **öncelik dışı**; oyunun kendi insan dokusu yeterli görünüyor.
- "Uzaylı" hissini veren: (a) zemin orta gri ve (b) çimen yamaları siyah-gri leke olarak çizildiği için asker gövdesi
  (yine orta gri) uzaktan zeminden ayrışmıyor; (c) araç gövdesi tek tip beyaz.
- Önceki sürümlerdeki varsayılan "kontrast 0.85, parlaklık 0.95" siyah-beyaz farkını **sıkıştırıyordu** (beyaza patlama
  varsayımıyla yazılmıştı; yanlıştı). 0.3.0'da varsayılan **Agresif**: kontrast ↑, siyah seviyesi (ofset) ↓, bulanıklık ↑.
- Çimen yamaları araziye çizilen clutter'dır; sınıf adına bağlı termal ayarı yok. Ton ayarı + bulanıklık yamaları siler;
  gerçek kaldırma arazi ızgarasıdır (Video "Arazi ayrıntısı").
- Hava / mevsim: `env/` modülü hesaplar (hava sıcaklığı, güneş, bulutluluk, sis, yağmur). Nesne bazında kontrast yalnızca
  araçlarda (`setVehicleTIPars`) ayarlanabilir; statik nesneleri (bina, kaya) oyun kendisi çizer.

## 1. Motor termali nasıl çiziyor (özet)

Arma 3'te bir nesnenin termal görünümü, **modelin kendi termal dokusundan** (`*_ti_ca.paa`, rvmat içindeki
`StageTI` sınıfı) gelir. Bu doku modelin UV düzenine boyanmıştır: vücudun hangi bölgesinin, aracın hangi
panelinin ne kadar sıcak olacağını **model yazarı** belirler. Motor bunun üstüne yalnızca birkaç dinamik
çarpan uygular (motor çalışıyor mu, araç hareket ediyor mu, silah ateş etti mi).

**TI dokusunun kanalları** ✅ (BI wiki "Thermal Imaging Maps"; dikkat: sayfa Arma 2 dönemi, son düzenleme 2020 — Arma 3'te de aynı kabul ediliyor ama oyunda sınanmalı):

| Kanal | Anlam | `setVehicleTIPars` karşılığı (çıkarım) |
|-------|-------|-----------------------------------------|
| Kırmızı | Hep %100 beyaz ise config'teki yarı-soğuma süreleri değişmeden kullanılır; yalnızca **güneşten** ne kadar ısınacağını etkiler | — |
| Yeşil | Gri 3D gürültü + lightmap taban katmanı; parlak alanlar = araç **çalışırken** ısınan kaynaklar (motor) | `engine` (motor **ve gövde**) |
| Mavi | %100 siyah; beyaz alanlar hareketli parçalar (ör. tekerlekler) | `wheels` (palet/tekerlek) |
| Alfa | **Metabolizma ısısı: insanlarda**; tank/silahlarda **namlu ısısı**. Yeşil kanalla benzer boyanır | `weapon` (ana silah) |

(Yeşil/Mavi/Alfa ↔ motor/tekerlek/silah eşlemesi iki wiki sayfasının birlikte okunmasından çıkarımdır; wiki açıkça yazmıyor.
`getVehicleTIPars` aynı üç değeri `[aliveFactor, movementFactor, metabolismFactor]` adıyla döndürür.)

Sonuçları:

| İstek | Neden script/config ile olmaz |
|-------|-------------------------------|
| İnsan anatomisine göre ısı (yüz/el sıcak, gövde/üniforma serin) | Bölge dağılımı üniforma/karakter modelinin TI dokusunun **alfa kanalındadır** ✅. Script bir pikseli boyayamaz. (Genel vücut ısısı çarpanı ayrı bir konu: bkz. §2c.) |
| Motordan ve namludan uzaklaştıkça **mekânsal** sönümleme | Gradyan aracın TI dokusunun **yeşil** (motor) ve **alfa** (namlu) kanalındadır ✅. Script yalnızca bu kanalların çarpanını zamanla değiştirebilir. |
| Işık / ateş kaynağının sıcak görünmesi | Dünyada sıcak nokta yaratmak için nesne ya da parçacık gerekir; parçacığın TI'de nasıl çizildiği **doğrulanmadı**. |

## 2. Bu modun script ile yaptıkları

- **Ekran işleme (sensör):** TI çizildikten sonra post-process uygulanır (`ColorCorrections`, `FilmGrain`,
  `DynamicBlur`). Beyaza patlamış, keskin kenarlı "uzaylı" görünümü yumuşatır; gerçek sensörlerin AGC /
  NETD / MTF karakterini taklit eder. Isı dağılımını **değiştirmez**, yalnızca tonlamayı.
- **Zamansal araç ısısı:** motor ısınma/soğuma, tekerlek-palet ısınması, namlu ısınması. Birinci derece model
  `H(t) = hedef + (H0 − hedef)·exp(−Δt/τ)`; sınıfa göre zaman sabitleri `vehicle/fn_vehProfile.sqf`'de
  (tahmin değerleri; "Soğuma süresi çarpanı" ile ölçeklenir).
- **Kendi atışım için flaş:** ekran uzayında; dünya nesnesine bağlı olmadığı için termal render'ını
  nasıl yaptığından bağımsızdır.

## 2b. Sıcak nokta "hilesi" (araçlar için, v0.2)

RHS/CUP dosyalarına erişim olmadan mekânsal sönümü yaklaşıklamak için: model dokusunu değiştirmek yerine
**üstüne ısı lekesi** bırakılır.

1. Nokta konumları araç sınıfı config'inden otomatik çözülür (sınıf tablosu yok):
   - motor: `HitPoints >> HitEngine >> name` seçiminin `selectionPosition [ad, "HitPoints"]` konumu, modelin
     sınır kutusunun tepesine doğru "Motor lekesi yükseltme" oranında kaldırılır (gövdeye gömülü kalmasın);
   - egzoz: `Exhausts >> * >> position` bellek noktaları (en çok 2);
   - namlu: ilk `gunBeg` / `gunEnd` bellek noktaları (namlu ucu ve kama). `attachTo [araç, ofset, bellekNoktası]`
     ile taret/namlu dönerken noktalar onu izler.
2. Her noktaya yumuşak kenarlı yuvarlak bir sprite (`kouleSvetlo`) konur; parlaklığı, mevcut zamansal modelden
   gelen motor / namlu ısısına göre 4 kademeden biridir. Kenara doğru sönme sprite'ın radyal gradyanıdır.
3. Yalnızca oyuncu termaldeyken, yalnızca en yakın N araç için, yerel (ağ trafiği yok) üretilir. Normal görüşte
   hiçbir leke oluşturulmaz.

Sınırları: sprite kameraya dönüktür (yandan bakınca "asılı leke"), gövde geometrisiyle kırpılır (içerideyse
görünmez), gerçek dokunun yerini tutmaz. Yaklaşık ama mod-bağımsız çalışır. Doğrulama: `[true] call RTI_fnc_spotDebug`
(normal görüşte noktaların yerini gösterir) ve `call RTI_fnc_diag` (çözülen noktaları yazar).

Daha sağlam yol (v0.4): **kendi** küçük bir proxy modelimiz (düz disk) ve kendi radyal gradyanlı TI dokumuz;
araç sınıfına göre bulunan motor noktasına eklenir. RHS/CUP dosyası gerekmez çünkü varlık bize aittir. Kanal anlamları
artık biliniyor ✅ (yeşil = motor gibi ısı kaynağı gradyanı), yani proxy'nin dokusunun yeşil kanalına radyal gradyan
boyanır ve proxy'nin `engine` çarpanı `setVehicleTIPars` ile sürülebilir (proxy da bir nesne; **doğrulanmadı**).
Kalan iş: MLOD p3d + rvmat (`StageTI`) + PAA üretimi ve oyunda sınama.

İnsanlar için bu hile **işe yaramaz**: leke ekleyebilir (yüz/el), üniformanın taban ısısını düşüremez; ayrıca her
askere sprite eklemek hem ağır hem dağınık görünür.

## 2c. İnsan vücut ısısı çarpanı (test edilecek, v0.3 adayı)

`setVehicleTIPars` wiki sayfası yalnızca "piyade **silahlarında** çalışmaz" diyor ✅; piyade **birimleri** hakkında bir şey
söylemiyor. İnsanda TI dokusunun alfa kanalı "metabolizma ısısı" olduğu için (`metabolismFactor`), komut bir askerde de
bu çarpanı sürüyor olabilir. **Bu doğrulanmadı**; tek komutla sınanır (debug konsolu, bir askere bakarken):

```sqf
getVehicleTIPars cursorObject;                  // [alive, movement, metabolism] dönüyor mu? değerler ne?
cursorObject setVehicleTIPars [1, 0, 0.3];      // 3. değer = metabolizma/silah; askerin ısısı termalde değişiyor mu?
```

Çalışırsa mümkün olan (hepsi **genel** çarpandır, bölge dağılımı dokuda kalır):
- üniformanın "uzaylı" taban parlaklığını düşürmek (ayarlanabilir vücut ısısı çarpanı);
- dinamik metabolizma: koşarken / sprintte artış, yatarken / dinlenirken düşüş, yaralıda düşüş, soğuk havada düşüş;
- ölü askerin soğuma eğrisi (oyunun kendi eğrisi yeterli değilse).

Çalışmazsa insan tarafında yalnızca doku yolu kalır (§3).

## 3. Gerçek anatomik / mekânsal ısı için gereken (v0.3+)

**Kapsam kararı (anatomik ısı): yalnızca VÜCUT.** Yelek, kask, çanta gibi ekipman kapsam dışı. RHS'teki iri yelekler
gövdeyi zaten örter ve kendi modelleri vardır; görünür ısı farkını belirleyen yüz, boyun, eller/ön kollar ve
uzuvlardır. Bu iş yükünü ciddi biçimde küçültür: yelek/kask/çanta için ayrı doku gerekmez.

Not: Arma'da "çıplak vücut" genelde ayrı bir varlık değildir. Vücut ve kıyafet çoğunlukla **aynı üniforma
modelinin** parçasıdır (eller üniforma mesh'indedir), kafa ise ayrı bir modeldir (yüz dokusu). Yani vücut haritası
**üniforma modeli başına** bir kez boyanır; kamuflaj çeşitleri aynı modeli paylaşıyorsa aynı haritayı paylaşır.
Kaç farklı model olduğunu `call RTI_fnc_exportUniforms` söyler.

RHS ve CUP modellerinin termal dokularını yeniden yazmak gerekir:

1. Üniforma ve araç sınıfları için yeni bir rvmat + `*_ti_ca.paa` hazırlanır. Kanal anlamları §1'de ✅:
   insan için **alfa** (metabolizma), araç motoru için **yeşil**, namlu için **alfa**, tekerlek/palet için **mavi**;
   kırmızı kanal %100 beyaz bırakılır (config'teki yarı-soğuma süreleri değişmez).
2. Config'te `hiddenSelectionsMaterials[]` ile modelin ilgili seçimine yeni rvmat bağlanır (forum
   kaynaklı bir öneri; **doğrulanmadı**). Bu, modelin `hiddenSelections` tanımlamasına ve orijinal rvmat'ların
   bilinmesine bağlıdır.
3. Doku, modelin UV düzenine göre boyanmalıdır → **RHS/CUP model dosyaları veya UV şablonları gerekir.**
   Lisans koşulları (türev varlık dağıtımı) ilgili mod yazarlarının kurallarına göre ayrıca kontrol edilmelidir.

Bu iş sanatsal/asset işidir; script modu bunun altyapısı ile karıştırılmamalı. Anatomik ısıyı gerçekten
istiyorsan v0.3 ayrı bir "veri modu" (`rti_data`) olarak planlanmalı.

## 4. Doğrulanması gereken varsayımlar (kodun dayandığı)

| # | Varsayım | Nasıl doğrulanır | Yanlışsa ne olur |
|---|----------|------------------|------------------|
| A1 | `setVehicleTIPars` / `getVehicleTIPars` vardır | ✅ wiki: set Arma 3 0.50+, get 2.00+. `call RTI_fnc_diag` ile yine de teyit | — |
| A2 | Dizi sırası `[motor+gövde, tekerlek/palet, ana silah]` | ✅ wiki sayfası bu sırayı veriyor (varsayılan `0,1,2` doğru) | — |
| A3a | Komut **yerel** etkilidir | ✅ wiki: "Local Effect" — tasarım zaten her istemcide ayrı uyguluyor | — |
| A3b | Oyun, motor kapalıyken bile verdiğimiz değerleri her karede üzerine yazmaz | Wiki örneği ("motoru ısıt, kış için ideal") kalıcı geçersiz kılma olduğunu düşündürüyor; yine de `diagTrace` ile 1 sn'lik tikler arasında değerlerin bizim hesapladığımızla uyuşmasına bak | Gözlem gereken ayrıntı; bildir |
| A4 | Post-process, TI çiziminin üstüne uygulanır **ve** termal/NVG açıkken çizilir | Termalde ayar sürgüleri görüntüyü değiştirmeli. Wiki'nin "See also" listesindeki `ppEffectForceInNVG` bu yüzden tüm PP efektlerine uygulandı (v0.2.2); gerekli olup olmadığı oyunda sınanmalı | Sensör modülü işe yaramaz |
| A5 | `#particlesource` parçacıkları TI'de sıcak çizilir | `call RTI_fnc_testHeatSpot` (termalden bak) | "Başkalarının flaşı" kapatılır, farklı yöntem (nesne) denenir |
| A6 | `Fired` olayı yalnızca atıcının yerel olduğu makinede çalışır | Dedicated sunucu + 2 istemci testi (TEST_ASAMA1 §7) | Olay yolu değişir |
| A7 | PiP mercekli optikte `currentVisionMode` 2 döner ama ana ekran normaldir | PiP'li RHS/CUP optikle dene | "Efekt uygulanmayacak optikler" listesi doldurulur |
| A8 | `selectionPosition [ad, "HitPoints"]` HitEngine seçiminin konumunu verir; RHS/CUP araçlarında `HitEngine >> name` dolu | `call RTI_fnc_diag` (sıcak nokta satırı) + `[true] call RTI_fnc_spotDebug` | Motor noktası çıkmaz; konum sınıf bazlı elle verilmeli |
| A9 | `attachTo [araç, [0,0,0], bellekNoktası]` `#particlesource` için çalışır ve taret dönerken izler | `spotDebug` açıkken tareti çevir; termalde namlu lekesi izliyor mu | Namlu lekesi sabit kalır; ofset yöntemine geçilir |
| A10 | `\A3\data_f\kouleSvetlo` yumuşak yuvarlak sprite'tır ve TI'de parlaklığına göre çizilir | `testHeatSpot` benzeri; termalde araç üstünde leke | Sprite görünmez ya da kare/sert çıkar; başka doku denenir |
| A11 | `setVehicleTIPars` piyade **birimlerinde** de çarpan sürer (3. değer = metabolizma) | §2c komutları | İnsanda yalnızca doku yolu kalır |
| A12 | FLIR indeksi -> palet kutbu eşlemesi: siyah sıcak = 1, 3, 5 (`setCamUseTI` sayfasından teyit edilmedi) | Ayar "Otomatik"; optikte palet değiştirirken flaş yönü de değişmeli | `RTI_sensor_blackHotIndices` düzeltilir veya elle seçim |
| A13 | `attachTo [araç, ofset, bellekNoktası]` `#particlesource` için de çalışır (wiki `setParticleClass` örneği yalnızca `[nesne,[0,0,0]]` ofset biçimini gösteriyor) | Bkz. A9 | Namlu için ofset yöntemine geçilir |

✅ `setParticleClass`: sınıf değerleri düz sayı olmalı (wiki: basit ifadeler değerlendirilmez); `RTI_Glow_*` / `RTI_MuzzleHeat_*` sınıfları düz sayıdır.
✅ `currentVisionMode [birim]` Arma 3 2.08+ ile `[mod, flirIndeksi]` döndürür; hatada `objNull` için 0 / `[-1,-1]` — kod bunu zaten güvenle ele alıyor. Bu yüzden `requiredVersion = 2.08`.

## 5. Kullanıcıdan istenen dokümanlar

Alınan sayfalar ✅: `Thermal_Imaging_Maps`, `setVehicleTIPars`, `getVehicleTIPars`, `currentVisionMode`,
`ppEffectAdjust`, `setParticleClass`.

Hâlâ doğrulama bekleyenler için okunması gerekenler (BI wiki ve forum geliştirme ortamının ağında kapalı;
sayfa içeriğini yapıştırmak yeterli):

- https://community.bistudio.com/wiki/setCamUseTI (FLIR indeksi -> palet kutbu eşlemesi; A12)
- https://community.bistudio.com/wiki/ppEffectForceInNVG (PP efektlerinin termalde çizilmesi; A4)
- https://community.bistudio.com/wiki/attachTo (bellek noktasına ekleme + parçacık kaynağı; A9, A13)
- https://community.bistudio.com/wiki/Arma_3:_Particle_Effects (parçacıkların TI'de çizimi; A5)
- https://community.bistudio.com/wiki/disableTIEquipment (wiki "See also"; kapsamı)
- https://forums.bohemia.net/forums/topic/107957-thermal-imaging-maps/ (TI haritası tartışması)
- https://forums.bohemia.net/forums/topic/223414-thermal-signature-question (`hiddenSelectionsMaterials` ile rvmat değiştirme)
- Arma 3'te TI haritasının **config tarafı**: Thermal Imaging Maps sayfası "config'teki yarı-soğuma süreleri"nden söz
  ediyor; bu değerlerin sınıf özellik adları (araç başına soğuma süresi) bilinirse model buna bağlanabilir.

Ayrıca TEST_ASAMA1.md'deki testlerin RPT çıktıları (`[RTI][DIAG]`, `[RTI][SCOPE]`, `[RTI][TRACE]`).
