/*
    Fonksiyon: RTI_fnc_surfaceClass
    Çalışma yeri: İstemci (saf hesap + önbellek)

    Bir CfgSurfaces sınıfını ISIL gruba çevirir ve gün / gece zemin ısı çarpanlarını verir.
    CfgSurfaces'te termal bir özellik YOKTUR; grup, sınıf adındaki anahtar kelimelerden (önce) ve
    soundEnviron özelliğinden (yedek) çıkarılır. Bu yüzden RHS/CUP/üçüncü taraf arazilerde de çalışır
    (ör. "GdtAsphalt", "cp_concrete", "GdtGrassDry").

    Çarpanlar ısı kapasitesi ve güneş yükleme sezgisine dayanır (tahmin; doğrulanmadı):
        grup      gündüz  gece   neden
        asfalt     1.3    1.9    ısıyı tutar, geceleri de sıcak
        kaya       1.3    1.5    ısıyı tutar
        kum        1.6    0.5    gündüz çok ısınır, geceleri hızla soğur
        kar        0.4    0.4    soğuk
        su         0.9    1.2    ısıl kütle büyük; geceleri karadan sıcak
        toprak     1.2    0.9    kuru toprak gündüz ısınır
        çimen      0.8    1.0    buharlaşma gündüz serinletir
        bilinmeyen 1.0    1.0

    Parametreler:
        0: STRING - CfgSurfaces sınıf adı ("#" olmadan)

    Dönüş: ARRAY - [grup, gündüzK, geceK]
*/

params ["_class"];

if (isNil "RTI_surf_cache") then {RTI_surf_cache = createHashMap};

private _cached = RTI_surf_cache getOrDefault [_class, []];
if (_cached isNotEqualTo []) exitWith {_cached};

private _name = toLower _class;
private _soundEnv = toLower (getText (configFile >> "CfgSurfaces" >> _class >> "soundEnviron"));

private _table = [
    ["asfalt", ["asphalt", "concrete", "tarmac", "pavement", "paving", "runway"], 1.3, 1.9],
    ["kaya", ["rock", "stone", "cliff", "gravel", "rubble"], 1.3, 1.5],
    ["kum", ["sand", "beach", "desert", "dune"], 1.6, 0.5],
    ["kar", ["snow", "ice", "frozen"], 0.4, 0.4],
    ["su", ["water", "sea", "lake", "river", "shallow"], 0.9, 1.2],
    ["toprak", ["dirt", "soil", "earth", "mud", "farm", "field", "plow", "clay", "dust"], 1.2, 0.9],
    ["cimen", ["grass", "forest", "leaves", "fern", "meadow", "weed", "bush", "moss", "pine"], 0.8, 1.0]
];

private _result = ["bilinmeyen", 1, 1];

// 1) Sınıf adındaki anahtar kelimeler
{
    _x params ["_group", "_keys", "_day", "_night"];

    if ((_keys findIf {(_name find _x) >= 0}) >= 0) exitWith {
        _result = [_group, _day, _night];
    };
} forEach _table;

// 2) Yedek: soundEnviron ("road" asfalt, diğerleri anahtar kelimeyle eşleşir)
if ((_result select 0) isEqualTo "bilinmeyen" && {_soundEnv isNotEqualTo ""}) then {
    if (_soundEnv isEqualTo "road") then {
        _result = ["asfalt", 1.3, 1.9];
    } else {
        {
            _x params ["_group", "_keys", "_day", "_night"];

            if ((_keys findIf {(_soundEnv find _x) >= 0}) >= 0) exitWith {
                _result = [_group, _day, _night];
            };
        } forEach _table;
    };
};

RTI_surf_cache set [_class, _result];

diag_log format ["[RTI][SURF] %1 (soundEnviron '%2') -> %3", _class, _soundEnv, _result];

_result
