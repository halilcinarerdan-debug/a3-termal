/*
    Fonksiyon: RTI_fnc_vehHeat
    Çalışma yeri: herhangi makine (saf hesap)

    Birinci derece ısıl model:  dH/dt = (hedef - H) / tau
    Kapalı çözüm:  H(t) = hedef + (H0 - hedef) * exp(-(t - t0) / tau)
    Hedef >= H ise ısınma (tau = tauUp), değilse soğuma (tau = tauDown).
    Durum yalnızca hedef değişince yayınlandığı için her istemci aynı sonucu bulur.

    Parametreler:
        0: ARRAY  - durum [H0, t0 (serverTime), hedef]
        1: NUMBER - şimdiki serverTime
        2: NUMBER - ısınma zaman sabiti (sn)
        3: NUMBER - soğuma zaman sabiti (sn)

    Dönüş: NUMBER - 0..1
*/

params ["_state", "_now", "_tauUp", "_tauDown"];
_state params ["_h0", "_t0", "_target"];

private _tau = ([_tauDown, _tauUp] select (_target >= _h0)) max 0.1;
private _elapsed = (_now - _t0) max 0;

((_target + ((_h0 - _target) * exp (-(_elapsed / _tau)))) min 1) max 0
