/*
    Fonksiyon: RTI_fnc_ppBisect
    Çalışma yeri: İstemci (debug konsolu, Local Exec:  call RTI_fnc_ppBisect;)

    "Nötr ayarda bile ekran simsiyah" hatasını ayırt eder: her post-process efektini TEK BAŞINA, nötr değerle ve
    ppEffectForceInNVG AÇIK / KAPALI olarak 5 sn dener; her adımı sohbete ve RPT'ye ([RTI][BISECT]) yazar.
    Termal görüntüye bakarken çalıştır (RTI efektleri geçici durdurulur, sonunda geri açılır).

    Adım 0 hiçbir efekt yok (normal görünmeli). Sonra:
      1 ColorCorrections nötr, ForceInNVG AÇIK      2 aynısı, ForceInNVG KAPALI
      3 FilmGrain,            ForceInNVG AÇIK       4 aynısı, ForceInNVG KAPALI
      5 DynamicBlur,          ForceInNVG AÇIK       6 aynısı, ForceInNVG KAPALI

    Bana yaz: hangi adım(lar) ekranı karartıyor / hangileri normal.

    Parametreler: yok
    Dönüş: yok
*/

if (missionNamespace getVariable ["RTI_ladder_running", false]) exitWith {
    systemChat "[RTI] Bir kalibrasyon / bisect zaten calisiyor; bitmesini bekle.";
};

RTI_ladder_running = true;
RTI_sensor_forced = true;
call RTI_fnc_sensorStop;

[] spawn {
    private _weights = [0.299, 0.587, 0.114, 0];

    private _steps = [
        ["ColorCorrections notr, ForceInNVG ACIK", "ColorCorrections", [1, 1, 0, [0, 0, 0, 0], [1, 1, 1, 0], _weights], true],
        ["ColorCorrections notr, ForceInNVG KAPALI", "ColorCorrections", [1, 1, 0, [0, 0, 0, 0], [1, 1, 1, 0], _weights], false],
        ["FilmGrain 0.06, ForceInNVG ACIK", "FilmGrain", [0.06, 1.5, 2.5, 1, 1, true], true],
        ["FilmGrain 0.06, ForceInNVG KAPALI", "FilmGrain", [0.06, 1.5, 2.5, 1, 1, true], false],
        ["DynamicBlur 0.3, ForceInNVG ACIK", "DynamicBlur", [0.3], true],
        ["DynamicBlur 0.3, ForceInNVG KAPALI", "DynamicBlur", [0.3], false]
    ];

    systemChat "[RTI] BISECT ADIM 0/6: hicbir efekt yok, goruntu NORMAL olmali (5 sn).";
    diag_log "[RTI][BISECT] adim 0: efekt yok";
    uiSleep 5;

    {
        _x params ["_label", "_type", "_params", "_force"];

        private _handle = -1;
        for "_i" from 0 to 20 do {
            _handle = ppEffectCreate [_type, 7600 + _i];
            if (_handle >= 0) exitWith {};
        };

        private _msg = format ["BISECT ADIM %1/%2: %3 (handle %4)", _forEachIndex + 1, count _steps, _label, _handle];
        systemChat ("[RTI] " + _msg);
        diag_log ("[RTI][BISECT] " + _msg);

        if (_handle >= 0) then {
            _handle ppEffectForceInNVG _force;
            _handle ppEffectEnable true;
            _handle ppEffectAdjust _params;
            _handle ppEffectCommit 0;
        };

        uiSleep 5;

        if (_handle >= 0) then {
            _handle ppEffectEnable false;
            ppEffectDestroy _handle;
        };
    } forEach _steps;

    systemChat "[RTI] BISECT bitti. Hangi adimlar ekrani karartti / hangileri normaldi? Yaz.";

    RTI_ladder_running = false;
    RTI_sensor_forced = false;
};
