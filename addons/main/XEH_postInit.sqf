/*
    XEH_postInit.sqf
    Mission başlarken, objeler oluşturulduktan sonra çalışır (JIP dahil).
    Mission dosyasına hiçbir şey eklemek gerekmez.
*/

// Araç ısı durumunu sahibi olan makine yayımlar (sunucu / HC / istemci fark etmez).
call RTI_fnc_vehPostInit;

// Geri kalanı oyuncu arayüzüyle ilgili: sunucuda / headless client'ta yapacak iş yok.
if (!hasInterface) exitWith {};

call RTI_fnc_corePostInit;
call RTI_fnc_sensorPostInit;
call RTI_fnc_flashPostInit;
