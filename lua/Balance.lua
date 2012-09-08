// ======= Copyright (c) 2003-2012, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\Balance.lua
//
//    Created by:   Charlie Cleveland (charlie@unknownworlds.com)
//
// Auto-generated. Copy and paste from balance spreadsheet.
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================
Script.Load("lua/BalanceHealth.lua")
Script.Load("lua/BalanceMisc.lua")

// used as fallback
kDefaultBuildTime = 8

// MARINE COSTS
kCommandStationCost = 15

kExtractorCost = 10
kResourceUpgradeResearchCost = 5

kInfantryPortalCost = 15

kArmoryCost = 10
kArmsLabCost = 25

kAdvancedArmoryUpgradeCost = 20
kPrototypeLabCost = 40

kSentryCost = 10
kPowerPackCost = 15
kPowerNodeCost = 0

kWelderDropCost = 5
kMinesDropCost = 5
kShotgunDropCost = 10
kGrenadeLauncherDropCost = 15
kFlamethrowerDropCost = 15
kJetpackDropCost = 10
kExosuitDropCost = 40

kMACCost = 5
kMineCost = 15
kMineResearchCost  = 15
kTechEMPResearchCost = 15
kTechMACSpeedResearchCost = 15

kWelderTechResearchTime = 10

kShotgunCost = 20
kShotgunTechResearchCost = 20

kGrenadeLauncherCost = 25
kGrenadeLauncherTechResearchCost = 20
kNerveGasTechResearchCost = 20

kFlamethrowerCost = 30
kFlamethrowerTechResearchCost = 25

kRoboticsFactoryCost = 15
kUpgradeRoboticsFactoryCost = 20
kUpgradeRoboticsFactoryTime = 40
kARCCost = 20
kARCSplashTechResearchCost = 15
kARCArmorTechResearchCost = 15
kWelderTechResearchCost = 10
kWelderCost = 5

kJetpackCost = 10
kJetpackTechResearchCost = 25
kJetpackFuelTechResearchCost = 15
kJetpackArmorTechResearchCost = 15

kExosuitCost = 50
kExosuitTechResearchCost = 30
kExosuitLockdownTechResearchCost = 20
kExosuitUpgradeTechResearchCost = 20
kDualExosuitCost = 75

kMinigunCost = 30
kDualMinigunCost = 25
kDualMinigunTechResearchCost = 20

kWeapons1ResearchCost = 20
kWeapons2ResearchCost = 30
kWeapons3ResearchCost = 40
kArmor1ResearchCost = 20
kArmor2ResearchCost = 30
kArmor3ResearchCost = 40

kCatPackCost = 2
kCatPackTechResearchCost = 10

kRifleUpgradeTechResearchCost = 10

kObservatoryCost = 15
kPhaseGateCost = 15
kPhaseTechResearchCost = 15



kHiveCost = 40

kHarvesterCost = 10

kShellCost = 15
kCragCost = 15
kEvolveBabblersCost = 15

kSpurCost = 10
kShiftCost = 10
kEvolveEchoCost = 15

kVeilCost = 5
kShadeCost = 15
kEvolveHallucinationsCost = 15

kWhipCost = 15
kEvolveBombardCost = 15

kGorgeCost = 10
kLerkCost = 30
kFadeCost = 50
kOnosCost = 75

kGorgeEggCost = 10
kLerkEggCost = 20
kFadeEggCost = 30
kOnosEggCost = 40

kHydraCost = 3
kClogCost = 0
kRuptureCost = 1

kEnzymeCloudDuration = 3

kAuraResearchCost = 15
kFeintResearchCost = 10
kSilenceResearchCost = 10
kCamouflageResearchCost = 10


kCarapaceResearchCost = 15
kRegenerationResearchCost = 10

kCelerityResearchCost = 15
kHyperMutationResearchCost = 5

kAdrenalineResearchCost = 15


kCarapaceCost = 0
kRegenerationCost = 0
kCamouflageCost = 0
kAuraCost = 0
kSilenceCost = 0
kHydraAbilityCost = 0
kPiercingCost = 0
kAdrenalineCost = 0
kFeintCost = 0
kSapCost = 0
kBoneShieldCost = 0
kCelerityCost = 0
kHyperMutationCost = 0

kPlayingTeamInitialTeamRes = 50
kMaxTeamResources = 200

kPlayerInitialIndivRes = 20
kMaxPersonalResources = 100

kResourceTowerResourceInterval = 6
kTeamResourcePerTick = 1

kPlayerResPerInterval = 0.125

kKillRewardMin = 0
kKillRewardMax = 0
kKillTeamReward = 0






















// MARINE DAMAGE
kRifleDamage = 10
kRifleDamageType = kDamageType.Normal
kRifleClipSize = 50


kRifleMeleeDamage = 20
kRifleMeleeDamageType = kDamageType.Normal


