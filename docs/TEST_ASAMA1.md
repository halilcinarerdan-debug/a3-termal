# Aşama 1 — oyunda test rehberi (v0.1)

Kod HEMTT ile derlendi ama **hiç oyunda çalıştırılmadı**. Bu rehber, hangi parçanın gerçekten çalıştığını
sırayla kanıtlamak içindir. Her adımın sonunda "beklenen" ve "bana ne gönder" var.

| Kademe | Nasıl | Neyi kanıtlar | Neyi **kanıtlamaz** |
|--------|-------|---------------|---------------------|
| 1. Editör (SP) | Eden → Play | sensör, kendi flaşım, araç modeli, komut desteği | ağ, başkalarının flaşı (uzak istemci) |
| 2. Hosted MP | Eden → In Multiplayer | MP ortamı | uzak istemci yolu (host aynı zamanda sunucu) |
| 3. Yerel dedicated + 2 istemci | `arma3server_x64.exe` + iki `arma3_x64.exe` | **gerçek ağ yolu**: başkalarının flaşı, araç durum yayını, JIP | — |

İpuçları:
- Başlatma: `-mod=@CBA_A3;@RTI;@RHS...;@CUP... -showScriptErrors`
- Debug konsolu: **Local Exec** = senin makinen. Sonuçlar RPT'de (`%LOCALAPPDATA%\Arma 3\*.rpt`, `[RTI]` ara).
- Oyun açıkken PBO değiştirilemez; her değişiklikten sonra `hemtt build`.

---

## 0. Hazırlık

1. `hemtt build` → `.hemttout/build` içindeki `@RTI`'yı mod klasörüne kopyala.
2. Ana menü → **Options → Addon Options → "RTI - Gerçekçi Termal"** kategorileri görünmeli (Genel, Sensör, Namlu flaşı, Araç ısı modeli).

## 1. Yükleme ve komut desteği

Eden'de VR haritası, bir oyuncu birimi → **Play**. Debug konsolu, Local Exec:

```sqf
call RTI_fnc_diag;
```

Beklenen: sohbet satırında "Tanı raporu panoya kopyalandı". **Raporu bana yapıştır** (Ctrl+V). Özellikle:
`yetenek | setVehicleTIPars=… getVehicleTIPars=…` ve `ilgili komutlar (…)` satırları.

RPT'de `[RTI][SCOPE] termal optik: toplam N | RHS x | CUP y` satırı çıkmalı (RHS/CUP yüklüyse x, y > 0).
**O RPT satırlarını da gönder** (RHS/CUP optik listesi).

## 2. Sensör (ekran işleme) — termal optik gerekir

Oyuncuya termal bir optik ver (RHS veya CUP termal nişangah / vanilla TWS) ve nişan al.

- Termal açıkken **Addon Options → Sensör**'deki sürgüler **anında** görüntüyü değiştirmeli
  (kontrast 0.5 ↔ 1.2, gürültü 0 ↔ 1, yumuşatma 0 ↔ 1.5). Değiştirmiyorsa varsayım A4 yanlış.
- Termalden çıkınca (normal görüş) görüntü **tamamen eski haline** dönmeli.
- "Sensör efektleri aktif" kapalıyken görüntü vanilla olmalı.
- **Hiç değişiklik olmuyorsa** (sürgüler görüntüye etki etmiyorsa) bunu özellikle bildir: PP efektlerinin termalde
  çizilmesi (varsayım A4) o zaman çözülmemiş demektir. Efektlere zaten `ppEffectForceInNVG` uygulandı; yetmediyse
  başka bir yol (ör. optiğin kendi `opticsPPEffects` ayarı) gerekir.

**Gönder:** hangi optikte test ettin, "daha az uzaylı" mı oldu (kontrast/parlaklık hangi değerde iyi göründü), ekran görüntüsü.

PiP (render-target) mercekli bir optikse: normal ana ekran bozuluyorsa optik sınıfını "Efekt uygulanmayacak optikler"e yaz.

## 2a. KALİBRASYON: ekran tamamen kararıyorsa (0.4.2)

