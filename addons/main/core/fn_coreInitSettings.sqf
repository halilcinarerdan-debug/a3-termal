/*
    Fonksiyon: RTI_fnc_coreInitSettings
    Çalışma yeri: TÜM makineler (XEH_preInit.sqf çağırır)

    Genel CBA ayarları.

    Parametreler: yok
    Dönüş: yok
*/

private _category = ["RTI - Gerçekçi Termal", "Genel"];

[
    "RTI_core_debug",
    "CHECKBOX",
    ["Ayrıntılı günlük (RPT)", "Açıkken [RTI] satırlarını RPT'ye yazar (flaş olayları, araç ısı güncellemeleri). Normal oyunda kapalı tut."],
    _category,
    false,
    false
] call CBA_settings_fnc_init;
