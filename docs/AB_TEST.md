# A/B görsel testi: referanslara karşı karşılaştırma

Amaç: modun termal görüntüsünü (B) vanilla termalle (A) ve gerçek termal referanslarla karşılaştırıp neyin
yaklaştığını, neyin yaklaşamayacağını **ölçütlerle** görmek. "Daha iyi hissettiriyor" yerine puan.

## 1. Referans görseller

Telifli üçüncü taraf görseller oldukları için depoya **konmaz** (`.gitignore`). Yerelde `docs/referans/` altında tutulur;
adlandırma: `ref<NN>_<konu>_<detay>_<palet>.png` (hepsi **beyaz sıcak**).

| Dosya | Ne | Neye bakılır |
|-------|----|--------------|
| `ref01_fil_whot.png` | Fil, gerçek termal | Vücutta ince doku (deri kıvrımları) var, tek tip beyaz değil. Kulak (ince, damarlı) koyu, damarlar parlak çizgi. Arka plan bitki örtüsü orta gri ve dokulu. |
| `ref02_insan_arac_18mm_whot.png` | Üç kişi + binek araç, 18 mm | **İnsanlar patlamıyor:** baş ve eller en parlak, mont orta-açık gri, bacaklar daha koyu. Araçta tekerlekler/alt kısım parlak, motor kaputu açık gri, **camlar koyu**. Duvar/bina kenarları orta gri. |
| `ref03_geyik_orman_nocpix_whot.png` | Orman geyiği, Nocpix | Hayvan parlak ama **içinde desen var** (benekler), bacaklar gövdeden hafif sönük. Ağaç gövdeleri zeminden açık, zemin çok koyu ama dokulu. Kenar halesi çok az. |
| `ref04_geyik_tarla_atn_whot.png` | Tarla geyiği, ATN | **Gözler/kafa en parlak nokta.** Gövde açık gri, tüy dokusu görünür. Zemin (sürülmüş tarla) zengin orta gri doku. İnce tane gürültü. |
| `ref05_tank_abrams_wt_whot.png` | Abrams, **War Thunder** ekran görüntüsü (oyun render'ı) | **Yol tekerlekleri çok parlak**, gövde yanı orta gri, **motor bölgesi arka gövdede yumuşak radyal sönümlü parlak leke** + arka panelde parlak şerit, kule orta gri, namlu orta gri (kama tarafı biraz açık), gökyüzü saf siyah. |

Not: `ref05` bir oyun görüntüsü; "bir oyun motorunda ulaşılabilir hedef"tir, fiziksel doğruluk referansı değildir.
Fiziksel referans `ref01`-`ref04`'tür.

## 2. Ölçütler (ref'lerden çıkarıldı) ve modun ulaşabildiği yer

Puan: 0 = vanilla'dan farksız / yanlış, 1 = kısmen, 2 = referansa yakın.
**Yol:** S = script (sensör ekran işleme), V = araç ısı modeli / sıcak noktalar, F = flaş modülü, T = **doku (TI haritası) gerekir**,
H = insan çarpanı (§5b2 testi çalışırsa).

| # | Ölçüt | Referans | Yol |
|---|-------|----------|-----|
| K1 | Sıcak cisimler beyaza **patlamıyor** (parlak alanda doku seçilebiliyor) | ref01, 02, 04 | S |
| K2 | Arka plan (bitki, zemin, duvar) **orta tonlarda dokulu**, düz siyah değil | ref01, 03, 04 | S |
| K3 | Kenarlar yumuşak, **halo/parlama çemberi yok** | ref03 | S |
| K4 | İnce tane gürültü, görünür ama baskın değil | ref04 | S |
| K5 | İnsanda **baş/eller > gövde > bacak** (bölge dağılımı) | ref02 | T (+H taban seviye) |
| K6 | Göz / kafa gibi küçük sıcak noktalar | ref04 | T |
| K7 | İnsan gövdesi tek tip beyaz değil, giysi **orta ton** | ref02 | H, T |
| K8 | Araçta **tekerlek/palet parlak**, gövde orta ton | ref02, 05 | V (hareketteyken `wheels`), T |
| K9 | Motor bölgesinde **yumuşak radyal sönümlü** sıcak leke | ref05 | V (sıcak nokta, yaklaşık), T (gerçek) |
| K10 | Namlu orta ton; ateşten sonra ısınır, zamanla söner | ref05 | V |
| K11 | Cam / yansıtıcı yüzey koyu | ref02 | T |
| K12 | Atışta namlu parlaması | (gerçek termal davranışı) | F |

Beklenti yönetimi: **S** ölçütlerinin (K1-K4) ve **F**'nin (K12) B'de belirgin iyileşmesi beklenir. **T** işaretli ölçütler
(K5, K6, K11 ve K7/K9'un tam hâli) modelin dokusuna bağlıdır; B'de bunların *değişmemesi* modun hatası değil, bilinen sınırdır
(FIZIBILITE.md).

## 3. Çekim protokolü (A ve B aynı sahne)

Aynı Eden sahnesi, her varyantta **aynı kamera konumu, optik, yakınlaştırma ve palet (beyaz sıcak)**. Gece, açık hava, aynı hava/saat.

Sahneler (her biri ~100 m ve ~300 m):
1. `insan`: tek ayakta asker, düz üniforma (yelek/kask yok; ekipman kapsam dışı).
2. `arac_motor_acik`: tank, motor 2 dakikadır rölantide (ısınma için); bir de hareketten hemen sonra.
3. `arac_motor_kapali`: aynı tank, motor kapalı (başlangıç) ve motor kapatıldıktan 5 dk sonra ("Soğuma süresi çarpanı" ile hızlandırılabilir).
4. `tank_atis`: tank ateş ediyor (bir mermi), 1 sn sonra ve 30 sn sonra.
5. `orman`: bitki örtüsü/zemin dokusu için, hedefsiz geniş kadraj (K2 için).

Varyantlar:
- **A (vanilla):** RTI yüklü ama Addon Options'ta *Sensör efektleri*, *Namlu flaşı*, *Araç ısı modeli*, *Araç sıcak noktaları* **kapalı**
  (ya da mod hiç yüklü değil, daha temiz).
- **B (RTI):** hepsi açık, varsayılan ayarlar. İkinci tur **B2**: sürgüler elle ayarlı (kontrast/parlaklık/gürültü), değerleri not et.
- **Zeus kamerası ile çekiyorsan** RTI otomatik devreye girmez: B için **Shift + Ctrl + T** (ya da `[true] call RTI_fnc_sensorForce;`), A için tekrar Shift + Ctrl + T (ya da `[false] call RTI_fnc_sensorForce;`).
- **Tekrarlanabilirlik:** Ortam modeli hava/saatle değişir. A/B çiftlerinde saat ve hava aynı olsun; ya da "Hava sıcaklığını elle ver" ile sıcaklığı sabitle ve dosya adına yaz (ör. `..._t15C_...`).

HUD kapalı, aynı çözünürlük, ekran görüntüsünü oyunun kendi aracıyla al (Steam `F12` vb.).

## 4. Dosya adı

Referanslar: `ref<NN>_<konu>_<detay>_<palet>.png` (yukarıdaki tablo).

Çekimler (`docs/ab/`, yerelde, depoya konmaz):

```
ab_<sahne>_<mesafe>m_<varyant>_<surum>.png

ab_insan_100m_A_vanilla.png
ab_insan_100m_B_rti0.2.2.png
ab_arac_motor_acik_300m_B2_rti0.2.2_k0.80_p0.90_n0.15.png     (B2: elle ayarlı sürgüler dosya adına)
ab_tank_atis_300m_B_rti0.2.2_t+1s.png
```

Kurallar: küçük harf, ASCII (ç→c, ğ→g, ı→i, ö→o, ş→s, ü→u), boşluk yok, ayırıcı `_`, sürüm `rti<major.minor.patch>`.

## 5. Puan tablosu şablonu

| Sahne | Ölçüt | A (0-2) | B (0-2) | Not |
|-------|-------|---------|---------|-----|
| insan 100 m | K1 | | | |
| insan 100 m | K5 | | | |
| arac_motor_acik 300 m | K8 | | | |
| arac_motor_acik 300 m | K9 | | | |
| tank_atis 300 m | K10 | | | |
| tank_atis 300 m | K12 | | | |
| orman | K2 | | | |

Bana ekran görüntülerini (A/B çiftleri) ve gerekiyorsa doldurulmuş tabloyu gönder; ben referanslarla karşılaştırıp hangi sürgünün /
hangi parçanın düzeltilmesi gerektiğini söylerim.
