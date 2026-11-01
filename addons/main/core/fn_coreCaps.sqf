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
RTI_cap_setAperture = ["setaperture"] call _has;

// A3TI (A3 Thermal Improvement) yuklu mu? CfgPatches sinif adini bilmiyoruz: adinda "a3ti" gecen herhangi bir sinif.
RTI_a3tiPatches = (configProperties [configFile >> "CfgPatches", "(toLower (configName _x)) find 'a3ti' >= 0", true]) apply {configName _x};
RTI_cap_a3ti = (count RTI_a3tiPatches) > 0;

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

// HDR pozu: komut yoksa mod cokmesin diye compile ile sarilir (-1 = otomatige don).
RTI_setAperture = if (RTI_cap_setAperture) then {
    compile "params ['_v']; setAperture _v;"
} else {
    {}
};

RTI_cap_ready = true;

diag_log format [
    "[RTI] yetenekler | setVehicleTIPars=%1 getVehicleTIPars=%2 setAperture=%4 | CBA=%3",
    RTI_cap_setVehicleTIPars,
    RTI_cap_getVehicleTIPars,
    isClass (configFile >> "CfgPatches" >> "cba_main"),
    RTI_cap_setAperture
];

diag_log format ["[RTI] A3TI tespiti: %1 | eslesen CfgPatches: %2", RTI_cap_a3ti, RTI_a3tiPatches];
