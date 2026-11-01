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

**Gönder:** hangi optikte test ettin, "daha az uzaylı" mı oldu (kontrast/parlaklık hangi değerde iyi göründü), ekran görüntüsü.

PiP (render-target) mercekli bir optikse: normal ana ekran bozuluyorsa optik sınıfını "Efekt uygulanmayacak optikler"e yaz.

## 3. Kendi silahım için flaş

Termal optikle birkaç tek atış, sonra otomatik atış.

- Her atışta görüntü kısa süre **parlamalı** ve ~0.15 sn'de normale dönmeli.
- Palet **siyah sıcak** ise Addon Options → "Termal palet kutbu" = Siyah sıcak yap; flaş koyu yöne gitmeli.
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
  Sıra `0,1,2` değilse Addon Options → "TI parametre sırası"nı düzelt (ör. `1,0,2`).
- Motoru kapatınca değerler yavaşça düşmeli (tank ~25 dk yarı-ömür; hızlı görmek için
  "Soğuma süresi çarpanı" = 0.1).
- Termalden araca bakarken motor bölgesinin zamanla söndüğü gözle görülmeli.

Komut yoksa (`yetenek | setVehicleTIPars=false`) bu bölüm atlanır.

## 6. Genel sağlık

- RPT'de `[RTI]` ile başlayan **hata** satırı (`Error in expression`, `Undefined variable`) olmamalı. Varsa gönder.
- Termal kapalıyken FPS etkisi sıfıra yakın olmalı (araç döngüleri 3 sn'de bir hafif çalışır).

## 7. Dedicated sunucu + 2 istemci (başkalarının flaşı)

1. Yerel dedicated aç, iki istemci bağlan (A, B). Mod her üçünde yüklü.
2. B termal optikten A'ya bakar; A (≥100 m) ateş eder. Beklenen: B'de A'nın namlu ucunda kısa parlama.
3. Ayarlar sunucu tarafında "Namlu flaşı → Başkalarının flaşı" ile kapatılabilmeli.
4. Hiçbir oyuncu termalde değilken ağda `RTI_flash` olayı **gitmemeli** (ayrıntılı günlük açıkken `[RTI][FLASH]` satırı çıkmamalı).
5. YZ atışı: sunucuda YZ'ye ateş ettir; B'de aynı parlama.
