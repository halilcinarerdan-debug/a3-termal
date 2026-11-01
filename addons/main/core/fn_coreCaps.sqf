/*
    Fonksiyon: RTI_fnc_coreCaps
    Çalışma yeri: TÜM makineler (XEH_preInit.sqf çağırır)

    Bu oyun sürümünde hangi termal komutlarının var olduğunu çalışma anında tespit eder.
    Komutlar doğrudan yazılmaz; yalnızca varsa derlenen ince sarmalayıcılar kullanılır:
    komut yoksa mod çökmez, ilgili özellik sessizce devre dışı kalır ve RPT'ye yazılır.

    Tanımladığı değişkenler:
        RTI_cap_setVehicleTIPars  BOOL
        RTI_cap_getVehicleTIPars  BOOL
        RTI_setTIPars             CODE   [araç, [a,b,c]] call RTI_setTIPars
        RTI_getTIPars             CODE   [araç] call RTI_getTIPars  -> ARRAY

    Parametreler: yok
    Dönüş: yok
*/

if (!isNil "RTI_cap_ready") exitWith {};

private _info = (supportInfo "") apply {toLower _x};

private _has = {
    params ["_name"];
    (_info findIf {(_x find _name) >= 0}) >= 0
};

RTI_cap_setVehicleTIPars = ["setvehicletipars"] call _has;
RTI_cap_getVehicleTIPars = ["getvehicletipars"] call _has;

RTI_setTIPars = if (RTI_cap_setVehicleTIPars) then {
    compile "params ['_v', '_a']; _v setVehicleTIPars _a;"
} else {
    {}
};

RTI_getTIPars = if (RTI_cap_getVehicleTIPars) then {
    compile "params ['_v']; getVehicleTIPars _v"
} else {
    {[]}
};

RTI_cap_ready = true;

diag_log format [
    "[RTI] yetenekler | setVehicleTIPars=%1 getVehicleTIPars=%2 | CBA=%3",
    RTI_cap_setVehicleTIPars,
    RTI_cap_getVehicleTIPars,
    isClass (configFile >> "CfgPatches" >> "cba_main")
];
