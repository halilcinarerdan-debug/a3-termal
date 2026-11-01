class core
{
    file = "z\rti\addons\main\core";

    class coreInitSettings {};
    class coreCaps {};
    class corePostInit {};
    class coreScanScopes {};

    // Teshis (debug konsolu): call RTI_fnc_diag; [arac, sn] call RTI_fnc_diagTrace; call RTI_fnc_testHeatSpot;
    class diag {};
    class diagTrace {};
    class testHeatSpot {};

    // Uniformalari karakter modeline gore gruplar (anatomik isi isinin buyuklugunu olcer)
    class exportUniforms {};

    // Cimen clutter siniflarini ve yakin arazi nesnelerini listeler (cimen yamalarinin kaynagi)
    class exportClutter {};

    // Bir sinifin (silah / birim / arac) hangi modda tanimli oldugunu gosterir (termal ozellik kimden?)
    class diagOwner {};
};
