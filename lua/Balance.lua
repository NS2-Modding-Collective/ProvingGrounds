// ======= Copyright (c) 2003-2012, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\Balance.lua
//
//    Created by:   Andreas Urwalek (andi@unknownworlds.com)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/BalanceHealth.lua")

kDefaultFov = 95

kDamageVelocityScalar = 2.5

kPulseGrenadeDamageRadius = 6
kPulseGrenadeEnergyDamageRadius = 10
kPulseGrenadeDamage = 110
kPulseGrenadeEnergyDamage = 0
kPulseGrenadeDamageType = kDamageType.Normal

kClusterGrenadeDamageRadius = 10
kClusterGrenadeDamage = 55
kClusterFragmentDamageRadius = 6
kClusterFragmentDamage = 20
kClusterGrenadeDamageType = kDamageType.Flame

kNerveGasDamagePerSecond = 50
kNerveGasDamageType = kDamageType.NerveGas


// AVATAR DAMAGE
kRifleDamage = 3
kRifleDamageType = kDamageType.Normal
kRifleClipSize = 50

kHeavyRifleDamage = 10
kHeavyRifleDamageType = kDamageType.Puncture
kHeavyRifleClipSize = 75

kRifleMeleeDamage = 25
kRifleMeleeDamageType = kDamageType.Normal

kPistolDamage = 7
kPistolDamageType = kDamageType.Normal
kPistolClipSize = 20
// not used yet
kPistolMinFireDelay = 0.1

kPistolAltDamage = 40

kAxeDamage = 151
kAxeDamageType = kDamageType.Normal


kGrenadeLauncherGrenadeDamage = 45
kGrenadeLauncherGrenadeDamageType = kDamageType.Normal
kGrenadeLauncherClipSize = 4
kGrenadeLauncherGrenadeDamageRadius = 4
kGrenadeLifetime = 2.0
kGrenadeUpgradedLifetime = 1.5

kRocketLauncherRocketDamage = 60
kRocketLauncherRocketDamageType = kDamageType.Normal
kRocketLauncherRocketDamageRadius = 4
kRocketLauncherClipSize = 4

kShotgunDamage = 2
kShotgunDamageType = kDamageType.Normal
kShotgunClipSize = 8
kShotgunBulletsPerShot = 14

kNadeLauncherClipSize = 4

kFlamethrowerDamage = 15
kFlameThrowerEnergyDamage = 3
kBurnDamagePerSecond = 2
kFlamethrowerDamageType = kDamageType.Normal
kFlamethrowerClipSize = 50
kFlamethrowerRange = 9
kFlamethrowerUpgradedRange = 11.5

kBurnDamagePerStackPerSecond = 3
kFlamethrowerMaxStacks = 20
kFlamethrowerBurnDuration = 6
kFlamethrowerStackRate = 0.4
kFlameRadius = 1.8
kFlameDamageStackWeight = 0.5

kAmmoPackCost = 1
kMedPackCost = 1
kMedPackCooldown = 0
kCatPackCost = 3
kCatPackMoveAddSpeed = 1.25
kCatPackWeaponSpeed = 1.5
kCatPackDuration = 12

