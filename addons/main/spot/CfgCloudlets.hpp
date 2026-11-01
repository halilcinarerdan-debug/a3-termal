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

class RTI_Glow_S1
{
    interval = 0.2;
    circleRadius = 0;
    circleVelocity[] = {0,0,0};
    particleShape = "\A3\data_f\kouleSvetlo";
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
    moveVelocity[] = {0,0,0};
    rotationVelocity = 0;
    weight = 0;
    volume = 0;
    rubbing = 0;
    size[] = {0.6,0.6};
    color[] = {{1,0.95,0.85,0},{1,0.95,0.85,0.10},{1,0.95,0.85,0.10},{1,0.95,0.85,0}};
    animationSpeed[] = {1};
    randomDirectionPeriod = 0;
    randomDirectionIntensity = 0;
    onTimerScript = "";
    beforeDestroyScript = "";
    lifeTimeVar = 0;
    positionVar[] = {0,0,0};
    moveVelocityVar[] = {0,0,0};
    rotationVelocityVar = 0;
    sizeVar = 0;
    colorVar[] = {0,0,0,0};
    randomDirectionPeriodVar = 0;
    randomDirectionIntensityVar = 0;
};

class RTI_Glow_S2
{
    interval = 0.2;
    circleRadius = 0;
    circleVelocity[] = {0,0,0};
    particleShape = "\A3\data_f\kouleSvetlo";
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
    moveVelocity[] = {0,0,0};
    rotationVelocity = 0;
    weight = 0;
    volume = 0;
    rubbing = 0;
    size[] = {0.6,0.6};
    color[] = {{1,0.95,0.85,0},{1,0.95,0.85,0.22},{1,0.95,0.85,0.22},{1,0.95,0.85,0}};
    animationSpeed[] = {1};
    randomDirectionPeriod = 0;
    randomDirectionIntensity = 0;
    onTimerScript = "";
    beforeDestroyScript = "";
    lifeTimeVar = 0;
    positionVar[] = {0,0,0};
    moveVelocityVar[] = {0,0,0};
    rotationVelocityVar = 0;
    sizeVar = 0;
    colorVar[] = {0,0,0,0};
    randomDirectionPeriodVar = 0;
    randomDirectionIntensityVar = 0;
};

class RTI_Glow_S3
{
    interval = 0.2;
    circleRadius = 0;
    circleVelocity[] = {0,0,0};
    particleShape = "\A3\data_f\kouleSvetlo";
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
    moveVelocity[] = {0,0,0};
    rotationVelocity = 0;
    weight = 0;
    volume = 0;
    rubbing = 0;
    size[] = {0.6,0.6};
    color[] = {{1,0.95,0.85,0},{1,0.95,0.85,0.40},{1,0.95,0.85,0.40},{1,0.95,0.85,0}};
    animationSpeed[] = {1};
    randomDirectionPeriod = 0;
    randomDirectionIntensity = 0;
    onTimerScript = "";
    beforeDestroyScript = "";
    lifeTimeVar = 0;
    positionVar[] = {0,0,0};
    moveVelocityVar[] = {0,0,0};
    rotationVelocityVar = 0;
    sizeVar = 0;
    colorVar[] = {0,0,0,0};
    randomDirectionPeriodVar = 0;
    randomDirectionIntensityVar = 0;
};

class RTI_Glow_S4
{
    interval = 0.2;
    circleRadius = 0;
    circleVelocity[] = {0,0,0};
    particleShape = "\A3\data_f\kouleSvetlo";
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
    moveVelocity[] = {0,0,0};
    rotationVelocity = 0;
    weight = 0;
    volume = 0;
    rubbing = 0;
    size[] = {0.6,0.6};
    color[] = {{1,0.95,0.85,0},{1,0.95,0.85,0.65},{1,0.95,0.85,0.65},{1,0.95,0.85,0}};
    animationSpeed[] = {1};
    randomDirectionPeriod = 0;
    randomDirectionIntensity = 0;
    onTimerScript = "";
    beforeDestroyScript = "";
    lifeTimeVar = 0;
    positionVar[] = {0,0,0};
    moveVelocityVar[] = {0,0,0};
    rotationVelocityVar = 0;
    sizeVar = 0;
    colorVar[] = {0,0,0,0};
    randomDirectionPeriodVar = 0;
    randomDirectionIntensityVar = 0;
};

