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
| "Uzaylı" görüntü kalksın | **Büyük ölçüde (script ile)** | Gözlemlenen neden: zemin orta gri, çimen yamaları siyah-gri leke, asker gövdesi zemine yakın gri (uzaktan seçilmiyor), araç tek tip beyaz. Çözüm: **Agresif** ton ayarı (kontrast ↑, **siyah seviyesi ↓**: zemin ve çimen siyaha, sıcak hedefler beyaza), bulanıklık (ince çimen desenini yutar), ortam modeli, araç gövde ısısı modeli (tek tip beyaz yerine motor lekeli orta gri). **Asker yüz/boyun/giysi dağılımı zaten iyi** (oyunun kendi dokusu): üniforma yeniden boyamaya gerek görünmüyor |
| Çimenlerdeki termal kalksın | **Kısmen** | Çimen bir nesne değil, araziye çizilen "clutter"; sınıf adına bağlı ayrı termal ayarı yok. Agresif ton + bulanıklık yamaları büyük ölçüde siler. Gerçek kaldırma: arazi ızgarası (Video "Arazi ayrıntısı" ya da "Termalde çimeni kapat"; normal görüşte de çimeni siler, geçişte takılabilir). Kaynak araştırması: `call RTI_fnc_exportClutter` |
| Toprak simsiyah olmasın, yüzey sınıfına (CfgSurfaces) göre | **Kısmen (hile)** | CfgSurfaces'te termal özellik yok, zemini oyun kendisi çiziyor; yüzeyi boyayamam. Bunun yerine çimen ve toprak kontrastla siyaha gömüldükten SONRA ayrı bir katmanla **zemin tabanı** kaldırılır (ikisi eşit koyu griye oturur: çimen kaybolur, toprak simsiyah olmaz). Taban, kameranın BAKTIĞI yüzeyin sınıfına (asfalt, kaya, kum, kar, su, toprak, çimen) ve gün saatine göre ölçeklenir (asfalt ısıyı tutar, kum geceleri soğur...), yukarı bakınca sıfırlanır (gökyüzü siyah kalır). Sahneye uyan bir sensör (AGC) gibi davranır |
| Hava sıcaklığı / mevsime göre kontrast | **Deneysel** | Ortam modeli: sıcaklık (ACE Weather varsa onun değeri, yoksa tarih/enlem/saatten tahmin), güneş yüklemesi, bulutluluk, sis, yağmur → kontrast / bulanıklık / gürültü çarpanı; güneşte duran araç gövdesi zemine eşitlenir. Nesne bazında kontrast yalnızca **araçlarda** mümkün (`setVehicleTIPars`); bina, kaya gibi statik nesneleri oyun kendisi çiziyor |
| Motordan / egzozdan / namludan uzaklaştıkça sönen ısı (mekânsal) | **Deneysel (hile)** | Model dokusuna dokunmadan: sınıf config'inden motor (`HitEngine`), egzoz (`Exhausts`) ve namlu (`gunBeg`/`gunEnd`) noktaları **otomatik** bulunur; oraya ısıya göre parlaklığı değişen, kenarı yumuşak bir ısı lekesi (parçacık) bırakılır. Uzaklaştıkça sönmesi sprite'ın radyal gradyanından gelir. RHS/CUP sınıf tablosu gerekmez. Gerçek "boyama" değildir (bkz. FIZIBILITE.md §2b) |
| Namlu ateşi (muzzle flash) termalde parlasın | **Kendi silahım: güvenilir. Başkaları: deneysel** | Kendi atışım: ekran flaşı (PP), dünya nesnesine bağlı değil. Başkalarının atışı: namlu ucunda kısa ömürlü sıcak parçacık; parçacığın TI'de parlak çizilip çizilmediği **doğrulanmadı** (`call RTI_fnc_testHeatSpot`) |
| Her türlü ışık kaynağı (lamba, far, fişek) | **Yapılmadı (v0.2)** | Parçacık yönteminin TI'de çalıştığı doğrulanınca aynı altyapıya eklenecek |
| RHS / CUP scope'ları | **Hazır** | Çalışma anında taranır, sonuç RPT'de (`[RTI][SCOPE]`) |

## Mikero ile derleme

Başlatma parametresi: `-mod=@CBA_A3;@RTI`

