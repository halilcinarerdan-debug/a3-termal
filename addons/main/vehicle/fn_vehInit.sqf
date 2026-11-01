/*
    Fonksiyon: RTI_fnc_vehInit
    Çalışma yeri: TÜM makineler (XEH_preInit.sqf çağırır)

    - Profil önbelleğini kurar.
    - Araç silahı atışlarını namlu ısısına çevirmek için "fired" sınıf olayını bağlar.
      (Yaya silahları için TI parametresi tanımlı değil; yalnızca araçlar.)
      CBA sınıf olayları nesneler oluşmadan önce (preInit) eklenmeli.

    Parametreler: yok
    Dönüş: yok
*/

RTI_veh_profileCache = createHashMap;

{
    [_x, "fired", {
        _this call RTI_fnc_vehOnFired;
    }] call CBA_fnc_addClassEventHandler;
} forEach ["LandVehicle", "Air", "Ship"];
