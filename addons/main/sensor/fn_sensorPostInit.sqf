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

// Canlı ayar tuşları (Ctrl + Alt + ...): termale bakarken parlaklık / kontrast / siyah seviyesini değiştir, End ile değerleri panoya al.
{
    _x params ["_id", "_name", "_dik", "_which", "_dir"];

    [
        "RTI - Gerçekçi Termal",
        _id,
        [_name, "Canlı ayar: termale bakarken değiştir, End ile değerleri panoya kopyala ve bana yapıştır."],
        compile format ["[""%1"", %2] call RTI_fnc_liveAdjust; true", _which, _dir],
        {},
        [_dik, [false, true, true]]
    ] call CBA_fnc_addKeybind;
} forEach [
    ["RTI_liveBrightUp",   "Canlı: parlaklık +10%",          200, "b", 1],
    ["RTI_liveBrightDown", "Canlı: parlaklık -10%",          208, "b", -1],
    ["RTI_liveContrUp",    "Canlı: kontrast +10%",           205, "c", 1],
    ["RTI_liveContrDown",  "Canlı: kontrast -10%",           203, "c", -1],
    ["RTI_liveBlackUp",    "Canlı: siyah seviyesi +0.03",    201, "o", 1],
    ["RTI_liveBlackDown",  "Canlı: siyah seviyesi -0.03",    209, "o", -1],
    ["RTI_liveReport",     "Canlı: değerleri yaz / panoya kopyala", 207, "report", 0],
    ["RTI_liveOff",        "Canlı: kapat (hazır ayara dön)", 199, "off", 0]
];
