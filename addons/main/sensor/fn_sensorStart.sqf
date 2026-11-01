/*
    Fonksiyon: RTI_fnc_sensorStart
    Çalışma yeri: İstemci

    Termal efekt zincirini etkinleştirir. Zaten etkinse yalnızca ayarları yeniden uygular.
      - Ortam modelini bir kez günceller ve 30 sn'lik bir PFH ile yeniler (yalnızca termal açıkken).
      - "Termalde çimeni kapat" açıksa arazi ızgarasını 50'ye (çimensiz) çeker; çıkışta geri yüklenir.

    Parametreler: yok
    Dönüş: yok
*/

missionNamespace setVariable ["RTI_sensor_active", true];

// Ortam: başlangıçta bir kez zorla, sonra 30 sn'de bir (yalnızca termal açıkken çalışır).
[true] call RTI_fnc_envUpdate;

if ((missionNamespace getVariable ["RTI_env_pfh", -1]) < 0) then {
    RTI_env_pfh = [{
        [] call RTI_fnc_envUpdate;
        call RTI_fnc_sensorRefresh;
    }, 30] call CBA_fnc_addPerFrameHandler;
};

// Çimen (deneysel, kapalı gelir): çimen yamalarını kaldırmanın tek gerçek yolu arazi ızgarasıdır.
if (RTI_sensor_grassOff && {!(missionNamespace getVariable ["RTI_grass_changed", false])}) then {
    RTI_grass_changed = true;
    setTerrainGrid 50;
};

call RTI_fnc_sensorRefresh;
