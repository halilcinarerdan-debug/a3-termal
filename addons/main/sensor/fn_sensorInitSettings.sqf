/*
    Fonksiyon: RTI_fnc_sensorInitSettings
    Çalışma yeri: TÜM makineler (XEH_preInit.sqf çağırır)

    Sensör (ekran işleme) ayarları. Hepsi kişisel tercihtir (isGlobal = false):
    görüntü tonu oyuncudan oyuncuya değişebilir. Değerler değişince efekt anında güncellenir.

    "Hazır ayar" Elle dışında bir değerdeyse sürgüler yok sayılır (RTI_fnc_sensorParams).

    Parametreler: yok
    Dönüş: yok
*/

private _category = ["RTI - Gerçekçi Termal", "Sensör (ekran işleme)"];
private _refresh = {call RTI_fnc_sensorRefresh};

[
    "RTI_sensor_enabled",
    "CHECKBOX",
    ["Sensör efektleri aktif", "Termal moddayken kontrast/siyah seviyesi/gürültü/bulanıklık uygular. Kapalıysa görüntü vanilla kalır."],
    _category,
    true,
    false,
    {
        // Sunucuda / HC'de oyuncu yok; ayar başlangıçta da bu işlevi çağırır.
        if (hasInterface && {!isNull player}) then {
            if (_this) then {
                [player, currentVisionMode player] call RTI_fnc_sensorOnVisionMode;
            } else {
                call RTI_fnc_sensorStop;
            };
        };
    }
] call CBA_settings_fnc_init;

[
    "RTI_sensor_preset",
    "LIST",
    ["Hazır ayar", "Agresif: sert siyah-beyaz, zemin siyaha yakın, çimen koyu gri, belirgin bulanıklık. Siyah: çimeni ve zayıf ısıları siyaha gömer (sert eşik); insan giysisi de koyulaşır, yalnızca yüz/el gibi sıcak yerler parlak kalır. Dengeli: ılımlı. Yumuşak: vanilla'ya yakın. Elle: aşağıdaki sürgüler kullanılır."],
    _category,
    [[0, 1, 2, 3, 4], ["Elle (aşağıdaki sürgüler)", "Agresif (sert siyah-beyaz, bulanık)", "Dengeli", "Yumuşak", "Siyah (çimeni sil, sert eşik)"], 1],
    false,
    _refresh
] call CBA_settings_fnc_init;

[
    "RTI_sensor_brightness",
    "SLIDER",
    ["[Elle] Parlaklık", "1 = değişiklik yok. Yalnızca Hazır ayar = Elle iken kullanılır."],
    _category,
    [0.5, 1.5, 1.0, 2],
    false,
    _refresh
] call CBA_settings_fnc_init;

[
    "RTI_sensor_contrast",
    "SLIDER",
    ["[Elle] Kontrast", "1 = değişiklik yok. Yüksek kontrast siyah-beyaz ayrımını sertleştirir; siyah seviyesiyle birlikte kullan. Yalnızca Elle iken."],
    _category,
    [0.5, 3, 1.7, 2],
    false,
    _refresh
] call CBA_settings_fnc_init;

[
    "RTI_sensor_blackLevel",
    "SLIDER",
    ["[Elle] Siyah seviyesi (ofset)", "Negatif değer görüntüyü karartır: orta gri zemin ve çimen yamaları siyaha yaklaşır, parlak hedefler beyazda kalır. Uzaktaki askerin zeminden ayrışması için en etkili sürgü. Yalnızca Elle iken."],
    _category,
    [-0.6, 0.3, -0.12, 2],
    false,
    _refresh
] call CBA_settings_fnc_init;

[
    "RTI_sensor_noise",
    "SLIDER",
    ["[Elle] Sensör gürültüsü (NETD)", "Gerçek mikrobolometre sensörlerin ince tanecik gürültüsü. 0 = yok. Yalnızca Elle iken."],
    _category,
    [0, 1, 0.12, 2],
    false,
    _refresh
] call CBA_settings_fnc_init;

[
    "RTI_sensor_blur",
    "SLIDER",
    ["[Elle] Bulanıklık (MTF)", "Optik/sensör çözünürlük kaybı: keskin kenarları ve ince çimen desenini yumuşatır. 0 = yok. Çok yükseltirsen uzaktaki hedefler de silinir. Yalnızca Elle iken."],
    _category,
    [0, 3, 0.6, 2],
    false,
    _refresh
] call CBA_settings_fnc_init;

