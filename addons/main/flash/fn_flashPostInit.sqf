/*
    Fonksiyon: RTI_fnc_flashPostInit
    Çalışma yeri: İstemci (XEH_postInit.sqf çağırır)

    Uzaktaki atıcılardan gelen "RTI_flash" CBA olayını dinler ve yerel parçacığı üretir.

    Parametreler: yok
    Dönüş: yok
*/

["RTI_flash", {
    _this call RTI_fnc_flashSpawn;
}] call CBA_fnc_addEventHandler;
