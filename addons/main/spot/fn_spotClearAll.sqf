/*
    Fonksiyon: RTI_fnc_spotClearAll
    Çalışma yeri: İstemci

    Tüm sıcak nokta parçacıklarını siler. Termalden çıkınca ve özellik kapanınca çağrılır.
    Normal görüşte hiçbir parçacık kalmaz (normal görüşte parlak leke görünmesin diye).
    Hiç kaynak yoksa neredeyse bedavadır.

    Parametreler: yok
    Dönüş: yok
*/

private _vehicles = missionNamespace getVariable ["RTI_spot_vehicles", []];

if (_vehicles isEqualTo []) exitWith {};

{
    [_x] call RTI_fnc_spotClear;
} forEach +_vehicles;

RTI_spot_vehicles = [];
