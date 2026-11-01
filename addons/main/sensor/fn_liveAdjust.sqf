/*
    Fonksiyon: RTI_fnc_liveAdjust
    Çalışma yeri: İstemci (CBA tuş atamaları çağırır; debug konsolundan da: ["b", 1] call RTI_fnc_liveAdjust;)

    CANLI AYAR: termale bakarken parlaklık / kontrast / siyah seviyesini tuşlarla değiştirir, değişimi ANINDA görürsün.
    İlk tuşa basışta mevcut hazır ayarın (ve ortamın) değerleri başlangıç olarak alınır. Canlı mod açıkken hazır ayar ve ortam
    çarpanı yok sayılır (yalnızca bu üç değer kullanılır; taban ve gürültü hazır ayardan gelir).

    Varsayılan tuşlar (CBA > Tuş Atamaları > "RTI - Gerçekçi Termal"; hepsi Ctrl + Alt ile):
        Yukarı / Aşağı        parlaklık  +10% / -10%
        Sağ / Sol             kontrast   +10% / -10%
        PageUp / PageDown     siyah seviyesi +0.03 / -0.03
        End                   değerleri sohbete yaz + panoya kopyala  (BUNU BANA YAPIŞTIR)
        Home                  canlı modu kapat (hazır ayara dön)

    Sensör efektleri açık olmalı (termal ya da Shift+Ctrl+T).

    Parametreler:
        0: STRING - "b" (parlaklık), "c" (kontrast), "o" (siyah seviyesi), "report", "off"
        1: NUMBER - yön: 1 artır, -1 azalt (report / off için yok sayılır)

    Dönüş: yok
*/

params [["_which", "", [""]], ["_dir", 0, [0]]];

if (_which isEqualTo "off") exitWith {
    RTI_live_enabled = false;
    call RTI_fnc_sensorRefresh;
    systemChat "[RTI] Canli ayar KAPALI (hazir ayara donuldu).";
};

if !(missionNamespace getVariable ["RTI_sensor_active", false]) exitWith {
    systemChat "[RTI] Canli ayar icin sensor efektleri acik olmali (termal ya da Shift+Ctrl+T).";
};

// İlk kullanımda mevcut değerlerle başla.
if !(missionNamespace getVariable ["RTI_live_enabled", false]) then {
    private _p = call RTI_fnc_sensorParams;
    RTI_live_vals = [_p select 0, _p select 1, _p select 2];
    RTI_live_enabled = true;
};

private _v = +RTI_live_vals;

switch (_which) do {
    case "b": {_v set [0, (((_v select 0) * (1 + (0.1 * _dir))) max 0.05) min 4]};
    case "c": {_v set [1, (((_v select 1) * (1 + (0.1 * _dir))) max 0.05) min 4]};
    case "o": {_v set [2, (((_v select 2) + (0.03 * _dir)) max -1.5) min 0.5]};
    default {};
};

RTI_live_vals = _v;

private _text = format [
    "parlaklik=%1 kontrast=%2 siyahSeviyesi=%3",
    (_v select 0) toFixed 2,
    (_v select 1) toFixed 2,
    (_v select 2) toFixed 2
];

if (_which isEqualTo "report") exitWith {
    copyToClipboard _text;
    systemChat ("[RTI] CANLI DEGERLER (panoya kopyalandi): " + _text);
    diag_log ("[RTI][LIVE] " + _text);
};

call RTI_fnc_sensorRefresh;
systemChat ("[RTI] canli: " + _text);
