// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\ConsoleCommands_Server.lua
//
//    Created by:   Charlie Cleveland (charlie@unknownworlds.com) and
//                  Max McGuire (max@unknownworlds.com)
//
// NS2 Gamerules specific console commands. 
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

local function JoinTeam(player, teamIndex)

    if player ~= nil and player:GetTeamNumber() == kTeamReadyRoom then
    
        // Auto team balance checks.
        if GetGamerules():GetCanJoinTeamNumber(teamIndex) or Shared.GetCheatsEnabled() then
            return GetGamerules():JoinTeam(player, teamIndex)
        end
        
    end
    
    return false
    
end

local function JoinTeamOne(player)
    return JoinTeam(player, kTeam1Index)
end

local function JoinTeamTwo(player)
    return JoinTeam(player, kTeam2Index)
end

local function ReadyRoom(player)
    player:SetCameraDistance(0)
    return GetGamerules():JoinTeam(player, kTeamReadyRoom)
end

local function Spectate(player)
    return GetGamerules():JoinTeam(player, kSpectatorIndex)
end

local function OnCommandJoinTeamOne(client)
    local player = client:GetControllingPlayer()
    JoinTeamOne(player)
end

local function OnCommandJoinTeamTwo(client)
    local player = client:GetControllingPlayer()
    JoinTeamTwo(player)
end

local function OnCommandReadyRoom(client)
    local player = client:GetControllingPlayer()
    ReadyRoom(player)
end

local function OnCommandSpectate(client)
    local player = client:GetControllingPlayer()
    Spectate(player)
end

local function OnCommandFilm(client)

    local player = client:GetControllingPlayer()
    
    if Shared.GetCheatsEnabled() or Shared.GetDevMode() or (player:GetTeamNumber() == kTeamReadyRoom) then

        Shared.Message("Film mode enabled. Hold crouch for dolly, movement modifier for speed or attack to orbit then press movement keys.")

        local success, newPlayer = Spectate(player)
        
        // Transform class into FilmSpectator
        newPlayer:Replace(FilmSpectator.kMapName, newPlayer:GetTeamNumber(), false)
        
    end
    
end

/**
 * Forces the game to end for testing purposes
 */
local function OnCommandEndGame(client)

    local player = client:GetControllingPlayer()

    if Shared.GetCheatsEnabled() and GetGamerules():GetGameStarted() then
        GetGamerules():EndGame(player:GetTeam())
    end
    
end

local function OnCommandEnergy(client)

    local player = client:GetControllingPlayer()
    
    if Shared.GetCheatsEnabled() then
    
        // Give energy to all structures on our team.
        for index, ent in ipairs(GetEntitiesWithMixinForTeam("Energy", player:GetTeamNumber())) do
            ent:SetEnergy(ent:GetMaxEnergy())
        end
        
    end
    
end

local function OnCommandTakeDamage(client, amount)

    local player = client:GetControllingPlayer()
    
    if Shared.GetCheatsEnabled() then
    
        local damage = tonumber(amount)
        if damage == nil then
            damage = 20 + math.random() * 10
        end
        
        local damageEntity = player
        if player:isa("Commander") then
        
            // Find command structure we're in and do damage to that instead
            local commandStructures = Shared.GetEntitiesWithClassname("CommandStructure")
            for index, commandStructure in ientitylist(commandStructures) do
            
                local comm = commandStructure:GetCommander()
                if comm and comm:GetId() == player:GetId() then
                
                    damageEntity = commandStructure
                    break
                    
                end
                
            end
            
        end
        
        if not damageEntity:GetCanTakeDamage() then
            damage = 0
        end
        
        Print("Doing %.2f damage to %s", damage, damageEntity:GetClassName())
        damageEntity:DeductHealth(damage, player, player)
        
    end
    
end

local function OnCommandHeal(client, amount)

    if Shared.GetCheatsEnabled() then
    
        amount = amount and tonumber(amount) or 10
        local player = client:GetControllingPlayer()
        player:AddHealth(amount)
        
    end
    
end

local function OnCommandGiveAmmo(client)

    if client ~= nil and Shared.GetCheatsEnabled() then

        local player = client:GetControllingPlayer()
        local weapon = player:GetActiveWeapon()

        if weapon ~= nil and weapon:isa("ClipWeapon") then
            weapon:GiveAmmo(1)
        end
    
    end
    
end

