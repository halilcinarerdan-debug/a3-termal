/*
    Fonksiyon: RTI_fnc_vehUpdateState
    Çalışma yeri: aracın YEREL olduğu makine

    Motor ve tekerlek/palet kanallarının hedefini günceller. Hedef değiştiyse mevcut ısı
    hesaplanıp sabitlenir ve yeni [ısı, zaman, hedef] üçlüsü global yayınlanır.

      Motor hedefi:  kapalı 0 | açık+duruyor rölanti (profil) | açık+hareket 1
      Tekerlek hedefi: hareket yokken 0 | hareketteyken 0.25..1 (hıza göre, 0.2 adımlı)

    Hedefler kuantize olduğu için ağ trafiği seyrektir. Namlu kanalı burada değil,
    RTI_fnc_vehOnFired içinde güncellenir.

    Parametreler:
        0: OBJECT - araç
        1: NUMBER - şimdiki serverTime

    Dönüş: yok
*/

params ["_veh", "_now"];

// Sabit silahlarda motor / tekerlek yok; yalnızca namlu kanalı kullanılır.
if (_veh isKindOf "StaticWeapon") exitWith {};

private _profile = [_veh] call RTI_fnc_vehProfile;
_profile params ["_engUp", "_engHalf", "_whlUp", "_whlHalf", "", "_idle", "_maxSpeed"];

private _k = RTI_veh_coolMult / 0.6931;
private _tauDownEng = _engHalf * _k;
private _tauDownWhl = _whlHalf * _k;

private _engineOn = isEngineOn _veh;
private _speed = abs (speed _veh);
private _fraction = (_speed / _maxSpeed) min 1;
private _moving = _speed > 4;

private _engTarget = if (!_engineOn) then {0} else {[_idle, 1] select _moving};
private _whlTarget = if (_engineOn && {_moving}) then {(round ((0.25 + (0.75 * _fraction)) * 5)) / 5} else {0};

// Durum yoksa oluştur (motor açıksa sıcak başlar, kapalıysa soğuk); hedef değiştiyse güncelle.
private _update = {
    params ["_var", "_target", "_tauUp", "_tauDown", "_initial"];

    private _state = _veh getVariable [_var, []];

    if (_state isEqualTo []) exitWith {
        _veh setVariable [_var, [_initial, _now, _target], true];
    };

    if ((_state select 2) != _target) then {
        private _heat = [_state, _now, _tauUp, _tauDown] call RTI_fnc_vehHeat;
        _veh setVariable [_var, [_heat, _now, _target], true];

        if (RTI_core_debug) then {
            diag_log format ["[RTI][VEH] %1 %2: isi %3 -> hedef %4", typeOf _veh, _var, _heat toFixed 2, _target];
        };
    };
};

["RTI_eng", _engTarget, _engUp, _tauDownEng, _engTarget] call _update;
["RTI_whl", _whlTarget, _whlUp, _tauDownWhl, 0] call _update;
