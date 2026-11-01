/*
    Fonksiyon: RTI_fnc_flashInit
    Çalışma yeri: TÜM makineler (XEH_preInit.sqf çağırır)

    Yerel birimlerin "fired" olayına flaş işleyicisini bağlar. Fired olayı yalnızca
    atıcının yerel olduğu makinede çalışır (oyuncu kendi makinesinde, YZ sunucuda/HC'de);
    bu yüzden her makinede kayıt gerekir. Sınıflar birbirinden ayrıktır, çift çalışmaz.

    CBA sınıf olayları nesneler oluşmadan önce (preInit) eklenmeli.

    Parametreler: yok
    Dönüş: yok
*/

{
    [_x, "fired", {
        _this call RTI_fnc_flashOnFired;
    }] call CBA_fnc_addClassEventHandler;
} forEach ["CAManBase", "LandVehicle", "Air", "Ship"];
