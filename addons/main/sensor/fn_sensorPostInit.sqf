/*
    Fonksiyon: RTI_fnc_sensorPostInit
    Çalışma yeri: İstemci (XEH_postInit.sqf çağırır)

    CBA oyuncu olayları:
      "visionMode": termal (2) açılınca / kapanınca efekt zincirini kurar / söker.
                    Sürekli döngü yoktur; efektler yalnızca termal açıkken yaşar.
      "unit":       birim değişince (respawn) eski bedenin termal bayrağını temizler.

    Parametreler: yok
    Dönüş: yok
*/

// applyInitial = true: oyun termal açıkken başladıysa da mevcut durum işlenir.
["visionMode", {
    _this call RTI_fnc_sensorOnVisionMode;
}, true] call CBA_fnc_addPlayerEventHandler;

["unit", {
    params ["", "_oldUnit"];

    call RTI_fnc_sensorStop;

    if (!isNull _oldUnit) then {
        _oldUnit setVariable ["RTI_tiActive", false, true];
    };
}] call CBA_fnc_addPlayerEventHandler;

// Zeus kamerasında "N" ile açılan termal oyuncu biriminin görüş modunu değiştirmez; RTI efektleri bu yüzden kendiliğinden
// devreye girmez. Zeus (ve herhangi bir test) için tek tuşla zorla aç / kapat. Varsayılan: Shift + Ctrl + T
// (CBA > Tuş Atamaları > "RTI - Gerçekçi Termal"). Tuş Zeus ekranında çalışmazsa konsol: [true] call RTI_fnc_sensorForce;
[
    "RTI - Gerçekçi Termal",
    "RTI_sensorForceToggle",
    ["Sensör efektlerini zorla aç / kapat (Zeus, test)", "Görüş moduna bakmadan RTI efektlerini açar, tekrar basınca kapatır. Zeus kamerasında termali N ile açtıktan sonra kullan."],
    {
        [!(missionNamespace getVariable ["RTI_sensor_forced", false])] call RTI_fnc_sensorForce;
        true
    },
    {},
    [20, [true, true, false]]
] call CBA_fnc_addKeybind;
