/*
    Fonksiyon: RTI_fnc_sensorStart
    Çalışma yeri: İstemci

    Termal efekt zincirini etkinleştirir. Zaten etkinse yalnızca ayarları yeniden uygular.

    Parametreler: yok
    Dönüş: yok
*/

missionNamespace setVariable ["RTI_sensor_active", true];

call RTI_fnc_sensorRefresh;
