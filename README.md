# RTI – Gerçekçi Termal (Arma 3, CBA_A3)

Arma 3'ün termal görüntüsünü (vanilla, **RHS**, **CUP** ve termal modu olan her optik) daha gerçekçi hale
getirmeyi hedefleyen tek PBO'luk mod (`@RTI`, `rti_main.pbo`). Yalnızca **CBA_A3** gerektirir; RHS/CUP'a
bağımlılık yoktur: termal optikler çalışma anında config'ten taranır, sınıf adı listesi koda gömülü değildir.

> **Durum: v0.2, oyunda henüz test edilmedi.** Kod HEMTT ile derlendi (config rapify + 41 SQF dosyası + PBO) ve
> statik olarak denetlendi; ama Arma 3 çalıştırılamadı. Neyin güvenilir, neyin deneysel olduğu aşağıda açık.
> Test adımları: [`docs/TEST_ASAMA1.md`](docs/TEST_ASAMA1.md). Motorun sınırları: [`docs/FIZIBILITE.md`](docs/FIZIBILITE.md).

## İstenenler ve gerçek durum

| İstek | Durum | Nasıl / sınır |
|-------|-------|---------------|
| "Uzaylı" görüntü kalksın | **Kısmen** | Ekran işleme: kontrast/parlaklık (beyaza patlamayı kırar), sensör gürültüsü, yumuşatma. Ayarlanabilir. **İnsanın anatomik ısısı** (yüz/el sıcak, üniforma serin) ve **motordan uzaklaştıkça mekânsal sönümleme** ise modelin termal dokusuna (TI haritası) bağlıdır; script/config ile yapılamaz → bkz. FIZIBILITE.md |
| Motor / araç ısısı zamanla değişsin | **Deneysel** | Motor, tekerlek-palet ve namlu için ısınma/soğuma modeli (`setVehicleTIPars`). Komut yoksa kendini kapatır. Dizideki sıranın (motor/tekerlek/silah) doğrulanması gerek |
| Motordan / egzozdan / namludan uzaklaştıkça sönen ısı (mekânsal) | **Deneysel (hile)** | Model dokusuna dokunmadan: sınıf config'inden motor (`HitEngine`), egzoz (`Exhausts`) ve namlu (`gunBeg`/`gunEnd`) noktaları **otomatik** bulunur; oraya ısıya göre parlaklığı değişen, kenarı yumuşak bir ısı lekesi (parçacık) bırakılır. Uzaklaştıkça sönmesi sprite'ın radyal gradyanından gelir. RHS/CUP sınıf tablosu gerekmez. Gerçek "boyama" değildir (bkz. FIZIBILITE.md §2b) |
| Namlu ateşi (muzzle flash) termalde parlasın | **Kendi silahım: güvenilir. Başkaları: deneysel** | Kendi atışım: ekran flaşı (PP), dünya nesnesine bağlı değil. Başkalarının atışı: namlu ucunda kısa ömürlü sıcak parçacık; parçacığın TI'de parlak çizilip çizilmediği **doğrulanmadı** (`call RTI_fnc_testHeatSpot`) |
| Her türlü ışık kaynağı (lamba, far, fişek) | **Yapılmadı (v0.2)** | Parçacık yönteminin TI'de çalıştığı doğrulanınca aynı altyapıya eklenecek |
| RHS / CUP scope'ları | **Hazır** | Çalışma anında taranır, sonuç RPT'de (`[RTI][SCOPE]`) |

## Kurulum

Başlatma parametresi: `-mod=@CBA_A3;@RTI`

**HEMTT** (önerilen, bu depoda yapılandırılı):

```bash
hemtt build        # .hemttout/build/ içine @RTI yapısı çıkar
hemtt check        # yalnızca denetim
```

**Mikero:** depo kökünü `P:\z\rti` olarak konumlandır (`$PBOPREFIX$` = `z\rti\addons\main`), `addons\main`'i paketle,
`mod.cpp`'yi `@RTI` köküne kopyala.

## Yapı

```
mod.cpp
.hemtt/project.toml                      HEMTT (prefix z\rti)
addons/main/                             -> rti_main.pbo
    config.cpp                           CfgPatches, CfgFunctions, CfgCloudlets, CBA XEH
    XEH_preInit.sqf / XEH_postInit.sqf
    core/       yetenek tespiti (komut var mı?), termal optik taraması, teşhis araçları
    sensor/     termal modda ekran işleme: ColorCorrections + FilmGrain + DynamicBlur
    flash/      namlu flaşı: kendi ekran flaşı + başkaları için sıcak parçacık (CBA hedef olayı)
    vehicle/    araç motor/tekerlek/namlu ısınma-soğuma modeli
    spot/       motor/egzoz/namlu üzerinde ısıya bağlı ısı lekesi (noktalar sınıftan otomatik çözülür)
```

