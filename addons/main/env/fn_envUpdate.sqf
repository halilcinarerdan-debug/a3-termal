/*
    Fonksiyon: RTI_fnc_envUpdate
    Çalışma yeri: İstemci

    Ortam modelini hesaplar ve RTI_env_k = [kontrastK, bulanıklıkK, gürültüK, güneş, sıcaklık°C]
    değişkenine yazar. En çok 20 sn'de bir çalışır (zorlanmadıkça).

    Fizik özeti (basit):
      - İnsan yüzeyi ~33 °C. Hava soğudukça sıcak-soğuk farkı büyür, kontrast artar; 33 °C'ye yaklaşınca
        sıfırlanır (kontrastK = 0.55 + 0.55 * fark, fark = (33 - T) / 25, 0..1.2).
      - Güneş yüklemesi: gündüz zemin ve cisimler ısınır, hedefle arasındaki fark kapanır (kontrast
        en çok %35 düşer). Bulutluluk güneş etkisini azaltır.
      - Sis ve yağmur kontrastı düşürür, bulanıklığı ve gürültüyü artırır.
    Sapma "Ortam etkisi şiddeti" ile ölçeklenir.

    Çıktının kullanıcıları: RTI_fnc_sensorParams (kontrast/bulanıklık/gürültü), RTI_fnc_vehViewTick
    (güneş -> park halindeki araç gövdesi).

    Parametreler:
        0: BOOL - true ise 20 sn sınırını yok say (varsayılan false)

    Dönüş: yok
*/

params [["_force", false, [false]]];

if (!_force && {(diag_tickTime - (missionNamespace getVariable ["RTI_env_lastT", -999])) < 20}) exitWith {};

RTI_env_lastT = diag_tickTime;

private _temp = call RTI_fnc_envTemperature;
private _strength = RTI_env_strength;

private _solar = ((sunOrMoon max 0) min 1) * (1 - (0.6 * overcast));
private _delta = (((33 - _temp) / 25) max 0) min 1.2;

private _contrastK = (0.55 + (0.55 * _delta)) * (1 - (0.35 * _solar));
_contrastK = _contrastK * (1 - (0.4 * fog) - (0.25 * rain));
_contrastK = (_contrastK max 0.4) min 1.3;

private _blurK = 1 + (1.2 * fog) + (0.6 * rain) + (0.4 * ((1 - _contrastK) max 0));
private _noiseK = 1 + (0.6 * rain) + (0.4 * fog);

// Sapmayı şiddetle ölçekle (1 = hesaplanan).
RTI_env_k = [
    1 + ((_contrastK - 1) * _strength),
    1 + ((_blurK - 1) * _strength),
    1 + ((_noiseK - 1) * _strength),
    _solar,
    _temp
];

if (RTI_core_debug) then {
    diag_log format [
        "[RTI][ENV] sicaklik %1 C | gunes %2 | sis %3 yagmur %4 bulut %5 | kontrastK %6 bulaniklikK %7 gurultuK %8",
        _temp toFixed 1, _solar toFixed 2, fog toFixed 2, rain toFixed 2, overcast toFixed 2,
        (RTI_env_k select 0) toFixed 2, (RTI_env_k select 1) toFixed 2, (RTI_env_k select 2) toFixed 2
    ];
};
