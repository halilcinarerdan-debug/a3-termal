/*
    Fonksiyon: RTI_fnc_vehViewTick
    Çalışma yeri: İstemci (1 sn'lik CBA PFH)

    Oyuncu termaldeyse yakındaki araçların güncel motor / tekerlek / namlu ısısını
    yayınlanmış durumdan hesaplar ve setVehicleTIPars ile uygular. Yayınlanmış durumu
    olmayan araca dokunmaz (oyunun kendi değerleri kalır).

    Parametreler: yok
    Dönüş: yok
*/

if (!RTI_veh_enabled || {!RTI_cap_setVehicleTIPars}) exitWith {};
if (isNull player || {currentVisionMode player != 2}) exitWith {};

private _now = serverTime;
private _map = RTI_veh_parMapArr;
private _k = RTI_veh_coolMult / 0.6931;

{
    private _veh = _x;

    private _stEng = _veh getVariable ["RTI_eng", []];
    private _stWhl = _veh getVariable ["RTI_whl", []];
    private _stWpn = _veh getVariable ["RTI_wpn", []];

    if !((_stEng isEqualTo []) && {_stWhl isEqualTo []} && {_stWpn isEqualTo []}) then {
        private _profile = [_veh] call RTI_fnc_vehProfile;
        _profile params ["_engUp", "_engHalf", "_whlUp", "_whlHalf", "_wpnHalf"];

        private _eng = if (_stEng isEqualTo []) then {0} else {[_stEng, _now, _engUp, _engHalf * _k] call RTI_fnc_vehHeat};
        private _whl = if (_stWhl isEqualTo []) then {0} else {[_stWhl, _now, _whlUp, _whlHalf * _k] call RTI_fnc_vehHeat};
        private _wpn = if (_stWpn isEqualTo []) then {0} else {[_stWpn, _now, _wpnHalf * _k, _wpnHalf * _k] call RTI_fnc_vehHeat};

        private _pars = [0, 0, 0];
        _pars set [_map select 0, _eng];
        _pars set [_map select 1, _whl];
        _pars set [_map select 2, _wpn];

        [_veh, _pars] call RTI_setTIPars;
    };
} forEach ((positionCameraToWorld [0, 0, 0]) nearEntities [["LandVehicle", "Air", "Ship"], RTI_veh_viewDist]);
