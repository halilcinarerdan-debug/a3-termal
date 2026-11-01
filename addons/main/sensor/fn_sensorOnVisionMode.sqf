/*
    Fonksiyon: RTI_fnc_sensorOnVisionMode
    Çalışma yeri: İstemci (CBA "visionMode" oyuncu olayı)

    1) Oyuncu nesnesine "RTI_tiActive" bayrağını yayınlar (global). Flaş modülü, atış
       olaylarını yalnızca termalde olan oyunculara göndermek için bunu okur; yani kimse
       termalde değilse ağ ve CPU maliyeti sıfırdır.
    2) Termal açıksa ve efektler izinliyse ekran efekt zincirini kurar; değilse söker.

    Parametreler:
        0: OBJECT - oyuncu birimi
        1: NUMBER - görüş modu (0 normal, 1 NVG, 2 termal)

    Dönüş: yok
*/

params ["_unit", "_visionMode"];

if (isNull _unit) exitWith {
    call RTI_fnc_sensorStop;
};

private _active = _visionMode == 2;

// Bayrak yalnızca değişimde yayınlanır (seyrek olay).
if ((_unit getVariable ["RTI_tiActive", false]) isNotEqualTo _active) then {
    _unit setVariable ["RTI_tiActive", _active, true];
};

if (_active && {RTI_sensor_enabled}) then {
    private _excluded = [_unit] call RTI_fnc_sensorExcluded;

    // Flaş ekran efekti de aynı izne bağlıdır (PiP optikte ana ekranı bozmasın).
    missionNamespace setVariable ["RTI_ppAllowed", !_excluded];

    if (_excluded) then {
        call RTI_fnc_sensorStop;
    } else {
        call RTI_fnc_sensorStart;
    };
} else {
    call RTI_fnc_sensorStop;
};
