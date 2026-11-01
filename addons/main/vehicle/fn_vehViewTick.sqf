/*
    Fonksiyon: RTI_fnc_vehViewTick
    Çalışma yeri: İstemci (1 sn'lik CBA PFH)

    Oyuncu termaldeyse yakındaki araçların güncel motor / tekerlek / namlu ısısını
    yayınlanmış durumdan hesaplar ve iki yoldan uygular:
      1) setVehicleTIPars (komut varsa): oyunun kendi termal parametreleri
      2) Sıcak noktalar (spot modülü): motor / egzoz / namlu üstünde ısıya göre parlayan leke
         (yalnızca en yakın RTI_spot_maxVehicles araç)
    Yayınlanmış durumu olmayan araca dokunmaz (oyunun kendi değerleri kalır).

    Termal kapalıyken sıcak noktalar silinir (normal görüşte leke görünmesin).

    Parametreler: yok
    Dönüş: yok
*/

if (!RTI_veh_enabled) exitWith {};

if (isNull player || {currentVisionMode player != 2}) exitWith {
    call RTI_fnc_spotClearAll;
};

// Ortam modeli (20 sn'de bir yenilenir) -> güneşte duran araç gövdesi motor kapalıyken de bir miktar ısınmış sayılır.
[] call RTI_fnc_envUpdate;

private _solarFloor = if (RTI_env_enabled) then {(RTI_env_k select 3) * RTI_env_vehSolar} else {0};

private _now = serverTime;
private _map = RTI_veh_parMapArr;
private _k = RTI_veh_coolMult / 0.6931;
private _cam = positionCameraToWorld [0, 0, 0];

// En yakından uzağa: [uzaklık, indeks] çiftleri sayısal sıralanır (nesne karşılaştırması yok).
private _list = _cam nearEntities [["LandVehicle", "Air", "Ship"], RTI_veh_viewDist];
private _order = [];

{
    _order pushBack [_cam distance _x, _forEachIndex];
} forEach _list;

_order sort true;

private _seen = [];

{
    _x params ["_dist", "_index"];

    private _veh = _list select _index;

    private _stEng = _veh getVariable ["RTI_eng", []];
    private _stWhl = _veh getVariable ["RTI_whl", []];
    private _stWpn = _veh getVariable ["RTI_wpn", []];

    if !((_stEng isEqualTo []) && {_stWhl isEqualTo []} && {_stWpn isEqualTo []}) then {
        private _profile = [_veh] call RTI_fnc_vehProfile;
        _profile params ["_engUp", "_engHalf", "_whlUp", "_whlHalf", "_wpnHalf"];

        private _eng = if (_stEng isEqualTo []) then {0} else {[_stEng, _now, _engUp, _engHalf * _k] call RTI_fnc_vehHeat};
        private _whl = if (_stWhl isEqualTo []) then {0} else {[_stWhl, _now, _whlUp, _whlHalf * _k] call RTI_fnc_vehHeat};
        private _wpn = if (_stWpn isEqualTo []) then {0} else {[_stWpn, _now, _wpnHalf * _k, _wpnHalf * _k] call RTI_fnc_vehHeat};

        if (RTI_cap_setVehicleTIPars) then {
            private _pars = [0, 0, 0];
            // Güneş tabanı yalnızca oyunun termal parametresine yazılır; sıcak nokta (spot) gerçek motor ısısını kullanır.
            _pars set [_map select 0, _eng max _solarFloor];
            _pars set [_map select 1, _whl];
            _pars set [_map select 2, _wpn];

            [_veh, _pars] call RTI_setTIPars;
        };

        if (RTI_spot_enabled && {(count _seen) < RTI_spot_maxVehicles} && {alive _veh}) then {
            _seen pushBack _veh;
            [_veh, _eng, _wpn, _dist] call RTI_fnc_spotUpdate;
        };
    };
} forEach _order;

// Menzilden çıkan, sıcak nokta limitine takılan ya da yok olan araçların noktalarını kaldır.
{
    if !(_x in _seen) then {[_x] call RTI_fnc_spotClear};
} forEach +RTI_spot_vehicles;
