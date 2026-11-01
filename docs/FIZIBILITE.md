# Fizibilite: ne yapılabilir, ne yapılamaz, ne doğrulanmalı

Bu doküman, modun **neden bazı istekleri kısmen karşıladığını** açıklar. Yazarken BI wiki ve Bohemia forumuna
erişilemedi (ağ izin listesinde değiller); aşağıdaki "kesin" ifadeler Arma 3 modlama pratiğinden gelir,
"doğrulanmadı" olarak işaretlenenler ise oyunda ya da resmi dokümanla sınanmalıdır.

## 1. Motor termali nasıl çiziyor (özet)

Arma 3'te bir nesnenin termal görünümü, **modelin kendi termal dokusundan** (`*_ti_ca.paa`, rvmat içindeki
`StageTI` sınıfı) gelir. Bu doku modelin UV düzenine boyanmıştır: vücudun hangi bölgesinin, aracın hangi
panelinin ne kadar sıcak olacağını **model yazarı** belirler. Motor bunun üstüne yalnızca birkaç dinamik
çarpan uygular (motor çalışıyor mu, araç hareket ediyor mu, silah ateş etti mi).

Sonuçları:

| İstek | Neden script/config ile olmaz |
|-------|-------------------------------|
| İnsan anatomisine göre ısı (yüz/el sıcak, gövde/üniforma serin, ekipman soğuk) | Isı dağılımı üniforma/karakter modelinin TI dokusundadır. Script bir pikseli boyayamaz. |
| Motordan ve namludan uzaklaştıkça **mekânsal** sönümleme | Gradyan aracın TI dokusundadır. Script yalnızca "motor ısısı" çarpanını zamanla değiştirebilir. |
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
araç sınıfına göre bulunan motor noktasına eklenir. RHS/CUP dosyası gerekmez çünkü varlık bize aittir; ama TI doku
formatı (kanal anlamları) bilinmeli → "Thermal Imaging Maps" sayfası.

İnsanlar için bu hile **işe yaramaz**: leke ekleyebilir (yüz/el), üniformanın taban ısısını düşüremez; ayrıca her
askere sprite eklemek hem ağır hem dağınık görünür.

## 3. Gerçek anatomik / mekânsal ısı için gereken (v0.3+)

**Kapsam kararı (anatomik ısı): yalnızca VÜCUT.** Yelek, kask, çanta gibi ekipman kapsam dışı. RHS'teki iri yelekler
gövdeyi zaten örter ve kendi modelleri vardır; görünür ısı farkını belirleyen yüz, boyun, eller/ön kollar ve
uzuvlardır. Bu iş yükünü ciddi biçimde küçültür: yelek/kask/çanta için ayrı doku gerekmez.

Not: Arma'da "çıplak vücut" genelde ayrı bir varlık değildir. Vücut ve kıyafet çoğunlukla **aynı üniforma
modelinin** parçasıdır (eller üniforma mesh'indedir), kafa ise ayrı bir modeldir (yüz dokusu). Yani vücut haritası
**üniforma modeli başına** bir kez boyanır; kamuflaj çeşitleri aynı modeli paylaşıyorsa aynı haritayı paylaşır.
Kaç farklı model olduğunu `call RTI_fnc_exportUniforms` söyler.

RHS ve CUP modellerinin termal dokularını yeniden yazmak gerekir:

1. Üniforma ve araç sınıfları için yeni bir rvmat + `*_ti_ca.paa` hazırlanır (kanal anlamları için BI
   "Thermal Imaging Maps" sayfası okunmalı; arama özetinde "kırmızı kanal %100 beyazsa config'teki yarı-soğuma
   süreleri değişmeden kullanılır" ifadesi geçiyor, **doğrulanmadı**).
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
| A1 | `setVehicleTIPars` / `getVehicleTIPars` vardır | `call RTI_fnc_diag` → "yetenek" satırı | Araç modeli kendini kapatır, mod çalışmaya devam eder |
| A2 | Dizi sırası `[motor, tekerlek, silah]` | `[] call RTI_fnc_diagTrace`; motoru aç / sür / ateş et, hangi indeks arttığına bak | "TI parametre sırası" ayarıyla düzelt (ör. `1,0,2`) |
| A3 | Komut yerel etkilidir; oyun her karede üzerine yazmaz | Trace'te değerlerin 1 sn'lik tikler arasında bizim hesapladığımızla uyuşması | Gözlem gereken ayrıntı; bildir |
| A4 | Post-process, TI çiziminin üstüne uygulanır | Termalde ayar sürgüleri görüntüyü değiştirmeli | Sensör modülü işe yaramaz |
| A5 | `#particlesource` parçacıkları TI'de sıcak çizilir | `call RTI_fnc_testHeatSpot` (termalden bak) | "Başkalarının flaşı" kapatılır, farklı yöntem (nesne) denenir |
| A6 | `Fired` olayı yalnızca atıcının yerel olduğu makinede çalışır | Dedicated sunucu + 2 istemci testi (TEST_ASAMA1 §7) | Olay yolu değişir |
| A7 | PiP mercekli optikte `currentVisionMode` 2 döner ama ana ekran normaldir | PiP'li RHS/CUP optikle dene | "Efekt uygulanmayacak optikler" listesi doldurulur |
| A8 | `selectionPosition [ad, "HitPoints"]` HitEngine seçiminin konumunu verir; RHS/CUP araçlarında `HitEngine >> name` dolu | `call RTI_fnc_diag` (sıcak nokta satırı) + `[true] call RTI_fnc_spotDebug` | Motor noktası çıkmaz; konum sınıf bazlı elle verilmeli |
| A9 | `attachTo [araç, [0,0,0], bellekNoktası]` `#particlesource` için çalışır ve taret dönerken izler | `spotDebug` açıkken tareti çevir; termalde namlu lekesi izliyor mu | Namlu lekesi sabit kalır; ofset yöntemine geçilir |
| A10 | `\A3\data_f\kouleSvetlo` yumuşak yuvarlak sprite'tır ve TI'de parlaklığına göre çizilir | `testHeatSpot` benzeri; termalde araç üstünde leke | Sprite görünmez ya da kare/sert çıkar; başka doku denenir |

## 5. Kullanıcıdan istenen dokümanlar

Doğrulama için okunması gerekenler (BI wiki ve forum bu oturumun ağında kapalıydı; içerikleri yapıştırmak
ya da alan adlarını izin listesine eklemek yeterli):

- https://community.bistudio.com/wiki/Thermal_Imaging_Maps (TI dokusu kanal anlamları, yarı-soğuma süresi)
- https://community.bistudio.com/wiki/setVehicleTIPars ve https://community.bistudio.com/wiki/getVehicleTIPars
  (sözdizimi, dizi sırası, yerellik, hangi nesnelerde çalıştığı)
- https://community.bistudio.com/wiki/currentVisionMode (optiklerde / PiP'te davranışı)
- https://community.bistudio.com/wiki/ppEffectAdjust (ColorCorrections / FilmGrain / DynamicBlur parametre tabloları)
- https://community.bistudio.com/wiki/setParticleClass ve CfgCloudlets sınıf alanları (parçacık sıcaklığı)
- https://forums.bohemia.net/forums/topic/107957-thermal-imaging-maps/
- https://forums.bohemia.net/forums/topic/223414-thermal-signature-question (`hiddenSelectionsMaterials` ile rvmat değiştirme)

Ayrıca TEST_ASAMA1.md'deki testlerin RPT çıktıları (`[RTI][DIAG]`, `[RTI][SCOPE]`, `[RTI][TRACE]`).
