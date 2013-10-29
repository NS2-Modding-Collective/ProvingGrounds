// ======= Copyright (c) 2003-2012, Unknown Worlds Entertainment, Inc. All rights reserved. =====
//
// lua\Server.lua
//
//    Created by:   Andy Wilson for Proving Grounds
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

// Set the name of the VM for debugging
decoda_name = "Server"

Script.Load("lua/PreLoadMod.lua")

Script.Load("lua/Shared.lua")
Script.Load("lua/MapEntityLoader.lua")
Script.Load("lua/TechData.lua")
Script.Load("lua/TargetCache.lua")

Script.Load("lua/GreenTeam.lua")
Script.Load("lua/PurpleTeam.lua")
Script.Load("lua/VoteManager.lua")
Script.Load("lua/Voting.lua")
Script.Load("lua/VotingKickPlayer.lua")
Script.Load("lua/VotingChangeMap.lua")
Script.Load("lua/VotingResetGame.lua")
Script.Load("lua/VotingRandomizeRR.lua")
Script.Load("lua/Badges_Server.lua")

Script.Load("lua/ServerConfig.lua")
Script.Load("lua/ServerAdmin.lua")
Script.Load("lua/TournamentMode.lua")
Script.Load("lua/ServerAdminCommands.lua")
Script.Load("lua/ServerWebInterface.lua")
Script.Load("lua/MapCycle.lua")
Script.Load("lua/ConsistencyConfig.lua")

Script.Load("lua/ConsoleCommands_Server.lua")
Script.Load("lua/NetworkMessages_Server.lua")

Script.Load("lua/dkjson.lua")

Script.Load("lua/NetworkDebug.lua")

Server.readyRoomSpawnList = table.array(32)

Server.team1SpawnList = table.array(16)
Server.team2SpawnList = table.array(16)

Server.spawnItem1List = table.array(32)

// map name, group name and values keys for all map entities loaded to
// be created on game reset
Server.mapLoadLiveEntityValues = table.array(100)

// Game entity indices created from mapLoadLiveEntityValues. They are all deleted
// on and rebuilt on map reset.
Server.mapLiveEntities = table.array(32)

// Map entities are stored here in order of their priority so they are loaded
// in the correct order (Structure assumes that Gamerules exists upon loading for example).
Server.mapPostLoadEntities = table.array(32)

// Recent chat messages are stored on the server.
Server.recentChatMessages = CreateRingBuffer(20)
local chatMessageCount = 0

local reservedSlots = Server.GetConfigSetting("reserved_slots")
if reservedSlots and reservedSlots.amount > 0 then
    SetReservedSlotAmount(reservedSlots.amount)
end

function Server.AddChatToHistory(message, playerName, steamId, teamNumber, teamOnly)

    chatMessageCount = chatMessageCount + 1
    Server.recentChatMessages:Insert({ id = chatMessageCount, message = message, player = playerName,
                                       steamId = steamId, team = teamNumber, teamOnly = teamOnly })
    
end

/**
 * Map entities with a higher priority are loaded first.
 */
local kMapEntityLoadPriorities = { }
kMapEntityLoadPriorities[PGGamerules.kMapName] = 1
local function GetMapEntityLoadPriority(mapName)

    local priority = 0
    
    if kMapEntityLoadPriorities[mapName] then
        priority = kMapEntityLoadPriorities[mapName]
    end
    
    return priority

end

// filter the entities which are explore mode only
// MUST BE GLOBAL - overridden by mods
function GetLoadEntity(mapName, groupName, values)
    return values.onlyexplore ~= true
end

// MUST BE GLOBAL - overridden by mods
function GetCreateEntityOnStart(mapName, groupName, values)

    return mapName ~= "prop_static"
       and mapName ~= "light_point"
       and mapName ~= "light_spot"
       and mapName ~= "light_ambient"
       and mapName ~= "color_grading"
       and mapName ~= "cinematic"
       and mapName ~= "skybox"
       and mapName ~= ReadyRoomSpawn.kMapName
       and mapName ~= "ambient_sound"
       and mapName ~= Reverb.kMapName
       and mapName ~= "spawn_selection_override"
    
