/*
    Fonksiyon: RTI_fnc_flashClear
    Çalışma yeri: İstemci

    Ekran flaşı PP efektini yok eder (termal modundan çıkılınca sensör modülü çağırır).
    Efekt yoksa zararsızdır.

    Parametreler: yok
    Dönüş: yok
*/

private _handle = missionNamespace getVariable ["RTI_pp_flash", -1];

if (_handle >= 0) then {
    _handle ppEffectEnable false;
    ppEffectDestroy _handle;
    missionNamespace setVariable ["RTI_pp_flash", -1];
};
