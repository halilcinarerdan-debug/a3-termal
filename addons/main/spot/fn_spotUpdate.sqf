/*
    Fonksiyon: RTI_fnc_spotUpdate
    Çalışma yeri: İstemci (termaldeyken, vehViewTick içinden saniyede bir)

    Aracın sıcak noktalarındaki yerel parçacık kaynaklarını ısıya göre günceller.
    Her nokta için ısı -> 4 parlaklık kademesi (0 = kapalı). Kademe ya da boyut sınıfı
    değişince eski kaynak silinip yenisi bağlanır; değişmediyse hiçbir şey yapılmaz.

    Boyut: noktanın temel boyutu + uzaklık (her 600 m'de bir sınıf büyür); uzakta küçük
    sprite piksel altına düşeceği için.

    Parametreler:
        0: OBJECT - araç
        1: NUMBER - motor ısısı 0..1
        2: NUMBER - namlu ısısı 0..1
        3: NUMBER - kameraya uzaklık (m)

    Dönüş: yok
*/

params ["_veh", "_eng", "_wpn", "_dist"];

private _points = [_veh] call RTI_fnc_spotResolve;
if (_points isEqualTo []) exitWith {};

private _slots = _veh getVariable ["RTI_spot_slots", []];

if (_slots isEqualTo []) then {
    _slots = _points apply {[objNull, ""]};
    _veh setVariable ["RTI_spot_slots", _slots];
    RTI_spot_vehicles pushBackUnique _veh;
};

{
    _x params ["_channel", "_mem", "_offset", "_baseTier", "_gain"];

    private _slot = _slots select _forEachIndex;

    private _heat = ([_eng, _wpn] select _channel) * _gain * RTI_spot_gain;
    private _level = count ([0.08, 0.3, 0.6, 0.85] select {_heat >= _x});
    private _tier = (_baseTier + (floor (_dist / 600))) min 2;

    private _class = ["", format ["RTI_Glow_%1%2", ["S", "M", "L"] select _tier, _level]] select (_level > 0);

    if (_class isNotEqualTo (_slot select 1)) then {
        deleteVehicle (_slot select 0);
        _slot set [0, objNull];

        if (_class isNotEqualTo "") then {
            private _src = "#particlesource" createVehicleLocal (getPosATL _veh);
            _src setParticleClass _class;
            _src setDropInterval 0.2;

            if (_mem isEqualTo "") then {
                _src attachTo [_veh, _offset];
            } else {
                _src attachTo [_veh, [0, 0, 0], _mem];
            };

            _slot set [0, _src];
        };

        _slot set [1, _class];
    };
} forEach _points;
