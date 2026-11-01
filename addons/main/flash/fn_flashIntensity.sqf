/*
    Fonksiyon: RTI_fnc_flashIntensity
    Çalışma yeri: herhangi (saf hesap)

    Bir atışın termal flaş şiddetini 0.15..1 arasında tahmin eder.
      - Mühimmatın CfgAmmo >> visibleFire değeri (büyük kalibre / top = daha parlak)
      - Yaya atıcıda namlu ucu ekipmanı: eklentinin AmmoCoef >> visibleFire katsayısı
        (susturucu bunu düşürür)
    Ölçek (visibleFire 2..30 -> 0.25..1) tahminidir; gerçek değerler oyunda
    gözlenerek ayarlanmalı. Değer yoksa orta şiddet (0.5) döner.

    Parametreler:
        0: OBJECT - atıcı
        1: STRING - silah
        2: STRING - mühimmat

    Dönüş: NUMBER
*/

params ["_unit", "_weapon", "_ammo"];

private _visible = getNumber (configFile >> "CfgAmmo" >> _ammo >> "visibleFire");
if (_visible <= 0) exitWith {0.5};

private _coef = 1;

if (_unit isKindOf "CAManBase") then {
    private _items = [];

    if (_weapon isEqualTo (primaryWeapon _unit)) then {_items = primaryWeaponItems _unit};
    if (_weapon isEqualTo (handgunWeapon _unit)) then {_items = handgunItems _unit};

    private _muzzleItem = _items param [0, ""];

    if (_muzzleItem isNotEqualTo "") then {
        private _c = getNumber (configFile >> "CfgWeapons" >> _muzzleItem >> "ItemInfo" >> "AmmoCoef" >> "visibleFire");
        if (_c > 0) then {_coef = _c};
    };
};

linearConversion [2, 30, _visible * _coef, 0.25, 1, true] max 0.15
