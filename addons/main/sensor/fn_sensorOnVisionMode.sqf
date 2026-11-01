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

// Zorlama açıkken (RTI_fnc_sensorForce: test / Zeus kamerası) görüş modu olayları efekte dokunmaz.
if (missionNamespace getVariable ["RTI_sensor_forced", false]) exitWith {};

if (isNull _unit) exitWith {
    call RTI_fnc_sensorStop;
};

private _active = _visionMode == 2;

// Bayrak yalnızca değişimde yayınlanır (seyrek olay).
if ((_unit getVariable ["RTI_tiActive", false]) isNotEqualTo _active) then {
    _unit setVariable ["RTI_tiActive", _active, true];
};

// A3TI yüklüyse (kendi görüntü zinciri ve poz kontrolü var) sensör efektlerimiz varsayılan olarak uygulanmaz: çifte işleme / çakışma olmasın.
// Ayar: "A3TI yüklüyken sensör efektleri". Zorlama (RTI_fnc_sensorForce) bundan etkilenmez.
if (_active && {missionNamespace getVariable ["RTI_cap_a3ti", false]} && {!(missionNamespace getVariable ["RTI_sensor_withA3TI", false])}) exitWith {
    call RTI_fnc_sensorStop;
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