end

// MUST BE GLOBAL - overridden by mods
function GetLoadSpecial(mapName, groupName, values)

    local success = false
    
    if mapName == ReadyRoomSpawn.kMapName then
    
        local entity = ReadyRoomSpawn()
        entity:OnCreate()
        LoadEntityFromValues(entity, values)
        table.insert(Server.readyRoomSpawnList, entity)
        success = true
    
    elseif mapName == TeamSpawn.kMapName then
    
        local entity = TeamSpawn()
        entity:OnCreate()
        LoadEntityFromValues(entity, values)
        if entity.teamNumber == kTeam1Index then
            table.insert(Server.team1SpawnList, entity)
        end
        if entity.teamNumber == kTeam2Index then
            table.insert(Server.team2SpawnList, entity)
        end
        
    elseif mapName == ItemSpawn.kMapName then
        
        local entity = ItemSpawn()
        entity:OnCreate()
        LoadEntityFromvalues(entity, values)
        if entity.itemName == kSpawnItem1 then
            table.insert(Server.spawnItem1List, entity)
        end
  
    elseif mapName == "cinematic" then
    
        success = values.startsOnMessage ~= nil and values.startsOnMessage ~= ""
        if success then
        
            PrecacheAsset(values.cinematicName)
            local entity = Server.CreateEntity(ServerParticleEmitter.kMapName, values)
            if entity then
                entity:SetMapEntity()
            end
            
        end
        
    elseif mapName == "spawn_selection_override" then
    
        Server.spawnSelectionOverrides = Server.spawnSelectionOverrides or { }
        table.insert(Server.spawnSelectionOverrides, { alienSpawn = string.lower(values.alienSpawn), marineSpawn = string.lower(values.marineSpawn) })
        success = true
        
    end
    
    return success
    
end

local function DumpServerEntity(mapName, groupName, values)

    Print("------------ %s ------------", ToString(mapName))
    
    for key, value in pairs(values) do    
        Print("[%s] %s", ToString(key), ToString(value))
    end
    
    Print("---------------------------------------------")

end

local function LoadServerMapEntity(mapName, groupName, values)

    if not GetLoadEntity(mapName, groupName, values) then
        return
    end
    
    // Skip the classes that are not true entities and are handled separately
    // on the client.
    if GetCreateEntityOnStart(mapName, groupName, values) then
        
        local entity = Server.CreateEntity(mapName, values)
        if entity then
        
            entity:SetMapEntity()
            
            // Map Entities with LiveMixin can be destroyed during the game.
            if HasMixin(entity, "Live") then
            
                // Insert into table so we can re-create them all on map post load (and game reset)
                table.insert(Server.mapLoadLiveEntityValues, {mapName, groupName, values})
                
                // Delete it because we're going to recreate it on map reset
                table.insert(Server.mapLiveEntities, entity:GetId())
                
            end
            
        end
    end
    
    if not GetLoadSpecial(mapName, groupName, values) then
    
        // Allow the MapEntityLoader to load it if all else fails.
        LoadMapEntity(mapName, groupName, values)
        
    end
    
end

/**
 * Called as the map is being loaded to create the entities.
 */
function OnMapLoadEntity(mapName, groupName, values)

    local priority = GetMapEntityLoadPriority(mapName)
    if Server.mapPostLoadEntities[priority] == nil then
        Server.mapPostLoadEntities[priority] = { }
    end

    table.insert(Server.mapPostLoadEntities[priority], { MapName = mapName, GroupName = groupName, Values = values })

end

