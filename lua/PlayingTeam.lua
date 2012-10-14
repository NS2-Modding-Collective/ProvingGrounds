// ======= Copyright (c) 2003-2012, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\PlayingTeam.lua
//
//    Created by:   Charlie Cleveland (charlie@unknownworlds.com) and
//                  Max McGuire (max@unknownworlds.com)
//
// This class is used for teams that are actually playing the game, e.g. Marines or Aliens.
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================
Script.Load("lua/Team.lua")
Script.Load("lua/Entity.lua")
Script.Load("lua/TeamDeathMessageMixin.lua")

class 'PlayingTeam' (Team)

PlayingTeam.kTooltipHelpInterval = 1

PlayingTeam.kTechTreeUpdateTime = 1

PlayingTeam.kBaseAlertInterval = 15
PlayingTeam.kRepeatAlertInterval = 15

// How often to update clear and update game effects
PlayingTeam.kUpdateGameEffectsInterval = .3

PlayingTeam.kResearchDisplayTime = 40

/**
 * spawnEntity is the name of the map entity that will be created by default
 * when a player is spawned.
 */
function PlayingTeam:Initialize(teamName, teamNumber)

    InitMixin(self, TeamDeathMessageMixin)
    
    Team.Initialize(self, teamName, teamNumber)

    self.respawnEntity = nil
    
    self:OnCreate()
        
    self.timeSinceLastLOSUpdate = Shared.GetTime()
    
    self.entityTechIds = {}
    self.techIdCount = {}

end

function PlayingTeam:Uninitialize()
    
    self.entityTechIds = { }
    self.techIdCount = { }
    
    Team.Uninitialize(self)
    
end

function PlayingTeam:AddPlayer(player)

    local added = Team.AddPlayer(self, player)
    
    return added
    
end

function PlayingTeam:OnCreate()

    self.entityTechIds = {}
    self.techIdCount = {}
    Team.OnCreate(self)
      
end

function PlayingTeam:OnInitialized()

    self.entityTechIds = {}
    self.techIdCount = {}

    Team.OnInitialized(self)
    
    self:InitTechTree()
    self.requiredTechIds = self.techTree:GetRequiredTechIds()
    self.timeOfLastTechTreeUpdate = nil
    
    self.lastPlayedTeamAlertName = nil
    self.timeOfLastPlayedTeamAlert = nil
    self.alerts = {}
    
end

function PlayingTeam:ResetTeam()
    
    for i, player in ipairs( GetEntitiesForTeam("Player", self:GetTeamNumber()) ) do
        self:RespawnPlayer(player)
    end 
    
end

function PlayingTeam:OnResetComplete()
end

function PlayingTeam:Reset()

    self:OnInitialized()
    
    Team.Reset(self)

    Server.SendNetworkMessage( "Reset", {}, true )

end

function PlayingTeam:InitTechTree()
   
    self.techTree = TechTree()
    
    self.techTree:Initialize()
    
    self.techTree:SetTeamNumber(self:GetTeamNumber())

end

// Returns marine or alien type
function PlayingTeam:GetTeamType()
    return self.teamType
end

// Returns sound name of last alert and time last alert played (for testing)
function PlayingTeam:GetLastAlert()
    return self.lastPlayedTeamAlertName, self.timeOfLastPlayedTeamAlert
end

