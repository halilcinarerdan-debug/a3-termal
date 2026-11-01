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

## 3. Gerçek anatomik / mekânsal ısı için gereken (v0.3+)

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
