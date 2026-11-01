/*
    Fonksiyon: RTI_fnc_spotDebug
    Çalışma yeri: İstemci (debug konsolu)

    Sıcak nokta konumlarını NORMAL görüşte ekranda etiketle gösterir: imlecin gösterdiği
    araç (ya da en yakın araç) için çözülen noktalar turuncu işaretçi + etiket olarak çizilir.
    Böylece motor / egzoz / namlu noktalarının doğru yerde olup olmadığı görülür.
    Motor noktası gövdeye gömülü ya da havada ise "Motor lekesi yükseltme" ayarını düzelt.

    Parametreler:
        0: BOOL - true aç, false kapat (varsayılan true)

    Kullanım:  [true] call RTI_fnc_spotDebug;     [false] call RTI_fnc_spotDebug;
    Dönüş: yok
*/

params [["_on", true, [true]]];

private _handle = missionNamespace getVariable ["RTI_spot_dbgEH", -1];

if (!_on) exitWith {
    if (_handle >= 0) then {
        removeMissionEventHandler ["Draw3D", _handle];
        RTI_spot_dbgEH = -1;
    };
};

if (_handle >= 0) exitWith {};

RTI_spot_dbgEH = addMissionEventHandler ["Draw3D", {
    private _veh = cursorObject;

    if (isNull _veh || {_veh isKindOf "CAManBase"}) then {
        private _list = player nearEntities [["LandVehicle", "Air", "Ship"], 60];
        _veh = if (_list isEqualTo []) then {objNull} else {_list select 0};
    };

    if (isNull _veh) exitWith {};

    {
        _x params ["_channel", "_mem", "_offset", "", "", "_label"];

        private _pos = if (_mem isEqualTo "") then {
            _veh modelToWorldVisual _offset
        } else {
            _veh modelToWorldVisual (_veh selectionPosition [_mem, "Memory"])
        };

        drawIcon3D [
            "\a3\ui_f\data\IGUI\Cfg\Cursors\select_target_ca.paa",
            [[1, 0.5, 0, 1], [1, 0.1, 0.1, 1]] select _channel,
            _pos, 0.6, 0.6, 0, _label, 2, 0.035
        ];
    } forEach ([_veh] call RTI_fnc_spotResolve);
}];

systemChat "[RTI] Sicak nokta isaretleri acik (kapatmak: [false] call RTI_fnc_spotDebug).";
