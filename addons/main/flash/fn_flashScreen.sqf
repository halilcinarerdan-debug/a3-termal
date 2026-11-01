/*
    Fonksiyon: RTI_fnc_flashScreen
    Çalışma yeri: İstemci

    Kendi atışımda ekran flaşı: ColorCorrections ile görüntüyü anında "sıcak" yöne
    (beyaz sıcak: beyaza, siyah sıcak: siyaha) karıştırır, sonra ayarlanan sürede normale
    döndürür. Gerçek termal nişangahlarda namlu parlaması sensörü kısa süre doyurur.
    Dünya nesnesi gerektirmez; kendi silahımızda flaşın termalde görünmesini sağlayan
    yöntem budur.

    Parametreler:
        0: NUMBER - şiddet 0..1 (RTI_fnc_flashIntensity)

    Dönüş: yok
*/

params [["_intensity", 0.5, [0]]];

// PiP / hariç tutulan optikte ana ekran normal görüntüdür: efekt uygulanmaz.
if !(missionNamespace getVariable ["RTI_ppAllowed", true]) exitWith {};

private _handle = missionNamespace getVariable ["RTI_pp_flash", -1];

if (_handle < 0) then {
    for "_i" from 0 to 20 do {
        _handle = ppEffectCreate ["ColorCorrections", 7300 + _i];
        if (_handle >= 0) exitWith {};
    };
    missionNamespace setVariable ["RTI_pp_flash", _handle];
};

if (_handle < 0) exitWith {};

private _alpha = ((_intensity * RTI_flash_ownGain) * 0.45) min 0.9;
// Beyaz sıcak (0): sıcak = parlak -> 1 (beyaz). Siyah sıcak (1): sıcak = koyu -> 0 (siyah).
private _tone = parseNumber (RTI_sensor_polarity isNotEqualTo 1);

_handle ppEffectEnable true;
_handle ppEffectAdjust [1, 1, 0, [_tone, _tone, _tone, _alpha], [1, 1, 1, 0], [0.299, 0.587, 0.114, 0]];
_handle ppEffectCommit 0;

// Art arda atışta son atış sönmeyi devralır.
private _token = (missionNamespace getVariable ["RTI_flash_token", 0]) + 1;
missionNamespace setVariable ["RTI_flash_token", _token];

[{
    params ["_handle", "_token", "_tone"];

    if (_token != (missionNamespace getVariable ["RTI_flash_token", 0])) exitWith {};
    if (_handle != (missionNamespace getVariable ["RTI_pp_flash", -1])) exitWith {};

    _handle ppEffectAdjust [1, 1, 0, [_tone, _tone, _tone, 0], [1, 1, 1, 0], [0.299, 0.587, 0.114, 0]];
    _handle ppEffectCommit RTI_flash_ownDecay;
}, [_handle, _token, _tone], 0.03] call CBA_fnc_waitAndExecute;
