/*
    Fonksiyon: RTI_fnc_diagOwner
    Çalışma yeri: İstemci (debug konsolu, Local Exec:  call RTI_fnc_diagOwner;)

    "Bu termal özellik hangi moddan geliyor?" sorusunu cevaplamak için: eldeki silahın ve imlecin
    gösterdiği birimin / aracın (yoksa oyuncunun) sınıfını, o sınıfı TANIMLAYAN modu (configSourceMod)
    ve model yolunu yazar. Model yolunun öneki sahibi gösterir:
        \A3\...     vanilla        \rhsusf\ / \rhsafrf\ / \rhsgref\   RHS        \CUP\...   CUP
    Ayrıca ACE overheating / CUP / RHS yüklü mü ve ACE overheating ayarı açık mı.

    Not: Termal (TI) dokusu modelin kendisindedir; yüzü/eli/namlu ısısını çizen doku, model hangi moddaysa ondandır.
    ACE overheating namlu SICAKLIĞINI simüle eder (sekme, sıkışma, duman); termal dokuyu değiştirdiğine dair bir
    kanıt bulunamadı, bu yüzden bu rapor + ACE overheating'i kapatıp açarak (TEST) ayrıştırılır.

    Rapor RPT'ye ([RTI][OWNER]) yazılır ve panoya kopyalanır.

    Parametreler: yok
    Dönüş: yok
*/

private _out = [];
private _log = {
    _out pushBack _this;
    diag_log ("[RTI][OWNER] " + _this);
};

private _hasPrefix = {
    params ["_prefix"];

    count (configProperties [configFile >> "CfgPatches", "(toLower (configName _x)) select [0, count '" + _prefix + "'] isEqualTo '" + _prefix + "'", true]) > 0
};

format [
    "yuklu | ACE overheating=%1 | ACE=%2 | CUP=%3 | RHS=%4 | ace_overheating_enabled=%5",
    isClass (configFile >> "CfgPatches" >> "ace_overheating"),
    isClass (configFile >> "CfgPatches" >> "ace_main"),
    ["cup_"] call _hasPrefix,
    ["rhs"] call _hasPrefix,
    missionNamespace getVariable ["ace_overheating_enabled", "ayar yok"]
] call _log;

// Silah
private _weapon = currentWeapon player;
private _wCfg = configFile >> "CfgWeapons" >> _weapon;

format [
    "silah | sinif=%1 | tanimlayan mod=%2 | model=%3",
    _weapon,
    configSourceMod _wCfg,
    getText (_wCfg >> "model")
] call _log;

// Birim / araç (imleç, yoksa oyuncu)
private _target = if (isNull cursorObject) then {player} else {cursorObject};
private _tCfg = configOf _target;

format [
    "hedef | sinif=%1 | tanimlayan mod=%2 | model=%3 | hiddenSelectionsMaterials=%4",
    typeOf _target,
    configSourceMod _tCfg,
    getText (_tCfg >> "model"),
    getArray (_tCfg >> "hiddenSelectionsMaterials")
] call _log;

copyToClipboard (_out joinString endl);
systemChat "[RTI] Sahiplik raporu panoya kopyalandi ve RPT'ye yazildi ([RTI][OWNER]).";
