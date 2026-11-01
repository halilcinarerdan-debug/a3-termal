/*
    Fonksiyon: RTI_fnc_diagTrace
    Çalışma yeri: İstemci (debug konsolu)

    Bir aracın termal parametrelerini her saniye RPT'ye yazar ([RTI][TRACE]).
    Amaç: setVehicleTIPars / getVehicleTIPars dizisindeki hangi sıranın motor, tekerlek
    ve silah ısısı olduğunu gözlemle doğrulamak (motoru aç, sür, ateş et, durdur).

    Parametreler:
        0: OBJECT - araç (varsayılan: bindiğin araç, yoksa imlecin gösterdiği)
        1: NUMBER - süre, saniye (varsayılan 120)

    Kullanım:  [] call RTI_fnc_diagTrace;   veya   [cursorObject, 180] call RTI_fnc_diagTrace;
    Dönüş: yok
*/

params [["_veh", objNull, [objNull]], ["_seconds", 120, [0]]];

if (isNull _veh) then {
    _veh = if ((vehicle player) isNotEqualTo player) then {vehicle player} else {cursorObject};
};

if (isNull _veh || {_veh isKindOf "CAManBase"}) exitWith {
    systemChat "[RTI] Izleme icin arac yok: araca bin ya da imleci araca tut.";
};

systemChat format ["[RTI] %1 izleniyor: %2 sn (RPT: [RTI][TRACE])", typeOf _veh, _seconds];

[_veh, _seconds] spawn {
    params ["_veh", "_seconds"];

    private _t0 = diag_tickTime;
    private _eh = _veh addEventHandler ["Fired", {
        (_this select 0) setVariable ["RTI_traceFired", diag_tickTime];
    }];

    while {(diag_tickTime - _t0) < _seconds && {!isNull _veh}} do {
        private _sinceFire = if ((_veh getVariable ["RTI_traceFired", -1]) < 0) then {-1} else {
            round (diag_tickTime - (_veh getVariable "RTI_traceFired"))
        };

        diag_log format [
            "[RTI][TRACE] t=%1 | motor=%2 hiz=%3 atistanBeri=%4s | TIPars=%5 | RTI_eng=%6 RTI_whl=%7 RTI_wpn=%8",
            round (diag_tickTime - _t0),
            isEngineOn _veh,
            round (speed _veh),
            _sinceFire,
            [_veh] call RTI_getTIPars,
            _veh getVariable ["RTI_eng", []],
            _veh getVariable ["RTI_whl", []],
            _veh getVariable ["RTI_wpn", []]
        ];

        uiSleep 1;
    };

    if (!isNull _veh) then {_veh removeEventHandler ["Fired", _eh]};
    systemChat "[RTI] Izleme bitti.";
};
