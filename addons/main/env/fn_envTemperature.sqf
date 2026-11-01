/*
    Fonksiyon: RTI_fnc_envTemperature
    Çalışma yeri: İstemci (saf hesap)

    Hava sıcaklığını (°C) verir. Öncelik:
      1) "Hava sıcaklığını elle ver" açıksa elle değer
      2) ACE Weather yüklüyse ace_weather_currentTemperature
      3) Tahmin: yıllık ortalama (enleme göre) + mevsim (tarih) + gün içi (saat, bulutluluk) - yağmur

    Tahmin kabadır: yıllık ort. = 30 - 0.45*|enlem|, mevsim genliği = 0.35*|enlem|, gün içi ±6 °C
    (tepe 15:00, bulutluluk genliği azaltır). Yarıküre, terrain config enlemi güvenilmez olduğu
    için ayardan okunur. vanilla `ambientTemperature` komutu belgesi doğrulanınca öncelikli olacak.

    Parametreler: yok
    Dönüş: NUMBER - °C
*/

if (RTI_env_useManual) exitWith {RTI_env_manualTemp};

private _ace = missionNamespace getVariable ["ace_weather_currentTemperature", -999];
if (_ace > -900) exitWith {_ace};

private _lat = abs (getNumber (configFile >> "CfgWorlds" >> worldName >> "latitude"));
if (_lat < 1) then {_lat = 40};
_lat = _lat min 70;

private _date = date;
private _month = (_date select 1) + (((_date select 2) - 1) / 30);

// -1 (Ocak) ... +1 (Temmuz) kuzeyde; güneyde ters.
private _season = -(cos (((_month - 1) / 12) * 360));
if (RTI_env_hemisphere == 1) then {_season = -_season};

private _temp = (30 - (0.45 * _lat)) + ((0.35 * _lat) * _season);

private _diurnal = (6 * (1 - (0.6 * overcast))) * (cos (((dayTime - 15) / 24) * 360));

_temp = (_temp + _diurnal) - (2 * rain);

(_temp max -40) min 55
