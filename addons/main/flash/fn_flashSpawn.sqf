/*
    Fonksiyon: RTI_fnc_flashSpawn
    Çalışma yeri: İstemci (CBA "RTI_flash" olayı; atıcı başka makinede)

    Verilen noktada çok kısa ömürlü (~0.07 sn) yerel sıcak parçacık bırakır.
    Yalnızca bu oyuncu hâlâ termaldeyse üretilir; normal görüşte hiç parçacık yaratılmaz,
    böylece asıl namlu efektinin üstüne ikinci bir görünür flaş binmez.

    Uzak atışlarda daha büyük parçacık sınıfı seçilir (küçük nokta uzakta piksel altına düşer).

    Parametreler:
        0: ARRAY  - dünya konumu (ASL)
        1: NUMBER - şiddet 0..1

    Dönüş: yok
*/

params ["_posASL", "_intensity"];

if (isNull player || {currentVisionMode player != 2}) exitWith {};

private _dist = (getPosASL player) distance _posASL;
if (_dist > RTI_flash_maxDist) exitWith {};

private _tier = ((floor ((_intensity * 1.4) + (_dist / 700))) min 2) max 0;
private _class = ["RTI_MuzzleHeat_S", "RTI_MuzzleHeat_M", "RTI_MuzzleHeat_L"] select _tier;

private _src = "#particlesource" createVehicleLocal [0, 0, 0];
_src setPosASL _posASL;
_src setParticleClass _class;
_src setDropInterval 0.01;

[{deleteVehicle _this}, _src, 0.07] call CBA_fnc_waitAndExecute;