Gözlem: Agresif (kontrast 2.2, ofset -0.30) Zeus'ta ekranı **tamamen karartıyor**. Bu iki şeyi söyler: (1) post-process termal görüntünün
üstüne **çiziliyor** (varsayım A4 doğrulandı), (2) ColorCorrections kontrast / ofset matematiği benim varsaydığım gibi **değil**.
Bu yüzden hesap yerine ölçüyoruz. **Önce** Hazır ayar = **Nötr** (0.4.3'te varsayılan: ton vanilla ile aynı, karartmaz) ya da Yumuşak yap; kontrast > 1 olan ayarlar (Dengeli, Agresif, Siyah) bu ortamda ekranı karartıyor; ekran kararıyorsa Shift+Ctrl+T ile efekti kapat.

Termal görüntüye (Zeus + Shift+Ctrl+T açık değilken, vanilla termal) çimen ve bir tank/asker görünecek şekilde bak, debug konsolunda sırayla:

```sqf
["offset"] call RTI_fnc_ppLadder;     // siyah seviyesi 0 -> -0.8  (8 adım x 5 sn)
["contrast"] call RTI_fnc_ppLadder;   // kontrast 1 -> 4
["gain"] call RTI_fnc_ppLadder;       // parlaklık çarpanı 1 -> 4
["blur"] call RTI_fnc_ppLadder;       // bulanıklık 0 -> 3
["grain"] call RTI_fnc_ppLadder;      // gürültü 0 -> 0.8
```

Her adımda sohbete `KALIBRASYON <mod>: adim n/N -> deger x` yazılır. **Her mod için bana şunu yaz:**
(a) çimenin kaybolmaya başladığı adım/değer, (b) tankın/askerin bozulmaya (griye/siyaha) başladığı adım/değer, (c) ekranın tamamen karardığı adım/değer.
Bu üç sayıdan hazır ayar değerlerini ölçüye göre yeniden yazarım. Mod seçeneğini değiştirmeden herhangi bir mod tek başına yeterli ilk veridir:
en bilgilendirici olan **offset** ve **contrast**.

## 2b2. Efektler hiç değişmiyorsa (sırayla kontrol et)

1. **Hangi sürüm yüklü?** `call RTI_fnc_diag;` ilk satır `surum (yuklu PBO, CfgPatches)=...` söyler. Komut yoksa / hata veriyorsa
   yüklü PBO **eski**: Mikero ile yeniden paketle, eski `rti_main.pbo`'yu sil/üzerine yaz, oyunu tamamen kapatıp aç.
2. **Zeus kullanıyorsan RTI KAPALIDIR.** Zeus'ta "N" ile açılan termal oyuncu biriminin görüş modunu değiştirmez; RTI görüş modunu
   izlediği için efektler **hiç devreye girmez ve gördüğün görüntü vanilladır**. Zeus'ta termali "N" ile aç, sonra
   **Shift + Ctrl + T** (CBA tuş ataması, "RTI - Gerçekçi Termal" altında değiştirilebilir) ile RTI efektlerini aç / kapat.
   Tuş Zeus ekranında çalışmazsa konsol: `[true] call RTI_fnc_sensorForce;` / `[false] ...`. Gerçek oynanışta (asker, optik, araç
   nişangahı) bunlar gerekmez; efektler termale girince kendiliğinden açılır.
   **Efekt çalışıyor mu?** `call RTI_fnc_diag` raporundaki `sensor durumu` satırına bak: `efekt calisiyor=true` ve `tutamac` değerleri `>= 0` olmalı.
3. **Post-process termalde çiziliyor mu?** Termal görüntüye bakarken `call RTI_fnc_ppTest;`. Ekran 3.5 sn **kırmızı**, sonra 3.5 sn **mavi**
   boyanmalı. Yorum tablosu fonksiyonun başlığında; **kırmızı mı / mavi mi / hiçbiri mi** olduğunu bana yaz.
4. **Video ayarı:** Ayarlar → Video → **Post Process Quality** "Disabled" olmasın. Kapalıysa script post-process efektleri çizilmez.
   (RPT'de `[RTI][SENSOR] PP efekti olusturulamadi` satırı bunun işaretidir; ekranda da uyarı çıkar.)
5. **CBA ayarı:** Addon Options → RTI → Sensör → "Sensör efektleri aktif" açık, "Hazır ayar" Agresif ya da Siyah olmalı.
6. RPT'de (`%LOCALAPPDATA%\Arma 3\*.rpt`) `[RTI]` ya da `Error` satırı varsa gönder.

## 2c. Hazır ayarlar, siyah-beyaz farkı, ortam modeli ve Zeus

**Zeus kamerasında test ediyorsan:** "N" ile açılan termal oyuncu birimini etkilemez; RTI otomatik devreye girmez.
Termal görüntüdeyken debug konsolunda:

```sqf
[true] call RTI_fnc_sensorForce;     // B: RTI efektleri açık
[false] call RTI_fnc_sensorForce;    // A: vanilla
```

1. **Hazır ayar karşılaştırması:** Addon Options → Sensör → "Hazır ayar" = Agresif / Dengeli / Yumuşak. Agresif'te:
   zemin ve çimen yamaları **siyaha yakın**, sıcak cisimler beyaz, görüntü belirgin yumuşak olmalı. Uzaktaki asker zeminden
   ayrışıyor mu? **Çimen hâlâ görünüyorsa** Hazır ayar = **Siyah (çimeni sil)** dene (kontrast 2.6, siyah seviyesi -0.45):
   çimen siyaha gömülür ama insan giysisi de koyulaşır, yalnızca yüz/el parlak kalır; hangi uzlaşma sana uyuyor bana yaz.
   Çimen yine görünüyorsa önce **Zeus'ta `[true] call RTI_fnc_sensorForce;`** açık mı kontrol et (açık değilse görüntü
   vanilladır), sonra "Ortam etkisi şiddeti"ni 0 yap (gündüz/sıcakta ortam modeli kontrastı düşürür).
   **Siyah-beyaz farkı hâlâ az ise**: Hazır ayar = Elle, kontrast 2.2-2.8, siyah seviyesi -0.3...-0.4 dene
   ve değerleri bana yaz.
2. **Ortam modeli:** "Hava sıcaklığını elle ver" aç; 35 °C ile -5 °C arasında değiştir. Sıcakta kontrast belirgin
   düşmeli (nesneler zeminle eşitlenir), soğukta artmalı. `call RTI_fnc_diag` satırında `ortam [...]` değerlerini gör.
   Kontrast beklediğinden düşük kalıyorsa "Ortam etkisi şiddeti"ni 0'a çek (ortam etkisini kapatır).
3. **Zemin tabanı / toprak:** Toprak artık simsiyah olmamalı (koyu gri), çimen yamaları toprakla aynı koyu griye oturup kaybolmalı,
   **yukarı baktığında gökyüzü siyah** olmalı. Hazır ayar = Elle ile "Zemin tabanı" sürgüsünü 0 (saf siyah) ↔ 0.3 oynat. Yüzeye göre
   taban açıkken bir asfalt yola, sonra kuma/toprağa bak (gece): taban asfaltta belirgin yüksek, kumda düşük olmalı. `call RTI_fnc_diag`
   satırı `yuzey [zeminK, gokK, grup, sinif]` bakılan yüzeyi gösterir; **grup yanlışsa (ör. toprak yerine bilinmeyen) o satırı ve
   RPT'deki `[RTI][SURF]` satırlarını gönder**, eşlemeyi düzeltelim.
4. **Çimen:** Agresif'te çimen yamaları yeterince sönüyor mu? Sönmüyorsa `call RTI_fnc_exportClutter` çıktısını gönder;
   gerekirse "Termalde çimeni kapat"ı dene (uyarı: ekran kısa süre takılabilir).

## 2d. Karakter / silah ısısı kimden geliyor? (ayrıştırma testi)

Bu modun kodu piyade vücut ısısına **ve** piyade silahı ısısına dokunmaz (yalnızca araçlara `setVehicleTIPars`
uygular). Termalde görülen asker ve silah ısısı oyunun / sahip modun model dokusundan gelir (BI wiki: TI dokusunun alfa
kanalı insanlarda metabolizma ısısı, silah/tank namlusunda namlu ısısıdır).

1. **Sahibi bul:** silah elindeyken, bir askere bakarken `call RTI_fnc_diagOwner;` — raporda silah ve birim için
   `tanimlayan mod` ve `model` yolu çıkar (`\A3\` vanilla, `\rhsusf\...` RHS, `\CUP\...` CUP). **Raporu (Ctrl+V) bana yapıştır.**
2. **Silah ısınması hangi mekanizmadan?** Aynı sahnede, aynı atış sayısıyla sırayla dene ve her seferinde termalde
   silahın ısınıp ısınmadığına bak:
   - vanilla bir silah (ör. MX), **ACE overheating kapalı** (ACE ayarları → Overheating → kapat);
   - aynı silah, **ACE overheating açık**;
   - bir **CUP** silahı ve bir **RHS** silahı (ACE overheating kapalıyken).
   Hangi kombinasyonda ısınıyorsa kaynak odur: vanilla motor / ACE / silah modeli. RTI'yi test için tamamen çıkarmak
   en temiz yoldur; çıkarmadan da olur (RTI piyade silahına dokunmuyor), ama o durumda "Namlu flaşı → Kendi silahım"
   kapalı olsun ki ekran parlaması karışmasın.
3. **Ayrım ipucu:** ısınma ateşle birlikte kademeli artıp dakikalarca sönüyorsa bir ısıl simülasyondur (motor ya da
   ACE); ateşin hemen ardından tüm ekranın ~0.15 sn parlaması ise bizim ekran flaşımızdır.

## 3. Kendi silahım için flaş

Termal optikle birkaç tek atış, sonra otomatik atış.

- Her atışta görüntü kısa süre **parlamalı** ve ~0.15 sn'de normale dönmeli.
- Palet **siyah sıcak** ise Addon Options → "Termal palet kutbu" = Siyah sıcak yap; flaş koyu yöne gitmeli.
- **Otomatik kutup (deneysel):** "Termal palet kutbu" = Otomatik yap, optikte paleti değiştir (`N`); flaşın yönü
  palete uyumlu değişmeli. Uymuyorsa `call RTI_fnc_diag` çıktısındaki `gorus [mod, flirIndeksi]` değerini her palet için
  not edip bana gönder (hangi indeks hangi palet), eşlemeyi düzeltelim.
- Susturuculu silahta flaş belirgin şekilde zayıf olmalı.

## 4. Sıcak parçacık görünürlüğü (kritik test)

Termal optikten bakarken debug konsolunda:

```sqf
call RTI_fnc_testHeatSpot;
```

25 m önünde 10 sn'lik küçük bir parçacık çıkar. **Termalde parlak mı görünüyor?**

- Evet → "Başkalarının namlu ateşi" yöntemi çalışır; ışık kaynakları (lamba/far/fişek) bunun üstüne eklenecek.
- Hayır (görünmüyor ya da soluk) → o yöntemden vazgeçeriz; bana söyle, farklı yöntem deneriz.

## 5. Araç ısı modeli

Bir tank / zırhlı / kamyon yerleştir, içine bin (ya da bakılan araç olsun). Debug konsolu:

```sqf
[] call RTI_fnc_diagTrace;
```

120 sn boyunca saniyede bir `[RTI][TRACE]` satırı RPT'ye yazılır. Bu sürede sırayla: **motoru aç → bekle (10 sn) →
sür (20 sn) → dur → ateş et (varsa silah) → motoru kapat**. Satırlardaki `TIPars=[a,b,c]` değerleri ve
`RTI_eng/whl/wpn` durumlarını izle.

- Motor açılınca hangi indeks (0/1/2) artıyor? Sürerken? Ateş edince? **Trace satırlarını bana gönder.**
  `TIPars` satırı `[aliveFactor, movementFactor, metabolismFactor]` sırasıdır. BI wiki, `setVehicleTIPars` sırasını
  `[motor+gövde, tekerlek/palet, ana silah]` olarak veriyor; beklenen: motor açılınca 1., sürerken 2., ateş edince 3. değer
  artar. Farklı çıkarsa Addon Options → "TI parametre sırası"nı düzelt.
- Kritik gözlem: motor kapalıyken **bizim yazdığımız** değerler oyunun kendi değerleriyle çakışıyor mu (değerler ileri
  geri zıplıyor mu)? Zıplıyorsa oyun üzerine yazıyor demektir (varsayım A3b); bana bildir.
- Motoru kapatınca değerler yavaşça düşmeli (tank ~25 dk yarı-ömür; hızlı görmek için
  "Soğuma süresi çarpanı" = 0.1).
- Termalden araca bakarken motor bölgesinin zamanla söndüğü gözle görülmeli.

Komut yoksa (`yetenek | setVehicleTIPars=false`) bu bölüm atlanır.

## 5b. Araç sıcak noktaları (motor / egzoz / namlu lekesi)

**Önce normal görüşte noktalar doğru yerde mi:** bir tank veya zırhlıya 10-30 m yaklaş, imleçle araca bak:

```sqf
[true] call RTI_fnc_spotDebug;
```

Araç üstünde turuncu (motor/egzoz) ve kırmızı (namlu) işaretçiler ve "motor", "egzoz", "namlu ucu", "kama" etiketleri
çıkmalı. Taret döndüğünde namlu işaretçileri onu izlemeli.
- Motor işaretçisi gövdenin **içinde** ya da **havada** ise Addon Options → Araç sıcak noktaları → "Motor lekesi yükseltme"yi ayarla.
- Hiç işaretçi yoksa RPT'de `[RTI][SPOT] <sınıf>: 0 nokta` satırı var mı bak (HitEngine seçimi boş olabilir). **O satırları gönder.**
- Kapatmak: `[false] call RTI_fnc_spotDebug;`

**Sonra termalde:** motoru aç, birkaç saniye bekle, termal optikten araca bak.
- Motor/egzoz üzerinde kenarı yumuşak bir parlak leke görünmeli; motoru kapatınca yavaşça sönmeli
  (hızlı görmek için "Soğuma süresi çarpanı" = 0.1).
- Tank topuyla ateş edince namlu ucunda leke belirmeli, birkaç dakikada sönmeli.
- Normal görüşe dönünce lekeler **görünmemeli** (termalden çıkınca silinir).
- Leke hiç görünmüyorsa §4 testi (`testHeatSpot`) de görünmüyordur: parçacıklar TI'de çizilmiyor demektir; bana söyle.

**Gönder:** ekran görüntüsü (termalde), kullandığın araç sınıfı, `[RTI][SPOT]` RPT satırı.

## 5b2. İnsan vücut ısısı çarpanı testi (karar verici, 1 dakika)

Sorulan: `setVehicleTIPars` bir **askerde** de ısıyı sürüyor mu? (BI wiki yalnızca "piyade silahlarında çalışmaz" diyor.)
Bir düşman/YZ askerine ya da kendine ~30-50 m mesafeden **termal optikten** bakarken debug konsolunda (Local Exec):

```sqf
getVehicleTIPars cursorObject;                  // imleç askerdeyken; sonuç satırına bak
cursorObject setVehicleTIPars [1, 0, 0.3];      // askerin termal parlaklığı değişti mi?
cursorObject setVehicleTIPars [1, 1, 1];        // geri al / tam sıcak
cursorObject setVehicleTIPars [0, 0, 0];        // tamamen soğuk
```

**Gönder:** `getVehicleTIPars` sonucu ve hangi komutun askerin görüntüsünü değiştirdiği (hiçbiri / hepsi / yalnızca 3. değer).
Değiştiriyorsa vücut ısısı modülü (taban parlaklık çarpanı, koşma/yatma/yaralanma/hava ile dinamik metabolizma) yazılır.
Değiştirmiyorsa insan tarafında yalnızca doku yolu kalır.

## 5c. Üniforma modeli sayımı (anatomik ısı için ölçüm)

RHS ve CUP yüklüyken debug konsolunda:

```sqf
call RTI_fnc_exportUniforms;
```

Sohbette "Uniforma raporu panoya kopyalandi" çıkar; **panodakini (Ctrl+V) bana yapıştır**. İlk satır özettir:
kaç üniforma, kaç **farklı karakter modeli** (RHS / CUP / diğer ayrı). Anatomik ısı işinin boyutunu bu sayı belirler.
Tam liste RPT'de `[RTI][UNI]` satırlarıdır.

## 6. Genel sağlık

- RPT'de `[RTI]` ile başlayan **hata** satırı (`Error in expression`, `Undefined variable`) olmamalı. Varsa gönder.
- Termal kapalıyken FPS etkisi sıfıra yakın olmalı (araç döngüleri 3 sn'de bir hafif çalışır).

## 7. Dedicated sunucu + 2 istemci (başkalarının flaşı)

1. Yerel dedicated aç, iki istemci bağlan (A, B). Mod her üçünde yüklü.
2. B termal optikten A'ya bakar; A (≥100 m) ateş eder. Beklenen: B'de A'nın namlu ucunda kısa parlama.
3. Ayarlar sunucu tarafında "Namlu flaşı → Başkalarının flaşı" ile kapatılabilmeli.
4. Hiçbir oyuncu termalde değilken ağda `RTI_flash` olayı **gitmemeli** (ayrıntılı günlük açıkken `[RTI][FLASH]` satırı çıkmamalı).
5. YZ atışı: sunucuda YZ'ye ateş ettir; B'de aynı parlama.
