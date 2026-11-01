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
