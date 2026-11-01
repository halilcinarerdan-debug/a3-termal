/*
    Fonksiyon: RTI_fnc_sensorStart
    Çalışma yeri: İstemci

    Termal efekt zincirini etkinleştirir. Zaten etkinse yalnızca ayarları yeniden uygular.

    SIRA ÖNEMLİ: önce ekran efekti uygulanır (RTI_fnc_sensorRefresh). İsteğe bağlı parçalar (ortam modeli,
    yüzey tabanı) ayrı betikte (spawn) ve PFH'lerde çalışır: SQF'te çalışma zamanı hatası o çağrı zincirini
    sonlandırır, bu yüzden isteğe bağlı bir parçadaki hata ekran efektini asla engellememeli.
      - Ortam modeli: başlangıçta bir kez + 30 sn'lik PFH (yalnızca termal açıkken).
      - Zemin tabanı: bakılan yüzey / bakış yönü için 1.5 sn'lik PFH (yalnızca termal açıkken).
      - "Termalde çimeni kapat" açıksa arazi ızgarasını 50'ye çeker; çıkışta geri yüklenir.

    Parametreler: yok
    Dönüş: yok
*/

missionNamespace setVariable ["RTI_sensor_active", true];

// 1) Ekran efekti ÖNCE (ortam / yüzey henüz hesaplanmadıysa tarafsız varsayılanlar kullanılır).
call RTI_fnc_sensorRefresh;

// 2) İsteğe bağlı başlangıç hesapları: ayrı betik, hata sensörü öldürmez; bitince efekti yeniler.
[] spawn {
    [true] call RTI_fnc_envUpdate;
    call RTI_fnc_surfaceUpdate;
    call RTI_fnc_sensorRefresh;
};

// 3) Periyodik yenileme (PFH kodu kendi betik örneğinde çalışır).
if ((missionNamespace getVariable ["RTI_env_pfh", -1]) < 0) then {
    RTI_env_pfh = [{
        [] call RTI_fnc_envUpdate;
        call RTI_fnc_sensorRefresh;
    }, 30] call CBA_fnc_addPerFrameHandler;
};

if ((missionNamespace getVariable ["RTI_surf_pfh", -1]) < 0) then {
    RTI_surf_pfh = [{
        call RTI_fnc_surfaceUpdate;
    }, 1.5] call CBA_fnc_addPerFrameHandler;
};

// Çimen (deneysel, kapalı gelir): çimen yamalarını kaldırmanın tek gerçek yolu arazi ızgarasıdır.
if (missionNamespace getVariable ["RTI_sensor_grassOff", false] && {!(missionNamespace getVariable ["RTI_grass_changed", false])}) then {
    RTI_grass_changed = true;
    setTerrainGrid 50;
};