kPistolDamage = 25
kPistolDamageType = kDamageType.Light
kPistolClipSize = 10

kPistolAltDamage = 40


kWelderDamagePerSecond = 30
kWelderDamageType = kDamageType.Flame
kWelderFireDelay = 0.1

kAxeDamage = 30
kAxeDamageType = kDamageType.Structural


kGrenadeLauncherGrenadeDamage = 130
kGrenadeLauncherGrenadeDamageType = kDamageType.Structural
kGrenadeLauncherClipSize = 4
kGrenadeLauncherGrenadeDamageRadius = 8
kGrenadeLifetime = 2.0

kShotgunDamage = 17
kShotgunDamageType = kDamageType.Normal
kShotgunClipSize = 8
kShotgunBulletsPerShot = 10
kShotgunRange = 30

kNadeLauncherClipSize = 4

kFlamethrowerDamage = 7.5
kFlamethrowerDamageType = kDamageType.Flame
kFlamethrowerClipSize = 30

kBurnDamagePerStackPerSecond = 2
kFlamethrowerMaxStacks = 20
kFlamethrowerBurnDuration = 6
kFlamethrowerStackRate = 0.4
kFlameRadius = 1.8
kFlameDamageStackWeight = 0.5

kMinigunDamage = 25
kMinigunDamageType = kDamageType.Heavy
kMinigunClipSize = 250

kClawDamage = 50
kClawDamageType = kDamageType.Structural

kMACAttackDamage = 5
kMACAttackDamageType = kDamageType.Normal
kMACAttackFireDelay = 0.6


kMineDamage = 125
kMineDamageType = kDamageType.Light

kSentryAttackDamage = 10
kSentryAttackDamageType = kDamageType.Light
kSentryAttackBaseROF = 0.08
kSentryAttackRandROF = 0.04
kSentryAttackBulletsPerSalvo = 1
kConfusedSentryBaseROF = 1.5

// sentry increases damage when shooting at the same target (resets when switching targets)
kSentryMinAttackDamage = 5
kSentryMaxAttackDamage = 20
kSentryDamageRampUpDuration = 5

kARCDamage = 900
kARCDamageType = kDamageType.Splash // splash damage hits friendly arcs as well
kARCRange = 26
kARCMinRange = 7

kWeapons1DamageScalar = 1.1
kWeapons2DamageScalar = 1.2
kWeapons3DamageScalar = 1.3

kNanoShieldDamageReductionDamage = 0.5

// ALIEN DAMAGE
kBiteDamage = 75
kBiteDamageType = kDamageType.Normal
kBiteEnergyCost = 5.85

kLeapEnergyCost = 45

kParasiteDamage = 10
kParasiteDamageType = kDamageType.Normal
kParasiteEnergyCost = 30

kXenocideDamage = 200
kXenocideDamageType = kDamageType.Normal
kXenocideRange = 14
kXenocideEnergyCost = 30

kSpitDamage = 40
kSpitDamageType = kDamageType.Normal
kSpitEnergyCost = 7

// Also see kHealsprayHealStructureRate
kHealsprayDamage = 8
kHealsprayDamageType = kDamageType.Biological
kHealsprayFireDelay = 0.8
kHealsprayEnergyCost = 12
kHealsprayRadius = 3.5

kBileBombDamage = 70 // per second
kBileBombDamageType = kDamageType.Corrode
kBileBombEnergyCost = 20
kBileBombDuration = 5

kLerkBiteDamage = 50
kBitePoisonDamage = 6 // per second
kPoisonBiteDuration = 6
kLerkBiteEnergyCost = 5
kLerkBiteDamageType = kDamageType.Light

kUmbraEnergyCost = 25
kUmbraDuration = 5

kSpikeMaxDamage = 18
kSpikeMinDamage = 15
kSpikeDamageType = kDamageType.Puncture
kSpikeEnergyCost = 1.8
kSpikesAttackDelay = 0.07
kSpikeMinDamageRange = 9
kSpikeMaxDamageRange = 2
kSpikesPerShot = 1
kSpikesRange = 30 -- As as shotgun range

kSporesDamageType = kDamageType.Gas
kSporesDustDamagePerSecond = 13
kSporesDustFireDelay = 0.18
kSporesCloudFireDelay = 0.8
kSporesDustEnergyCost = 5
kSporesDustCloudRadius = 1.5
kSporesDustCloudLifetime = 8


kSwipeDamage = 65
kSwipeDamageType = kDamageType.Puncture
kSwipeEnergyCost = 6

kStabDamage = 160
kStabDamageType = kDamageType.Puncture
kStabEnergyCost = 20

kVortexEnergyCost = 60

kStartBlinkEnergyCost = 8
kBlinkEnergyCost = 40
kHealthOnBlink = 0


