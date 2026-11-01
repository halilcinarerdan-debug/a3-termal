/*
    Fonksiyon: RTI_fnc_sensorRefresh
    Çalışma yeri: İstemci (başlangıçta, bir ayar değişince ve ortam güncellenince)

    Termal etkinse sensör değerlerini (RTI_fnc_sensorParams: hazır ayar / sürgüler + ortam)
    PP efektlerine uygular; efektler ilk kullanımda oluşturulur. Etkin değilse hiçbir şey yapmaz.

    Üç PP efekti (öncelikler TAC NVG modülünün 7100-7130 aralığıyla çakışmaz):
      ColorCorrections : parlaklık + kontrast + siyah seviyesi (ofset)
      FilmGrain        : sensör gürültüsü
      DynamicBlur      : yumuşatma (ince çimen desenini ve keskin kenarları yutar)

    Parametreler: yok
    Dönüş: yok
*/

if !(missionNamespace getVariable ["RTI_sensor_active", false]) exitWith {};

// Öncelik doluysa bir sonrakini dene. Başarısızlıkta -1 döner.
private _create = {
    params ["_name", "_priority"];

    private _handle = -1;
    for "_i" from 0 to 20 do {
        _handle = ppEffectCreate [_name, _priority + _i];
        if (_handle >= 0) exitWith {};
    };

    // PP efektleri gece görüşü (NVG/termal) açıkken varsayılan olarak çizilmeyebilir;
    // ppEffectForceInNVG bunu zorlar (BI wiki ppEffectAdjust "See also"). Termalde gerekli olup
    // olmadığı oyunda doğrulanmadı; zararsızdır çünkü efektler yalnızca termalde yaşar.
    if (_handle >= 0) then {_handle ppEffectForceInNVG true};

    _handle
};

{
    _x params ["_var", "_name", "_priority"];

    if ((missionNamespace getVariable [_var, -1]) < 0) then {
        missionNamespace setVariable [_var, [_name, _priority] call _create];
    };
} forEach [
    ["RTI_pp_color", "ColorCorrections", 7210],
    ["RTI_pp_grain", "FilmGrain", 7240],
    ["RTI_pp_blur", "DynamicBlur", 7270]
];

private _color = missionNamespace getVariable ["RTI_pp_color", -1];
private _grain = missionNamespace getVariable ["RTI_pp_grain", -1];
private _blur = missionNamespace getVariable ["RTI_pp_blur", -1];

private _params = call RTI_fnc_sensorParams;
_params params ["_brightness", "_contrast", "_offset", "_noise", "_blurAmount"];

// [parlaklık, kontrast, ofset (siyah seviyesi), karışım rengi, renklendirme, kanal ağırlıkları]
if (_color >= 0) then {
    _color ppEffectEnable true;
    _color ppEffectAdjust [_brightness, _contrast, _offset, [0, 0, 0, 0], [1, 1, 1, 0], [0.299, 0.587, 0.114, 0]];
    _color ppEffectCommit 0.15;
};

// [yoğunluk, keskinlik, tane boyutu, parlaklık etkisi 0, parlaklık etkisi 1, tek renk]
if (_grain >= 0) then {
    _grain ppEffectEnable (_noise > 0);
    _grain ppEffectAdjust [_noise, 1.5, 2.5, 1, 1, true];
    _grain ppEffectCommit 0.15;
};

if (_blur >= 0) then {
    _blur ppEffectEnable (_blurAmount > 0);
    _blur ppEffectAdjust [_blurAmount];
    _blur ppEffectCommit 0.15;
};

if (RTI_core_debug) then {
    diag_log format ["[RTI][SENSOR] parlaklik %1 | kontrast %2 | ofset %3 | gurultu %4 | bulaniklik %5 | env %6",
        _brightness toFixed 2, _contrast toFixed 2, _offset toFixed 2, _noise toFixed 2, _blurAmount toFixed 2,
        missionNamespace getVariable ["RTI_env_k", []]];
};
