class vehicle
{
    file = "z\rti\addons\main\vehicle";

    class vehInitSettings {};
    class vehInit {};
    class vehPostInit {};
    class vehParseParMap {};

    // Model (saf hesap)
    class vehProfile {};
    class vehHeat {};

    // Durumu yayimlayan taraf (arac sahibi makine)
    class vehUpdateState {};
    class vehOwnerTick {};
    class vehOnFired {};

    // Goruntuleyen taraf (termaldeki oyuncu)
    class vehViewTick {};
};
