/*
    Fonksiyon: RTI_fnc_diag
    Çalışma yeri: İstemci (debug konsolu, Local Exec:  call RTI_fnc_diag;)

    Tanı raporu üretir: komut desteği, mevcut görüş modu, takılı optiğin OpticsModes
    ayrıntıları, termal optik taraması özeti, bakılan/binilen aracın ısı parametreleri.
    Rapor RPT'ye ([RTI][DIAG]) yazılır VE panoya kopyalanır (sohbete yapıştırılabilir).

    Parametreler: yok
    Dönüş: ARRAY - rapor satırları
*/

private _out = [];
private _log = {
    _out pushBack _this;
    diag_log ("[RTI][DIAG] " + _this);
};

format [
    "surum (yuklu PBO, CfgPatches)=%1 | CBA=%2 | rti_main=%3",
    getText (configFile >> "CfgPatches" >> "rti_main" >> "versionStr"),
    isClass (configFile >> "CfgPatches" >> "cba_main"),
    isClass (configFile >> "CfgPatches" >> "rti_main")
] call _log;

// Efekt gercekten uygulaniyor mu? (aktif bayragi, PP tutamaclari, hazir ayar, zorlama, gorus modu)
private _ppNames = ["RTI_pp_color", "RTI_pp_floor", "RTI_pp_grain", "RTI_pp_blur"];
private _ppHandles = _ppNames apply {missionNamespace getVariable [_x, -1]};
private _ppEnabled = _ppHandles apply {if (_x >= 0) then {ppEffectEnabled _x} else {"yok"}};

format [
    "sensor durumu | ayar aktif=%1 | efekt calisiyor=%2 | zorla=%3 | ppAllowed=%4 | tutamac [renk,taban,gurultu,bulaniklik]=%5 | etkin=%6 | hazir ayar=%7 | gorus=%8",
    missionNamespace getVariable ["RTI_sensor_enabled", "?"],
    missionNamespace getVariable ["RTI_sensor_active", false],
    missionNamespace getVariable ["RTI_sensor_forced", false],
    missionNamespace getVariable ["RTI_ppAllowed", "?"],
    _ppHandles,
    _ppEnabled,
    missionNamespace getVariable ["RTI_sensor_preset", "?"],
    currentVisionMode [player]
] call _log;

format [
    "yetenek | setVehicleTIPars=%1 getVehicleTIPars=%2",
    missionNamespace getVariable ["RTI_cap_setVehicleTIPars", "?"],
    missionNamespace getVariable ["RTI_cap_getVehicleTIPars", "?"]
] call _log;

// Oyunun gerçekten bildirdiği termal/görüş ile ilgili komutlar (imzalarıyla)
private _si = (supportInfo "") select {
    private _l = toLower _x;
    ((_l find "tipar") >= 0) || {(_l find "thermal") >= 0} || {(_l find "visionmode") >= 0} || {(_l find "aperture") >= 0}
};
format ["ilgili komutlar (%1): %2", count _si, _si joinString " ; "] call _log;

// Görüş modu ve optik
private _weapon = currentWeapon player;
private _optic = (primaryWeaponItems player) param [2, ""];
format [
    "gorus [mod, flirIndeksi]=%1 (mod: 0 normal, 1 NVG, 2 TI) | silah=%2 | optik=%3 | kamera=%4",
    currentVisionMode [player],
    _weapon,
    _optic,
    cameraView
] call _log;

private _modes = if (_optic isEqualTo "") then {
    configFile >> "CfgWeapons" >> _weapon >> "OpticsModes"
} else {
    configFile >> "CfgWeapons" >> _optic >> "ItemInfo" >> "OpticsModes"
};

if (isClass _modes) then {
    {
        format [
            "  mod '%1' | visionMode=%2 | thermalMode=%3 | useModelOptics=%4 | opticsPPEffects=%5",
            configName _x,
            getArray (_x >> "visionMode"),
            getArray (_x >> "thermalMode"),
            getNumber (_x >> "useModelOptics"),
            getArray (_x >> "opticsPPEffects")
        ] call _log;
    } forEach ("true" configClasses _modes);
} else {
    "  bu silah/optikte OpticsModes yok" call _log;
};

// Ortam modeli ve sensör değerleri
format [
    "ortam [kontrastK, bulaniklikK, gurultuK, gunes, sicaklikC]=%1 | sensor [parlaklik, kontrast, ofset, gurultu, bulaniklik, taban]=%2 | hazir ayar=%3",
    missionNamespace getVariable ["RTI_env_k", "?"],
    if (missionNamespace getVariable ["RTI_env_enabled", false]) then {call RTI_fnc_sensorParams} else {"ortam kapali"},
    missionNamespace getVariable ["RTI_sensor_preset", "?"]
] call _log;

// Zemin tabanı: bakılan yüzey
format [
    "yuzey [zeminK, gokK, grup, sinif]=%1 | sensor ayar: yuzeye gore taban=%2 taban surgusu=%3",
    missionNamespace getVariable ["RTI_surf_k", "?"],
    missionNamespace getVariable ["RTI_sensor_surface", "?"],
    missionNamespace getVariable ["RTI_sensor_floor", "?"]
] call _log;

// A3TI uyumluluğu
format [
    "A3TI tespiti=%1 | eslesen CfgPatches=%2 | 'A3TI yukluyken sensor efektleri'=%3",
    missionNamespace getVariable ["RTI_cap_a3ti", "?"],
    missionNamespace getVariable ["RTI_a3tiPatches", "?"],
    missionNamespace getVariable ["RTI_sensor_withA3TI", "?"]
] call _log;

// Optik taraması
private _scan = missionNamespace getVariable ["RTI_thermalOptics", []];
format ["taranan termal optik sayisi: %1 (ayrinti: RPT '[RTI][SCOPE]')", count _scan] call _log;

// İnsan: getVehicleTIPars piyadede de değer döndürüyor mu? (wiki yalnızca "piyade SİLAHLARINDA çalışmaz" diyor)
format [
    "insan TI parametreleri | oyuncu=%1 | imlecteki=%2",
    [player] call RTI_getTIPars,
    if (cursorObject isKindOf "CAManBase") then {[cursorObject] call RTI_getTIPars} else {"imlec bir askerde degil"}
] call _log;

// Araç
private _veh =if ((vehicle player) isNotEqualTo player) then {vehicle player} else {cursorObject};
if (!isNull _veh && {!(_veh isKindOf "CAManBase")}) then {
    format [
        "arac=%1 | motor=%2 | hiz=%3 | getVehicleTIPars=%4 ([aliveFactor, movementFactor, metabolismFactor])",
        typeOf _veh,
        isEngineOn _veh,
        round (speed _veh),
        [_veh] call RTI_getTIPars
    ] call _log;
    format [
        "  durum | RTI_eng=%1 RTI_whl=%2 RTI_wpn=%3 | profil=%4",
        _veh getVariable ["RTI_eng", []],
        _veh getVariable ["RTI_whl", []],
        _veh getVariable ["RTI_wpn", []],
        [_veh] call RTI_fnc_vehProfile
    ] call _log;
    format [
        "  sicak noktalar (kanal 0 motor, 1 namlu; kanal, bellek noktasi, ofset, boyut, kazanc, etiket): %1",
        [_veh] call RTI_fnc_spotResolve
    ] call _log;
} else {
    "arac: yok (bir araca bin ya da imleci araca tut)" call _log;
};

copyToClipboard (_out joinString endl);
systemChat "[RTI] Tanı raporu panoya kopyalandı ve RPT'ye yazıldı.";

_out