local function OnCommandEnts(client, className)

    // Allow it to be run on dedicated server
    if client == nil or Shared.GetCheatsEnabled() then
    
        local entityCount = Shared.GetEntitiesWithClassname("Entity"):GetSize()
        
        local weaponCount = Shared.GetEntitiesWithClassname("Weapon"):GetSize()
        local playerCount = Shared.GetEntitiesWithClassname("Player"):GetSize()
        local team1 = GetGamerules():GetTeam1()
        local team2 = GetGamerules():GetTeam2()
        local playersOnPlayingTeams = team1:GetNumPlayers() + team2:GetNumPlayers()

        if className then
            local numClassEnts = Shared.GetEntitiesWithClassname(className):GetSize()
            Shared.Message(Pluralize(numClassEnts, className))
        else
        
            local formatString = "%d entities (%s, %d playing, %s )."
            Shared.Message( string.format(formatString, 
                            entityCount, 
                            Pluralize(playerCount, "player"), playersOnPlayingTeams, 
                            Pluralize(weaponCount, "weapon")))
        end
    end
    
end

local function OnCommandServerEntities(client, entityType)

    if client == nil or Shared.GetCheatsEnabled() then
        DumpEntityCounts(entityType)
    end
    
end

local function OnCommandEntityInfo(client, entityId)

    if client == nil or Shared.GetCheatsEnabled() then
    
        local ent = Shared.GetEntity(tonumber(entityId))
        if not ent then
        
            Shared.Message("No entity matching Id: " .. entityId)
            return
            
        end
        
        local entInfo = GetEntityInfo(ent)
        Shared.Message(entInfo)
        
    end
    
end

local function OnCommandServerEntInfo(client, entityId)

    if client == nil or Shared.GetCheatsEnabled() then
    end
    
end

// Switch player from one team to the other, while staying in the same place
local function OnCommandSwitch(client)

    local player = client:GetControllingPlayer()
    local teamNumber = player:GetTeamNumber()
    if(Shared.GetCheatsEnabled() and (teamNumber == kTeam1Index or teamNumber == kTeam2Index)) and not player:GetIsCommander() then
    
        // Remember position and team for calling player for debugging
        local playerOrigin = player:GetOrigin()
        local playerViewAngles = player:GetViewAngles()
        
        local newTeamNumber = kTeam1Index
        if(teamNumber == kTeam1Index) then
            newTeamNumber = kTeam2Index
        end
        
        local success, newPlayer = GetGamerules():JoinTeam(player, kTeamReadyRoom)
        success, newPlayer = GetGamerules():JoinTeam(newPlayer, newTeamNumber)
        
        newPlayer:SetOrigin(playerOrigin)
        newPlayer:SetViewAngles(playerViewAngles)
        
    end
    
end

local function OnCommandDamage(client,multiplier)

    if(Shared.GetCheatsEnabled()) then
        local m = multiplier and tonumber(multiplier) or 1
        GetGamerules():SetDamageMultiplier(m)
        Shared.Message("Damage multipler set to " .. m)
    end
    
end

local function OnCommandHighDamage(client)

    if Shared.GetCheatsEnabled() and GetGamerules():GetDamageMultiplier() < 10 then
    
        GetGamerules():SetDamageMultiplier(10)
        Print("highdamage on (10x damage)")
        
    // Toggle off
    elseif not Shared.GetCheatsEnabled() or GetGamerules():GetDamageMultiplier() > 1 then
    
        GetGamerules():SetDamageMultiplier(1)
        Print("highdamage off")
        
    end
    
end

local function OnCommandGive(client, itemName)

    local player = client:GetControllingPlayer()
    if(Shared.GetCheatsEnabled() and itemName ~= nil) then
        player:GiveItem(itemName)
        //player:SetActiveWeapon(itemName)
    end
    
end

local function OnCommandSpawn(client, itemName, teamnum)

    local player = client:GetControllingPlayer()
    if(Shared.GetCheatsEnabled() and itemName ~= nil) then
    
        // trace along players zAxis and spawn the item there
        local startPoint = player:GetEyePos()
        local endPoint = startPoint + player:GetViewCoords().zAxis * 100
        
        local trace = Shared.TraceRay(startPoint, endPoint,  CollisionRep.Default, PhysicsMask.Bullets, EntityFilterAll())
        
        if not teamnum then
            teamnum = player:GetTeamNumber()
        else
            teamnum = tonumber(teamnum)
        end

        local newItem = CreateEntity(itemName, trace.endPoint, teamnum)
        if newItem:isa("Projectile") then
            newItem:SetVelocity(Vector(0, 1, 0))
        end
        
        
    end
    
