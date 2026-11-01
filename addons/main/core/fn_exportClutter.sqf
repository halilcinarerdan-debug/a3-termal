/*
    Fonksiyon: RTI_fnc_exportClutter
    Çalışma yeri: İstemci (debug konsolu, Local Exec:  call RTI_fnc_exportClutter;)

    Çimen yamalarının ("sınıf adıyla ara") kaynağını bulmak için iki liste çıkarır:
      1) Mevcut arazinin çimen "clutter" sınıfları: CfgWorlds >> <arazi> >> Clutter >> *
         (sınıf adı, model yolu, ölçek aralığı, rüzgâr etkisi)
      2) Oyuncunun 40 m çevresindeki arazi nesneleri (çalı, ağaç, kaya...) ve model yolları

    Not: Çimen clutter'ı bir nesne değildir; sınıf adına bağlı ayrı bir termal ayarı yoktur. Bu liste, hangi
    modelin yamaları yaptığını görmek ve (isteğe bağlı) ileride config yamasıyla seyreltmek içindir.
    Gerçek kaldırma yolu arazi ızgarasıdır (Video "Arazi ayrıntısı" / "Termalde çimeni kapat").

    Çıktı: RPT ([RTI][CLUTTER]) + pano (ilk 40 satır).

    Parametreler: yok
    Dönüş: yok
*/

private _out = [];
private _log = {
    _out pushBack _this;
    diag_log ("[RTI][CLUTTER] " + _this);
};

format ["arazi=%1", worldName] call _log;

private _clutter = configFile >> "CfgWorlds" >> worldName >> "Clutter";

if (isClass _clutter) then {
    {
        format [
            "clutter=%1 | model=%2 | scaleMin=%3 scaleMax=%4 | affectedByWind=%5",
            configName _x,
            getText (_x >> "model"),
            getNumber (_x >> "scaleMin"),
            getNumber (_x >> "scaleMax"),
            getNumber (_x >> "affectedByWind")
        ] call _log;
    } forEach ("true" configClasses _clutter);
} else {
    "bu arazide CfgWorlds >> Clutter sinifi yok (clutter baska bir sinifta tanimli olabilir)" call _log;
};

private _near = nearestTerrainObjects [player, [], 40, false];
private _models = createHashMap;

{
    private _model = (getModelInfo _x) select 0;
    _models set [_model, (_models getOrDefault [_model, 0]) + 1];
} forEach _near;

format ["yakin arazi nesnesi: %1 adet, %2 farkli model", count _near, count _models] call _log;

{
    format ["  model=%1 | adet=%2", _x, _models get _x] call _log;
} forEach (keys _models);

copyToClipboard ((_out select [0, 40]) joinString endl);
systemChat "[RTI] Clutter raporu panoya kopyalandi (ilk 40 satir), tamami RPT'de [RTI][CLUTTER].";
