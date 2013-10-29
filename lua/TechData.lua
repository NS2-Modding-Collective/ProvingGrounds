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
kTechDataMaxHealth                      = "maxhealth"
kTechDataDamageType                     = "damagetype"

// If specified, draw a range indicator for the commander when selected.
kVisualRange                            = "visualrange"
// set to true when attach structure is not required but optional
kTechDataAttachOptional                   = "attachoptional"

// If specified, object spawns this far off the ground
kTechDataSpawnHeightOffset              = "spawnheight"
// All player tech ids should have this, nothing else uses it. Pre-computed by looking at the min and max extents of the model, 
// adding their absolute values together and dividing by 2. 
kTechDataMaxExtents                     = "maxextents"
// Set true if entity should be rotated before being placed
kTechDataSpecifyOrientation             = "specifyorientation"
// manipulate build coords in a custom function
kTechDataOverrideCoordsMethod           = "overridecoordsmethod"
// Point value for killing structure
kTechDataPointValue                     = "pointvalue"
// Set to false if not yet implemented, for displaying differently for not enabling
kTechDataImplemented                    = "implemented"
// Set to localizable string that will be added to end of description indicating date it went in. 
kTechDataNew                            = "new"
// Alert sound name
kTechDataAlertSound                     = "alertsound"
// Alert text for commander HUD
kTechDataAlertText                      = "alerttext"
// Alert type. These are the types in CommanderUI_GetDynamicMapBlips. "Request" alert types count as player alert requests and show up on the commander HUD as such.
kTechDataAlertType                      = "alerttype"
// Alert scope
kTechDataAlertTeam                      = "alertteam"
// Alert should ignore distance for triggering
kTechDataAlertIgnoreDistance            = "alertignoredistance"
// Alert should also trigger a team message.
kTechDataAlertSendTeamMessage           = "alertsendteammessage"
// Don't send alert to originator of this alert 
kTechDataAlertOthersOnly                = "alertothers"
// Usage notes, caveats, etc. for use in commander tooltip (localizable)
kTechDataTooltipInfo                    = "tooltipinfo"
// Quite the same as tooltip, but shorter
kTechDataHint                           = "hintinfo"
// Indicate tech id that we're replicating
// Engagement distance - how close can unit get to it before it can repair or build it
kTechDataEngagementDistance             = "engagementdist"

// Allows dropping onto other entities
kTechDataAllowStacking                 = "allowstacking"
// will ignore other entities when searching for spawn position
kTechDataCollideWithWorldOnly          = "collidewithworldonly"
// only useable once every X seconds
kTechDataCooldown = "coldownduration"
// ignore any alert interval
kTechDataAlertIgnoreInterval = "ignorealertinterval"

kTechDataSupply = "supply"