function OnMapPreLoad()

    Shared.PreLoadSetGroupNeverVisible(kCollisionGeometryGroupName)
    Shared.PreLoadSetGroupNeverVisible(kMovementCollisionGroupName)
    Shared.PreLoadSetGroupNeverVisible(kInvisibleCollisionGroupName)
    Shared.PreLoadSetGroupPhysicsId(kNonCollisionGeometryGroupName, 0)
    
    // Don't have bullets collide with collision geometry
    Shared.PreLoadSetGroupPhysicsId(kCollisionGeometryGroupName, PhysicsGroup.CollisionGeometryGroup)
    Shared.PreLoadSetGroupPhysicsId(kMovementCollisionGroupName, PhysicsGroup.CollisionGeometryGroup)
    
    
    // Clear spawn points
    Server.readyRoomSpawnList = {}
    Server.team1SpawnList = {}
    Server.team2SpawnList = {}
    Server.spawnItem1List = {}
    
    Server.mapLoadLiveEntityValues = {}
    Server.mapLiveEntities = {}
    
end

function DestroyLiveMapEntities()

    // Delete any map entities that have been created
    for index, mapEntId in ipairs(Server.mapLiveEntities) do
    
        local ent = Shared.GetEntity(mapEntId)
        if ent then
            DestroyEntity(ent)
        end
        
    end
    
    Server.mapLiveEntities = { }
    
end

function CreateLiveMapEntities()

    // Create new Live map entities
    for index, triple in ipairs(Server.mapLoadLiveEntityValues) do
        
        // {mapName, groupName, keyvalues}
        local entity = Server.CreateEntity(triple[1], triple[3])
        
        // Store so we can track it during the game and delete it on game reset if not dead yet
        table.insert(Server.mapLiveEntities, entity:GetId())

    end

end

local function CheckForDuplicateLocations()

    local locations = GetLocations()
    for _, checkLocation in ipairs(locations) do
    
        for _, dupLocation in ipairs(locations) do
        
            // Don't check the same exact location against itself.
            if checkLocation ~= dupLocation then
            
                if checkLocation:GetOrigin() == dupLocation:GetOrigin() then
                    Print("Duplicate location detected: " .. dupLocation:GetName())
                end
                
            end
            
        end
        
    end
    
end

/**
 * Callback handler for when the map is finished loading.
 */
local function OnMapPostLoad()

    // Higher priority entities are loaded first.
    local highestPriority = 0
    for k, v in pairs(kMapEntityLoadPriorities) do
        if v > highestPriority then highestPriority = v end
    end
    
    for i = highestPriority, 0, -1 do
    
        if Server.mapPostLoadEntities[i] then
        
            for k, entityData in ipairs(Server.mapPostLoadEntities[i]) do
                LoadServerMapEntity(entityData.MapName, entityData.GroupName, entityData.Values)
            end
            
        end
        
    end
    
    Server.mapPostLoadEntities = { }
    
    CheckForDuplicateLocations()
    
    GetGamerules():OnMapPostLoad()
    
end

/**
 * Called by the engine to test if a player (represented by the entity they are
 * controlling) can hear another player for the purposes of voice chat.
 */
local function OnCanPlayerHearPlayer(listener, speaker)
    return GetGamerules():GetCanPlayerHearPlayer(listener, speaker)
end

/**
 * The reserved slot system allows players marked as reserved players to join while
 * all non-reserved slots are taken and the server is not full.
 */
local function OnCheckConnectionAllowed(userId)

    local reservedSlots = Server.GetConfigSetting("reserved_slots")
    
    if not reservedSlots or not reservedSlots.amount or not reservedSlots.ids then
        return true
    end
    
    local newPlayerIsReserved = false
    for name, id in pairs(reservedSlots.ids) do
    
        if id == userId then
        
            newPlayerIsReserved = true
            break
            
        end
        
    end
    
    local numPlayers = Server.GetNumPlayers()
    local maxPlayers = Server.GetMaxPlayers()
    
    if (numPlayers < (maxPlayers - reservedSlots.amount)) or (newPlayerIsReserved and (numPlayers < maxPlayers)) then
        return true
    end
    
    return false
    
end
Event.Hook("CheckConnectionAllowed", OnCheckConnectionAllowed)

Event.Hook("MapPreLoad", OnMapPreLoad)
Event.Hook("MapPostLoad", OnMapPostLoad)
Event.Hook("MapLoadEntity", OnMapLoadEntity)
Event.Hook("CanPlayerHearPlayer", OnCanPlayerHearPlayer)

Script.Load("lua/PostLoadMod.lua")
