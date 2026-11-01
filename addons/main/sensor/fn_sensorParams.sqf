/*
    Fonksiyon: RTI_fnc_sensorParams
    Çalışma yeri: İstemci (saf hesap)

    Ekrana uygulanacak sensör değerlerini üretir:
      1) Hazır ayar ("Agresif" / "Dengeli" / "Yumuşak") ya da elle sürgüler
      2) Ortam modeli çarpanları (hava sıcaklığı / mevsim / saat / sis / yağmur), açıksa

    Mantık (neden "agresif"): vanilla termalde zemin orta gri, çimen yamaları siyah, asker gövdesi
    zemine yakın gri olduğu için uzaktan seçilmiyor. Kontrastı artırıp SİYAH SEVİYESİNİ düşürmek
    (negatif ofset) zemini ve çimen yamalarını siyaha yaklaştırır, sıcak cisimleri beyazda bırakır;
    böylece arka plan dokusu söner, hedef öne çıkar. Bulanıklık ince çimen desenini yutar.

    Hazır ayar değerleri: [parlaklık, kontrast, siyahSeviyesi(ofset), gürültü, bulanıklık]

    Parametreler: yok
    Dönüş: ARRAY - [parlaklık, kontrast, ofset, gürültü, bulanıklık]
*/

private _base = switch (RTI_sensor_preset) do {
    case 1: {[1.0, 1.9, -0.18, 0.14, 0.7]};
    case 2: {[1.0, 1.35, -0.08, 0.10, 0.4]};
    case 3: {[0.95, 0.9, 0, 0.08, 0.25]};
    default {[RTI_sensor_brightness, RTI_sensor_contrast, RTI_sensor_blackLevel, RTI_sensor_noise, RTI_sensor_blur]};
};

_base params ["_brightness", "_contrast", "_offset", "_noise", "_blur"];

if (RTI_env_enabled) then {
    private _env = missionNamespace getVariable ["RTI_env_k", [1, 1, 1, 0, 15]];
    _env params ["_contrastK", "_blurK", "_noiseK"];

    // Kontrastın 1'den sapması ortama göre ölçeklenir (sıcak güneşli gün: düşer; soğuk gece: artar).
    _contrast = 1 + ((_contrast - 1) * _contrastK);
    _offset = _offset * _contrastK;
    _blur = _blur * _blurK;
    _noise = _noise * _noiseK;
};

[_brightness, _contrast, _offset, _noise, _blur]
