/*
    Fonksiyon: RTI_fnc_vehOwnerTick
    Çalışma yeri: TÜM makineler (3 sn'lik CBA PFH)

    Bu makinede YEREL olan canlı araçların ısı durumunu günceller. Başka makinelerin
    araçlarına dokunmaz; böylece her aracı tek makine yayınlar.

    Parametreler: yok
    Dönüş: yok
*/

if (!RTI_veh_enabled) exitWith {};

private _now = serverTime;

{
    if (local _x && {alive _x}) then {
        [_x, _now] call RTI_fnc_vehUpdateState;
    };
} forEach vehicles;
