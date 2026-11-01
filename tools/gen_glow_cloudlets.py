#!/usr/bin/env python3
"""
addons/main/spot/CfgCloudlets.hpp dosyasini uretir (12 sinif: RTI_Glow_<S|M|L><1..4>).

Neden ayri uretici: Mikero rapify'i cok satirli #define makrolarinda HEMTT kadar hosgorulu degil;
bu yuzden config'e DUZ siniflar yazilir. Boyut / alfa degerlerini degistirmek icin bu dosyadaki
SIZES / ALPHAS'i duzenleyip calistir:

    python3 tools/gen_glow_cloudlets.py

Cikti ASCII'dir (Mikero rapify icin).
"""
import os

SIZES = [("S", 0.6), ("M", 1.3), ("L", 2.6)]
ALPHAS = [0.10, 0.22, 0.40, 0.65]

HEADER = """\
// ----------------------------------------------------------------------------
//  OTOMATIK URETILDI: tools/gen_glow_cloudlets.py  (elle duzenleme, uretici ile degistir)
//
//  Arac "sicak nokta" (isi lekesi) parcaciklari.
//  Yumusak kenarli yuvarlak sprite (kouleSvetlo): merkezde parlak, kenara dogru
//  sonen radyal gradyan. Rengin alfa degeri 4 kademeden biri (isi seviyesi);
//  boyut S / M / L (arac uzaklastikca buyuk sinif secilir).
//  Sinif adi: RTI_Glow_<boyut><seviye>   ornek: RTI_Glow_M3
//  Renk dizisi 0 -> A -> A -> 0: dogum / olumde ani belirme olmasin diye.
//  NOT: Bu parcaciklarin TI'de sicak cizilip cizilmedigi OYUNDA DOGRULANMADI.
// ----------------------------------------------------------------------------
"""

CLASS = """\

class {name}
{{
    interval = 0.2;
    circleRadius = 0;
    circleVelocity[] = {{0,0,0}};
    particleShape = "\\A3\\data_f\\kouleSvetlo";
    particleFSNtieth = 1;
    particleFSIndex = 0;
    particleFSFrameCount = 1;
    particleFSLoop = 0;
    angle = 0;
    angleVar = 0;
    animationName = "";
    particleType = "Billboard";
    timerPeriod = 1;
    lifeTime = 0.4;
    moveVelocity[] = {{0,0,0}};
    rotationVelocity = 0;
    weight = 0;
    volume = 0;
    rubbing = 0;
    size[] = {{{sz},{sz}}};
    color[] = {{{{1,0.95,0.85,0}},{{1,0.95,0.85,{a}}},{{1,0.95,0.85,{a}}},{{1,0.95,0.85,0}}}};
    animationSpeed[] = {{1}};
    randomDirectionPeriod = 0;
    randomDirectionIntensity = 0;
    onTimerScript = "";
    beforeDestroyScript = "";
    lifeTimeVar = 0;
    positionVar[] = {{0,0,0}};
    moveVelocityVar[] = {{0,0,0}};
    rotationVelocityVar = 0;
    sizeVar = 0;
    colorVar[] = {{0,0,0,0}};
    randomDirectionPeriodVar = 0;
    randomDirectionIntensityVar = 0;
}};
"""

out = HEADER
for tag, sz in SIZES:
    for level, a in enumerate(ALPHAS, start=1):
        out += CLASS.format(name=f"RTI_Glow_{tag}{level}", sz=f"{sz:g}", a=f"{a:.2f}")

path = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "addons", "main", "spot", "CfgCloudlets.hpp")
with open(path, "w", newline="\n") as f:
    f.write(out)
print("yazildi:", os.path.normpath(path), len(out), "bayt")