// Play audio alert for all players, but don't trigger them too often. 
// This also allows neat tactics where players can time strikes to prevent the other team from instant notification of an alert, ala RTS.
// Returns true if the alert was played.
function PlayingTeam:TriggerAlert(techId, entity)

    local triggeredAlert = false
    
    assert(techId ~= kTechId.None)
    assert(techId ~= nil)
    assert(entity ~= nil)
    
    if GetGamerules():GetGameStarted() then
    
        local location = entity:GetOrigin()
        table.insert(self.alerts, { techId, entity:GetId() })
        
        // Lookup sound name
        local soundName = LookupTechData(techId, kTechDataAlertSound, "")
        if soundName ~= "" then
        
            local isRepeat = (self.lastPlayedTeamAlertName ~= nil and self.lastPlayedTeamAlertName == soundName)
            
            local timeElapsed = math.huge
            if self.timeOfLastPlayedTeamAlert ~= nil then
                timeElapsed = Shared.GetTime() - self.timeOfLastPlayedTeamAlert
            end
            
            // Ignore source players for some alerts
            local ignoreSourcePlayer = ConditionalValue(LookupTechData(techId, kTechDataAlertOthersOnly, false), nil, entity)
            local ignoreInterval = LookupTechData(techId, kTechDataAlertIgnoreInterval, false)
            
            local newAlertPriority = LookupTechData(techId, kTechDataAlertPriority, 0)
            if not self.lastAlertPriority then
                self.lastAlertPriority = 0
            end

            // If time elapsed > kBaseAlertInterval and not a repeat, play it OR
            // If time elapsed > kRepeatAlertInterval then play it no matter what
            if ignoreInterval or (timeElapsed >= PlayingTeam.kBaseAlertInterval and not isRepeat) or timeElapsed >= PlayingTeam.kRepeatAlertInterval or newAlertPriority  > self.lastAlertPriority then
            
                // Play for commanders only or for the whole team
                local commandersOnly = not LookupTechData(techId, kTechDataAlertTeam, false)
                
                local ignoreDistance = LookupTechData(techId, kTechDataAlertIgnoreDistance, false)
                
                self:PlayPrivateTeamSound(soundName, location, commandersOnly, ignoreSourcePlayer, ignoreDistance)
                
                if not ignoreInterval then
                
                    self.lastPlayedTeamAlertName = soundName
                    self.lastAlertPriority = newAlertPriority
                    self.timeOfLastPlayedTeamAlert = Shared.GetTime()
                    
                end
                
                triggeredAlert = true
                
                // Check if we should also send out a team message for this alert.
                local sendTeamMessageType = LookupTechData(techId, kTechDataAlertSendTeamMessage)
                if sendTeamMessageType then
                    SendTeamMessage(self, sendTeamMessageType, entity:GetLocationId())
                end
                
                for i, playerId in ipairs(self.playerIds) do
                
                    local player = Shared.GetEntity(playerId)
                    if player then
                        player:TriggerAlert(techId, entity)
                    end
                    
                end
                
            end
            
        end
  
    end
    
    return triggeredAlert
    
end

function PlayingTeam:GetHasTeamLost()

    if GetGamerules():GetGameStarted() and not Shared.GetCheatsEnabled() then
    
        // Team can't respawn or last Command Station or Hive destroyed
        local activePlayers = self:GetHasActivePlayers()
        local abilityToRespawn = self:GetHasAbilityToRespawn()
        
        if  (not activePlayers and not abilityToRespawn) or
            (self:GetNumPlayers() == 0) then
            
            return true
            
        end
        
    end
    
    return false
    
end

// TODO: Returns true if team has acheived alternate victory condition - hive releases bio-plague and marines teleport
// away and nuke station from orbit!
function PlayingTeam:GetHasTeamWon()
    return false
end



function PlayingTeam:GetHasAbilityToRespawn()
    return true
end

function PlayingTeam:GetIsRedTeam()
    return false
end

function PlayingTeam:GetIsMarineTeam()
    return false    
end

/**
 * Transform player to appropriate team respawn class and respawn them at an appropriate spot for the team.
 * Pass nil origin/angles to have spawn entity chosen.
 */
