// ============================================================================
//  RTI - Gercekci Termal (tek PBO: rti_main)
//  Yeni modul eklemek icin:
//    1) addons\main\<modul>\ klasoru ac (fn_*.sqf + CfgFunctions.hpp)
//    2) asagidaki CfgFunctions icine #include satiri ekle
//    3) XEH_preInit.sqf / XEH_postInit.sqf icine modulun giris fonksiyonunu ekle
//  NOT: config.cpp'yi ASCII tut (Mikero rapify / HEMTT icin en guvenlisi).
//  RHS / CUP'a BAGIMLILIK YOK: termal optikler calisma aninda config'ten taranir.
// ============================================================================

class CfgPatches
{
    class rti_main
    {
        name = "RTI - Gercekci Termal";
        author = "RTI";
        url = "";
        units[] = {};
        weapons[] = {};
        requiredVersion = 2.08;
        requiredAddons[] = {"cba_main"};
        version = 0.2;
        versionStr = "0.2.2";
        versionAr[] = {0,2,2};
    };
};

class CfgFunctions
{
    class RTI
    {
        tag = "RTI";

        // 0. Cekirdek: yetenek tespiti, optik tarama, teshis
        #include "core\CfgFunctions.hpp"

        // 1. Sensor: termal goruntu isleme (kontrast, gurultu, yumusatma)
        #include "sensor\CfgFunctions.hpp"

        // 2. Flas: namlu atesi / isi noktalari termalde parlar
        #include "flash\CfgFunctions.hpp"

        // 3. Arac: motor / tekerlek / namlu isinma-sogunma modeli
        #include "vehicle\CfgFunctions.hpp"

        // 4. Sicak noktalar: motor / egzoz / namlu uzerinde isiya bagli isi lekesi (sinifa gore otomatik)
        #include "spot\CfgFunctions.hpp"
    };
};

// Termalde "sicak nokta" olarak kullanilan parcacik siniflari (flash modulu).
class CfgCloudlets
{
    #include "flash\CfgCloudlets.hpp"
    #include "spot\CfgCloudlets.hpp"
};

// CBA XEH: tum makinelerde (sunucu, istemci, HC) mod yuklenince calisir.
class Extended_PreInit_EventHandlers
{
    class rti_main
    {
        init = "call compile preprocessFileLineNumbers '\z\rti\addons\main\XEH_preInit.sqf'";
    };
};

class Extended_PostInit_EventHandlers
{
    class rti_main
    {
        init = "call compile preprocessFileLineNumbers '\z\rti\addons\main\XEH_postInit.sqf'";
    };
};
