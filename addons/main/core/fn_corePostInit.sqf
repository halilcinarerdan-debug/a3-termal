/*
    Fonksiyon: RTI_fnc_corePostInit
    Çalışma yeri: İstemci (XEH_postInit.sqf çağırır)

    Yüklü modlardaki (vanilla, RHS, CUP, ...) termal optiklerin taramasını arka planda başlatır.
    Tarama sonucu RPT'ye yazılır ve RTI_thermalOptics değişkeninde tutulur.

    Parametreler: yok
    Dönüş: yok
*/

[] spawn RTI_fnc_coreScanScopes;