function PlayingTeam:ReplaceRespawnPlayer(player, origin, angles, mapName)

    local spawnMapName = self.respawnEntity
    
    if mapName ~= nil then
        spawnMapName = mapName
    end
    
    local newPlayer = player:Replace(spawnMapName, self:GetTeamNumber(), false, origin)
    
    // If we fail to find a place to respawn this player, put them in the Team's
    // respawn queue.
    if not self:RespawnPlayer(newPlayer, origin, angles) then
    
        newPlayer = newPlayer:Replace(newPlayer:GetDeathMapName())
        self:PutPlayerInRespawnQueue(newPlayer)
        
    end
    
    newPlayer:ClearGameEffects()
    if HasMixin(newPlayer, "Upgradable") then
        newPlayer:ClearUpgrades()
    end
    
    return (newPlayer ~= nil), newPlayer
    
end

// Call with origin and angles, or pass nil to have them determined from team location and spawn points.
function PlayingTeam:RespawnPlayer(player, origin, angles)

    if self:GetIsMarineTeam() then
        if origin == nil or angles == nil then
        
            // Randomly choose unobstructed spawn points to respawn the player
            local marineSpawnPoint = nil
            local marineSpawnPoints = Server.team1SpawnList
            local numSpawnPoints = table.maxn(marineSpawnPoints)
          
            if numSpawnPoints > 0 then
            
                local marineSpawnPoint = GetRandomClearSpawnPoint(player, marineSpawnPoints)
                if marineSpawnPoint ~= nil then
                
                    origin = marineSpawnPoint:GetOrigin()
                    angles = marineSpawnPoint:GetAngles()
                    
                end
                
            end
            
        end
        
        // Move origin up and drop it to floor to prevent stuck issues with floating errors or slightly misplaced spawns
        if origin ~= nil then
        
            SpawnPlayerAtPoint(player, origin, angles)
            
            player:ClearEffects()
            
            return true
            
        else
            Print("PlayingTeam:RespawnPlayer(player, %s, %s) - No Marine Team Spawns.", ToString(origin), ToString(angles))
        end
    elseif self:GetIsRedTeam() then
        if origin == nil or angles == nil then
        
            // Randomly choose unobstructed spawn points to respawn the player
            local redSpawnPoint = nil
            local redSpawnPoints = Server.team2SpawnList
            local numSpawnPoints = table.maxn(redSpawnPoints)
            
            if numSpawnPoints > 0 then
            
                redSpawnPoint = GetRandomClearSpawnPoint(player, redSpawnPoints)
                if redSpawnPoint ~= nil then
                
                    origin = redSpawnPoint:GetOrigin()
                    angles = redSpawnPoint:GetAngles()
                    
                end
                
            end
            
        end
        
        // Move origin up and drop it to floor to prevent stuck issues with floating errors or slightly misplaced spawns
        if origin ~= nil then
        
            SpawnPlayerAtPoint(player, origin, angles)
            
            player:ClearEffects()
            
            return true
            
        else
            Print("PlayingTeam:RespawnPlayer(player, %s, %s) - No Alien Team Spawns.", ToString(origin), ToString(angles))
        end  
    else
        Print("PlayingTeam:RespawnPlayer(player) - Player isn't on team.")
    end
    
    return false
    
end


function PlayingTeam:Update(timePassed)

    PROFILE("PlayingTeam:Update")
    
    self:UpdateGameEffects(timePassed)
    
end

function PlayingTeam:PrintWorldTextForTeamInRange(messageType, data, position, range)

    local playersInRange = GetEntitiesForTeamWithinRange("Player", self:GetTeamNumber(), position, range)
    local message = BuildWorldTextMessage(messageType, data, position)
    
    for _, player in ipairs(playersInRange) do
        Server.SendNetworkMessage(player, "WorldText", message, true)        
    end

end

function PlayingTeam:GetTechTree()
    return self.techTree
end

function PlayingTeam:TriggerSayingAction(player, sayingActionTechId)
end

// Update from alien team instead of in alien buildings think because we need to clear
// game effect flag too.
function PlayingTeam:UpdateGameEffects(timePassed)

    PROFILE("PlayingTeam:UpdateGameEffects")  

end

function PlayingTeam:UpdateTeamSpecificGameEffects()
end

