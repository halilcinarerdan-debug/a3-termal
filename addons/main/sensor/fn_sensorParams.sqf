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

    Hazır ayar değerleri: [parlaklık, kontrast, siyahSeviyesi(ofset), gürültü, bulanıklık, zeminTabanı]
      1 Agresif : 2.2 / -0.30  (çimen ~0.47 gri -> ~0.13; tank ~0.85 -> ~0.97)
      4 Siyah   : 2.6 / -0.45  (çimen siyaha gömülür; zayıf ısı kaynakları da siyaha gider)
    Hesap, ColorCorrections kontrastının 0.5 gri etrafında döndüğü varsayımına dayanır (doğrulanmadı);
    oyunda sürgülerle ayarlanır.

    Parametreler: yok
    Dönüş: ARRAY - [parlaklık, kontrast, ofset, gürültü, bulanıklık, zeminTabanı]
*/

// Tüm okumalar varsayılanlı: tanımsız bir ayar değişkeni (ör. eski/yarım yüklenmiş ayarlar) hata verip efekti öldürmesin.
private _preset = missionNamespace getVariable ["RTI_sensor_preset", 5];

private _base = switch (_preset) do {
    // Gozlem: kontrast > 1 bu ortamda goruntunun cogunu karartiyor (kontrast 0.85 iken goruntu aydinlikti); 1, 2, 4 kalibrasyon bekliyor.
    // 1 ve 4: oyunda ekranı TAMAMEN KARARTTI (ColorCorrections matematiği 0.5 pivot varsayımına uymuyor); kalibrasyon (RTI_fnc_ppLadder) bekliyor.
    case 1: {[1.0, 2.2, -0.30, 0.10, 0, 0.10]};
    case 2: {[1.0, 1.35, -0.08, 0.10, 0, 0.04]};
    case 3: {[0.95, 0.9, 0, 0.08, 0, 0]};
    case 4: {[1.0, 2.6, -0.45, 0.05, 0, 0.07]};
    // GOZLEM: DynamicBlur (bulaniklik) EKRANI KARARTIYOR (katman acilinca goruntu siyah; kapaliyken normal). Bu yuzden tum hazir ayarlarda
    // bulaniklik 0 (deger 0 ise efekt devre disi kalir). Bulaniklik yalnizca Elle'de ve acikca verilen degerle kullanilir.
    // 5 Notr: parlaklik/kontrast/ofset OLDUGU GIBI (vanilla ile ayni ton), yalnizca hafif bulaniklik ve gurultu. Karartmaz.
    case 5: {[1.0, 1.0, 0, 0.06, 0, 0]};
    // 6 Gozetleme (AC-130 / uav gozetleme kamerasi gorunumu): sahne DAR BIR GRI BANTA sikisir (dusuk kontrast + dusuk parlaklik carpani),
    // yalniz isi kaynaklari (arac, patlama) tavana vurup beyazlar. BASLANGIC TAHMINI: gozlem (kontrast < 1 aydinlatir, parlaklik < 1 uzak beyazi indirir).
    // Cok karanlikssa parlakligi artir; cok soluk/silikse kontrasti daha da dusur.
    case 6: {[0.6, 0.55, 0, 0.05, 0, 0]};
    default {[
        missionNamespace getVariable ["RTI_sensor_brightness", 1.0],
        missionNamespace getVariable ["RTI_sensor_contrast", 1.7],
        missionNamespace getVariable ["RTI_sensor_blackLevel", -0.12],
        missionNamespace getVariable ["RTI_sensor_noise", 0.12],
        missionNamespace getVariable ["RTI_sensor_blur", 0],
        missionNamespace getVariable ["RTI_sensor_floor", 0.10]
    ]};
};

_base params ["_brightness", "_contrast", "_offset", "_noise", "_blur", "_floor"];

if (missionNamespace getVariable ["RTI_env_enabled", false]) then {
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

// Canlı ayar (RTI_fnc_liveAdjust, tuşlarla): açıkken parlaklık / kontrast / siyah seviyesi canlı değerlerden gelir (ortam çarpanı yok sayılır).
if (missionNamespace getVariable ["RTI_live_enabled", false]) then {
    private _live = missionNamespace getVariable ["RTI_live_vals", [1, 1, 0]];

    _brightness = _live select 0;
    _contrast = _live select 1;
    _offset = _live select 2;
};

// Zemin tabanı: kontrast siyaha gömdükten SONRA, ayrı bir katmanla siyahı biraz kaldırır; çimen ve toprak eşit koyu griye
// oturur (çimen kaybolur, toprak simsiyah olmaz). Bakılan yüzeye (RTI_fnc_surfaceUpdate) ve bakış yönüne
// (gökyüzü siyah kalsın) göre ölçeklenir.
private _surf = missionNamespace getVariable ["RTI_surf_k", [1, 1, "", ""]];
_floor = (((_floor * (_surf select 0)) * (_surf select 1)) max 0) min 0.3;

[_brightness, _contrast, _offset, _noise, _blur, _floor]
