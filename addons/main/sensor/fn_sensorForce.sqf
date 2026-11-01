/*
    Fonksiyon: RTI_fnc_sensorForce
    Çalışma yeri: İstemci (debug konsolu)

    Sensör ekran efektlerini görüş moduna BAKMADAN açar / kapatır. Amaç: A/B testi ve Zeus kamerası.

    Zeus kamerasında "N" ile açılan termal, oyuncu biriminin görüş modunu değiştirmez
    (currentVisionMode oyuncu birimini sorar, kamerayı değil), bu yüzden RTI efektleri kendiliğinden
    devreye girmez. Zeus'ta ya da başka bir kamerada termal görüntüde:

        [true] call RTI_fnc_sensorForce;      // B: RTI efektleri açık
        [false] call RTI_fnc_sensorForce;     // A: vanilla'ya dön

    Zorlama açıkken görüş modu olayları efekti kapatmaz. Aynı işi CBA tuş ataması da yapar (varsayılan Shift + Ctrl + T,
    RTI_fnc_sensorPostInit).

    Parametreler:
        0: BOOL - true aç, false kapat (varsayılan true)

    Dönüş: yok
*/

params [["_on", true, [true]]];

RTI_sensor_forced = _on;

if (_on) then {
    missionNamespace setVariable ["RTI_ppAllowed", true];
    call RTI_fnc_sensorStart;
    systemChat "[RTI] Sensor efektleri ZORLA acik. Kapatmak: [false] call RTI_fnc_sensorForce";
} else {
    call RTI_fnc_sensorStop;
    systemChat "[RTI] Sensor efektleri kapali (zorlama bitti).";
};