end

local function OnCommandSetFOV(client, fovValue)

    local player = client:GetControllingPlayer()
    if Shared.GetDevMode() then
        player:SetFov(tonumber(fovValue))
    end
    
end

local function OnCommandChangeClass(className, teamNumber, extraValues)

    return function(client)
    
        local player = client:GetControllingPlayer()
        if Shared.GetCheatsEnabled() and player:GetTeamNumber() == teamNumber then
            player:Replace(className, player:GetTeamNumber(), false, nil, extraValues)
        end
        
    end
    
end

local function OnCommandCatPack(client)

    local player = client:GetControllingPlayer()
    if(Shared.GetCheatsEnabled() and player:isa("Marine")) then
        player:ApplyCatPack()
    end
end

local function OnCommandAllTech(client)

    local player = client:GetControllingPlayer()
    if(Shared.GetCheatsEnabled()) then
    
        local newAllTechState = not GetGamerules():GetAllTech()
        GetGamerules():SetAllTech(newAllTechState)
        Print("Setting alltech cheat %s", ConditionalValue(newAllTechState, "on", "off"))
        
    end
    
end

local function OnCommandLocation(client)

    local player = client:GetControllingPlayer()
    local locationName = player:GetLocationName()
    if locationName ~= "" then
        Print("You are in \"%s\".", locationName)
    else
        Print("You are nowhere.")
    end
    
end

local function OnCommandCloseMenu(client)
    local player = client:GetControllingPlayer()
    player:CloseMenu()
end

local function OnCommandPush(client)

    if Shared.GetCheatsEnabled() then
        local player = client:GetControllingPlayer()
        if player then
            player:AddPushImpulse(Vector(50,10,0))
        end
    end
    
end

local function techIdStringToTechId(techIdString)

    local techId = tonumber(techIdString)
    
    if type(techId) ~= "number" then
        techId = StringToEnum(kTechId, techIdString)
    end        
    
    return techId
    
end

// Create structure, weapon, etc. near player
local function OnCommandCreate(client, techIdString, number)

    if Shared.GetCheatsEnabled() then
    
        local techId = techIdStringToTechId(techIdString)
        local attachClass = LookupTechData(techId, kStructureAttachClass)
        
        number = number or 1
        
        if techId ~= nil then
        
            for i = 1, number do
            
                local success = false
                // Persistence is the path to victory.
                for index = 1, 2000 do
                
                    local player = client:GetControllingPlayer()
                    local teamNumber = player:GetTeamNumber()
                    if techId == kTechId.Scan then
                        teamNumber = GetEnemyTeamNumber(teamNumber)
                    end
                    local position = nil
                    
                    if attachClass then
                    
                        local attachEntity = GetNearestFreeAttachEntity(techId, player:GetOrigin(), 1000)
                        if attachEntity then
                            position = attachEntity:GetOrigin()
                        end
                        
                    else
                    
                        /*local modelName = LookupTechData(techId, kTechDataModel)
                        local modelIndex = Shared.GetModelIndex(modelName)
                        local model = Shared.GetModel(modelIndex)
                        local minExtents, maxExtents = model:GetExtents()
                        Print(modelName .. " bounding box min: " .. ToString(minExtents) .. " max: " .. ToString(maxExtents))
                        local extents = maxExtents
                        DebugBox(player:GetOrigin(), player:GetOrigin(), maxExtents - minExtents, 1000, 1, 0, 0, 1)
                        DebugBox(player:GetOrigin(), player:GetOrigin(), minExtents, 1000, 0, 1, 0, 1)
                        DebugBox(player:GetOrigin(), player:GetOrigin(), maxExtents, 1000, 0, 0, 1, 1)*/
                        //position = GetRandomSpawnForCapsule(extents.y, extents.x, player:GetOrigin() + Vector(0, 0.5, 0), 2, 10)
                        //position = position - Vector(0, extents.y, 0)
                        
                        position = CalculateRandomSpawn(nil, player:GetOrigin() + Vector(0, 0.5, 0), techId, true, 2, 10, 3)
                        
                    end
                    
                    if position then
                    
                        success = true
                        CreateEntityForTeam(techId, position, teamNumber, player)
                        break
                        
                    end
                    
                end
                
                if not success then
                    Print("Create %s: Couldn't find space for entity", EnumToString(kTechId, techId))
                end
                
            end
            
        else
            Print("Usage: create (techId name)")
        end
        
    end
    
