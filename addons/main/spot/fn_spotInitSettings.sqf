/*
    Fonksiyon: RTI_fnc_spotInitSettings
    Çalışma yeri: TÜM makineler (XEH_preInit.sqf çağırır)

    Araç "sıcak nokta" ayarları. Nokta konumları araç sınıfından OTOMATİK çözülür
    (motor / egzoz / namlu); RHS ve CUP için sınıf tablosu gerekmez.

    Parametreler: yok
    Dönüş: yok
*/

private _category = ["RTI - Gerçekçi Termal", "Araç sıcak noktaları"];

RTI_spot_vehicles = [];
RTI_spot_cache = createHashMap;

[
    "RTI_spot_enabled",
    "CHECKBOX",
    ["Araç sıcak noktaları (deneysel)", "Motor, egzoz ve namlu üzerine, ısıya göre parlaklığı değişen yumuşak kenarlı bir ısı lekesi bırakır (merkezden uzaklaştıkça söner). Termal dokuya dokunmaz; yalnızca termaldeyken yerel parçacık üretir. Parçacığın TI'de sıcak çizilmesine bağlıdır (call RTI_fnc_testHeatSpot)."],
    _category,
    true,
    true,
    {
        if !(_this) then {call RTI_fnc_spotClearAll};
    }
] call CBA_settings_fnc_init;

[
    "RTI_spot_gain",
    "SLIDER",
    ["Sıcak nokta şiddeti", "Isı değeri bu çarpanla ölçeklenir, sonra 4 parlaklık kademesinden birine yuvarlanır."],
    _category,
    [0.2, 3, 1, 2],
    false
] call CBA_settings_fnc_init;

[
    "RTI_spot_maxVehicles",
    "SLIDER",
    ["Aynı anda en fazla araç", "Termalde bakılan en yakın bu kadar araca sıcak nokta konur. Her araç 2-5 yerel parçacık kaynağı demektir."],
    _category,
    [1, 40, 10, 0],
    false
] call CBA_settings_fnc_init;

// Motor noktası modelin içinde (gövdenin altında) olabilir; parçacık gövdeye gömülü
// kalırsa dışarıdan görünmez. 0 = olduğu yerde, 1 = modelin sınır kutusunun tepesi.
[
    "RTI_spot_engineLift",
    "SLIDER",
    ["Motor lekesi yükseltme", "Motor noktasının modelin tepesine doğru ne kadar kaldırılacağı (0..1). Leke gövdeye gömülüyse artır, havada asılı görünüyorsa azalt. Debug: [true] call RTI_fnc_spotDebug"],
    _category,
    [0, 1, 0.7, 2],
    true,
    {
        RTI_spot_cache = createHashMap;
        call RTI_fnc_spotClearAll;
    }
] call CBA_settings_fnc_init;
