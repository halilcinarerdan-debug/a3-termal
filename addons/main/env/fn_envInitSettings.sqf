/*
    Fonksiyon: RTI_fnc_envInitSettings
    Çalışma yeri: TÜM makineler (XEH_preInit.sqf çağırır)

    Ortam modeli ayarları (hava sıcaklığı, mevsim, saat, sis, yağmur). Hepsi kişisel tercih.

    Geri çağrılar yalnızca bir "kirli" bayrağı koyar ve (termal açıksa) yeniler; ayarlar sırayla
    kaydedildiği için geri çağrı içinde henüz tanımlanmamış başka ayarları okumak güvenli değildir.

    Parametreler: yok
    Dönüş: yok
*/

private _category = ["RTI - Gerçekçi Termal", "Ortam (hava / mevsim)"];

RTI_env_k = [1, 1, 1, 0, 15];

private _apply = {
    RTI_env_lastT = -999;

    if (missionNamespace getVariable ["RTI_sensor_active", false]) then {
        [true] call RTI_fnc_envUpdate;
        call RTI_fnc_sensorRefresh;
    };
};

[
    "RTI_env_enabled",
    "CHECKBOX",
    ["Ortam modeli aktif", "Hava sıcaklığı, mevsim, gün saati, bulutluluk, sis ve yağmura göre termal kontrastı, bulanıklığı ve gürültüyü ayarlar: sıcak güneşli günde kontrast düşer (nesneler zeminle eşitlenir), soğuk açık gecede artar, sis ve yağmurda bulanıklaşır."],
    _category,
    true,
    false,
    _apply
] call CBA_settings_fnc_init;

[
    "RTI_env_strength",
    "SLIDER",
    ["Ortam etkisi şiddeti", "1 = hesaplanan değer. 0 = etki yok, 1.5 = abartılı."],
    _category,
    [0, 1.5, 1, 2],
    false,
    _apply
] call CBA_settings_fnc_init;

[
    "RTI_env_useManual",
    "CHECKBOX",
    ["Hava sıcaklığını elle ver (test)", "Açıkken aşağıdaki değer kullanılır; kapalıyken ACE Weather varsa onun sıcaklığı, yoksa tarih / enlem / saatten tahmin."],
    _category,
    false,
    false,
    _apply
] call CBA_settings_fnc_init;

[
    "RTI_env_manualTemp",
    "SLIDER",
    ["Elle hava sıcaklığı (°C)", "Yalnızca yukarıdaki kutu açıkken. A/B testinde sıcak gün (35) ile soğuk gece (-5) arasındaki farkı görmek için."],
    _category,
    [-30, 50, 15, 0],
    false,
    _apply
] call CBA_settings_fnc_init;

[
    "RTI_env_hemisphere",
    "LIST",
    ["Yarıküre (mevsim için)", "Arma terrain config'indeki enlem işareti güvenilir değil; mevsim tahmini için yarıküreyi sen seç."],
    _category,
    [[0, 1], ["Kuzey", "Güney"], 0],
    false,
    _apply
] call CBA_settings_fnc_init;

[
    "RTI_env_vehSolar",
    "SLIDER",
    ["Güneş yüklemesi (araç)", "Gündüz güneşte duran araçların gövdesi motor kapalıyken de bu oranda ısınmış görünür; böylece araç zeminle eşitlenir (düşük kontrast). 0 = kapalı."],
    _category,
    [0, 1, 0.3, 2],
    false
] call CBA_settings_fnc_init;
