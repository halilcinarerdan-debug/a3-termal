/*
    Fonksiyon: RTI_fnc_vehPostInit
    Çalışma yeri: TÜM makineler (XEH_postInit.sqf çağırır)

    İki döngü (CBA PerFrameHandler):
      - Sahip döngüsü (3 sn, her makine): o makinede YEREL araçların motor / tekerlek
        ısı hedefi değiştiyse durumu yayınlar.
      - Görüntüleme döngüsü (1 sn, yalnızca istemci): oyuncu termaldeyse yakındaki
        araçların güncel ısısını hesaplayıp setVehicleTIPars ile uygular.
        Termal kapalıyken ilk satırda çıkar.

    Parametreler: yok
    Dönüş: yok
*/

if (!RTI_cap_setVehicleTIPars) then {
    diag_log "[RTI] setVehicleTIPars bu surumde yok: arac isi modeli goruntuleme tarafi kapali (durum yayini yine calisir).";
};

[{
    call RTI_fnc_vehOwnerTick;
}, 3] call CBA_fnc_addPerFrameHandler;

if (hasInterface) then {
    [{
        call RTI_fnc_vehViewTick;
    }, 1] call CBA_fnc_addPerFrameHandler;
};
