/*
    Fonksiyon: RTI_fnc_vehOnFired
    Çalışma yeri: aracın YEREL olduğu makine (CBA sınıf olayı "fired")

    Her araç atışı namlu ısısını artırır:
        artış = (0.004 + CfgAmmo >> hit * 0.0004) (en çok 0.25) * "Namlu ısınma çarpanı"
    (hafif makineli ~0.008/mermi, 12.7 mm ~0.015, tank topu 0.15-0.25).
    Soğuma, profildeki namlu yarı-ömrüyle üstel.

    Seri atışta ağ yükünü sınırlamak için değer yerelde anında güncellenir, global
    yayın ise 0.5 sn içinde tek seferde yapılır.

    Parametreler: "Fired" olayı ile aynı (ilk 7 öğe kullanılır)
    Dönüş: yok
*/

params ["_veh", "", "", "", "_ammo"];

if (!RTI_veh_enabled || {RTI_veh_weaponGain <= 0}) exitWith {};

private _hit = getNumber (configFile >> "CfgAmmo" >> _ammo >> "hit");
private _add = ((0.004 + (_hit * 0.0004)) min 0.25) * RTI_veh_weaponGain;

private _now = serverTime;
private _profile = [_veh] call RTI_fnc_vehProfile;
private _tauDown = (_profile select 4) * RTI_veh_coolMult / 0.6931;

private _state = _veh getVariable ["RTI_wpn", []];
private _heat = if (_state isEqualTo []) then {0} else {[_state, _now, _tauDown, _tauDown] call RTI_fnc_vehHeat};

_veh setVariable ["RTI_wpn", [(_heat + _add) min 1, _now, 0]];

// Yayın: art arda atışları tek güncellemede topla.
if !(_veh getVariable ["RTI_wpnPending", false]) then {
    _veh setVariable ["RTI_wpnPending", true];

    [{
        params ["_vehicle"];

        _vehicle setVariable ["RTI_wpnPending", false];
        _vehicle setVariable ["RTI_wpn", _vehicle getVariable ["RTI_wpn", []], true];
    }, [_veh], 0.5] call CBA_fnc_waitAndExecute;
};