1. Mikero araçlarını (**pboProject**, MakePbo, DePbo) ve P: sürücüsünü kur.
2. Depoyu `P:\z\rti` yoluna getir. Ya doğrudan oraya klonla ya da yönetici komut isteminde:
   ```bat
   mklink /J "P:\z\rti" "C:\yol\a3-termal"
   ```
   (`P:\z` klasörü önceden var olmalı.) Sonuçta `P:\z\rti\addons\main\config.cpp` bulunmalı.
3. pboProject'te kaynak klasör: `P:\z\rti\addons\main`, çıktı klasörü: `...\@RTI\addons`.
   Prefix, klasördeki `$PBOPREFIX$` dosyasından okunur (`z\rti\addons\main`).
4. `mod.cpp` dosyasını `...\@RTI\` köküne kopyala.
5. pboProject `requiredAddons` (`cba_main`) bulunamadı diye uyarı verirse CBA PBO'larını DePbo ile P: sürücüsüne aç
   ya da bu denetimi pboProject ayarlarından gevşet (TAC ile aynı durum).
6. Config'teki `\A3\data_f\...` parçacık yolları için "dosya bulunamadı" uyarısı gelirse A3 verisini P: sürücüsüne aç
   ya da uyarıyı yok say (yollar oyunun kendi dosyalarıdır, çalışma zamanında bulunur).
7. Çıkan PBO adı klasör adına göre `main.pbo` olabilir. TAC ile aynı düzen için `rti_main.pbo` olarak yeniden adlandır
   (zorunlu değil; CfgPatches adı `rti_main`, `tac_main` ile çakışmaz).
8. Dedicated sunucuda imza doğrulaması açıksa: `DSCreateKey` ile anahtar üret, PBO'yu `.biprivatekey` ile imzala,
   `.bikey`'i sunucunun `keys/` klasörüne koy. **`.biprivatekey` dosyasını asla depoya koyma** (`.gitignore` engeller).

Sonuç: `@RTI\addons\rti_main.pbo` (+ varsa `.bisign`) ve `@RTI\mod.cpp`.

**Mikero'ya göre sağlamlaştırılanlar:** `config.cpp` ve bütün `.hpp` dosyaları ASCII; `$PBOPREFIX$` sonunda satır sonu yok
(TAC ile aynı); config'te `#define` makrosu yok (sıcak nokta sınıfları düz yazılı; üretici: `tools/gen_glow_cloudlets.py`);
her `CfgFunctions` sınıfının `fn_*.sqf` karşılığı var. `docs/`, `tools/`, `.hemtt/` kaynak klasörünün (`addons\main`) dışındadır,
PBO'ya girmez.

**HEMTT (isteğe bağlı, yalnızca denetim):** Mikero'yu değiştirmez. Komut sürümü ve SQF sözdizimi denetimi için:

```bash
hemtt check        # config rapify + SQF analizi
hemtt build        # .hemttout/build/ içine deneme PBO'su
```

## Yapı

```
mod.cpp
.hemtt/project.toml                      yalnızca HEMTT denetimi için (Mikero'yu etkilemez)
tools/gen_glow_cloudlets.py              spot/CfgCloudlets.hpp üreticisi (12 düz sınıf, makro yok)
docs/                                    FIZIBILITE, TEST_ASAMA1, AB_TEST
addons/main/                             -> rti_main.pbo
    $PBOPREFIX$                          Mikero bu dosyadan prefix'i okur (z\rti\addons\main)
    config.cpp                           CfgPatches, CfgFunctions, CfgCloudlets, CBA XEH
    XEH_preInit.sqf / XEH_postInit.sqf
    core/       yetenek tespiti (komut var mı?), termal optik taraması, teşhis araçları
    sensor/     termal modda ekran işleme: ColorCorrections + FilmGrain + DynamicBlur
    flash/      namlu flaşı: kendi ekran flaşı + başkaları için sıcak parçacık (CBA hedef olayı)
    vehicle/    araç motor/tekerlek/namlu ısınma-soğuma modeli
    spot/       motor/egzoz/namlu üzerinde ısıya bağlı ısı lekesi (noktalar sınıftan otomatik çözülür)
    env/        ortam modeli: hava sıcaklığı / mevsim / saat / sis / yağmur -> kontrast, bulanıklık, gürültü
```

