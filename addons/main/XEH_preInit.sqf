/*
    XEH_preInit.sqf
    TÜM makinelerde (sunucu + istemci + HC), objeler oluşmadan önce çalışır.
    - CBA ayarları burada kaydedilir (sunucu da kaydetmek zorunda: global ayarlar
      sunucudan istemcilere senkronlanır).
    - CBA sınıf olay işleyicileri (Fired) BURADA eklenmeli: nesneler oluşmadan önce
      kaydedilmezse mevcut nesnelere uygulanmaz.
*/

// 0. Çekirdek
call RTI_fnc_coreInitSettings;
call RTI_fnc_coreCaps;

// 1. Sensör
call RTI_fnc_sensorInitSettings;

// 2. Flaş
call RTI_fnc_flashInitSettings;
call RTI_fnc_flashInit;

// 3. Araç
call RTI_fnc_vehInitSettings;
call RTI_fnc_vehInit;
