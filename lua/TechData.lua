// ======= Copyright (c) 2003-2012, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\TechData.lua
//
//    Created by:   Charlie Cleveland (charlie@unknownworlds.com)
//
// A "database" of attributes for all units, abilities, structures, weapons, etc. in the game.
// Shared between client and server.
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

// Set up structure data for easy use by Server.lua and model classes
// Store whatever data is necessary here and use LookupTechData to access
// Store any data that needs to used on both client and server here
// Lookup by key with LookupTechData()
kTechDataId                             = "id"
// Localizable string describing tech node
kTechDataDisplayName                    = "displayname"
kTechDataMapName                        = "mapname"
kTechDataModel                          = "model"
// TeamResources, resources or energy
kTechDataCostKey                        = "costkey"
kTechDataMaxHealth                      = "maxhealth"
kTechDataMaxArmor                       = "maxarmor"
kTechDataDamageType                     = "damagetype"
// Class that structure must be placed on top of (resource towers on resource points)
// If adding more attach classes, add them to GetIsAttachment(). When attaching entities
// to this attach class, ignore class.
kStructureAttachClass                   = "attachclass"
// set to true when attach structure is not required but optional
kTechDataAttachOptional                   = "attachoptional"
// the entity will be optionally attached if it passed the method check
kTechDataOptionalAttachToMethod        = "optionalattach"
// The tech id of the attach class 
kStructureAttachId                      = "attachid"
// If specified, object spawns this far off the ground
kTechDataSpawnHeightOffset              = "spawnheight"
// All player tech ids should have this, nothing else uses it. Pre-computed by looking at the min and max extents of the model, 
// adding their absolute values together and dividing by 2. 
kTechDataMaxExtents                     = "maxextents"
// Menu priority. If more than one techId is specified for the same spot in a menu, use the one with the higher priority.
// If a tech doesn't specify a priority, treat as 0. If all priorities are tied, show none of them. This is how Starcraft works (see siege behavior).
kTechDataMenuPriority                   = "menupriority"
// if an alert with higher priority is trigger the interval should be ignored
kTechDataAlertPriority                  = "alertpriority"
// manipulate build coords in a custom function
kTechDataOverrideCoordsMethod           = "overridecoordsmethod"
// Point value for killing structure
kTechDataPointValue                     = "pointvalue"
// Set to false if not yet implemented, for displaying differently for not enabling
kTechDataImplemented                    = "implemented"
// Alert sound name
kTechDataAlertSound                     = "alertsound"
// Alert scope
kTechDataAlertTeam                      = "alertteam"
// Alert should ignore distance for triggering
kTechDataAlertIgnoreDistance            = "alertignoredistance"
// Alert should also trigger a team message.
kTechDataAlertSendTeamMessage           = "alertsendteammessage"
// Usage notes, caveats, etc. for use in commander tooltip (localizable)
kTechDataTooltipInfo                    = "tooltipinfo"
// Quite the same as tooltip, but shorter
kTechDataHint                           = "hintinfo"
// Engagement distance - how close can unit get to it before it can repair or build it
kTechDataEngagementDistance             = "engagementdist"
// Allows dropping onto other entities
kTechDataAllowStacking                 = "allowstacking"
// will ignore other entities when searching for spawn position
kTechDataCollideWithWorldOnly          = "collidewithworldonly"
// the entity will be optionally attached if it passed the method check
kTechDataOptionalAttachToMethod        = "optionalattach"
// only useable once every X seconds
kTechDataCooldown = "coldownduration"
// ignore any alert interval
kTechDataAlertIgnoreInterval = "ignorealertinterval"

