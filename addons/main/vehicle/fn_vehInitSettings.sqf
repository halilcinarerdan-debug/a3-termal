/*
    Fonksiyon: RTI_fnc_vehInitSettings
    Çalışma yeri: TÜM makineler (XEH_preInit.sqf çağırır)

    Araç ısı modeli ayarları. Model deterministiktir: araç sahibi makine yalnızca
    [ısı, zaman damgası, hedef] üçlüsünü yayınlar; her istemci güncel ısıyı bu üçlüden
    kendi hesaplar. Ağ trafiği yalnızca hedef değişince oluşur.

    Parametreler: yok
    Dönüş: yok
*/

private _category = ["RTI - Gerçekçi Termal", "Araç ısı modeli"];

// Varsayılan; EDITBOX geri çağrısı geçerli bir değer girilince günceller.
RTI_veh_parMapArr = [0, 1, 2];

[
    "RTI_veh_enabled",
    "CHECKBOX",
    ["Araç ısı modeli aktif (deneysel)", "Motor / tekerlek-palet / namlu ısısını zamana yayılı ısınma-soğuma modeliyle setVehicleTIPars'a yazar. Oyun sürümünde komut yoksa otomatik devre dışı kalır."],
    _category,
    true,
    true
] call CBA_settings_fnc_init;

[
    "RTI_veh_coolMult",
    "SLIDER",
    ["Soğuma süresi çarpanı", "1 = varsayılan yarı-ömürler (tank motoru ~25 dk, kamyon ~8 dk). Kısa görevlerde 0.3-0.5, gerçekçilik için 1+."],
    _category,
    [0.1, 5, 1, 2],
    true
] call CBA_settings_fnc_init;

[
    "RTI_veh_weaponGain",
    "SLIDER",
    ["Namlu ısınma çarpanı", "Her atışın namluya verdiği ısı bu değerle çarpılır. 0 = namlu ısınmaz."],
    _category,
    [0, 3, 1, 2],
    true
] call CBA_settings_fnc_init;

[
    "RTI_veh_viewDist",
    "SLIDER",
    ["Isı güncelleme mesafesi (m)", "Termaldeyken bu mesafedeki araçlar için saniyede bir hesaplanır. Düşürmek CPU'yu rahatlatır."],
    _category,
    [200, 5000, 2500, 0],
    false
] call CBA_settings_fnc_init;

// setVehicleTIPars dizisinde hangi sıranın motor/tekerlek/silah olduğu belgelenmeden
// doğrulanamadı. Varsayım "0,1,2" = [motor, tekerlek, silah]. RTI_fnc_diagTrace ile
// gözlenip yanlışsa buradan düzeltilir (ör. "1,0,2").
[
    "RTI_veh_parMap",
    "EDITBOX",
    ["TI parametre sırası (motor, tekerlek, silah)", "setVehicleTIPars dizisindeki indeksler. Varsayılan 0,1,2. Doğrulama: debug konsolunda [] call RTI_fnc_diagTrace, sonra motoru aç / sür / ateş et."],
    _category,
    "0,1,2",
    true,
    {
        RTI_veh_parMapArr = [_this] call RTI_fnc_vehParseParMap;
    }
] call CBA_settings_fnc_init;
