/*
    Fonksiyon: RTI_fnc_sensorExcluded
    Çalışma yeri: İstemci

    Oyuncunun şu an kullandığı optik, "Efekt uygulanmayacak optikler" listesinde mi?
    Yalnızca yaya birimler için denetlenir (araç optikleri ana ekranda render edilir).

    Parametreler:
        0: OBJECT - oyuncu birimi

    Dönüş: BOOL
*/

params ["_unit"];

private _list = (RTI_sensor_excludeOptics splitString ", ;") apply {toLower _x};

if (_list isEqualTo [] || {(vehicle _unit) isNotEqualTo _unit}) exitWith {false};

private _items = ((primaryWeaponItems _unit) + (handgunItems _unit) + [currentWeapon _unit]) apply {toLower _x};

(_items findIf {_x in _list}) >= 0
