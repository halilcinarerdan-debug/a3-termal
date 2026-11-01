/*
    Fonksiyon: RTI_fnc_ppTest
    Çalışma yeri: İstemci (debug konsolu, Local Exec:  call RTI_fnc_ppTest;)

    "Efektler neden hiç değişmiyor?" sorusunu ayırt eder: ekranı ABARTILI şekilde boyar ve hangi aşamada
    boyandığını söyler. Termal görüntüye bakarken (Zeus kamerası, optik, araç nişangahı) çalıştır.

      Aşama 1 (3.5 sn): KIRMIZI + koyu,  ppEffectForceInNVG KAPALI
      Aşama 2 (3.5 sn): MAVİ + koyu,     ppEffectForceInNVG AÇIK

    Yorum:
      kırmızı da mavi de görünüyor : PP termalde çiziliyor ve ForceInNVG gerekmiyor -> sorun başka yerde
                                     (efekt başlamıyor: sürüm, Zeus, ayar). call RTI_fnc_diag ile bak.
      yalnızca mavi görünüyor      : PP termalde ForceInNVG ile çiziliyor (mod bunu zaten uyguluyor)
      hiçbiri görünmüyor           : PP bu görüntüde çizilmiyor: Video ayarlarında "Post Process" kapalı olabilir
                                     ya da bu görünüm (PiP / özel kamera) PP'yi desteklemiyor

    Parametreler: yok
    Dönüş: yok
*/

private _handle = -1;

for "_i" from 0 to 20 do {
    _handle = ppEffectCreate ["ColorCorrections", 7400 + _i];
    if (_handle >= 0) exitWith {};
};

if (_handle < 0) exitWith {
    systemChat "[RTI] PP testi: ppEffectCreate basarisiz (-1). Video ayarinda Post Process kapali olabilir.";
    diag_log "[RTI][PPTEST] ppEffectCreate basarisiz (-1)";
};

diag_log format ["[RTI][PPTEST] handle %1 | gorus modu %2", _handle, currentVisionMode [player]];

// Aşama 1: kırmızı, ForceInNVG kapalı
_handle ppEffectForceInNVG false;
_handle ppEffectEnable true;
_handle ppEffectAdjust [0.35, 1, 0, [1, 0, 0, 0.55], [1, 1, 1, 0], [0.299, 0.587, 0.114, 0]];
_handle ppEffectCommit 0;

systemChat format ["[RTI] PP testi ASAMA 1: ekran 3.5 sn KIRMIZI ve KOYU olmali (handle %1, ForceInNVG kapali).", _handle];

[{
    params ["_handle"];

    // Aşama 2: mavi, ForceInNVG açık
    _handle ppEffectForceInNVG true;
    _handle ppEffectAdjust [0.35, 1, 0, [0, 0, 1, 0.55], [1, 1, 1, 0], [0.299, 0.587, 0.114, 0]];
    _handle ppEffectCommit 0;

    systemChat "[RTI] PP testi ASAMA 2: ekran 3.5 sn MAVI ve KOYU olmali (ForceInNVG acik).";

    [{
        params ["_handle"];

        _handle ppEffectEnable false;
        ppEffectDestroy _handle;

        systemChat "[RTI] PP testi bitti. Hangi asamalarda boyandigini soyle (kirmizi / mavi / hicbiri).";
    }, [_handle], 3.5] call CBA_fnc_waitAndExecute;
}, [_handle], 3.5] call CBA_fnc_waitAndExecute;
