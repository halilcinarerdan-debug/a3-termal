/*
    Fonksiyon: RTI_fnc_testHeatSpot
    Çalışma yeri: İstemci (debug konsolu:  call RTI_fnc_testHeatSpot;)

    Kameranın 25 m önüne 10 sn boyunca yerel bir parçacık "sıcak nokta" bırakır.
    TEST: bunu termal optikten bak. Nokta parlak görünüyorsa dünya-uzayı flaş yöntemi
    (flash modülü, başkalarının namlu ateşi) bu oyun sürümünde çalışıyor demektir.
    Görünmüyorsa o yöntem bırakılmalı (README > Bilinen sınırlar).

    Parametreler:
        0: NUMBER - mesafe, metre (varsayılan 25)

    Dönüş: OBJECT - parçacık kaynağı
*/

params [["_dist", 25, [0]]];

private _pos = positionCameraToWorld [0, 0, _dist];

private _src = "#particlesource" createVehicleLocal _pos;
_src setParticleClass "RTI_HeatSpotTest";
_src setDropInterval 0.03;

[{deleteVehicle _this}, _src, 10] call CBA_fnc_waitAndExecute;

systemChat format ["[RTI] Test sicak noktasi %1 m onde, 10 sn. Termalden bak; normal gorusle de gorunmeli.", _dist];

_src