Tasarım ilkeleri: termalde kimse yokken maliyet sıfır (oyuncular `RTI_tiActive` bayrağı yayınlar; atış olayları
yalnızca termaldeki oyunculara gider), sürekli döngü yok (araç durumu yalnızca hedef değişince yayınlanır),
belgelenemeyen komutlar doğrudan yazılmaz (`supportInfo` ile tespit edilip `compile` ile sarılır).

## Ayarlar (Seçenekler → Eklenti Ayarları → "RTI - Gerçekçi Termal")

| Kategori | Öne çıkanlar |
|----------|--------------|
| Sensör | aktif, **hazır ayar (Agresif / Siyah / Dengeli / Yumuşak / Elle)**, [elle] parlaklık / kontrast / **siyah seviyesi** / **zemin tabanı** / gürültü / bulanıklık, **yüzeye göre taban**, palet kutbu, hariç optikler, termalde çimeni kapat (deneysel) |
| Ortam (hava / mevsim) | aktif, etki şiddeti, elle hava sıcaklığı (test), yarıküre, araç güneş yüklemesi |
| Namlu flaşı | aktif, kendi ekran flaşı (+şiddet, sönme), başkalarının flaşı (deneysel), azami mesafe |
| Araç ısı modeli | aktif, soğuma çarpanı, namlu ısınma çarpanı, güncelleme mesafesi, **TI parametre sırası** |
| Araç sıcak noktaları | aktif, şiddet, aynı anda en fazla araç, **motor lekesi yükseltme** |
| Genel | ayrıntılı günlük (RPT) |

Flaşın yönü paletin kutbuna (beyaz/siyah sıcak) bağlı. Ayarı elle kullandığın paletle eşleyebilir ya da
"Otomatik"i seçebilirsin: oyun FLIR indeksini bildiriyor (`currentVisionMode [birim]`, 2.08+). İndeks → kutup eşlemesi
henüz teyit edilmedi, bu yüzden varsayılan elle seçimdir.

## Teşhis (debug konsolu, Local Exec)

```sqf
call RTI_fnc_diag;                      // komut desteği, optik modları, araç parametreleri -> pano + RPT
call RTI_fnc_testHeatSpot;              // termalde parçacık "sıcak nokta" görünüyor mu?
[] call RTI_fnc_diagTrace;              // bindiğin / baktığın aracın TI parametrelerini 120 sn boyunca RPT'ye yazar
[true] call RTI_fnc_spotDebug;          // normal görüşte: motor/egzoz/namlu noktalarını araç üstünde işaretle ([false] kapatır)
call RTI_fnc_exportUniforms;            // üniformaları karakter modeline göre gruplar (anatomik ısı artık öncelikli değil)
call RTI_fnc_exportClutter;             // çimen clutter sınıfları + yakın arazi nesneleri (çimen yamalarının kaynağı)
call RTI_fnc_diagOwner;                 // eldeki silah / baktığın birim hangi modda tanımlı? (termal özellik kimden: vanilla, RHS, CUP, ACE?)
[true] call RTI_fnc_sensorForce;        // görüş moduna bakmadan RTI efektlerini aç (Zeus kamerası / A-B testi); [false] kapatır
```

## Bilinen sınırlar

- **Zeus kamerası:** Zeus'ta "N" ile açılan termal oyuncu biriminin görüş modunu değiştirmez; RTI efektleri kendiliğinden devreye girmez. Zeus'ta test için `[true] call RTI_fnc_sensorForce;` kullan (görüntüleri A/B için bu yüzden aynı komutla karşılaştır).
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
| 7 | İnsan vücut ısısı çarpanı (taban parlaklık, koşma/yatma/yaralanma ile metabolizma) | ⏳ `setVehicleTIPars` askerde çalışıyor mu testi gerekir (TEST §5b2) |
| 8 | Kendi proxy modelimiz + kendi TI dokumuz (gerçek radyal gradyan, RHS/CUP dosyası gerekmez) | ⏳ kanal anlamları belli ✅; MLOD p3d + rvmat + PAA üretimi kalan iş |
| 9 | Üniforma TI haritaları (anatomik bölge dağılımı, alfa kanalı) | ⏸ gerek görünmüyor: asker yüz/giysi dokusu zaten iyi (oyun içi gözlem) |
| 10 | Ortam modeli (sıcaklık / mevsim / saat / hava -> kontrast), Agresif ton, siyah seviyesi, **zemin tabanı (yüzey sınıfına göre)** | 🧪 deneysel (0.4.0, test bekliyor) |