function BuildTechData()
    
    local techData = { 
        // Ready room player is the default player, hence the ReadyRoomPlayer.kMapName
        { [kTechDataId] = kTechId.ReadyRoomPlayer,        [kTechDataDisplayName] = "READY_ROOM_PLAYER", [kTechDataMapName] = ReadyRoomPlayer.kMapName, [kTechDataModel] = Avatar.kModelName, [kTechDataMaxExtents] = Vector(Player.kXZExtents, Player.kYExtents, Player.kXZExtents) },
        
        // Spectators classes.
        { [kTechDataId] = kTechId.Spectator,              [kTechDataModel] = "" },
        { [kTechDataId] = kTechId.AlienSpectator,         [kTechDataModel] = "" },
        
        // Marine classes
        { [kTechDataId] = kTechId.Avatar,      [kTechDataDisplayName] = "AVATAR", [kTechDataMapName] = Avatar.kMapName, [kTechDataModel] = Avatar.kModelName, [kTechDataMaxExtents] = Vector(Player.kXZExtents, Player.kYExtents, Player.kXZExtents), [kTechDataMaxHealth] = Avatar.kHealth, [kTechDataEngagementDistance] = kPlayerEngagementDistance, [kTechDataPointValue] = kMarinePointValue},
        { [kTechDataId] = kTechId.AmmoPack,              [kTechDataAllowStacking] = true, [kTechDataCollideWithWorldOnly] = true, [kTechDataOptionalAttachToMethod] = GetAttachToMarineRequiresAmmo, [kTechDataMapName] = AmmoPack.kMapName,                 [kTechDataDisplayName] = "AMMO_PACK",      [kTechDataCostKey] = kAmmoPackCost,            [kTechDataModel] = AmmoPack.kModelName, [kTechDataTooltipInfo] = "AMMO_PACK_TOOLTIP", [kTechDataSpawnHeightOffset] = kCommanderDropSpawnHeight },
        { [kTechDataId] = kTechId.MedPack,               [kTechDataAllowStacking] = true, [kTechDataCollideWithWorldOnly] = true, [kTechDataOptionalAttachToMethod] = GetAttachToMarineRequiresHealth, [kTechDataMapName] = MedPack.kMapName,                  [kTechDataDisplayName] = "MED_PACK",     [kTechDataCostKey] = kMedPackCost,             [kTechDataModel] = MedPack.kModelName,  [kTechDataTooltipInfo] = "MED_PACK_TOOLTIP", [kTechDataSpawnHeightOffset] = kCommanderDropSpawnHeight},
        { [kTechDataId] = kTechId.CatPack,               [kTechDataAllowStacking] = true, [kTechDataCollideWithWorldOnly] = true, [kTechDataOptionalAttachToMethod] = GetAttachToMarineNotCatalysted, [kTechDataMapName] = CatPack.kMapName,                  [kTechDataDisplayName] = "CAT_PACK",      [kTechDataCostKey] = kCatPackCost,             [kTechDataModel] = CatPack.kModelName,  [kTechDataTooltipInfo] = "CAT_PACK_TOOLTIP", [kTechDataSpawnHeightOffset] = kCommanderDropSpawnHeight},

        { [kTechDataId] = kTechId.Rifle,      [kTechDataMaxHealth] = kRifleHealth, [kTechDataMaxArmor] = kRifleArmor,  [kTechDataPointValue] = kWeaponPointValue,    [kTechDataMapName] = Rifle.kMapName,                    [kTechDataDisplayName] = "RIFLE",         [kTechDataModel] = Rifle.kModelName, [kTechDataDamageType] = kRifleDamageType, [kTechDataCostKey] = kRifleCost, },
        { [kTechDataId] = kTechId.Pistol,     [kTechDataMaxHealth] = kPistolHealth, [kTechDataMaxArmor] = kPistolArmor,  [kTechDataPointValue] = kWeaponPointValue,          [kTechDataMapName] = Pistol.kMapName,                   [kTechDataDisplayName] = "PISTOL",         [kTechDataModel] = Pistol.kModelName, [kTechDataDamageType] = kPistolDamageType, [kTechDataCostKey] = kPistolCost, },
        { [kTechDataId] = kTechId.Axe,                   [kTechDataMapName] = Axe.kMapName,                      [kTechDataDisplayName] = "SWITCH_AX",         [kTechDataModel] = Axe.kModelName, [kTechDataDamageType] = kAxeDamageType, [kTechDataCostKey] = kAxeCost, },
        { [kTechDataId] = kTechId.Shotgun,     [kTechDataMaxHealth] = kShotgunHealth, [kTechDataMaxArmor] = kShotgunArmor,    [kTechDataPointValue] = kWeaponPointValue,      [kTechDataMapName] = Shotgun.kMapName,                  [kTechDataDisplayName] = "SHOTGUN",             [kTechDataTooltipInfo] =  "SHOTGUN_TOOLTIP", [kTechDataModel] = Shotgun.kModelName, [kTechDataDamageType] = kShotgunDamageType, [kTechDataCostKey] = kShotgunCost },
 

        { [kTechDataId] = kTechId.Flamethrower,     [kTechDataMaxHealth] = kFlamethrowerHealth, [kTechDataMaxArmor] = kFlamethrowerArmor,   [kTechDataPointValue] = kWeaponPointValue,  [kTechDataMapName] = Flamethrower.kMapName,             [kTechDataDisplayName] = "FLAMETHROWER", [kTechDataTooltipInfo] = "FLAMETHROWER_TOOLTIP", [kTechDataModel] = Flamethrower.kModelName,  [kTechDataDamageType] = kFlamethrowerDamageType, [kTechDataCostKey] = kFlamethrowerCost},
        { [kTechDataId] = kTechId.GrenadeLauncher,    [kTechDataMaxHealth] = kGrenadeLauncherHealth, [kTechDataMaxArmor] = kGrenadeLauncherArmor,   [kTechDataMapName] = GrenadeLauncher.kMapName,          [kTechDataDisplayName] = "GRENADE_LAUNCHER",  [kTechDataTooltipInfo] = "GRENADE_LAUNCHER_TOOLTIP",   [kTechDataModel] = GrenadeLauncher.kModelName,   [kTechDataDamageType] = kRifleDamageType,    [kTechDataCostKey] = kGrenadeLauncherCost},
 
        
        { [kTechDataId] = kTechId.DeathTrigger,                                 [kTechDataDisplayName] = "DEATH_TRIGGER",                                   [kTechDataMapName] = DeathTrigger.kMapName, [kTechDataModel] = ""},

    }

    return techData

