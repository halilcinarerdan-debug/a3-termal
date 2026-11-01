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
      1 Agresif : 2.2 / -0.30  (çimen ~0.47 gri -> ~0.13; tank ~0.85 -> ~0.97)
      4 Siyah   : 2.6 / -0.45  (çimen siyaha gömülür; zayıf ısı kaynakları da siyaha gider)
    Hesap, ColorCorrections kontrastının 0.5 gri etrafında döndüğü varsayımına dayanır (doğrulanmadı);
    oyunda sürgülerle ayarlanır.

    Parametreler: yok
    Dönüş: ARRAY - [parlaklık, kontrast, ofset, gürültü, bulanıklık]
*/

private _base = switch (RTI_sensor_preset) do {
    case 1: {[1.0, 2.2, -0.30, 0.10, 0.6]};
    case 2: {[1.0, 1.35, -0.08, 0.10, 0.4]};
    case 3: {[0.95, 0.9, 0, 0.08, 0.25]};
    case 4: {[1.0, 2.6, -0.45, 0.05, 0.45]};
    default {[RTI_sensor_brightness, RTI_sensor_contrast, RTI_sensor_blackLevel, RTI_sensor_noise, RTI_sensor_blur]};
};

_base params ["_brightness", "_contrast", "_offset", "_noise", "_blur"];

if (RTI_env_enabled) then {
    private _env = missionNamespace getVariable ["RTI_env_k", [1, 1, 1, 0, 15]];
    _env params ["_contrastK", "_blurK", "_noiseK"];

    // Kontrastın 1'den sapması ortama göre ölçeklenir (sıcak güneşli gün: düşer; soğuk gece: artar).
    _contrast = 1 + ((_contrast - 1) * _contrastK);

    // Siyah seviyesi çimen ve zemin gürültüsünü bastıran asıl ayardır; sıcak/güneşli günde bile tamamen
    // zayıflamasın diye yalnızca kısmen ölçeklenir (contrastK 0.4 iken ofset %70'i kalır).
    _offset = _offset * (0.5 + (0.5 * _contrastK));
    _blur = _blur * _blurK;
    _noise = _noise * _noiseK;
};

[_brightness, _contrast, _offset, _noise, _blur]
