/*
    Fonksiyon: RTI_fnc_surfaceUpdate
    Çalışma yeri: İstemci (termal açıkken 1.5 sn'lik PFH)

    "Zemin tabanı" (siyahın tamamen siyah olmaması) çarpanlarını hesaplar ve RTI_surf_k'ya yazar:
        RTI_surf_k = [zeminK, gökK, yüzeyGrubu, yüzeySınıfı]

      zeminK : kameranın BAKTIĞI noktadaki yüzeyin ısı çarpanı (RTI_fnc_surfaceClass), güneşe göre
               gece / gündüz arasında karıştırılır. Ayar kapalıysa 1.
      gökK   : bakış yukarı kalktıkça tabanı sıfıra çeker (gökyüzü siyah kalsın). Yatay bakışta 1,
               ~11.5 derece yukarıda 0.

    Taban gerçekte sahnenin parlaklığına uyan bir sensörün (AGC) davranışına benzer; yüzeyi
    "boyamaz", yalnızca tüm ekrandaki siyah tabanını ayarlar.

    Taban anlamlı değişince sensör efektleri 0.8 sn'lik yumuşak geçişle yenilenir.

    Parametreler: yok
    Dönüş: yok
*/

// Kamera yönü (Zeus dahil her kamerada çalışır): z bileşeni > 0 yukarı bakış
private _dir = (positionCameraToWorld [0, 0, 1]) vectorDiff (positionCameraToWorld [0, 0, 0]);
private _skyK = (1 - (((_dir select 2) max 0) / 0.2)) max 0;

private _groundK = 1;
private _group = "kapali";
private _class = "";

if (RTI_sensor_surface) then {
    private _pos = screenToWorld [0.5, 0.5];
    _class = (surfaceType _pos) select [1];

    if (_class isNotEqualTo "") then {
        private _info = [_class] call RTI_fnc_surfaceClass;
        _info params ["_surfaceGroup", "_day", "_night"];

        private _solar = (missionNamespace getVariable ["RTI_env_k", [1, 1, 1, 0, 15]]) select 3;

        _group = _surfaceGroup;
        _groundK = _night + ((_day - _night) * _solar);
    };
};

private _old = missionNamespace getVariable ["RTI_surf_k", [1, 1, "", ""]];
RTI_surf_k = [_groundK, _skyK, _group, _class];

// Yalnızca anlamlı değişimde ekranı yumuşak geçişle yenile.
if ((abs ((_groundK * _skyK) - ((_old select 0) * (_old select 1)))) > 0.04) then {
    RTI_sensor_commit = 0.8;
    call RTI_fnc_sensorRefresh;
    RTI_sensor_commit = 0.15;
};
