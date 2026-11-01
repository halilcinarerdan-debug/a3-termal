/*
    Fonksiyon: RTI_fnc_spotResolve
    Çalışma yeri: İstemci

    Bir aracın sıcak nokta listesini SINIF CONFIG'İNDEN çözer ve sınıf başına önbelleğe alır.
    Modelin kendisine dokunulmaz; RHS / CUP / vanilla fark etmez, ortak taban sınıflar
    (HitEngine, Exhausts, Turrets >> gunBeg/gunEnd) kullanılır:

      motor   : HitPoints >> HitEngine >> name  (HitPoints LOD'undaki seçim)
                -> selectionPosition ile model konumu, sınır kutusunun tepesine doğru kaldırılır
      egzoz   : Exhausts >> * >> position       (bellek noktası, en çok 2)
      namlu   : ilk gunBeg'i olan taret -> gunBeg (namlu ucu) + gunEnd (kama)

    Bulunamayan nokta atlanır; sonuç RPT'ye bir kez yazılır ([RTI][SPOT]), bu yüzden
    yanlış yer / eksik nokta gözlenebilir. Görsel doğrulama: [true] call RTI_fnc_spotDebug

    Parametreler:
        0: OBJECT - araç

    Dönüş: ARRAY of [kanal, bellekNoktası, modelOfseti, temelBoyut, kazanç, etiket]
        kanal      : 0 = motor ısısı, 1 = namlu ısısı
        bellekNoktası : "" ise modelOfseti kullanılır; doluysa bu bellek noktasına eklenir
        temelBoyut : 0 S, 1 M, 2 L
*/

params ["_veh"];

private _type = typeOf _veh;
private _cached = RTI_spot_cache getOrDefault [_type, objNull];

if (_cached isEqualType []) exitWith {_cached};

private _cfg = configFile >> "CfgVehicles" >> _type;
private _points = [];

// --- Motor ---
private _engineSel = getText (_cfg >> "HitPoints" >> "HitEngine" >> "name");

if (_engineSel isNotEqualTo "") then {
    private _pos = _veh selectionPosition [_engineSel, "HitPoints"];

    if (_pos isNotEqualTo [0, 0, 0]) then {
        private _top = ((boundingBoxReal _veh) select 1) select 2;
        private _z = (_pos select 2) + (((_top - (_pos select 2)) max 0) * RTI_spot_engineLift);

        _points pushBack [0, "", [_pos select 0, _pos select 1, _z], 1, 1, "motor"];
    };
};

// --- Egzoz (en çok 2) ---
private _exhausts = 0;

{
    private _mem = getText (_x >> "position");

    if (_exhausts < 2 && {_mem isNotEqualTo ""} && {(_veh selectionPosition [_mem, "Memory"]) isNotEqualTo [0, 0, 0]}) then {
        _points pushBack [0, _mem, [0, 0, 0], 0, 1.2, "egzoz"];
        _exhausts = _exhausts + 1;
    };
} forEach ("true" configClasses (_cfg >> "Exhausts"));

// --- Namlu: ilk gunBeg'i olan taret ---
{
    private _beg = getText (_x >> "gunBeg");
    private _end = getText (_x >> "gunEnd");

    if (_beg isNotEqualTo "" && {(_veh selectionPosition [_beg, "Memory"]) isNotEqualTo [0, 0, 0]}) exitWith {
        _points pushBack [1, _beg, [0, 0, 0], 0, 1, "namlu ucu"];

        if (_end isNotEqualTo "" && {(_veh selectionPosition [_end, "Memory"]) isNotEqualTo [0, 0, 0]}) then {
            _points pushBack [1, _end, [0, 0, 0], 0, 0.6, "kama"];
        };
    };
} forEach ("true" configClasses (_cfg >> "Turrets"));

RTI_spot_cache set [_type, _points];

diag_log format [
    "[RTI][SPOT] %1: %2 nokta -> %3 | HitEngine secimi='%4'",
    _type,
    count _points,
    _points apply {_x select 5},
    _engineSel
];

_points
