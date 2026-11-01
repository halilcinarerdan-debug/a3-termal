/*
    Fonksiyon: RTI_fnc_ppLadder
    Çalışma yeri: İstemci (debug konsolu, Local Exec:  ["offset"] call RTI_fnc_ppLadder;)

    KALİBRASYON MERDİVENİ: bir post-process parametresini adım adım değiştirir ve her adımda sohbete yazar.
    Neden: ColorCorrections kontrast / ofset matematiğinin gerçekte nasıl davrandığı belgelenmemiş; Agresif
    hazır ayarı (kontrast 2.2, ofset -0.30) ekranı tamamen kararttı. Tahmin yerine ÖLÇÜYORUZ.

    Termal görüntüye (Zeus, optik, araç nişangahı) bakarken, çimen ve bir hedef (asker/tank) görünürken çalıştır.
    Mod: tüm RTI efektleri geçici olarak durdurulur; yalnızca denenen parametre değişir; sonunda geri açılır.

    Modlar (her adım varsayılan 5 sn):
        "offset"   : ColorCorrections ofset   0 -> -1.0        (siyah seviyesi)
        "contrast" : ColorCorrections kontrast 1 -> 4
        "gain"     : ColorCorrections parlaklık çarpanı 1 -> 4
        "gainlow"  : parlaklık çarpanı 1 -> 0.1   (parlak/uzak bölgeler tavanı aşıp bembeyaz oluyorsa: indirir)
        "contrastlow": kontrast 1 -> 0.1          (aynı amaç)
        "blur"     : DynamicBlur 0 -> 3
        "grain"    : FilmGrain yoğunluğu 0 -> 0.8

    Bana yaz: her mod için (a) çimenin kaybolmaya başladığı adım, (b) tankın/askerin bozulmaya başladığı adım,
    (c) ekranın tamamen karardığı adım. Adım numarası ve değeri sohbette ve RPT'de ([RTI][LADDER]) yazar.

    Parametreler:
        0: STRING - mod (varsayılan "offset")
        1: NUMBER - adım süresi, sn (varsayılan 5)

    Dönüş: yok
*/

params [["_mode", "offset", [""]], ["_stepSeconds", 5, [0]]];

private _steps = switch (_mode) do {
    case "offset":   {[0, -0.05, -0.1, -0.2, -0.3, -0.45, -0.6, -0.8, -1.0]};
    case "gainlow":  {[1, 0.8, 0.6, 0.45, 0.3, 0.2, 0.1]};
    case "contrastlow": {[1, 0.8, 0.6, 0.45, 0.3, 0.2, 0.1]};
    case "contrast": {[1, 1.2, 1.5, 2, 2.5, 3, 4]};
    case "gain":     {[1, 1.3, 1.6, 2, 3, 4]};
    case "blur":     {[0, 0.2, 0.5, 1, 2, 3]};
    case "grain":    {[0, 0.05, 0.1, 0.2, 0.4, 0.8]};
    default {[]};
};

if (_steps isEqualTo []) exitWith {
    systemChat "[RTI] ppLadder modlari: offset, contrast, gain, blur, grain. Ornek: [""offset""] call RTI_fnc_ppLadder;";
};

if (missionNamespace getVariable ["RTI_ladder_running", false]) exitWith {
    systemChat "[RTI] Kalibrasyon zaten calisiyor; bitmesini bekle.";
};

RTI_ladder_running = true;

// RTI efektleri ve görüş modu olayları karışmasın: zorlamayı aç (olayları susturur), efektleri durdur.
RTI_sensor_forced = true;
call RTI_fnc_sensorStop;

[_mode, _steps, _stepSeconds] spawn {
    params ["_mode", "_steps", "_stepSeconds"];

    private _type = switch (_mode) do {
        case "blur": {"DynamicBlur"};
        case "grain": {"FilmGrain"};
        default {"ColorCorrections"};
    };

    private _handle = -1;
    for "_i" from 0 to 20 do {
        _handle = ppEffectCreate [_type, 7500 + _i];
        if (_handle >= 0) exitWith {};
    };

    if (_handle < 0) exitWith {
        systemChat "[RTI] Kalibrasyon: PP olusturulamadi (Video'da Post Process kapali olabilir).";
        RTI_ladder_running = false;
        RTI_sensor_forced = false;
    };

    _handle ppEffectForceInNVG true;
    _handle ppEffectEnable true;

    private _weights = [0.299, 0.587, 0.114, 0];
    private _count = count _steps;

    {
        private _value = _x;

        switch (_mode) do {
            case "offset":   {_handle ppEffectAdjust [1, 1, _value, [0, 0, 0, 0], [1, 1, 1, 0], _weights]};
            case "contrast": {_handle ppEffectAdjust [1, _value, 0, [0, 0, 0, 0], [1, 1, 1, 0], _weights]};
            case "gain":     {_handle ppEffectAdjust [_value, 1, 0, [0, 0, 0, 0], [1, 1, 1, 0], _weights]};
            case "gainlow":  {_handle ppEffectAdjust [_value, 1, 0, [0, 0, 0, 0], [1, 1, 1, 0], _weights]};
            case "contrastlow": {_handle ppEffectAdjust [1, _value, 0, [0, 0, 0, 0], [1, 1, 1, 0], _weights]};
            case "blur":     {_handle ppEffectAdjust [_value]};
            case "grain":    {_handle ppEffectAdjust [_value, 1.5, 2.5, 1, 1, true]};
        };

        _handle ppEffectCommit 0.3;

        private _msg = format ["KALIBRASYON %1: adim %2/%3 -> deger %4", _mode, _forEachIndex + 1, _count, _value];
        systemChat ("[RTI] " + _msg);
        diag_log ("[RTI][LADDER] " + _msg);

        uiSleep _stepSeconds;
    } forEach _steps;

    _handle ppEffectEnable false;
    ppEffectDestroy _handle;

    systemChat format ["[RTI] Kalibrasyon (%1) bitti. Cimen kaybolma / hedef bozulma / tam kararma adimlarini soyle.", _mode];

    RTI_ladder_running = false;
    RTI_sensor_forced = false;
};