end

local function OnCommandRandomDebug(s)

    if Shared.GetCheatsEnabled() then
    
        local newState = not gRandomDebugEnabled
        Print("OnCommandRandomDebug() now %s", ToString(newState))
        gRandomDebugEnabled = newState

    end
    
end

local function OnCommandSetGameEffect(client, gameEffectString, trueFalseString)

    if Shared.GetCheatsEnabled() then
    
        local player = client:GetControllingPlayer()          
        local gameEffectBitMask = kGameEffect[gameEffectString]
        if gameEffectBitMask ~= nil then
        
            Print("OnCommandSetGameEffect(%s) => %s", gameEffectString, ToString(gameEffectBitMask))
            
            local state = true
            if trueFalseString and ((trueFalseString == "false") or (trueFalseString == "0")) then
                state = false
            end
            
            player:SetGameEffectMask(gameEffectBitMask, state)
            
        else
            Print("Couldn't find bitmask in %s for %s", ToString(kGameEffect), gameEffectString)
        end        
        
    end
    
end

local function OnCommandChangeGCSettingServer(client, settingName, newValue)

    if Shared.GetCheatsEnabled() then
    
        if settingName == "setpause" or settingName == "setstepmul" then
            Shared.Message("Changing server GC setting " .. settingName .. " to " .. tostring(newValue))
            collectgarbage(settingName, newValue)
        else
            Shared.Message(settingName .. " is not a valid setting")
        end
        
    end
    
end

local function OnCommandRespawnTeam(client, teamNum)

    if Shared.GetCheatsEnabled() then
    
        teamNum = tonumber(teamNum)
        if teamNum == 1 then
            GetGamerules():GetTeam1():ReplaceRespawnAllPlayers()
        elseif teamNum == 2 then
            GetGamerules():GetTeam2():ReplaceRespawnAllPlayers()
        end
        
    end
    
end

// GC commands
Event.Hook("Console_changegcsettingserver", OnCommandChangeGCSettingServer)

// NS2 game mode console commands
Event.Hook("Console_jointeamone", OnCommandJoinTeamOne)
Event.Hook("Console_jointeamtwo", OnCommandJoinTeamTwo)
Event.Hook("Console_readyroom", OnCommandReadyRoom)
Event.Hook("Console_spectate", OnCommandSpectate)
Event.Hook("Console_film", OnCommandFilm)

// Shortcuts because we type them so much
Event.Hook("Console_j1", OnCommandJoinTeamOne)
Event.Hook("Console_j2", OnCommandJoinTeamTwo)
Event.Hook("Console_rr", OnCommandReadyRoom)

Event.Hook("Console_endgame", OnCommandEndGame)

// Cheats
Event.Hook("Console_takedamage", OnCommandTakeDamage)
Event.Hook("Console_heal", OnCommandHeal)
Event.Hook("Console_giveammo", OnCommandGiveAmmo)
Event.Hook("Console_respawn_team", OnCommandRespawnTeam)

Event.Hook("Console_ents", OnCommandEnts)
Event.Hook("Console_sents", OnCommandServerEntities)
Event.Hook("Console_entinfo", OnCommandEntityInfo)

Event.Hook("Console_switch", OnCommandSwitch)
Event.Hook("Console_damage", OnCommandDamage)
Event.Hook("Console_highdamage", OnCommandHighDamage)
Event.Hook("Console_give", OnCommandGive)
Event.Hook("Console_spawn", OnCommandSpawn)
Event.Hook("Console_setfov", OnCommandSetFOV)

// For testing lifeforms
Event.Hook("Console_av1", OnCommandChangeClass("avatar", kTeam1Index))
Event.Hook("Console_av2", OnCommandChangeClass("avatar", kTeam2Index))

Event.Hook("Console_catpack", OnCommandCatPack)
Event.Hook("Console_alltech", OnCommandAllTech)
Event.Hook("Console_location", OnCommandLocation)
Event.Hook("Console_push", OnCommandPush)

Event.Hook("Console_closemenu", OnCommandCloseMenu)

Event.Hook("Console_create",OnCommandCreate)
Event.Hook("Console_random_debug", OnCommandRandomDebug)
Event.Hook("Console_setgameeffect", OnCommandSetGameEffect)