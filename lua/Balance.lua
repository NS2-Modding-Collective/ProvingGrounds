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
kArmsLabCost = 20

kAdvancedArmoryUpgradeCost = 20
kPrototypeLabCost = 40

kSentryCost = 5
kPowerNodeCost = 0

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

kFlamethrowerCost = 25
kFlamethrowerTechResearchCost = 25

kRoboticsFactoryCost = 15
kUpgradeRoboticsFactoryCost = 10
kUpgradeRoboticsFactoryTime = 40
kARCCost = 15
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

kWeapons1ResearchCost = 15
kWeapons2ResearchCost = 25
kWeapons3ResearchCost = 35
kArmor1ResearchCost = 15
kArmor2ResearchCost = 25
kArmor3ResearchCost = 35 

kCatPackCost = 2
kCatPackTechResearchCost = 10

kRifleUpgradeTechResearchCost = 10

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
kAntiMatterSwordDamagePerSecond = 70
kWelderDamageType = kDamageType.Heavy
kWelderFireDelay = 0.1
kAntiMatterSwordFireDelay = 0.1

kAxeDamage = 30
kAxeDamageType = kDamageType.Structural


kGrenadeLauncherGrenadeDamage = 130
kGrenadeLauncherGrenadeDamageType = kDamageType.Structural
kGrenadeLauncherClipSize = 4
kGrenadeLauncherGrenadeDamageRadius = 8
kGrenadeLifetime = 2.0

kShotgunDamage = 15
kShotgunDamageType = kDamageType.Normal
kShotgunClipSize = 8
kShotgunBulletsPerShot = 10
kShotgunRange = 15

kNadeLauncherClipSize = 4

kFlamethrowerDamage = 7.5
kFlamethrowerDamageType = kDamageType.Flame
kFlamethrowerClipSize = 30

kBurnDamagePerStackPerSecond = 3
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

kSentryAttackDamageType = kDamageType.Structural
kSentryAttackBaseROF = .5 // don't set ROF faster, will cause performance issues, adjust damage instead if not sufficient
kSentryAttackRandROF = 0.1
kSentryAttackBulletsPerSalvo = 1
kConfusedSentryBaseROF = 2.0

// sentry increases damage when shooting at the same target (resets when switching targets)
kSentryMinAttackDamage = 3
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

kLerkBiteDamage = 60
kBitePoisonDamage = 6 // per second
kPoisonBiteDuration = 6
kLerkBiteEnergyCost = 5
kLerkBiteDamageType = kDamageType.Normal

kUmbraEnergyCost = 25
kUmbraDuration = 5

kSpikeMaxDamage = 9
kSpikeMinDamage = 7
kSpikeDamageType = kDamageType.Puncture
kSpikeEnergyCost = 1.4
kSpikesAttackDelay = 0.07
kSpikeMinDamageRange = 9
kSpikeMaxDamageRange = 2
kSpikesPerShot = 1
kSpikesRange = 50

kSporesDamageType = kDamageType.Gas
kSporesDustDamagePerSecond = 20
kSporesDustFireDelay = 0.18
kSporesCloudFireDelay = 0.8
kSporesDustEnergyCost = 5
kSporesDustCloudRadius = 2.0
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
kWhipBombardDamageType = kDamageType.Corrode
kWhipBombardRadius = 3
kWhipBombardRange = 10
kWhipBombardROF = 6





// SPAWN TIMES
kMarineRespawnTime = 7

// every 4 seconds an egg is generated, scales with player size
kEggSpawnTime = 4
// hive triggers a spawn wave every kAlienWaveSpawnInterval seconds
kAlienWaveSpawnInterval = 13
// time an aliens needs to be dead before respawn is allowed
kAlienMinDeathTime = 3

kAlienEggMinSpawnTime = 7
kAlienEggMaxSpawnTime = 60
kAlienEggPlayerScalar = 10
kAlienEggSinScalar = 14
kAlienEggsPerHive = 9

// BUILD/RESEARCH TIMES
kRecycleTime = 12
kArmoryBuildTime = 12
kAdvancedArmoryResearchTime = 90
kWeaponsModuleAddonTime = 40
kPrototypeLabBuildTime = 20
kArmsLabBuildTime = 17

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

kSentryBatteryCost = 10
kSentryBatteryBuildTime = 5

kRoboticsFactoryBuildTime = 13
kARCBuildTime = 10
kARCSplashTechResearchTime = 30
kARCArmorTechResearchTime = 30

kNanoShieldDuration = 8
kSentryBuildTime = 3

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

kDualMinigunTechResearchTime = 60
kCatPackTechResearchTime = 15

kObservatoryBuildTime = 15
kPhaseTechResearchCost = 15
kPhaseTechResearchTime = 45
kPhaseGateBuildTime = 12

kWeapons1ResearchTime = 80
kWeapons2ResearchTime = 100
kWeapons3ResearchTime = 120
kArmor1ResearchTime = 80
kArmor2ResearchTime = 100
kArmor3ResearchTime = 120


kHiveBuildTime = 150

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

kXenocideResearchCost = 30
kXenocideResearchTime = 90
kWebStalkResearchCost = 30
kWebStalkResearchTime = 90
kUmbraResearchCost = 30
kUmbraResearchTime = 90
kVortexResearchCost = 30
kVortexResearchTime = 90
kPrimalScreamResearchCost = 30
kPrimalScreamResearchTime = 90

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
kBoneWallCost = 3
kBoneWallCooldown = 10
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
kUpgradeHiveResearchTime = 20

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


















































































































