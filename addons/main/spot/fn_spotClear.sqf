/*
    Fonksiyon: RTI_fnc_spotClear
    Çalışma yeri: İstemci

    Tek bir aracın tüm sıcak nokta parçacıklarını siler ve izleme listesinden çıkarır.
    Aracın yok olmuş (null) olması zararsızdır.

    Parametreler:
        0: OBJECT - araç

    Dönüş: yok
*/

params ["_veh"];

if (!isNull _veh) then {
    {
        deleteVehicle (_x select 0);
    } forEach (_veh getVariable ["RTI_spot_slots", []]);

    _veh setVariable ["RTI_spot_slots", []];
};

RTI_spot_vehicles = RTI_spot_vehicles - [_veh] - [objNull];
