// ----------------------------------------------------------------------------
//  Termalde "sicak nokta" olarak kullanilan parcacik siniflari.
//  Hepsi bagimsizdir (vanilla CfgCloudlets >> Default'a bagimli degil).
//  S / M / L: namlu atesi boyutlari. Uzak atislarda daha buyuk sinif secilir
//  (flash\fn_flashSpawn.sqf), cunku kucuk bir nokta uzakta piksel altina duser.
//  RTI_HeatSpotTest: RTI_fnc_testHeatSpot ile TI'de gorunurluk testi.
//  NOT: Bu siniflarin TI'de sicak cizilip cizilmedigi OYUNDA DOGRULANMADI.
// ----------------------------------------------------------------------------

class RTI_MuzzleHeat_S
{
    interval = 0.01;
    circleRadius = 0;
    circleVelocity[] = {0,0,0};
    particleShape = "\A3\data_f\ParticleEffects\Universal\Universal";
    particleFSNtieth = 16;
    particleFSIndex = 12;
    particleFSFrameCount = 8;
    particleFSLoop = 0;
    angle = 0;
    angleVar = 0;
    animationName = "";
    particleType = "Billboard";
    timerPeriod = 1;
    lifeTime = 0.08;
    moveVelocity[] = {0,0,0};
    rotationVelocity = 0;
    weight = 0;
    volume = 0;
    rubbing = 0;
    size[] = {0.25,0.12};
    color[] = {{1,0.95,0.8,1},{1,0.6,0.25,0}};
    animationSpeed[] = {1};
    randomDirectionPeriod = 0;
    randomDirectionIntensity = 0;
    onTimerScript = "";
    beforeDestroyScript = "";
    lifeTimeVar = 0.02;
    positionVar[] = {0.03,0.03,0.03};
    moveVelocityVar[] = {0,0,0};
    rotationVelocityVar = 0;
    sizeVar = 0.03;
    colorVar[] = {0,0,0,0};
    randomDirectionPeriodVar = 0;
    randomDirectionIntensityVar = 0;
};

class RTI_MuzzleHeat_M
{
    interval = 0.01;
    circleRadius = 0;
    circleVelocity[] = {0,0,0};
    particleShape = "\A3\data_f\ParticleEffects\Universal\Universal";
    particleFSNtieth = 16;
    particleFSIndex = 12;
    particleFSFrameCount = 8;
    particleFSLoop = 0;
    angle = 0;
    angleVar = 0;
    animationName = "";
    particleType = "Billboard";
    timerPeriod = 1;
    lifeTime = 0.09;
    moveVelocity[] = {0,0,0};
    rotationVelocity = 0;
    weight = 0;
    volume = 0;
    rubbing = 0;
    size[] = {0.6,0.3};
    color[] = {{1,0.95,0.8,1},{1,0.6,0.25,0}};
    animationSpeed[] = {1};
    randomDirectionPeriod = 0;
    randomDirectionIntensity = 0;
    onTimerScript = "";
    beforeDestroyScript = "";
    lifeTimeVar = 0.02;
    positionVar[] = {0.05,0.05,0.05};
    moveVelocityVar[] = {0,0,0};
    rotationVelocityVar = 0;
    sizeVar = 0.08;
    colorVar[] = {0,0,0,0};
    randomDirectionPeriodVar = 0;
    randomDirectionIntensityVar = 0;
};

class RTI_MuzzleHeat_L
{
    interval = 0.01;
    circleRadius = 0;
    circleVelocity[] = {0,0,0};
    particleShape = "\A3\data_f\ParticleEffects\Universal\Universal";
    particleFSNtieth = 16;
    particleFSIndex = 12;
    particleFSFrameCount = 8;
    particleFSLoop = 0;
    angle = 0;
    angleVar = 0;
    animationName = "";
    particleType = "Billboard";
    timerPeriod = 1;
    lifeTime = 0.1;
    moveVelocity[] = {0,0,0};
    rotationVelocity = 0;
    weight = 0;
    volume = 0;
    rubbing = 0;
    size[] = {1.4,0.7};
    color[] = {{1,0.95,0.8,1},{1,0.6,0.25,0}};
    animationSpeed[] = {1};
    randomDirectionPeriod = 0;
    randomDirectionIntensity = 0;
    onTimerScript = "";
    beforeDestroyScript = "";
    lifeTimeVar = 0.02;
    positionVar[] = {0.1,0.1,0.1};
    moveVelocityVar[] = {0,0,0};
    rotationVelocityVar = 0;
    sizeVar = 0.15;
    colorVar[] = {0,0,0,0};
    randomDirectionPeriodVar = 0;
    randomDirectionIntensityVar = 0;
};

class RTI_HeatSpotTest
{
    interval = 0.03;
    circleRadius = 0;
    circleVelocity[] = {0,0,0};
    particleShape = "\A3\data_f\ParticleEffects\Universal\Universal";
    particleFSNtieth = 16;
    particleFSIndex = 12;
    particleFSFrameCount = 8;
    particleFSLoop = 0;
    angle = 0;
    angleVar = 0;
    animationName = "";
    particleType = "Billboard";
    timerPeriod = 1;
    lifeTime = 0.6;
    moveVelocity[] = {0,0,0.2};
    rotationVelocity = 0;
    weight = 0;
    volume = 0;
    rubbing = 0;
    size[] = {0.8,0.5};
    color[] = {{1,0.95,0.8,1},{1,0.6,0.25,0}};
    animationSpeed[] = {1};
    randomDirectionPeriod = 0;
    randomDirectionIntensity = 0;
    onTimerScript = "";
    beforeDestroyScript = "";
    lifeTimeVar = 0.1;
    positionVar[] = {0.1,0.1,0.1};
    moveVelocityVar[] = {0,0,0};
    rotationVelocityVar = 0;
    sizeVar = 0.1;
    colorVar[] = {0,0,0,0};
    randomDirectionPeriodVar = 0;
    randomDirectionIntensityVar = 0;
};
