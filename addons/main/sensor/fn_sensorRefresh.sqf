/*
    Fonksiyon: RTI_fnc_sensorRefresh
    Çalışma yeri: İstemci (başlangıçta, bir ayar değişince ve ortam güncellenince)

    Termal etkinse sensör değerlerini (RTI_fnc_sensorParams: hazır ayar / sürgüler + ortam)
    PP efektlerine uygular; efektler ilk kullanımda oluşturulur. Etkin değilse hiçbir şey yapmaz.

    Üç PP efekti (öncelikler TAC NVG modülünün 7100-7130 aralığıyla çakışmaz):
      ColorCorrections : parlaklık + kontrast + siyah seviyesi (ofset); ikinci bir ColorCorrections zemin tabanı için
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
    ["RTI_pp_floor", "ColorCorrections", 7225],
    ["RTI_pp_grain", "FilmGrain", 7240],
    ["RTI_pp_blur", "DynamicBlur", 7270]
];

private _color = missionNamespace getVariable ["RTI_pp_color", -1];
private _floorH = missionNamespace getVariable ["RTI_pp_floor", -1];
private _grain = missionNamespace getVariable ["RTI_pp_grain", -1];
private _blur = missionNamespace getVariable ["RTI_pp_blur", -1];

// Efekt oluşturulamadıysa (ppEffectCreate -1: Video'da Post Process kapalı ya da öncelikler dolu) bir kez uyar.
if ((_color < 0 || {_floorH < 0} || {_grain < 0} || {_blur < 0}) && {!(missionNamespace getVariable ["RTI_pp_warned", false])}) then {
    RTI_pp_warned = true;
    diag_log format ["[RTI][SENSOR] PP efekti olusturulamadi | renk %1 taban %2 gurultu %3 bulaniklik %4 (-1 = basarisiz)", _color, _floorH, _grain, _blur];
    systemChat "[RTI] Uyari: PP efekti olusturulamadi (Video ayarinda Post Process kapali olabilir). RPT: [RTI][SENSOR]";
};

private _params = call RTI_fnc_sensorParams;
_params params ["_brightness", "_contrast", "_offset", "_noise", "_blurAmount", "_floorLevel"];

// Geçiş süresi: yüzey / bakış değişimi yumuşak (0.8 sn), ayar değişimi hızlı (0.15 sn).
private _commit = missionNamespace getVariable ["RTI_sensor_commit", 0.15];

// [parlaklık, kontrast, ofset (siyah seviyesi), karışım rengi, renklendirme, kanal ağırlıkları]
if (_color >= 0) then {
    _color ppEffectEnable true;
    _color ppEffectAdjust [_brightness, _contrast, _offset, [0, 0, 0, 0], [1, 1, 1, 0], [0.299, 0.587, 0.114, 0]];
    _color ppEffectCommit _commit;
};

// Zemin tabanı: kontrast ve ofsetten SONRA (öncelik 7225 > 7210) çalışan ayrı ColorCorrections. Kontrast 1, ofset 0, yalnızca
// gri (0.5) ile karışım: siyah -> 0.5 * alfa, beyaz -> 1 - 0.5 * alfa. Karışım sırası belirsizliğinden etkilenmesin diye ayrı efekt.
if (_floorH >= 0) then {
    private _alpha = (2 * _floorLevel) min 0.6;

    _floorH ppEffectEnable (_alpha > 0);
    _floorH ppEffectAdjust [1, 1, 0, [0.5, 0.5, 0.5, _alpha], [1, 1, 1, 0], [0.299, 0.587, 0.114, 0]];
    _floorH ppEffectCommit _commit;
};

// [yoğunluk, keskinlik, tane boyutu, parlaklık etkisi 0, parlaklık etkisi 1, tek renk]
if (_grain >= 0) then {
    _grain ppEffectEnable (_noise > 0);
    _grain ppEffectAdjust [_noise, 1.5, 2.5, 1, 1, true];
    _grain ppEffectCommit _commit;
};

if (_blur >= 0) then {
    _blur ppEffectEnable (_blurAmount > 0);
    _blur ppEffectAdjust [_blurAmount];
    _blur ppEffectCommit _commit;
};

if (RTI_core_debug) then {
    diag_log format ["[RTI][SENSOR] parlaklik %1 | kontrast %2 | ofset %3 | gurultu %4 | bulaniklik %5 | taban %6 | env %7 | yuzey %8",
        _brightness toFixed 2, _contrast toFixed 2, _offset toFixed 2, _noise toFixed 2, _blurAmount toFixed 2, _floorLevel toFixed 2,
        missionNamespace getVariable ["RTI_env_k", []], missionNamespace getVariable ["RTI_surf_k", []]];
};
