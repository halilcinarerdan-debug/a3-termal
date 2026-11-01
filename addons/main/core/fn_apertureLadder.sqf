/*
    Fonksiyon: RTI_fnc_apertureLadder
    Çalışma yeri: İstemci (debug konsolu, Local Exec:  call RTI_fnc_apertureLadder;)

    KALİBRASYON: oyunun HDR POZUNU (kamera açıklığı, setAperture) adım adım değiştirir. Termaldeki asıl parlaklık/ton bu katmandan gelir,
    post-process'in altındadır; uzak bölgelerin bembeyaz olması aşırı pozlamadan olabilir.

    Adımlar (her biri 5 sn): -1 (otomatik, oyunun kendi değeri), 0.5, 1, 2, 5, 10, 20, 50, 100, 300.
    Hangi yönün parlak / karanlık olduğu belgesiz; bu yüzden ÖLÇÜYORUZ. Sonunda otomatiğe (-1) döner.
    Termal görüntüye bakarken, uzak ağaç ve zemin görünürken çalıştır. Sohbete ve RPT'ye ([RTI][APERTURE]) yazar.

    Bana yaz: (a) hangi değerlerde ekran daha parlak / daha karanlık, (b) hangi adımda uzaktaki beyaz bölge griye inip detay veriyor,
    (c) hangi adımda ekran çok karanlık. Ayrıca call RTI_fnc_diag çıktısındaki "ilgili komutlar" satırını gönder (komut imzaları orada).

    Parametreler:
        0: NUMBER - adım süresi, sn (varsayılan 5)

    Dönüş: yok
*/

params [["_stepSeconds", 5, [0]]];

if !(missionNamespace getVariable ["RTI_cap_setAperture", false]) exitWith {
    systemChat "[RTI] setAperture bu oyun surumunde yok (call RTI_fnc_diag ile komut listesine bak).";
};

if (missionNamespace getVariable ["RTI_ladder_running", false]) exitWith {
    systemChat "[RTI] Bir kalibrasyon zaten calisiyor; bitmesini bekle.";
};

RTI_ladder_running = true;

[_stepSeconds] spawn {
    params ["_stepSeconds"];

    private _steps = [-1, 0.5, 1, 2, 5, 10, 20, 50, 100, 300];

    {
        [_x] call RTI_setAperture;

        private _msg = format ["APERTURE adim %1/%2 -> deger %3 (-1 = otomatik)", _forEachIndex + 1, count _steps, _x];
        systemChat ("[RTI] " + _msg);
        diag_log ("[RTI][APERTURE] " + _msg);

        uiSleep _stepSeconds;
    } forEach _steps;

    [-1] call RTI_setAperture;
    systemChat "[RTI] Aperture kalibrasyonu bitti (otomatige donuldu). Hangi degerler parlak/karanlik, hangi adimda uzak beyaz indi? Yaz.";

    RTI_ladder_running = false;
};