end

kTechData = nil

function LookupTechId(fieldData, fieldName)

    // Initialize table if necessary
    if(kTechData == nil) then
    
        kTechData = BuildTechData()
        
    end
    
    if fieldName == nil or fieldName == "" then
    
        Print("LookupTechId(%s, %s) called improperly.", tostring(fieldData), tostring(fieldName))
        return kTechId.None
        
    end

    for index,record in ipairs(kTechData) do 
    
        local currentField = record[fieldName]
        
        if(fieldData == currentField) then
        
            return record[kTechDataId]
            
        end

    end
    
    //Print("LookupTechId(%s, %s) returned kTechId.None", fieldData, fieldName)
    
    return kTechId.None

end

// Table of fieldName tables. Each fieldName table is indexed by techId and returns data.
local cachedTechData = {}

function ClearCachedTechData()
    cachedTechData = {}
end

// Returns true or false. If true, return output in "data"
function GetCachedTechData(techId, fieldName)
    
    local entry = cachedTechData[fieldName]
    
    if entry ~= nil then
    
        return entry[techId]
        
    end
        
    return nil
    
end

function SetCachedTechData(techId, fieldName, data)

    local inserted = false
    
    local entry = cachedTechData[fieldName]
    
    if entry == nil then
    
        cachedTechData[fieldName] = {}
        entry = cachedTechData[fieldName]
        
    end
    
    if entry[techId] == nil then
    
        entry[techId] = data
        inserted = true
        
    end
    
    return inserted
    
end

// Call with techId and fieldname (returns nil if field not found). Pass optional
// third parameter to use as default if not found.
function LookupTechData(techId, fieldName, default)

    // Initialize table if necessary
    if(kTechData == nil) then
    
        kTechData = BuildTechData()
        
    end
    
    if techId == nil or techId == 0 or fieldName == nil or fieldName == "" then
    
        /*    
        local techIdString = ""
        if type(tonumber(techId)) == "number" then            
            techIdString = EnumToString(kTechId, techId)
        end
        
        Print("LookupTechData(%s, %s, %s) called improperly.", tostring(techIdString), tostring(fieldName), tostring(default))
        */
        
        return default
        
    end

    local data = GetCachedTechData(techId, fieldName)
    
    if data == nil then
    
        for index,record in ipairs(kTechData) do 
        
            local currentid = record[kTechDataId]

            if(techId == currentid and record[fieldName] ~= nil) then
            
                data = record[fieldName]
                
                break
                
            end
            
        end        
        
        if data == nil then
            data = default
        end
        
        if not SetCachedTechData(techId, fieldName, data) then
            //Print("Didn't insert anything when calling SetCachedTechData(%d, %s, %s)", techId, fieldName, tostring(data))
        else
            //Print("Inserted new field with SetCachedTechData(%d, %s, %s)", techId, fieldName, tostring(data))
        end
    
    end
    
    return data

end