Tasarım ilkeleri: termalde kimse yokken maliyet sıfır (oyuncular `RTI_tiActive` bayrağı yayınlar; atış olayları
yalnızca termaldeki oyunculara gider), sürekli döngü yok (araç durumu yalnızca hedef değişince yayınlanır),
belgelenemeyen komutlar doğrudan yazılmaz (`supportInfo` ile tespit edilip `compile` ile sarılır).

## Ayarlar (Seçenekler → Eklenti Ayarları → "RTI - Gerçekçi Termal")

| Kategori | Öne çıkanlar |
|----------|--------------|
| Sensör | aktif, parlaklık, kontrast, gürültü, yumuşatma, **palet kutbu** (beyaz/siyah sıcak), efekt uygulanmayacak optikler |
| Namlu flaşı | aktif, kendi ekran flaşı (+şiddet, sönme), başkalarının flaşı (deneysel), azami mesafe |
| Araç ısı modeli | aktif, soğuma çarpanı, namlu ısınma çarpanı, güncelleme mesafesi, **TI parametre sırası** |
| Araç sıcak noktaları | aktif, şiddet, aynı anda en fazla araç, **motor lekesi yükseltme** |
| Genel | ayrıntılı günlük (RPT) |

Termal paletin kutbu (beyaz/siyah sıcak) oyundan okunamıyor; kendi flaşının doğru yönde çizilmesi için ayarı
kullandığın paletle eşle (optikte `N`).

## Teşhis (debug konsolu, Local Exec)

```sqf
call RTI_fnc_diag;                      // komut desteği, optik modları, araç parametreleri -> pano + RPT
call RTI_fnc_testHeatSpot;              // termalde parçacık "sıcak nokta" görünüyor mu?
[] call RTI_fnc_diagTrace;              // bindiğin / baktığın aracın TI parametrelerini 120 sn boyunca RPT'ye yazar
[true] call RTI_fnc_spotDebug;          // normal görüşte: motor/egzoz/namlu noktalarını araç üstünde işaretle ([false] kapatır)
call RTI_fnc_exportUniforms;            // üniformaları karakter modeline göre gruplar: anatomik ısı için kaç model boyanacak?
```

## Bilinen sınırlar

- Render-target (PiP) mercekli optiklerde ana ekran normal görüntüdür; sensör efekti onu bozar. Böyle bir optik
  varsa sınıf adını "Efekt uygulanmayacak optikler" listesine yaz.
- Araç ısı modeli yalnızca araçlara uygulanır; yaya silahlarının namlu ısısı için TI parametresi yok.
- Sıcak noktalar yaklaşık bir görünümdür: kameraya dönük sprite'lardır (yan açıdan "asılı leke" gibi durabilir),
  gövde geometrisiyle kırpılır ve normal görüşte oluşturulmaz. Gerçek dağılım model dokusudur.
- İnsan anatomisi (yüz/el sıcak, üniforma serin) bu yöntemle yapılamaz: parçacık ekleyebilir ama üniformanın
  taban ısısını düşüremez. Model dokusu gerekir (FIZIBILITE.md §3).

## Yol haritası

| # | Özellik | Durum |
|---|---------|-------|
| 1 | Sensör ekran işleme | ✅ hazır (test bekliyor) |
| 2 | Kendi silahım için ekran flaşı | ✅ hazır (test bekliyor) |
| 3 | Başkalarının namlu ateşi (sıcak parçacık) | 🧪 deneysel (TI'de görünürlük doğrulanacak) |
| 4 | Araç ısınma/soğuma modeli | 🧪 deneysel (`setVehicleTIPars` doğrulanacak) |
| 5 | Araç sıcak noktaları (motor/egzoz/namlu lekesi) | 🧪 deneysel (parçacık TI + `selectionPosition` doğrulanacak) |
| 6 | Işık kaynakları: lamba, far, fişek | ⏳ #3 doğrulanınca |
| 7 | Kendi proxy modelimiz + kendi TI dokumuz (gerçek radyal gradyan, RHS/CUP dosyası gerekmez) | ⏳ TI doku formatı belgesi gerekir |
| 8 | Üniforma TI haritaları (anatomik ısı) | ⏳ model verisi gerektirir, bkz. FIZIBILITE.md |
