/*
    Fonksiyon: RTI_fnc_vehProfile
    Çalışma yeri: herhangi makine (saf hesap + önbellek)

    Araç sınıfına göre termal zaman sabitleri. RHS / CUP araçları da vanilla taban
    sınıflardan (Tank, Car_F, Air, Ship ...) türediği için ayrı liste gerekmez.

    Dönen dizi (saniye, hedef 0..1, km/s):
        0: motor ısınma zaman sabiti (tau)
        1: motor soğuma yarı-ömrü
        2: tekerlek/palet ısınma zaman sabiti
        3: tekerlek/palet soğuma yarı-ömrü
        4: namlu soğuma yarı-ömrü
        5: rölanti motor ısı hedefi (hareketteyken 1)
        6: azami hız (config maxSpeed)

    Değerler tahmindir (kitlesi büyük araç = daha yavaş ısınır / soğur); oyunda
    "Soğuma süresi çarpanı" ile ölçeklenir.

    Parametreler:
        0: OBJECT - araç

    Dönüş: ARRAY
*/

params ["_veh"];

if (isNil "RTI_veh_profileCache") then {RTI_veh_profileCache = createHashMap};

private _type = typeOf _veh;
private _profile = RTI_veh_profileCache getOrDefault [_type, []];

if (_profile isEqualTo []) then {
    _profile = switch (true) do {
        case (_veh isKindOf "Tank"):           {[180, 1500, 150, 900, 300, 0.5]};
        case (_veh isKindOf "Wheeled_APC_F"):  {[120,  900,  90, 480, 300, 0.5]};
        case (_veh isKindOf "Helicopter"):     {[ 60,  600,   1,   1, 240, 0.7]};
        case (_veh isKindOf "Plane"):          {[ 60,  400,   1,   1, 240, 0.7]};
        case (_veh isKindOf "Ship"):           {[120,  600,   1,   1, 240, 0.5]};
        case (_veh isKindOf "StaticWeapon"):   {[  1,    1,   1,   1, 300, 0]};
        case (_veh isKindOf "Car"):            {[ 90,  480,  60, 300, 240, 0.5]};
        default                                {[120,  600,  90, 300, 240, 0.5]};
    };

    _profile = _profile + [(getNumber (configFile >> "CfgVehicles" >> _type >> "maxSpeed")) max 20];

    RTI_veh_profileCache set [_type, _profile];
};

_profile
