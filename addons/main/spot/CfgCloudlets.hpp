// ----------------------------------------------------------------------------
//  Arac "sicak nokta" (isi lekesi) parcaciklari.
//  Yumusak kenarli yuvarlak sprite (kouleSvetlo): merkezde parlak, kenara dogru
//  sonen radyal gradyan. Rengin alfa degeri 4 kademeden biri (isi seviyesi);
//  boyut S / M / L (arac uzaklastikca buyuk sinif secilir).
//  Sinif adi: RTI_Glow_<boyut><seviye>   ornek: RTI_Glow_M3
//  Renk dizisi 0 -> A -> A -> 0: dogum / olumde ani belirme olmasin diye.
//  NOT: Bu parcaciklarin TI'de sicak cizilip cizilmedigi OYUNDA DOGRULANMADI.
// ----------------------------------------------------------------------------

#define RTI_GLOW(NAME,SZ,ALPHA) \
class NAME \
{ \
    interval = 0.2; \
    circleRadius = 0; \
    circleVelocity[] = {0,0,0}; \
    particleShape = "\A3\data_f\kouleSvetlo"; \
    particleFSNtieth = 1; \
    particleFSIndex = 0; \
    particleFSFrameCount = 1; \
    particleFSLoop = 0; \
    angle = 0; \
    angleVar = 0; \
    animationName = ""; \
    particleType = "Billboard"; \
    timerPeriod = 1; \
    lifeTime = 0.4; \
    moveVelocity[] = {0,0,0}; \
    rotationVelocity = 0; \
    weight = 0; \
    volume = 0; \
    rubbing = 0; \
    size[] = {SZ,SZ}; \
    color[] = {{1,0.95,0.85,0},{1,0.95,0.85,ALPHA},{1,0.95,0.85,ALPHA},{1,0.95,0.85,0}}; \
    animationSpeed[] = {1}; \
    randomDirectionPeriod = 0; \
    randomDirectionIntensity = 0; \
    onTimerScript = ""; \
    beforeDestroyScript = ""; \
    lifeTimeVar = 0; \
    positionVar[] = {0,0,0}; \
    moveVelocityVar[] = {0,0,0}; \
    rotationVelocityVar = 0; \
    sizeVar = 0; \
    colorVar[] = {0,0,0,0}; \
    randomDirectionPeriodVar = 0; \
    randomDirectionIntensityVar = 0; \
};

RTI_GLOW(RTI_Glow_S1,0.6,0.10)
RTI_GLOW(RTI_Glow_S2,0.6,0.22)
RTI_GLOW(RTI_Glow_S3,0.6,0.40)
RTI_GLOW(RTI_Glow_S4,0.6,0.65)

RTI_GLOW(RTI_Glow_M1,1.3,0.10)
RTI_GLOW(RTI_Glow_M2,1.3,0.22)
RTI_GLOW(RTI_Glow_M3,1.3,0.40)
RTI_GLOW(RTI_Glow_M4,1.3,0.65)

RTI_GLOW(RTI_Glow_L1,2.6,0.10)
RTI_GLOW(RTI_Glow_L2,2.6,0.22)
RTI_GLOW(RTI_Glow_L3,2.6,0.40)
RTI_GLOW(RTI_Glow_L4,2.6,0.65)