class RTI_Glow_M1
{
    interval = 0.2;
    circleRadius = 0;
    circleVelocity[] = {0,0,0};
    particleShape = "\A3\data_f\kouleSvetlo";
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
    moveVelocity[] = {0,0,0};
    rotationVelocity = 0;
    weight = 0;
    volume = 0;
    rubbing = 0;
    size[] = {1.3,1.3};
    color[] = {{1,0.95,0.85,0},{1,0.95,0.85,0.10},{1,0.95,0.85,0.10},{1,0.95,0.85,0}};
    animationSpeed[] = {1};
    randomDirectionPeriod = 0;
    randomDirectionIntensity = 0;
    onTimerScript = "";
    beforeDestroyScript = "";
    lifeTimeVar = 0;
    positionVar[] = {0,0,0};
    moveVelocityVar[] = {0,0,0};
    rotationVelocityVar = 0;
    sizeVar = 0;
    colorVar[] = {0,0,0,0};
    randomDirectionPeriodVar = 0;
    randomDirectionIntensityVar = 0;
};

class RTI_Glow_M2
{
    interval = 0.2;
    circleRadius = 0;
    circleVelocity[] = {0,0,0};
    particleShape = "\A3\data_f\kouleSvetlo";
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
    moveVelocity[] = {0,0,0};
    rotationVelocity = 0;
    weight = 0;
    volume = 0;
    rubbing = 0;
    size[] = {1.3,1.3};
    color[] = {{1,0.95,0.85,0},{1,0.95,0.85,0.22},{1,0.95,0.85,0.22},{1,0.95,0.85,0}};
    animationSpeed[] = {1};
    randomDirectionPeriod = 0;
    randomDirectionIntensity = 0;
    onTimerScript = "";
    beforeDestroyScript = "";
    lifeTimeVar = 0;
    positionVar[] = {0,0,0};
    moveVelocityVar[] = {0,0,0};
    rotationVelocityVar = 0;
    sizeVar = 0;
    colorVar[] = {0,0,0,0};
    randomDirectionPeriodVar = 0;
    randomDirectionIntensityVar = 0;
};

class RTI_Glow_M3
{
    interval = 0.2;
    circleRadius = 0;
    circleVelocity[] = {0,0,0};
    particleShape = "\A3\data_f\kouleSvetlo";
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
    moveVelocity[] = {0,0,0};
    rotationVelocity = 0;
    weight = 0;
    volume = 0;
    rubbing = 0;
    size[] = {1.3,1.3};
    color[] = {{1,0.95,0.85,0},{1,0.95,0.85,0.40},{1,0.95,0.85,0.40},{1,0.95,0.85,0}};
    animationSpeed[] = {1};
    randomDirectionPeriod = 0;
    randomDirectionIntensity = 0;
    onTimerScript = "";
    beforeDestroyScript = "";
    lifeTimeVar = 0;
    positionVar[] = {0,0,0};
    moveVelocityVar[] = {0,0,0};
    rotationVelocityVar = 0;
    sizeVar = 0;
    colorVar[] = {0,0,0,0};
    randomDirectionPeriodVar = 0;
    randomDirectionIntensityVar = 0;
};

class RTI_Glow_M4
{
    interval = 0.2;
    circleRadius = 0;
    circleVelocity[] = {0,0,0};
    particleShape = "\A3\data_f\kouleSvetlo";
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
    moveVelocity[] = {0,0,0};
    rotationVelocity = 0;
    weight = 0;
    volume = 0;
    rubbing = 0;
    size[] = {1.3,1.3};
    color[] = {{1,0.95,0.85,0},{1,0.95,0.85,0.65},{1,0.95,0.85,0.65},{1,0.95,0.85,0}};
    animationSpeed[] = {1};
    randomDirectionPeriod = 0;
    randomDirectionIntensity = 0;
    onTimerScript = "";
    beforeDestroyScript = "";
    lifeTimeVar = 0;
    positionVar[] = {0,0,0};
    moveVelocityVar[] = {0,0,0};
    rotationVelocityVar = 0;
    sizeVar = 0;
    colorVar[] = {0,0,0,0};
    randomDirectionPeriodVar = 0;
    randomDirectionIntensityVar = 0;
};