function BuildTechData()
    
    local techData = { 

        // Ready room player is the default player, hence the ReadyRoomPlayer.kMapName
        { [kTechDataId] = kTechId.ReadyRoomPlayer,        [kTechDataDisplayName] = "READY_ROOM_PLAYER", [kTechDataMapName] = ReadyRoomPlayer.kMapName, [kTechDataModel] = AvatarVariantMixin.kModelNames["male"]["green"], [kTechDataMaxExtents] = Vector(Player.kXZExtents, Player.kYExtents, Player.kXZExtents) },
        
        // Spectators classes.
        { [kTechDataId] = kTechId.Spectator,              [kTechDataModel] = "" },
        { [kTechDataId] = kTechId.MarineSpectator,         [kTechDataModel] = "" },
        
        // Player Classes
        { [kTechDataId] = kTechId.Avatar,      [kTechDataDisplayName] = "Avatar", [kTechDataMapName] = Avatar.kMapName}, 
        { [kTechDataId] = kTechId.GreenAvatar,      [kTechDataDisplayName] = "GreenAvatar", [kTechDataMapName] = GreenAvatar.kMapName, [kTechDataModel] = AvatarVariantMixin.kModelNames["male"]["green"], [kTechDataMaxExtents] = Vector(Player.kXZExtents, Player.kYExtents, Player.kXZExtents), [kTechDataMaxHealth] = Avatar.kHealth, [kTechDataEngagementDistance] = kPlayerEngagementDistance, [kTechDataPointValue] = kAvatarPointValue},
        { [kTechDataId] = kTechId.PurpleAvatar,      [kTechDataDisplayName] = "PurpleAvatar", [kTechDataMapName] = PurpleAvatar.kMapName, [kTechDataModel] = AvatarVariantMixin.kModelNames["male"]["green"], [kTechDataMaxExtents] = Vector(Player.kXZExtents, Player.kYExtents, Player.kXZExtents), [kTechDataMaxHealth] = Avatar.kHealth, [kTechDataEngagementDistance] = kPlayerEngagementDistance, [kTechDataPointValue] = kAvatarPointValue},
        
        // Weapon Classes
        { [kTechDataId] = kTechId.Rifle,      [kTechDataMaxHealth] = kMarineWeaponHealth, [kTechDataTooltipInfo] = "RIFLE_TOOLTIP",    [kTechDataMapName] = Rifle.kMapName,                    [kTechDataDisplayName] = "RIFLE",         [kTechDataModel] = Rifle.kModelName, [kTechDataDamageType] = kRifleDamageType },
        { [kTechDataId] = kTechId.Pistol,     [kTechDataMaxHealth] = kMarineWeaponHealth,       [kTechDataMapName] = Pistol.kMapName,                   [kTechDataDisplayName] = "PISTOL",         [kTechDataModel] = Pistol.kModelName, [kTechDataDamageType] = kPistolDamageType, [kTechDataTooltipInfo] = "PISTOL_TOOLTIP"},
        { [kTechDataId] = kTechId.Axe,                   [kTechDataMapName] = Axe.kMapName,                      [kTechDataDisplayName] = "SWITCH_AX",         [kTechDataModel] = Axe.kModelName, [kTechDataDamageType] = kAxeDamageType},
        { [kTechDataId] = kTechId.Shotgun,     [kTechDataMaxHealth] = kMarineWeaponHealth,    [kTechDataPointValue] = kShotgunPointValue,      [kTechDataMapName] = Shotgun.kMapName,                  [kTechDataDisplayName] = "SHOTGUN",             [kTechDataModel] = Shotgun.kModelName, [kTechDataDamageType] = kShotgunDamageType},
        { [kTechDataId] = kTechId.Flamethrower,     [kTechDataMaxHealth] = kMarineWeaponHealth, [kTechDataPointValue] = kFlamethrowerPointValue,  [kTechDataMapName] = Flamethrower.kMapName,             [kTechDataDisplayName] = "FLAMETHROWER", [kTechDataModel] = Flamethrower.kModelName,  [kTechDataDamageType] = kFlamethrowerDamageType},
        { [kTechDataId] = kTechId.RocketLauncher,    [kTechDataMaxHealth] = kMarineWeaponHealth,  [kTechDataPointValue] = kRocketLauncherPointValue, [kTechDataMapName] = RocketLauncher.kMapName,          [kTechDataDisplayName] = "ROCKET_LAUNCHER",  [kTechDataModel] = RocketLauncher.kModelName,   [kTechDataDamageType] = kRifleDamageType},
        
        // Interactive Entities
        { [kTechDataId] = kTechId.JumpPadTrigger,       [kTechDataMapName] = JumpPadTrigger.kMapName },       
        { [kTechDataId] = kTechId.AmmoPack,              [kTechDataAllowStacking] = true, [kTechDataMapName] = AmmoPack.kMapName,  [kTechDataDisplayName] = "AMMO_PACK",      [kTechDataModel] = AmmoPack.kModelName, [kTechDataTooltipInfo] = "AMMO_PACK_TOOLTIP", [kTechDataSpawnHeightOffset] = kCommanderDropSpawnHeight },
        { [kTechDataId] = kTechId.MedPack,    [kTechDataCooldown] = kMedPackCooldown,         [kTechDataAllowStacking] = true, [kTechDataMapName] = MedPack.kMapName,   [kTechDataDisplayName] = "MED_PACK",     [kTechDataModel] = MedPack.kModelName,  [kTechDataTooltipInfo] = "MED_PACK_TOOLTIP", [kTechDataSpawnHeightOffset] = kCommanderDropSpawnHeight},
        { [kTechDataId] = kTechId.CatPack,               [kTechDataAllowStacking] = true, [kTechDataMapName] = CatPack.kMapName,   [kTechDataDisplayName] = "CAT_PACK",      [kTechDataModel] = CatPack.kModelName,  [kTechDataTooltipInfo] = "CAT_PACK_TOOLTIP", [kTechDataSpawnHeightOffset] = kCommanderDropSpawnHeight},
      
      
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

local gTechForCategory = nil
function GetTechForCategory(techId)

    if gTechForCategory == nil then

        gTechForCategory = {}

        for upgradeId = 2, #kTechId do
        
            local category = LookupTechData(upgradeId, kTechDataCategory, nil)
            if category and category ~= kTechId.None then
                
                if not gTechForCategory[category] then
                    gTechForCategory[category] = {}
                end
                
                table.insertunique(gTechForCategory[category], upgradeId)

            end
        
        end
    
    end
    
    return gTechForCategory[techId] or {}

end

