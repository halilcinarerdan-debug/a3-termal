/*
    Fonksiyon: RTI_fnc_flashInitSettings
    Çalışma yeri: TÜM makineler (XEH_preInit.sqf çağırır)

    Namlu flaşı ayarları. "Aktif", "başkalarının flaşı" ve "azami mesafe" global
    (sunucu zorlayabilir); kendi ekran flaşım kişisel tercihtir.

    Parametreler: yok
    Dönüş: yok
*/

private _category = ["RTI - Gerçekçi Termal", "Namlu flaşı"];

[
    "RTI_flash_enabled",
    "CHECKBOX",
    ["Namlu flaşı sistemi aktif", "Kapalıysa atış olayı hiç işlenmez (sıfır maliyet)."],
    _category,
    true,
    true
] call CBA_settings_fnc_init;

[
    "RTI_flash_own",
    "CHECKBOX",
    ["Kendi silahım: termalde ekran flaşı", "Termal optikteyken ateş edince görüntü kısa süre parlar (sensörün namlu parlamasıyla doygunluğa ulaşması). Dünya geometrisine bağlı değildir; kendi silahında en güvenilir yöntemdir."],
    _category,
    true,
    false
] call CBA_settings_fnc_init;

[
    "RTI_flash_ownGain",
    "SLIDER",
    ["Kendi flaşım: şiddet çarpanı", "1 = varsayılan. Susturuculu silahta ve düşük kalibrede flaş zaten daha zayıftır."],
    _category,
    [0, 2, 1, 2],
    false
] call CBA_settings_fnc_init;

[
    "RTI_flash_ownDecay",
    "SLIDER",
    ["Kendi flaşım: sönme süresi (sn)", "Parlamanın ne kadar sürede normale döneceği."],
    _category,
    [0.03, 0.6, 0.15, 2],
    false
] call CBA_settings_fnc_init;

[
    "RTI_flash_others",
    "CHECKBOX",
    ["Başkalarının namlu ateşi termalde parlasın (deneysel)", "Diğer oyuncu / YZ atışlarında namlu ucuna kısa ömürlü sıcak parçacık bırakır. Yalnızca termaldeki oyunculara ağ olayı gider. Parçacığın TI'de parlak çizilip çizilmediği oyunda doğrulanmalı (debug konsolu: call RTI_fnc_testHeatSpot)."],
    _category,
    true,
    true
] call CBA_settings_fnc_init;

[
    "RTI_flash_maxDist",
    "SLIDER",
    ["Başkalarının flaşı: azami mesafe (m)", "Bu mesafenin ötesindeki atışlar için olay gönderilmez ve parçacık üretilmez."],
    _category,
    [100, 3000, 1200, 0],
    true
] call CBA_settings_fnc_init;
