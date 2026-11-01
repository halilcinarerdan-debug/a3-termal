/*
    Fonksiyon: RTI_fnc_flashTargets
    Çalışma yeri: herhangi makine

    Şu an termalde olan oyuncular (sensör modülü "RTI_tiActive" bayrağını yayınlar).
    Her atışta tüm oyuncuları taramamak için sonuç 0.5 sn önbelleğe alınır.

    Parametreler: yok
    Dönüş: ARRAY of OBJECT
*/

if ((diag_tickTime - (missionNamespace getVariable ["RTI_flash_targetT", -10])) < 0.5) exitWith {
    missionNamespace getVariable ["RTI_flash_targetL", []]
};

private _list = allPlayers select {alive _x && {_x getVariable ["RTI_tiActive", false]}};

missionNamespace setVariable ["RTI_flash_targetT", diag_tickTime];
missionNamespace setVariable ["RTI_flash_targetL", _list];

_list
