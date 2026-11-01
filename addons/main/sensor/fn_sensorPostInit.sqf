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
