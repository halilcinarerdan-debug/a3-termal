/*
    Fonksiyon: RTI_fnc_sensorInitSettings
    Çalışma yeri: TÜM makineler (XEH_preInit.sqf çağırır)

    Sensör (ekran işleme) ayarları. Hepsi kişisel tercihtir (isGlobal = false):
    görüntü tonu oyuncudan oyuncuya değişebilir. Değerler değişince efekt anında güncellenir.

    Parametreler: yok
    Dönüş: yok
*/

private _category = ["RTI - Gerçekçi Termal", "Sensör (ekran işleme)"];
private _refresh = {call RTI_fnc_sensorRefresh};

[
    "RTI_sensor_enabled",
    "CHECKBOX",
    ["Sensör efektleri aktif", "Termal moddayken kontrast/gürültü/yumuşatma uygular. Kapalıysa görüntü vanilla kalır."],
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
    "RTI_sensor_brightness",
    "SLIDER",
    ["Parlaklık", "1 = değişiklik yok. Vanilla termal çok parlak/patlamış görünüyorsa 0.9 civarına çek."],
    _category,
    [0.5, 1.5, 0.95, 2],
    false,
    _refresh
] call CBA_settings_fnc_init;

[
    "RTI_sensor_contrast",
    "SLIDER",
    ["Kontrast", "1 = değişiklik yok. Düşürmek sıcak cisimlerin 'beyaz leke' gibi patlamasını azaltır, orta tonları (kıyafet, ekipman, zemin) açığa çıkarır."],
    _category,
    [0.5, 1.2, 0.85, 2],
    false,
    _refresh
] call CBA_settings_fnc_init;

[
    "RTI_sensor_noise",
    "SLIDER",
    ["Sensör gürültüsü (NETD)", "Gerçek mikrobolometre sensörlerin ince tanecik gürültüsü. 0 = yok."],
    _category,
    [0, 1, 0.12, 2],
    false,
    _refresh
] call CBA_settings_fnc_init;

[
    "RTI_sensor_blur",
    "SLIDER",
    ["Yumuşatma (MTF)", "Optik/sensör çözünürlük kaybı: keskin vanilla kenarları yumuşatır. 0 = yok."],
    _category,
    [0, 1.5, 0.2, 2],
    false,
    _refresh
] call CBA_settings_fnc_init;

// Termal paletin kutbu oyundan okunamaz; flaşın hangi yönde (parlak/koyu) çizileceğini
// senin seçmen gerekir. Optikte N tuşuyla beyaz-sıcak / siyah-sıcak değiştirilir.
[
    "RTI_sensor_polarity",
    "LIST",
    ["Termal palet kutbu", "Kullandığın paletle aynı olmalı. Beyaz sıcak: sıcak = parlak. Siyah sıcak: sıcak = koyu. Namlu flaşı bu yönde çizilir."],
    _category,
    [[0, 1], ["Beyaz sıcak", "Siyah sıcak"], 0],
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
