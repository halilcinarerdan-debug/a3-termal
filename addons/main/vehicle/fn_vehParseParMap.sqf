/*
    Fonksiyon: RTI_fnc_vehParseParMap

    "TI parametre sırası" ayarını çözer. Geçerli: 0..2 aralığında üç farklı tam sayı
    (ör. "0,1,2" veya "1,0,2"). Geçersizse varsayılan [0,1,2] döner.

    Parametreler:
        0: STRING - ayar değeri

    Dönüş: ARRAY - [motorIndeksi, tekerlekIndeksi, silahIndeksi]
*/

params [["_value", "0,1,2", [""]]];

private _parts = (_value splitString ", ;") apply {parseNumber _x};

if (
    (count _parts) != 3
    || {(_parts findIf {_x < 0 || {_x > 2}}) >= 0}
    || {(count (_parts arrayIntersect _parts)) != 3}
) exitWith {
    diag_log format ["[RTI] gecersiz TI parametre sirasi '%1' -> varsayilan 0,1,2", _value];
    [0, 1, 2]
};

_parts
