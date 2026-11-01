/*
    Fonksiyon: RTI_fnc_coreScanScopes
    Çalışma yeri: İstemci (zamanlanmış ortam: spawn ile çağrılmalı)

    CfgWeapons içinde termal (visionMode "Ti") modu olan tüm optikleri bulur. Sınıf adı
    listesi KODA GÖMÜLÜ DEĞİLDİR; RHS, CUP veya başka bir mod ne sağlıyorsa o taranır.
    Hem eklenti optiklerini (ItemInfo >> OpticsModes) hem de silahın kendi
    OpticsModes sınıfını (dürbün / lazer işaretleyici) kontrol eder.

    Sonuç: RTI_thermalOptics (ARRAY of STRING) + RPT özeti.

    Parametreler: yok
    Dönüş: ARRAY - termal optik sınıf adları
*/

private _t0 = diag_tickTime;
private _found = [];

{
    private _name = configName _x;
    private _candidates = [_x >> "ItemInfo" >> "OpticsModes", _x >> "OpticsModes"];
    private _ti = false;

    {
        if (isClass _x) then {
            {
                private _vision = (getArray (_x >> "visionMode")) apply {toLower _x};
                if ("ti" in _vision) exitWith {_ti = true};
            } forEach ("true" configClasses _x);
        };
        if (_ti) exitWith {};
    } forEach _candidates;

    if (_ti) then {_found pushBack _name};
} forEach ("getNumber (_x >> 'scope') == 2" configClasses (configFile >> "CfgWeapons"));

RTI_thermalOptics = _found;

private _rhs = _found select {(toLower (_x select [0, 3])) isEqualTo "rhs"};
private _cup = _found select {(toLower (_x select [0, 4])) isEqualTo "cup_"};
private _other = (_found - _rhs) - _cup;

diag_log format [
    "[RTI][SCOPE] termal optik: toplam %1 | RHS %2 | CUP %3 | diger %4 | tarama %5 ms",
    count _found,
    count _rhs,
    count _cup,
    count _other,
    round ((diag_tickTime - _t0) * 1000)
];
diag_log format ["[RTI][SCOPE] RHS: %1", _rhs joinString ", "];
diag_log format ["[RTI][SCOPE] CUP: %1", _cup joinString ", "];
diag_log format ["[RTI][SCOPE] diger: %1", _other joinString ", "];

_found
