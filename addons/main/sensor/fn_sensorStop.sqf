/*
    Fonksiyon: RTI_fnc_sensorStop
    Çalışma yeri: İstemci

    Sensör ekran efektlerini ve flaş efektini kapatıp yok eder.
    Etkin değilse zararsızdır.

    Parametreler: yok
    Dönüş: yok
*/

missionNamespace setVariable ["RTI_sensor_active", false];

{
    private _handle = missionNamespace getVariable [_x, -1];

    if (_handle >= 0) then {
        _handle ppEffectEnable false;
        ppEffectDestroy _handle;
        missionNamespace setVariable [_x, -1];
    };
} forEach ["RTI_pp_color", "RTI_pp_grain", "RTI_pp_blur"];

call RTI_fnc_flashClear;