[
    "RTI_sensor_floor",
    "SLIDER",
    ["[Elle] Zemin tabanı", "Kontrast siyaha gömdükten sonra siyahı bu kadar kaldırır: çimen ve toprak eşit koyu griye oturur (çimen görünmez, toprak simsiyah olmaz). 0 = saf siyah. Gökyüzü (yukarı bakış) siyah kalır. Yalnızca Elle iken."],
    _category,
    [0, 0.3, 0.10, 2],
    false,
    _refresh
] call CBA_settings_fnc_init;

[
    "RTI_sensor_surface",
    "CHECKBOX",
    ["Zemin tabanı yüzeye göre değişsin (deneysel)", "Kameranın baktığı yüzeyin sınıfına (CfgSurfaces: asfalt, kaya, kum, kar, su, toprak, çimen) ve gün saatine göre taban ayarlanır: asfalt ve kaya ısıyı tutar, kum geceleri soğur, kar soğuktur. Yüzeyi boyamaz; ekranın tabanını sahneye uydurur (AGC gibi). Termal açıkken 1.5 sn'de bir bakılan yüzeye bakar."],
    _category,
    true,
    false,
    _refresh
] call CBA_settings_fnc_init;

// Flaşın hangi yönde (parlak/koyu) çizileceği paletin kutbuna bağlı. Oyun FLIR indeksini
// bildiriyor (currentVisionMode [birim], 2.08+); "Otomatik" bunu kullanır. İndeks -> kutup
// eşlemesi setCamUseTI sayfasından doğrulanmadığı için varsayılan elle seçimdir.
// Siyah sıcak olan paletlerin FLIR indeksleri (hafızadan; doğrulanmadı):
RTI_sensor_blackHotIndices = [1, 3, 5];

[
    "RTI_sensor_polarity",
    "LIST",
    ["Termal palet kutbu", "Kullandığın paletle aynı olmalı. Beyaz sıcak: sıcak = parlak. Siyah sıcak: sıcak = koyu. Otomatik: oyunun bildirdiği FLIR indeksinden okur (deneysel; palet değişince flaş yönü de değişmeli). Namlu flaşı bu yönde çizilir."],
    _category,
    [[0, 1, 2], ["Beyaz sıcak", "Siyah sıcak", "Otomatik (FLIR indeksi, deneysel)"], 0],
    false
] call CBA_settings_fnc_init;

// Render-target (PiP) mercekli optiklerde ana ekran normal görüntüdür; ekran efekti
// onları bozar. Böyle bir optik varsa sınıf adını buraya yaz.
[
    "RTI_sensor_excludeOptics",
    "EDITBOX",
    ["Efekt uygulanmayacak optikler", "Virgülle ayrılmış sınıf adları (PiP / render-target mercekli optikler için). Boş bırak."],
    _category,
    "",
    false
] call CBA_settings_fnc_init;

// Çimen yamaları (siyah-gri leke deseni) araziye çizilen çimen "clutter"ıdır: nesne değil,
// sınıf adıyla ayrı bir termal özelliği yok. Gerçekten kaldırmanın tek yolu arazi ızgarasıdır
// (Video ayarlarındaki "Arazi ayrıntısı"); bu normal görüşte de çimeni siler.
[
    "RTI_sensor_grassOff",
    "CHECKBOX",
    ["Termalde çimeni kapat (deneysel)", "Termale girerken arazi ızgarasını 50'ye çeker (çimen yok), çıkınca aşağıdaki değere geri yükler. UYARI: ızgara değişimi ekranı kısa süre takılatabilir ve termal açıp kapatırken tekrarlanır; çimen normal görüşte de kalkar/geri gelir. Önce Hazır ayar = Agresif'i dene."],
    _category,
    false,
    false
] call CBA_settings_fnc_init;

[
    "RTI_sensor_grassRestore",
    "LIST",
    ["Termalden çıkınca arazi ızgarası", "Video ayarındaki 'Arazi ayrıntısı' değerinle aynı olmalı (oyun mevcut değeri okutmuyor). 50 = çimen yok, 3.125 = en ayrıntılı."],
    _category,
    [[50, 25, 12.5, 6.25, 3.125], ["50 (çimen yok)", "25", "12.5", "6.25", "3.125 (en ayrıntılı)"], 2],
    false
] call CBA_settings_fnc_init;
