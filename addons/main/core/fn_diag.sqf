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
    "surum 0.2.0 | CBA=%1 | rti_main=%2",
    isClass (configFile >> "CfgPatches" >> "cba_main"),
    isClass (configFile >> "CfgPatches" >> "rti_main")
] call _log;

format [
    "yetenek | setVehicleTIPars=%1 getVehicleTIPars=%2",
    missionNamespace getVariable ["RTI_cap_setVehicleTIPars", "?"],
    missionNamespace getVariable ["RTI_cap_getVehicleTIPars", "?"]
] call _log;

// Oyunun gerçekten bildirdiği termal/görüş ile ilgili komutlar (imzalarıyla)
private _si = (supportInfo "") select {
    private _l = toLower _x;
    ((_l find "tipar") >= 0) || {(_l find "thermal") >= 0} || {(_l find "visionmode") >= 0}
};
format ["ilgili komutlar (%1): %2", count _si, _si joinString " ; "] call _log;

// Görüş modu ve optik
private _weapon = currentWeapon player;
private _optic = (primaryWeaponItems player) param [2, ""];
format [
    "gorus modu=%1 (0 normal, 1 NVG, 2 TI) | silah=%2 | optik=%3 | kamera=%4",
    currentVisionMode player,
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

// Optik taraması
private _scan = missionNamespace getVariable ["RTI_thermalOptics", []];
format ["taranan termal optik sayisi: %1 (ayrinti: RPT '[RTI][SCOPE]')", count _scan] call _log;

// Araç
private _veh = if ((vehicle player) isNotEqualTo player) then {vehicle player} else {cursorObject};
if (!isNull _veh && {!(_veh isKindOf "CAManBase")}) then {
    format [
        "arac=%1 | motor=%2 | hiz=%3 | getVehicleTIPars=%4",
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