kGoreDamage = 95
kGoreDamageType = kDamageType.Puncture
kGoreEnergyCost = 12
kGoreMarineTossEnergyCost = 12

kSmashDamage = 100
kSmashDamageType = kDamageType.Door
kSmashEnergyCost = 13

kPrimalScreamEnergyCost = 40

kChargeMaxDamage = 4
kChargeMinDamage = 1

kStompEnergyCost = 40
kStompRange = 12
kDisruptMarineTime = 2
kShockwaveSpeed = 10



kDrifterAttackDamage = 5
kDrifterAttackDamageType = kDamageType.Normal
kDrifterAttackFireDelay = 0.6


kMelee1DamageScalar = 1.1
kMelee2DamageScalar = 1.2
kMelee3DamageScalar = 1.3

kWhipBombardDamage = 1200
kWhipBombardDamageType = kDamageType.StructuresOnlyLight
kWhipBombardRadius = 3
kWhipBombardRange = 10
kWhipBombardROF = 6





// SPAWN TIMES
kMarineRespawnTime = 7

// alien spawn
kMaxAliensPerWave = 4

// every 4 seconds an egg is generated, scales with player size
kEggSpawnTime = 4
// hive triggers a spawn wave every kAlienWaveSpawnInterval seconds
kAlienWaveSpawnInterval = 11
// add this amount of time per alien after the first
kWaveSpawnTimePerAlien = 4

// when kEmergencySpawnThreshold or more players are in queue kEmergencyMinSpawnTime is used instead of kAlienEggMinSpawnTime
// this values affect only egg generation
kEmergencySpawnThreshold = 5
kEmergencyMinSpawnTime = 6

kAlienEggMinSpawnTime = 8
kAlienEggMaxSpawnTime = 60
kAlienEggPlayerScalar = 10
kAlienEggSinScalar = 7
kAlienEggsPerHive = 9

// BUILD/RESEARCH TIMES
kRecycleTime = 12
kArmoryBuildTime = 12
kAdvancedArmoryResearchTime = 90
kWeaponsModuleAddonTime = 40
kPrototypeLabBuildTime = 20
kArmsLabBuildTime = 19

kMACBuildTime = 5
kExtractorBuildTime = 12
kResourceUpgradeResearchTime = 30
kResourceUpgradeAmount = 0.3333

kInfantryPortalBuildTime = 7

kRifleUpgradeTechResearchTime = 20
kShotgunTechResearchTime = 30
kDualMinigunTechResearchTime = 20
kGrenadeLauncherTechResearchTime = 20

kCommandStationBuildTime = 15

kPowerPointBuildTime = 3
kPowerPackBuildTime = 10

kRoboticsFactoryBuildTime = 17
kARCBuildTime = 20
kARCSplashTechResearchTime = 30
kARCArmorTechResearchTime = 30

kNanoShieldDuration = 8
kSentryBuildTime = 4

kMineResearchTime  = 20
kTechEMPResearchTime = 60
kTechMACSpeedResearchTime = 15

kJetpackTechResearchTime = 90
kJetpackFuelTechResearchTime = 60
kJetpackArmorTechResearchTime = 60
kExosuitTechResearchTime = 90
kExosuitLockdownTechResearchTime = 60
kExosuitUpgradeTechResearchTime = 60

kFlamethrowerTechResearchTime = 60
kFlamethrowerAltTechResearchTime = 60

kNerveGasTechResearchTime = 60

kDualMinigunTechResearchTime = 60
kCatPackTechResearchTime = 15

kObservatoryBuildTime = 15
kPhaseTechResearchCost = 15
kPhaseTechResearchTime = 45
kPhaseGateBuildTime = 12

kWeapons1ResearchTime = 60
kWeapons2ResearchTime = 90
kWeapons3ResearchTime = 120
kArmor1ResearchTime = 60
kArmor2ResearchTime = 90
kArmor3ResearchTime = 120


kHiveBuildTime = 120

kDrifterBuildTime = 4
kHarvesterBuildTime = 45

kShellBuildTime = 18
kCragBuildTime = 25
kEvolveBabblersResearchTime = 30

kWhipBuildTime = 30
kEvolveBombardResearchTime = 15

kSpurBuildTime = 16
kShiftBuildTime = 18
kEvolveEchoResearchTime = 30

kVeilBuildTime = 14
kShadeBuildTime = 18
kEvolveHallucinationsResearchTime = 30

kHydraBuildTime = 10
kCystBuildTime = 1

kSkulkGestateTime = 3
kGorgeGestateTime = 10
kLerkGestateTime = 15
kFadeGestateTime = 25
kOnosGestateTime = 30

kEvolutionGestateTime = 3