class RTI_Glow_L1
{
    interval = 0.2;
    circleRadius = 0;
    circleVelocity[] = {0,0,0};
    particleShape = "\A3\data_f\kouleSvetlo";
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
    moveVelocity[] = {0,0,0};
    rotationVelocity = 0;
    weight = 0;
    volume = 0;
    rubbing = 0;
    size[] = {2.6,2.6};
    color[] = {{1,0.95,0.85,0},{1,0.95,0.85,0.10},{1,0.95,0.85,0.10},{1,0.95,0.85,0}};
    animationSpeed[] = {1};
    randomDirectionPeriod = 0;
    randomDirectionIntensity = 0;
    onTimerScript = "";
    beforeDestroyScript = "";
    lifeTimeVar = 0;
    positionVar[] = {0,0,0};
    moveVelocityVar[] = {0,0,0};
    rotationVelocityVar = 0;
    sizeVar = 0;
    colorVar[] = {0,0,0,0};
    randomDirectionPeriodVar = 0;
    randomDirectionIntensityVar = 0;
};

class RTI_Glow_L2
{
    interval = 0.2;
    circleRadius = 0;
    circleVelocity[] = {0,0,0};
    particleShape = "\A3\data_f\kouleSvetlo";
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
    moveVelocity[] = {0,0,0};
    rotationVelocity = 0;
    weight = 0;
    volume = 0;
    rubbing = 0;
    size[] = {2.6,2.6};
    color[] = {{1,0.95,0.85,0},{1,0.95,0.85,0.22},{1,0.95,0.85,0.22},{1,0.95,0.85,0}};
    animationSpeed[] = {1};
    randomDirectionPeriod = 0;
    randomDirectionIntensity = 0;
    onTimerScript = "";
    beforeDestroyScript = "";
    lifeTimeVar = 0;
    positionVar[] = {0,0,0};
    moveVelocityVar[] = {0,0,0};
    rotationVelocityVar = 0;
    sizeVar = 0;
    colorVar[] = {0,0,0,0};
    randomDirectionPeriodVar = 0;
    randomDirectionIntensityVar = 0;
};

class RTI_Glow_L3
{
    interval = 0.2;
    circleRadius = 0;
    circleVelocity[] = {0,0,0};
    particleShape = "\A3\data_f\kouleSvetlo";
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
    moveVelocity[] = {0,0,0};
    rotationVelocity = 0;
    weight = 0;
    volume = 0;
    rubbing = 0;
    size[] = {2.6,2.6};
    color[] = {{1,0.95,0.85,0},{1,0.95,0.85,0.40},{1,0.95,0.85,0.40},{1,0.95,0.85,0}};
    animationSpeed[] = {1};
    randomDirectionPeriod = 0;
    randomDirectionIntensity = 0;
    onTimerScript = "";
    beforeDestroyScript = "";
    lifeTimeVar = 0;
    positionVar[] = {0,0,0};
    moveVelocityVar[] = {0,0,0};
    rotationVelocityVar = 0;
    sizeVar = 0;
    colorVar[] = {0,0,0,0};
    randomDirectionPeriodVar = 0;
    randomDirectionIntensityVar = 0;
};

class RTI_Glow_L4
{
    interval = 0.2;
    circleRadius = 0;
    circleVelocity[] = {0,0,0};
    particleShape = "\A3\data_f\kouleSvetlo";
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
    moveVelocity[] = {0,0,0};
    rotationVelocity = 0;
    weight = 0;
    volume = 0;
    rubbing = 0;
    size[] = {2.6,2.6};
    color[] = {{1,0.95,0.85,0},{1,0.95,0.85,0.65},{1,0.95,0.85,0.65},{1,0.95,0.85,0}};
    animationSpeed[] = {1};
    randomDirectionPeriod = 0;
    randomDirectionIntensity = 0;
    onTimerScript = "";
    beforeDestroyScript = "";
    lifeTimeVar = 0;
    positionVar[] = {0,0,0};
    moveVelocityVar[] = {0,0,0};
    rotationVelocityVar = 0;
    sizeVar = 0;
    colorVar[] = {0,0,0,0};
    randomDirectionPeriodVar = 0;
    randomDirectionIntensityVar = 0;
};
