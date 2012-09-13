// ======= Copyright (c) 2003-2012, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\TechTreeButtons.lua
//
//    Created by:   Charlie Cleveland (charlie@unknownworlds.com)
//
// Hard-coded data which maps tech tree constants to indices into a texture. Used to display
// icons in the commander build menu and alien buy menu.
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

// These are the icons that appear next to alerts or as hotkey icons.
// Icon size should be 20x20. Also used for the alien buy menu.
function CommanderUI_Icons()

    local player = Client.GetLocalPlayer()
    if(player and (player:isa("Alien") or player:isa("AlienCommander"))) then
        return "alien_upgradeicons"
    end
    
    return "marine_upgradeicons"

end

function CommanderUI_MenuImage()

    local player = Client.GetLocalPlayer()
    if(player and player:isa("AlienCommander")) then
        return "alien_buildmenu"
    end
    
    return "marine_buildmenu"
    
end

function CommanderUI_MenuImageSize()

    local player = Client.GetLocalPlayer()
    if(player and player:isa("AlienCommander")) then
        return 640, 1040
    end
    
    return 960, 960
    
end

// Init marine offsets
kMarineTechIdToMaterialOffset = {}

// Init alien offsets
kAlienTechIdToMaterialOffset = {}

// Create arrays that convert between tech ids and the offsets within
// the button images used to display their buttons. Look in marine_buildmenu.psd 
// and alien_buildmenu.psd to understand these indices.
function InitTechTreeMaterialOffsets()

    // Init marine offsets
    kMarineTechIdToMaterialOffset = {}

    // Init alien offsets
    kAlienTechIdToMaterialOffset = {}
    
    // Resource Points
    // First row
    kMarineTechIdToMaterialOffset[kTechId.CommandStation] = 0
    
    kMarineTechIdToMaterialOffset[kTechId.Armory] = 1
    kMarineTechIdToMaterialOffset[kTechId.RifleUpgradeTech] = 66
    kMarineTechIdToMaterialOffset[kTechId.MAC] = 2
    // Change offset in CommanderUI_GetIdleWorkerOffset when changing extractor
    kMarineTechIdToMaterialOffset[kTechId.Extractor] = 3
    kMarineTechIdToMaterialOffset[kTechId.InfantryPortal] = 4
    kMarineTechIdToMaterialOffset[kTechId.Sentry] = 5
    
    kMarineTechIdToMaterialOffset[kTechId.RoboticsFactory] = 6    
    kMarineTechIdToMaterialOffset[kTechId.UpgradeRoboticsFactory] = 6
    kMarineTechIdToMaterialOffset[kTechId.ARCRoboticsFactory] = 6
    
    kMarineTechIdToMaterialOffset[kTechId.Observatory] = 7
    kMarineTechIdToMaterialOffset[kTechId.SentryBattery] = 71
    kMarineTechIdToMaterialOffset[kTechId.ArmsLab] = 11
    

    kMarineTechIdToMaterialOffset[kTechId.BuildMenu] = 22
    kMarineTechIdToMaterialOffset[kTechId.AdvancedMenu] = 23    

    kMarineTechIdToMaterialOffset[kTechId.AssistMenu] = 33
    kMarineTechIdToMaterialOffset[kTechId.WeaponsMenu] = 55
    
    
    // Fourth row - droppables, research
    kMarineTechIdToMaterialOffset[kTechId.AmmoPack] = 36
    kMarineTechIdToMaterialOffset[kTechId.MedPack] = 37
    kMarineTechIdToMaterialOffset[kTechId.JetpackTech] = 40
    kMarineTechIdToMaterialOffset[kTechId.Jetpack] = 40
    kMarineTechIdToMaterialOffset[kTechId.DropJetpack] = 40
    kMarineTechIdToMaterialOffset[kTechId.Scan] = 41
    kMarineTechIdToMaterialOffset[kTechId.FlamethrowerTech] = 42
    kMarineTechIdToMaterialOffset[kTechId.Flamethrower] = 42
    kMarineTechIdToMaterialOffset[kTechId.DropFlamethrower] = 42
    kMarineTechIdToMaterialOffset[kTechId.FlamethrowerAltTech] = 42
    kMarineTechIdToMaterialOffset[kTechId.ARC] = 44
    kMarineTechIdToMaterialOffset[kTechId.CatPack] = 45
    kMarineTechIdToMaterialOffset[kTechId.CatPackTech] = 45
    kMarineTechIdToMaterialOffset[kTechId.NerveGasTech] = 46
    kMarineTechIdToMaterialOffset[kTechId.DualMinigunTech] = 47
    
    // Fifth row 
    kMarineTechIdToMaterialOffset[kTechId.ShotgunTech] = 48
    kMarineTechIdToMaterialOffset[kTechId.Shotgun] = 48
    kMarineTechIdToMaterialOffset[kTechId.DropShotgun] = 48
    kMarineTechIdToMaterialOffset[kTechId.Armor1] = 49
    kMarineTechIdToMaterialOffset[kTechId.Armor2] = 50
    kMarineTechIdToMaterialOffset[kTechId.Armor3] = 51
    kMarineTechIdToMaterialOffset[kTechId.NanoShield] = 52
    
    // upgrades
    kMarineTechIdToMaterialOffset[kTechId.Weapons1] = 55
    kMarineTechIdToMaterialOffset[kTechId.Weapons2] = 56
    kMarineTechIdToMaterialOffset[kTechId.Weapons3] = 57
    
    kMarineTechIdToMaterialOffset[kTechId.Marine] = 60
    kMarineTechIdToMaterialOffset[kTechId.JetpackMarine] = 60
    kMarineTechIdToMaterialOffset[kTechId.Exo] = 61
    kMarineTechIdToMaterialOffset[kTechId.MACEMPTech] = 62
    kMarineTechIdToMaterialOffset[kTechId.MACEMP] = 62
    kMarineTechIdToMaterialOffset[kTechId.DistressBeacon] = 63
    kMarineTechIdToMaterialOffset[kTechId.AdvancedArmory] = 65
    kMarineTechIdToMaterialOffset[kTechId.AdvancedArmoryUpgrade] = 65
    kMarineTechIdToMaterialOffset[kTechId.RifleUpgradeTech] = 66
    kMarineTechIdToMaterialOffset[kTechId.PhaseGate] = 67
    kMarineTechIdToMaterialOffset[kTechId.PhaseTech] = 68
    kMarineTechIdToMaterialOffset[kTechId.ARCSplashTech] = 69
    kMarineTechIdToMaterialOffset[kTechId.ARCArmorTech] = 70

    kMarineTechIdToMaterialOffset[kTechId.GrenadeLauncherTech] = 72
    kMarineTechIdToMaterialOffset[kTechId.GrenadeLauncher] = 72
    kMarineTechIdToMaterialOffset[kTechId.DropGrenadeLauncher] = 72
    kMarineTechIdToMaterialOffset[kTechId.JetpackFuelTech] = 73      
    kMarineTechIdToMaterialOffset[kTechId.JetpackArmorTech] = 74
    kMarineTechIdToMaterialOffset[kTechId.ExosuitTech] = 75
    kMarineTechIdToMaterialOffset[kTechId.Exosuit] = 77
    kMarineTechIdToMaterialOffset[kTechId.DropExosuit] = 77
    kMarineTechIdToMaterialOffset[kTechId.ExosuitLockdownTech] = 77
    kMarineTechIdToMaterialOffset[kTechId.ExosuitUpgradeTech] = 83
    kMarineTechIdToMaterialOffset[kTechId.ARCDeploy] = 78     
    kMarineTechIdToMaterialOffset[kTechId.ARCUndeploy] = 79
    
    kMarineTechIdToMaterialOffset[kTechId.MinesTech] = 80
    kMarineTechIdToMaterialOffset[kTechId.Mine] = 80
    kMarineTechIdToMaterialOffset[kTechId.DropMines] = 80
    kMarineTechIdToMaterialOffset[kTechId.LayMines] = 80
    
    kMarineTechIdToMaterialOffset[kTechId.WelderTech] = 21 // 17
    kMarineTechIdToMaterialOffset[kTechId.Welder] = 21    
    kMarineTechIdToMaterialOffset[kTechId.DropWelder] = 21
    
    kMarineTechIdToMaterialOffset[kTechId.MACSpeedTech] = 82
    
        
    // Doors
    kMarineTechIdToMaterialOffset[kTechId.Door] = 84
    kMarineTechIdToMaterialOffset[kTechId.DoorOpen] = 85
    kMarineTechIdToMaterialOffset[kTechId.DoorClose] = 86
    kMarineTechIdToMaterialOffset[kTechId.DoorLock] = 87
    kMarineTechIdToMaterialOffset[kTechId.DoorUnlock] = 88
    // 89 = nozzle
    // 90 = tech point
    
    // Robotics factory menus
    kMarineTechIdToMaterialOffset[kTechId.RoboticsFactoryARCUpgradesMenu] = 91
    kMarineTechIdToMaterialOffset[kTechId.RoboticsFactoryMACUpgradesMenu] = 93
    kMarineTechIdToMaterialOffset[kTechId.PrototypeLab] = 94
       
    // Menus
    kAlienTechIdToMaterialOffset[kTechId.RootMenu] = 21
    kAlienTechIdToMaterialOffset[kTechId.BuildMenu] = 8
    kAlienTechIdToMaterialOffset[kTechId.AdvancedMenu] = 9
    kAlienTechIdToMaterialOffset[kTechId.AssistMenu] = 10
    kAlienTechIdToMaterialOffset[kTechId.MarkersMenu] = 14
    kAlienTechIdToMaterialOffset[kTechId.UpgradesMenu] = 12
    kAlienTechIdToMaterialOffset[kTechId.Cyst] = 23
    kAlienTechIdToMaterialOffset[kTechId.LifeFormMenu] = 94

    // Cyst abilities
    kAlienTechIdToMaterialOffset[kTechId.EnzymeCloud] = 52
    kAlienTechIdToMaterialOffset[kTechId.Rupture] = 14
       
    // Lifeforms
    kAlienTechIdToMaterialOffset[kTechId.Skulk] = 16
    kAlienTechIdToMaterialOffset[kTechId.Gorge] = 17
    kAlienTechIdToMaterialOffset[kTechId.Lerk] = 18
    kAlienTechIdToMaterialOffset[kTechId.Fade] = 19
    kAlienTechIdToMaterialOffset[kTechId.Onos] = 20
    
    kAlienTechIdToMaterialOffset[kTechId.HealingBed] = 40
    kAlienTechIdToMaterialOffset[kTechId.BacterialReceptors] = 64
    kAlienTechIdToMaterialOffset[kTechId.MucousMembrane] = 56
    
    // Change offset in CommanderUI_GetIdleWorkerOffset when changing harvester
    kAlienTechIdToMaterialOffset[kTechId.Drifter] = 28
    kAlienTechIdToMaterialOffset[kTechId.DrifterCamouflage] = 29
    kAlienTechIdToMaterialOffset[kTechId.Egg] = 30
    kAlienTechIdToMaterialOffset[kTechId.GorgeEgg] = 17
    kAlienTechIdToMaterialOffset[kTechId.LerkEgg] = 18
    kAlienTechIdToMaterialOffset[kTechId.FadeEgg] = 19
    kAlienTechIdToMaterialOffset[kTechId.OnosEgg] = 20
    
    // $AS - Right now we do not have an icon for power nodes for aliens
    // so we are going to use the question mark until we get something
    kAlienTechIdToMaterialOffset[kTechId.PowerPoint] = 22
    
    // Doors
    // $AS - Aliens can select doors if an onos can potential break a door
    // the alien commander should be able to see its health I would think
    // we do not have any art for doors on aliens so we once again use the
    // question mark 
    kAlienTechIdToMaterialOffset[kTechId.Door] = 22
    kAlienTechIdToMaterialOffset[kTechId.DoorOpen] =22
    kAlienTechIdToMaterialOffset[kTechId.DoorClose] = 22
    kAlienTechIdToMaterialOffset[kTechId.DoorLock] = 22
    kAlienTechIdToMaterialOffset[kTechId.DoorUnlock] = 22
    
    // upgradeable alien abilities
    kAlienTechIdToMaterialOffset[kTechId.Leap] = 105
    kAlienTechIdToMaterialOffset[kTechId.BileBomb] = 107
    kAlienTechIdToMaterialOffset[kTechId.Spores] = 106
    kAlienTechIdToMaterialOffset[kTechId.Blink] = 110
    kAlienTechIdToMaterialOffset[kTechId.Stomp] = 111
    
    kAlienTechIdToMaterialOffset[kTechId.Xenocide] = 108
    kAlienTechIdToMaterialOffset[kTechId.WebStalk] = 112
    kAlienTechIdToMaterialOffset[kTechId.Umbra] = 114
    kAlienTechIdToMaterialOffset[kTechId.Vortex] = 113
    kAlienTechIdToMaterialOffset[kTechId.PrimalScream] = 20
    
    // Hive upgrades and markers
    kAlienTechIdToMaterialOffset[kTechId.ThreatMarker] = 2
    kAlienTechIdToMaterialOffset[kTechId.LargeThreatMarker] = 2
    kAlienTechIdToMaterialOffset[kTechId.NeedHealingMarker] = 3
    kAlienTechIdToMaterialOffset[kTechId.WeakMarker] = 3
    kAlienTechIdToMaterialOffset[kTechId.ExpandingMarker] = 1
   
    // Crag
    kAlienTechIdToMaterialOffset[kTechId.Shell] = 96
    kAlienTechIdToMaterialOffset[kTechId.Crag] = 40
    kAlienTechIdToMaterialOffset[kTechId.EvolveBabblers] = 41
    kAlienTechIdToMaterialOffset[kTechId.CragHeal] = 43
    kAlienTechIdToMaterialOffset[kTechId.HealWave] = 43
    kAlienTechIdToMaterialOffset[kTechId.CragBabblers] = 45 
    
    // Whip
    kAlienTechIdToMaterialOffset[kTechId.Whip] = 48
    kAlienTechIdToMaterialOffset[kTechId.EvolveBombard] = 49
    kAlienTechIdToMaterialOffset[kTechId.WhipBombard] = 53 
    kAlienTechIdToMaterialOffset[kTechId.WhipBombardCancel] = 5

    // Shift
    kAlienTechIdToMaterialOffset[kTechId.Spur] = 98

    kAlienTechIdToMaterialOffset[kTechId.Shift] = 56
    kAlienTechIdToMaterialOffset[kTechId.EvolveEcho] = 57
    kAlienTechIdToMaterialOffset[kTechId.ShiftHatch] = 59
    kAlienTechIdToMaterialOffset[kTechId.ShiftEcho] = 60
    kAlienTechIdToMaterialOffset[kTechId.ShiftEnergize] = 104
    
    kAlienTechIdToMaterialOffset[kTechId.TeleportHydra] = 88
    kAlienTechIdToMaterialOffset[kTechId.TeleportWhip] = 48
    kAlienTechIdToMaterialOffset[kTechId.TeleportCrag] = 40
    kAlienTechIdToMaterialOffset[kTechId.TeleportShade] = 64
    kAlienTechIdToMaterialOffset[kTechId.TeleportShift] = 56
    kAlienTechIdToMaterialOffset[kTechId.TeleportVeil] = 97
    kAlienTechIdToMaterialOffset[kTechId.TeleportSpur] = 98
    kAlienTechIdToMaterialOffset[kTechId.TeleportShell] = 96
    kAlienTechIdToMaterialOffset[kTechId.TeleportEgg] = 30
    
    kAlienTechIdToMaterialOffset[kTechId.UpgradeHyperMutationSpur] = 80
    kAlienTechIdToMaterialOffset[kTechId.HyperMutationSpur] = 80
    kAlienTechIdToMaterialOffset[kTechId.HyperMutation] = 80
    
    kAlienTechIdToMaterialOffset[kTechId.UpgradeAdrenalineSpur] = 83
    kAlienTechIdToMaterialOffset[kTechId.AdrenalineSpur] = 83
    kAlienTechIdToMaterialOffset[kTechId.Adrenaline] = 83
    
    kAlienTechIdToMaterialOffset[kTechId.UpgradeCeleritySpur] = 84
    kAlienTechIdToMaterialOffset[kTechId.CeleritySpur] = 84
    kAlienTechIdToMaterialOffset[kTechId.Celerity] = 84
    
    // Shade
    kAlienTechIdToMaterialOffset[kTechId.Veil] = 97
    kAlienTechIdToMaterialOffset[kTechId.Shade] = 64
    kAlienTechIdToMaterialOffset[kTechId.EvolveHallucinations] = 65
    kAlienTechIdToMaterialOffset[kTechId.ShadeCloak] = 67
    kAlienTechIdToMaterialOffset[kTechId.ShadeDisorient] = 68
    kAlienTechIdToMaterialOffset[kTechId.ShadeInk] = 68
    kAlienTechIdToMaterialOffset[kTechId.ShadePhantomMenu] = 69
    kAlienTechIdToMaterialOffset[kTechId.ShadePhantomStructuresMenu] = 70
    
    kAlienTechIdToMaterialOffset[kTechId.HallucinateDrifter] = 28
    kAlienTechIdToMaterialOffset[kTechId.HallucinateSkulk] = 16
    kAlienTechIdToMaterialOffset[kTechId.HallucinateGorge] = 17
    kAlienTechIdToMaterialOffset[kTechId.HallucinateLerk] = 18
    kAlienTechIdToMaterialOffset[kTechId.HallucinateFade] = 19
    kAlienTechIdToMaterialOffset[kTechId.HallucinateOnos] = 20
    kAlienTechIdToMaterialOffset[kTechId.Hallucination] = 69

    kAlienTechIdToMaterialOffset[kTechId.HallucinateWhip] = 48
    kAlienTechIdToMaterialOffset[kTechId.HallucinateShade] = 64
    kAlienTechIdToMaterialOffset[kTechId.HallucinateCrag] = 40
    kAlienTechIdToMaterialOffset[kTechId.HallucinateShift] = 56
    kAlienTechIdToMaterialOffset[kTechId.HallucinateHydra] = 88
    
    kAlienTechIdToMaterialOffset[kTechId.UpgradeCamouflageVeil] = 86
    kAlienTechIdToMaterialOffset[kTechId.CamouflageVeil] = 86
    kAlienTechIdToMaterialOffset[kTechId.Camouflage] = 86

    kAlienTechIdToMaterialOffset[kTechId.UpgradeAuraVeil] = 71
    kAlienTechIdToMaterialOffset[kTechId.AuraVeil] = 71
    kAlienTechIdToMaterialOffset[kTechId.Aura] = 71
    
    kAlienTechIdToMaterialOffset[kTechId.UpgradeFeintVeil] = 87
    kAlienTechIdToMaterialOffset[kTechId.FeintVeil] = 87
    kAlienTechIdToMaterialOffset[kTechId.Feint] = 87

    kAlienTechIdToMaterialOffset[kTechId.Silence] = 85
    kAlienTechIdToMaterialOffset[kTechId.UpgradeSilenceVeil] = 85
    kAlienTechIdToMaterialOffset[kTechId.SilenceVeil] = 85

    //Hydra
    kAlienTechIdToMaterialOffset[kTechId.Hydra] = 88
    
    // Whip movement
    kAlienTechIdToMaterialOffset[kTechId.WhipUnroot] = 78
    kAlienTechIdToMaterialOffset[kTechId.WhipRoot] = 79
    
    kAlienTechIdToMaterialOffset[kTechId.UpgradeCarapaceShell] = 81
    kAlienTechIdToMaterialOffset[kTechId.CarapaceShell] = 81
    kAlienTechIdToMaterialOffset[kTechId.Carapace] = 81
    
    kAlienTechIdToMaterialOffset[kTechId.UpgradeRegenerationShell] = 82
    kAlienTechIdToMaterialOffset[kTechId.RegenerationShell] = 82
    kAlienTechIdToMaterialOffset[kTechId.Regeneration] = 82
    
    
end

function GetMaterialXYOffset(techId, isaMarine)

    local index = nil
    
    local columns = 12
    if isaMarine then
        index = kMarineTechIdToMaterialOffset[techId]
    else
        index = kAlienTechIdToMaterialOffset[techId]
        columns = 8
    end
    
    if index == nil then
        Print("Warning: %s did not define kMarineTechIdToMaterialOffset/kAlienTechIdToMaterialOffset ", EnumToString(kTechId, techId) )
    end

    if(index ~= nil) then
    
        local x = index % columns
        local y = math.floor(index / columns)
        return x, y
        
    end
    
    return nil, nil
    
end

function GetPixelCoordsForIcon(entityId, forMarine)

    local ent = Shared.GetEntity(entityId)
    
    if (ent ~= nil and ent:isa("ScriptActor")) then
    
        local techId = ent:GetTechId()
        
        if (techId ~= kTechId.None) then
            
            local xOffset, yOffset = GetMaterialXYOffset(techId, forMarine)
            
            return {xOffset, yOffset}
            
        end
                    
    end
    
    return nil
    
end