kLeapResearchCost = 25
kLeapResearchTime = 60
kBileBombResearchCost = 20
kBileBombResearchTime = 60
kSporesResearchCost = 20
kSporesResearchTime = 90
kBlinkResearchCost = 30
kBlinkResearchTime = 90
kStompResearchCost = 30
kStompResearchTime = 90

kXenocideResearchCost = 40
kXenocideResearchTime = 120
kWebStalkResearchCost = 40
kWebStalkResearchTime = 90
kUmbraResearchCost = 40
kUmbraResearchTime = 120
kVortexResearchCost = 40
kVortexResearchTime = 140
kPrimalScreamResearchCost = 40
kPrimalScreamResearchTime = 140

kCarapaceResearchTime = 15
kRegenerationResearchTime = 15
kAuraResearchTime = 15
kCamouflageResearchTime = 15
kSilenceResearchTime = 15
kCelerityResearchTime = 15
kHyperMutationResearchTime = 15
kAdrenalineResearchTime = 15
kPiercingResearchTime = 15

kFeintResearchTime = 15
kSapResearchTime = 15

kBoneShieldResearchTime = 20





















// ENERGY COSTS
kCommandStationInitialEnergy = 100  kCommandStationMaxEnergy = 250
kNanoShieldCost = 5
kNanoShieldCooldown = 10
kEMPCost = 3
kEMPCooldown = 8

kArmoryInitialEnergy = 100  kArmoryMaxEnergy = 150

kAmmoPackCost = 1
kMedPackCost = 1

kHiveInitialEnergy = 50  kHiveMaxEnergy = 200
kMatureHiveMaxEnergy = 250
kCystCost = 1
kCystCooldown = 1

kDrifterInitialEnergy = 50
kDrifterMaxEnergy = 200
kEnzymeCloudCost = 2

kNutrientMistCost = 2
kInfestationSpikeCost = 3
kInfestationSpikeCooldown = 10
// Note: If kNutrientMistDuration changes, there is a tooltip that needs to be updated.
kNutrientMistDuration = 15

// 100% + X (increases by 66%, which is 10 second reduction over 15 seconds)
kNutrientMistPercentageIncrease = 66
kNutrientMistMaturingIncrease = 66

kObservatoryInitialEnergy = 25  kObservatoryMaxEnergy = 100
kObservatoryScanCost = 3
kObservatoryDistressBeaconCost = 10

kMACInitialEnergy = 50  kMACMaxEnergy = 150
kDrifterCost = 3

kCragInitialEnergy = 25  kCragMaxEnergy = 100
kCragHealCost = 0  
kCragHealWaveCost = 3
kCragUmbraCost = 10
kCragBabblersCost = 15
kMatureCragMaxEnergy = 150

kHydraDamage = 15 // From NS1
kHydraAttackDamageType = kDamageType.Normal

kWhipInitialEnergy = 25  kWhipMaxEnergy = 100
kWhipBombardCost = 15
kMatureWhipMaxEnergy = 150

kShiftInitialEnergy = 50  kShiftMaxEnergy = 150
kShiftEchoCost = 3
kShiftHatchCost = 1
kShiftHatchRange = 11
kMatureShiftMaxEnergy = 200

kEchoHydraCost = 3
kEchoWhipCost = 3
kEchoCragCost = 5
kEchoShadeCost = 5
kEchoShiftCost = 5
kEchoVeilCost = 3
kEchoSpurCost = 3
kEchoShellCost = 3
kEchoHiveCost = 10
kEchoEggCost = 1

kShadeInitialEnergy = 25  kShadeMaxEnergy = 100
kShadeInkCost = 3
kMatureShadeMaxEnergy = 150

kEnergyUpdateRate = 0.5

// infestation upgrades
kHealingBedCost = 20
kHealingBedResearchTime = 60

kMucousMembraneCost = 20
kMucousMembraneResearchTime = 60

kBacterialReceptorsCost = 20
kBacterialReceptorsResearchTime = 60

// This is for CragHive, ShadeHive and ShiftHive
kUpgradeHiveCost = 15
kUpgradeHiveResearchTime = 30

kHallucinateSkulkEnergyCost = 1
kHallucinateGorgeEnergyCost = 2
kHallucinateLerkEnergyCost = 3
kHallucinateFadeEnergyCost = 4
kHallucinateOnosEnergyCost = 5

kHallucinateDrifterEnergyCost = 1
kHallucinateHiveEnergyCost = 15
kHallucinateWhipEnergyCost = 2
kHallucinateHarvesterEnergyCost = 2
kHallucinateHydraEnergyCost = 1

kHallucinateShadeEnergyCost = 3
kHallucinateCragEnergyCost = 3
kHallucinateShiftEnergyCost = 3

kSkulkUpgradeCost = 1
kGorgeUpgradeCost = 2
kLerkUpgradeCost = 3
kFadeUpgradeCost = 4
kOnosUpgradeCost = 5


















































































































