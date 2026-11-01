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

    // Post-process termalde cizilir mi? Ekrani 7 sn boyar (kirmizi / mavi): call RTI_fnc_ppTest;
    class ppTest {};

    // Kalibrasyon merdiveni: bir PP parametresini adim adim degistirip sohbete yazar: ["offset"] call RTI_fnc_ppLadder;
    class ppLadder {};

    // Notr ayarda bile ekran kararirsa: her PP efektini tek basina ve ForceInNVG acik/kapali dener: call RTI_fnc_ppBisect;
    class ppBisect {};

    // HDR pozu (setAperture) merdiveni: termaldeki asil parlaklik bu katmandan gelebilir: call RTI_fnc_apertureLadder;
    class apertureLadder {};
};
