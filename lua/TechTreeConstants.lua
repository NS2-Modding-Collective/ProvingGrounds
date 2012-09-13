// ======= Copyright (c) 2003-2012, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\TechTreeConstants.lua
//
//    Created by:   Charlie Cleveland (charlie@unknownworlds.com)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

kTechId = enum({
    
    'None', 
    
    // Commander menus for selected units
    'RootMenu', 'BuildMenu', 'AdvancedMenu', 'AssistMenu', 'MarkersMenu', 'UpgradesMenu', 'WeaponsMenu',
    
    // Robotics factory menus
    'RoboticsFactoryARCUpgradesMenu', 'RoboticsFactoryMACUpgradesMenu', 'UpgradeRoboticsFactory',

    'ReadyRoomPlayer', 
    
    // Doors
    'Door', 'DoorOpen', 'DoorClose', 'DoorLock', 'DoorUnlock',

    // Misc
    'Mine',
    
    /////////////
    // Marines //
    /////////////
    
    // Marine classes + spectators
    'Marine', 'Exo', 'JetpackMarine', 'Spectator', 'AlienSpectator',
    
    // Special tech
    'TwoCommandStations', 'ThreeCommandStations',

    // Marine tech 
    'CommandStation', 'MAC', 'Armory', 'InfantryPortal', 'Extractor', 'Sentry', 'ARC',
    'Scan', 'AmmoPack', 'MedPack', 'CatPack', 'CatPackTech', 'PowerPoint', 'AdvancedArmoryUpgrade', 'Observatory', 'DistressBeacon', 'PhaseGate', 'RoboticsFactory', 'ARCRoboticsFactory', 'ArmsLab',
    'PowerPack', 'SentryBattery', 'PrototypeLab', 'AdvancedArmory',
    
    // Weapon tech
    'RifleUpgradeTech', 'ShotgunTech', 'GrenadeLauncherTech', 'FlamethrowerTech', 'NerveGasTech', 'FlamethrowerAltTech', 'WelderTech', 'MinesTech',
    'DropWelder', 'DropMines', 'DropShotgun', 'DropGrenadeLauncher', 'DropFlamethrower',
    
    // Marine buys
    'RifleUpgrade', 'NerveGas', 'FlamethrowerAlt',
    
    // Research 
    'PhaseTech', 'MACSpeedTech', 'MACEMPTech', 'ARCArmorTech', 'ARCSplashTech', 'JetpackTech', 'ExosuitTech', 'DualMinigunTech', 'DualMinigunExosuit',
    'DropJetpack', 'DropExosuit',
    
    // MAC (build bot) abilities
    'MACEMP',
    
    // Weapons 
    'Rifle', 'Pistol', 'Shotgun', 'Claw', 'Minigun', 'GrenadeLauncher', 'Flamethrower', 'Axe', 'LayMines', 'Welder',
    
    // Armor
    'Jetpack', 'JetpackFuelTech', 'JetpackArmorTech', 'Exosuit', 'ExosuitLockdownTech', 'ExosuitUpgradeTech',
    
    // Marine upgrades
    'Weapons1', 'Weapons2', 'Weapons3', 'Armor1', 'Armor2', 'Armor3',
    
    // Activations
    'ARCDeploy', 'ARCUndeploy',
    
    // Commander abilities
    'NanoShield',
    
    ////////////
    // Aliens //
    ////////////

    // Alien lifeforms 
    'Skulk', 'Gorge', 'Lerk', 'Fade', 'Onos', "AllAliens", "Hallucination",
    
    // Special tech
    'TwoHives', 'ThreeHives', 
    
    // Alien abilities (not all are needed, only ones with damage types)
    'Bite', 'LerkBite', 'Parasite',  'Spit', 'BuildAbility', 'Spray', 'Spores', 'HydraSpike', 'SwipeBlink', 'StabBlink', 'Gore', 'Smash',

    
    // upgradeable alien abilities (need to be unlocked)
    'LifeFormMenu',
    'BileBomb', 'Leap', 'Blink', 'Stomp', 'Spikes', 'Umbra', 'PoisonDart', 'Xenocide', 'Vortex', 'PrimalScream', 'WebStalk',

    // Alien structures 
    'Drifter', 'Egg', 'Embryo', 'Hydra', 'Cyst', 'Clog', 'WebStalk',
    'GorgeEgg', 'LerkEgg', 'FadeEgg', 'OnosEgg',
    
    // Infestation upgrades
    'HealingBed', 'MucousMembrane', 'BacterialReceptors',

    // Upgrade buildings and abilities (structure, upgraded structure, passive, triggered, targeted)
    'Shell', 'Crag', 'EvolveBabblers', 'CragHeal', 'Babbler',
    'Whip', 'EvolveBombard', 'WhipBombard', 'WhipBombardCancel', 'WhipBomb',
    'Spur', 'Shift', 'EvolveEcho', 'ShiftHatch', 'ShiftEcho', 'ShiftEnergize', 
    'Veil', 'Shade', 'EvolveHallucinations', 'ShadeDisorient', 'ShadeCloak', 'ShadePhantomMenu', 'ShadePhantomStructuresMenu',
    'UpgradeCeleritySpur', 'CeleritySpur', 'UpgradeAdrenalineSpur', 'AdrenalineSpur', 'UpgradeHyperMutationSpur', 'HyperMutationSpur',
    'UpgradeSilenceVeil', 'SilenceVeil', 'UpgradeCamouflageVeil', 'CamouflageVeil', 'UpgradeAuraVeil', 'AuraVeil', 'UpgradeFeintVeil', 'FeintVeil',
    'UpgradeRegenerationShell', 'RegenerationShell', 'UpgradeCarapaceShell', 'CarapaceShell',
    'DrifterCamouflage',
    
    // echo menu
    'TeleportHydra', 'TeleportWhip', 'TeleportCrag', 'TeleportShade', 'TeleportShift', 'TeleportVeil', 'TeleportSpur', 'TeleportShell', 'TeleportEgg',
    
    // Whip movement
    'WhipRoot', 'WhipUnroot',
    
    // Alien abilities and upgrades
    'Carapace', 'Regeneration', 'Aura', 'Silence', 'Feint', 'Camouflage', 'Celerity', 'Adrenaline', 'HyperMutation',  
    
    // Alien alerts
    'AlienAlertNeedHealing', 'AlienAlertStructureUnderAttack', 
    'AlienAlertLifeformUnderAttack', 'AlienCommanderEjected',
    'AlienAlertOrderComplete',
    'AlienAlertNotEnoughResources', 'AlienAlertResearchComplete', 'AlienAlertManufactureComplete', 'AlienAlertUpgradeComplete', 
    
    // Pheromones
    'ThreatMarker', 'LargeThreatMarker', 'NeedHealingMarker', 'WeakMarker', 'ExpandingMarker',
    
    // Infestation
    'Infestation',
    
    // Commander abilities
    'InfestationSpike', 'NutrientMist', 'HealWave', 'CragUmbra', 'CragBabblers', 'ShadeInk', 'EnzymeCloud', 'Rupture',
    
    // Alien Commander hallucinations
    'HallucinateDrifter', 'HallucinateSkulk', 'HallucinateGorge', 'HallucinateLerk', 'HallucinateFade', 'HallucinateOnos',
    'HallucinateWhip', 'HallucinateShade', 'HallucinateCrag', 'HallucinateShift', 'HallucinateHydra',
    
    // Voting commands
    'VoteDownCommander1', 'VoteDownCommander2', 'VoteDownCommander3',
    
    'GameStarted',
    
    'DeathTrigger',

    // Maximum index
    'Max'
    
    })

// Increase techNode network precision if more needed
kTechIdMax  = kTechId.Max

// Tech types
kTechType = enum({ 'Invalid', 'Order', 'Research', 'Upgrade', 'Action', 'Buy', 'Build', 'EnergyBuild', 'Manufacture', 'Activation', 'Menu', 'EnergyManufacture', 'PlasmaManufacture', 'Special', 'Passive' })

// Button indices
kRecycleCancelButtonIndex   = 12
kMarineUpgradeButtonIndex   = 5
kAlienBackButtonIndex       = 8

