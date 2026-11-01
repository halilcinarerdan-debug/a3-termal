/*
    Fonksiyon: RTI_fnc_flashOnFired
    Çalışma yeri: atıcının YEREL olduğu makine (CBA sınıf olayı "fired")

    İki yol:
      A) Atıcı bu makinedeki oyuncuysa (yaya ya da araç silahı) ve termaldeyse:
         ekran flaşı (PP). Dünya nesnesine bağlı olmadığı için kendi silahında güvenilirdir.
      B) Termalde olan BAŞKA oyunculara CBA hedef olayı: namlu ucunda kısa ömürlü sıcak
         parçacık. Kimse termalde değilse hiçbir şey yapılmaz.

    Aşırı yük önlemleri: sistem kapalıysa ilk satırda çıkar; termalde kimse yoksa çıkar;
    atıcı başına en fazla ~8 olay/sn; mesafe sınırı atıcı tarafında uygulanır.

    Parametreler: CBA/BIS "Fired" olayı ile aynı
        0: OBJECT - atıcı (birim ya da araç)
        1: STRING - silah
        2: STRING - namlu
        3: STRING - ateş modu
        4: STRING - mühimmat
        5: STRING - şarjör
        6: OBJECT - mermi
        7: OBJECT - atan kişi (opsiyonel)

    Dönüş: yok
*/

params ["_unit", "_weapon", "", "", "_ammo", "", "_projectile", ["_gunner", objNull]];

if (!RTI_flash_enabled) exitWith {};

private _intensity = -1;

// A) Kendi atışım -> ekran flaşı
private _own = hasInterface && {!isNull player} && {(_unit isEqualTo player) || {_gunner isEqualTo player}};

if (_own && {RTI_flash_own} && {currentVisionMode player == 2}) then {
    _intensity = [_unit, _weapon, _ammo] call RTI_fnc_flashIntensity;
    [_intensity] call RTI_fnc_flashScreen;
};

// B) Başkalarının termalinde parçacık
if (!RTI_flash_others) exitWith {};

private _targets = call RTI_fnc_flashTargets;
if (_targets isEqualTo []) exitWith {};

// Atıcı başına hız sınırı (otomatik ateşte olay sayısını sınırlar)
private _last = _unit getVariable ["RTI_flash_last", -1];
if ((diag_tickTime - _last) < 0.12) exitWith {};
_unit setVariable ["RTI_flash_last", diag_tickTime];

private _pos = if (isNull _projectile) then {eyePos _unit} else {getPosASL _projectile};
private _maxDist = RTI_flash_maxDist;

// Atıcının kendisi, aynı araçtaki oyuncular ve menzil dışındakiler hariç
_targets = _targets select {
    ((vehicle _x) isNotEqualTo (vehicle _unit))
    && {_x isNotEqualTo _gunner}
    && {((getPosASL _x) distance _pos) < _maxDist}
};

if (_targets isEqualTo []) exitWith {};

if (_intensity < 0) then {
    _intensity = [_unit, _weapon, _ammo] call RTI_fnc_flashIntensity;
};

["RTI_flash", [_pos, _intensity], _targets] call CBA_fnc_targetEvent;

if (RTI_core_debug) then {
    diag_log format ["[RTI][FLASH] %1 ates etti | siddet %2 | hedef %3", typeOf _unit, _intensity toFixed 2, count _targets];
};
