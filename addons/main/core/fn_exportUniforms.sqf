/*
    Fonksiyon: RTI_fnc_exportUniforms
    Çalışma yeri: İstemci (debug konsolu, Local Exec:  call RTI_fnc_exportUniforms;)

    Yüklü tüm üniformaları (vanilla, RHS, CUP, ...) tarar, kullandıkları KARAKTER MODELİNE
    göre gruplar. Amaç: anatomik ısı için kaç farklı model / UV düzeni boyanacağını görmek.
    Aynı modeli paylaşan onlarca kamuflaj tek TI haritasını paylaşabilir; iş, üniforma
    sayısıyla değil FARKLI MODEL sayısıyla ölçeklenir.

    Çıktı:
      RPT   : [RTI][UNI] özet + modelin yolu, üniforma sayısı, örnek sınıflar,
              hiddenSelections ve hiddenSelectionsMaterials (modeller çoktan aza sıralı)
      Pano  : özet + en kalabalık 30 model (sohbete yapıştırılabilir)

    Yalnızca üniformalar taranır (ItemInfo >> type 801). Yelek, kask, çanta kapsam dışıdır.

    Parametreler: yok
    Dönüş: yok
*/

[] spawn {
    private _t0 = diag_tickTime;
    private _models = createHashMap;
    private _total = 0;

    {
        private _class = configName _x;
        private _unit = getText (_x >> "ItemInfo" >> "uniformClass");
        private _unitCfg = configFile >> "CfgVehicles" >> _unit;

        if (_unit isNotEqualTo "" && {isClass _unitCfg}) then {
            _total = _total + 1;

            private _model = toLower (getText (_unitCfg >> "model"));
            private _entry = _models getOrDefault [_model, [[], getArray (_unitCfg >> "hiddenSelections"), getArray (_unitCfg >> "hiddenSelectionsMaterials")]];

            (_entry select 0) pushBack _class;
            _models set [_model, _entry];
        };
    } forEach ("getNumber (_x >> 'scope') == 2 && {getNumber (_x >> 'ItemInfo' >> 'type') == 801}" configClasses (configFile >> "CfgWeapons"));

    private _family = {
        params ["_class"];

        private _l = toLower _class;
        if ((_l select [0, 3]) isEqualTo "rhs") exitWith {"RHS"};
        if ((_l select [0, 4]) isEqualTo "cup_") exitWith {"CUP"};
        "diger"
    };

    // Aile bazında: [üniforma sayısı, farklı model sayısı]
    private _stats = createHashMap;

    {
        private _entry = _models get _x;
        private _fam = [(_entry select 0) select 0] call _family;
        private _s = _stats getOrDefault [_fam, [0, 0]];

        _s set [0, (_s select 0) + (count (_entry select 0))];
        _s set [1, (_s select 1) + 1];
        _stats set [_fam, _s];
    } forEach (keys _models);

    private _order = (keys _models) apply {[count ((_models get _x) select 0), _x]};
    _order sort false;

    private _out = [];

    private _summary = format [
        "ozet: %1 uniforma, %2 farkli model | RHS %3 | CUP %4 | diger %5 | (uniforma, model) | tarama %6 ms",
        _total,
        count _models,
        _stats getOrDefault ["RHS", [0, 0]],
        _stats getOrDefault ["CUP", [0, 0]],
        _stats getOrDefault ["diger", [0, 0]],
        round ((diag_tickTime - _t0) * 1000)
    ];

    _out pushBack _summary;
    diag_log ("[RTI][UNI] " + _summary);

    {
        _x params ["_count", "_model"];

        private _entry = _models get _model;

        private _line = format [
            "model=%1 | uniforma=%2 | ornek=%3 | selections=%4 | materials=%5",
            _model,
            _count,
            (_entry select 0) select [0, 4],
            _entry select 1,
            _entry select 2
        ];

        diag_log ("[RTI][UNI] " + _line);

        if (_forEachIndex < 30) then {_out pushBack _line};
    } forEach _order;

    copyToClipboard (_out joinString endl);
    systemChat "[RTI] Uniforma raporu panoya kopyalandi (ilk 30 model), tamami RPT'de [RTI][UNI].";
};
