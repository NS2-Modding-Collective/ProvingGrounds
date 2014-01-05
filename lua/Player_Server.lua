// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\Player_Server.lua
//
//    Created by:   Charlie Cleveland (charlie@unknownworlds.com)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/Gamerules.lua")

// Called when player first connects to server
// TODO: Move this into NS specific player class
function Player:OnClientConnect(client)

    self:SetRequestsScores(true)   
    self.clientIndex = client:GetId()
    self.client = client
    
end

function Player:GetClient()
    return self.client
end

function Player:Reset()

    ScriptActor.Reset(self)
    
    self:SetCameraDistance(0)
    
    local client = Server.GetOwner(self)
    
end

function Player:ClearEffects()
end

// ESC was hit on client or menu closed
function Player:CloseMenu()
end

function Player:GetName()
    return self.name
end

function Player:SetName(name)

    // If player is just changing the case on their own name, allow it.
    // Otherwise, make sure it's a unique name on the server.
    
    // Strip out surrounding "s
    local newName = string.gsub(name, "\"(.*)\"", "%1")
    // Strip out escape characters.
    newName = string.gsub(newName, "[\a\b\f\n\r\t\v]", "")
    
    // Make sure it's not too long
    newName = string.sub(newName, 0, kMaxNameLength)
    
    local currentName = self:GetName()
    if currentName ~= newName or string.lower(newName) ~= string.lower(currentName) then
        newName = GetUniqueNameForPlayer(newName)
    end
    
    if newName ~= self.name then
    
        self.name = newName
        
        self:SetScoreboardChanged(true)
        
    end
    
end

/**
 * Used to add the passed in client index to this player's mute list.
 * This player will either hear or not hear the passed in client's
 * voice chat based on the second parameter.
 */
function Player:SetClientMuted(muteClientIndex, setMuted)

    if not self.mutedClients then self.mutedClients = { } end
    self.mutedClients[muteClientIndex] = setMuted
    
end

/**
 * Returns true if the passed in client is muted by this Player.
 */
function Player:GetClientMuted(checkClientIndex)

    if not self.mutedClients then self.mutedClients = { } end
    return self.mutedClients[checkClientIndex] == true
    
end

function Player:GetRequestsScores()
    return self.requestsScores
end

function Player:SetRequestsScores(state)
    self.requestsScores = state
end

// Call to give player default weapons, abilities, equipment, etc. Usually called after CreateEntity() and OnInitialized()
function Player:InitWeapons()
end

local function DestroyViewModel(self)

    assert(self.viewModelId ~= Entity.invalidId)
    
    DestroyEntity(self:GetViewModelEntity())
    self.viewModelId = Entity.invalidId
    
end

/**
 * Called when the player is killed. Point and direction specify the world
 * space location and direction of the damage that killed the player. These
 * may be nil if the damage wasn't directional.
 */
function Player:OnKill(killer, doer, point, direction)

    if not Shared.GetCheatsEnabled() then
        if (killer == nil and doer == nil) or killer:isa("DeathTrigger") or doer:isa("DeathTrigger") then
            self.spawnBlockTime = Shared.GetTime() + kSuicideDelay + kFadeToBlackTime
        end
    end

    // Determine the killer's player name.
    local killerName = nil
    if killer ~= nil and not killer:isa("Player") then
    
        local realKiller = (killer.GetOwner and killer:GetOwner()) or nil
        if realKiller and realKiller:isa("Player") then
            killerName = realKiller:GetName()
        end
        
    end

    // Save death to server log
    if killer == self then        
        PrintToLog("%s committed suicide", self:GetName())
    elseif killerName ~= nil then
        PrintToLog("%s was killed by %s", self:GetName(), killerName)
    else
        PrintToLog("%s died", self:GetName())
    end

    // Go to third person so we can see ragdoll and avoid HUD effects (but keep short so it's personal)
    if not self:GetAnimateDeathCamera() then
        self:SetIsThirdPerson(4)
    end
    
    local angles = self:GetAngles()
    angles.roll = 0
    self:SetAngles(angles)
    
    // This is a hack, CameraHolderMixin should be doing this.
    self.baseYaw = 0
    
    self:AddDeaths()
    
    // Fade out screen.
    self.timeOfDeath = Shared.GetTime()
    
    DestroyViewModel(self)
    
    //self:GetTeam():ReplaceRespawnPlayer(self,nil,nil)
    
end

function Player:SetControllerClient(client)

    if client ~= nil then
    
        client:SetControllingPlayer(self)
        self:UpdateClientRelevancyMask()
        self:OnClientUpdated(client)
        
    end
    
end

function Player:UpdateClientRelevancyMask()

    local mask = 0xFFFFFFFF
    
    if self:GetTeamNumber() == 1 then
    
        mask = kRelevantToTeam1Unit
        
    elseif self:GetTeamNumber() == 2 then
    
        mask = kRelevantToTeam2Unit
        
    // Spectators should see all map blips.
    elseif self:GetTeamNumber() == kSpectatorIndex then
    
        mask = bit.bor(kRelevantToTeam1Unit, kRelevantToTeam2Unit, kRelevantToReadyRoom)
        
    // ReadyRoomPlayers should not see any blips.
    elseif self:GetTeamNumber() == kTeamReadyRoom then
        mask = kRelevantToReadyRoom
    end
    
    local client = Server.GetOwner(self)
    // client may be nil if the server is shutting down.
    if client then
        client:SetRelevancyMask(mask)
    end
    
end

function Player:OnTeamChange()

    self:UpdateIncludeRelevancyMask()
    self:SetScoreboardChanged(true)
    
end

function Player:UpdateIncludeRelevancyMask()

    // Players are always relevant to their commanders.
    local includeMask = 0
    
    if self:GetTeamNumber() == 1 then
        includeMask = kRelevantToTeam1
    elseif self:GetTeamNumber() == 2 then
        includeMask = kRelevantToTeam2
    end
    
    self:SetIncludeRelevancyMask(includeMask)
    
end

function Player:GetDeathMapName()
    return Spectator.kMapName
end

local function UpdateChangeToSpectator(self)

    if not self:GetIsAlive() and not self:isa("Spectator") then
    
        local time = Shared.GetTime()
        if self.timeOfDeath ~= nil and (time - self.timeOfDeath > kFadeToBlackTime) then
        
            // Destroy the existing player and create a spectator in their place (but only if it has an owner, ie not a body left behind by Phantom use)
            local owner = Server.GetOwner(self)
            if owner then
            
                self:GetTeam():ReplaceRespawnPlayer(self,nil,nil)                
                // Queue up the spectator for respawn.
                /*local spectator = self:Replace(self:GetDeathMapName())
                spectator:GetTeam():PutPlayerInRespawnQueue(spectator)*/
                
            end
            
        end
        
    end
    
end

function Player:OnUpdatePlayer(deltaTime)

    UpdateChangeToSpectator(self)
    
    local gamerules = GetGamerules()
    self.gameStarted = gamerules:GetGameStarted()
    if self:GetTeamNumber() == kTeam1Index or self:GetTeamNumber() == kTeam2Index then
        self.countingDown = gamerules:GetCountingDown()
    else
        self.countingDown = false
    end
    
end

// Remember game time player enters queue so they can be spawned in FIFO order
function Player:SetRespawnQueueEntryTime(time)
    self.respawnQueueEntryTime = time
end
function Player:ReplaceRespawn()
    return self:GetTeam():ReplaceRespawnPlayer(self, nil, nil)
end

function Player:GetRespawnQueueEntryTime()
    return self.respawnQueueEntryTime
end

// For children classes to override if they need to adjust data
// before the copy happens.
function Player:PreCopyPlayerData()

end

function Player:CopyPlayerDataFrom(player)

    // This is stuff from the former LiveScriptActor.
    self.gameEffectsFlags = player.gameEffectsFlags
    self.timeOfLastDamage = player.timeOfLastDamage
    self.spawnBlockTime = player.spawnBlockTime
    self.spawnReductionTime = player.spawnReductionTime
	self.desiredSpawnPoint = player.desiredSpawnPoint
    
    // ScriptActor and Actor fields
    self:SetAngles(player:GetAngles())
    self:SetOrigin(Vector(player:GetOrigin()))
    self:SetViewAngles(player:GetViewAngles())
    
    // Copy camera settings
    if player:GetIsThirdPerson() then
        self.cameraDistance = player.cameraDistance
    end
    
    // for OnProcessMove
    self.fullPrecisionOrigin = player.fullPrecisionOrigin
    
    // This is a hack, CameraHolderMixin should be doing this.
    self.baseYaw = player.baseYaw
    
    self.name = player.name
    self.clientIndex = player.clientIndex
    self.client = player.client
    
    // Copy network data over because it won't be necessarily be resent
    self.gameStarted = player.gameStarted
    self.countingDown = player.countingDown
    self.frozen = player.frozen
    
    self.timeOfDeath = player.timeOfDeath
    self.timeOfLastUse = player.timeOfLastUse
    self.crouching = player.crouching
    self.timeOfCrouchChange = player.timeOfCrouchChange 
    self.timeOfLastPoseUpdate = player.timeOfLastPoseUpdate

    self.timeLastBuyMenu = player.timeLastBuyMenu
    
    // Include here so it propagates through Spectator
    self.originOnDeath = player.originOnDeath
    
    self.jumpHandled = player.jumpHandled
    self.timeOfLastJump = player.timeOfLastJump
    self.darwinMode = player.darwinMode
    
    self.mode = player.mode
    self.modeTime = player.modeTime
    
    self.requestsScores = player.requestsScores
    self.isRookie = player.isRookie
    self.communicationStatus = player.communicationStatus
    
    // Remember this player's muted clients.
    self.mutedClients = player.mutedClients
    self.hotGroupNumber = player.hotGroupNumber
    
end

/**
 * Check if there were any spectators watching them. Make these
 * spectators follow the new player unless the new player is also
 * a spectator (in which case, make the spectating players follow a new target).
 */
function Player:RemoveSpectators(newPlayer)

    local spectators = Shared.GetEntitiesWithClassname("Spectator")
    for e = 0, spectators:GetSize() - 1 do
    
        local spectatorEntity = spectators:GetEntityAtIndex(e)
        if spectatorEntity ~= newPlayer then
        
            local spectatorClient = Server.GetOwner(spectatorEntity)
            if spectatorClient and spectatorClient:GetSpectatingPlayer() == self then
            
                local allowedToFollowNewPlayer = newPlayer and not newPlayer:isa("Spectator") and newPlayer:GetIsOnPlayingTeam()
                if not allowedToFollowNewPlayer then
                
                    local success = spectatorEntity:CycleSpectatingPlayer(self, true)
                    if not success and not self:GetIsOnPlayingTeam() then
                        spectatorEntity:SetSpectatorMode(kSpectatorMode.FreeLook)
                    end
                    
                else
                    spectatorClient:SetSpectatingPlayer(newPlayer)
                end
                
            end
            
        end
        
    end
    
end

/**
 * Replaces the existing player with a new player of the specified map name.
 * Removes old player off its team and adds new player to newTeamNumber parameter
 * if specified. Note this destroys self, so it should be called carefully. Returns 
 * the new player. If preserveWeapons is true, then InitWeapons() isn't called
 * and old ones are kept (including view model).
 */
function Player:Replace(mapName, newTeamNumber, preserveWeapons, atOrigin, extraValues)

    local team = self:GetTeam()
    if team == nil then
        return self
    end
    
    local teamNumber = team:GetTeamNumber()
    local client = Server.GetOwner(self)
    local teamChanged = newTeamNumber ~= nil and newTeamNumber ~= self:GetTeamNumber()
    
    // Add new player to new team if specified
    // Both nil and -1 are possible invalid team numbers.
    if newTeamNumber ~= nil and newTeamNumber ~= -1 then
        teamNumber = newTeamNumber
    end
    
    local player = CreateEntity(mapName, atOrigin or Vector(self:GetOrigin()), teamNumber, extraValues)
    
    // Save last player map name so we can show player of appropriate form in the ready room if the game ends while spectating
    player.previousMapName = self:GetMapName()
    
    // The class may need to adjust values before copying to the new player (such as gravity).
    self:PreCopyPlayerData()
    
    // If the atOrigin is specified, set self to that origin before
    // the copy happens or else it will be overridden inside player.
    if atOrigin then
        self:SetOrigin(atOrigin)
    end
    // Copy over the relevant fields to the new player, before we delete it
    player:CopyPlayerDataFrom(self)
    
    // Make model look where the player is looking
    player.standingBodyYaw = Math.Wrap( self:GetAngles().yaw, 0, 2*math.pi )
    
    if not player:GetTeam():GetSupportsOrders() and HasMixin(player, "Orders") then
        player:ClearOrders()
    end
    
    // Remove newly spawned weapons and reparent originals
    if preserveWeapons then
    
        player:DestroyWeapons()
        
        local allWeapons = { }
        local function AllWeapons(weapon) table.insert(allWeapons, weapon) end
        ForEachChildOfType(self, "Weapon", AllWeapons)
        
        for i, weapon in ipairs(allWeapons) do
            player:AddWeapon(weapon)
        end
        
    end
    
    // Notify others of the change     
    self:SendEntityChanged(player:GetId())
    
    // Update scoreboard because of new entity and potentially new team
    player:SetScoreboardChanged(true)
    
    // This player is no longer controlled by a client.
    self.client = nil
    
    // Remove any spectators currently spectating this player.
    self:RemoveSpectators(player)
    
    // Only destroy the old player if it is not a ragdoll.
    // Ragdolls will eventually destroy themselve.
    if not HasMixin(self, "Ragdoll") or not self:GetIsRagdoll() then
        DestroyEntity(self)
    end
    
    player:SetControllerClient(client)
    
    // There are some cases where the spectating player isn't set to nil.
    // Handle any edge cases here (like being dead when the game is reset).
    // In some cases, client will be nil (when the map is changing for example).
    if client and not player:isa("Spectator") then
        client:SetSpectatingPlayer(nil)
    end
    
    // Log player spawning
    if teamNumber ~= 0 then
        PostGameViz(string.format("%s spawned", SafeClassName(self)), self)
    end
    
    return player
    
end

// Creates an item by mapname and spawns it at our feet.
function Player:GiveItem(itemMapName, setActive)

    // Players must be alive in order to give them items.
    assert(self:GetIsAlive())
    
    local newItem = nil
    if setActive == nil then
        setActive = true
    end

    if itemMapName then
    
        newItem = CreateEntity(itemMapName, self:GetEyePos(), self:GetTeamNumber())
        if newItem then

            if newItem:isa("Weapon") then
                local removedWeapon = self:AddWeapon(newItem, setActive)
                
                if removedWeapon and HasMixin(removedWeapon, "Tech") and LookupTechData(removedWeapon:GetTechId(), kTechDataCostKey, 0) == 0 then
                    DestroyEntity(removedWeapon)
                end
                
            else

                if newItem.OnCollision then
                    newItem:OnCollision(self)
                end
                
            end
            
        else
            Print("Couldn't create entity named %s.", itemMapName)            
        end
        
    end
    
    return newItem
    
end

function Player:GetPing()

    local client = Server.GetOwner(self)
    
    if client ~= nil then
        return client:GetPing()
    else
        return 0
    end
    
end

// To be overridden by children
function Player:AttemptToBuy(techIds)
    return false
end

function Player:UpdateMisc(input)

    // Set near death mask so we can add sound/visual effects.
    self:SetGameEffectMask(kGameEffect.NearDeath, self:GetHealth() < 0.2 * self:GetMaxHealth())
    
end

function Player:GetPreviousMapName()
    return self.previousMapName
end

function Player:SetDarwinMode(darwinMode)
    self.darwinMode = darwinMode
end

function Player:GetIsInterestedInAlert(techId)
    return LookupTechData(techId, kTechDataAlertTeam, false)
end

// Send alert to player unless we recently sent the exact same alert. Returns true if it was sent.
function Player:TriggerAlert(techId, entity)

    assert(entity ~= nil)
    
    if self:GetIsInterestedInAlert(techId) then
    
        local entityId = entity:GetId()
        local time = Shared.GetTime()
        
        local location = entity:GetOrigin()
        assert(entity:GetTechId() ~= nil)
        
        local message =
        {
            techId = techId,
            worldX = location.x,
            worldZ = location.z,
            entityId = entity:GetId(),
            entityTechId = entity:GetTechId()
        }
        
        Server.SendNetworkMessage(self, "MinimapAlert", message, true)

        return true
    
    end
    
    return false
    
end

function Player:SetRookieMode(rookieMode)

     if self.isRookie ~= rookieMode then
    
        self.isRookie = rookieMode
        
        // rookie status sent along with scores
        self:SetScoreboardChanged(true)
        
    end
    
end

function Player:OnClientUpdated(client)
    // override me
    //DebugPrint("Player:OnClientUpdated")
end

// only use intensity value here to reduce traffic
function Player:SetCameraShake(intensity)

    local message = BuildCameraShakeMessage(intensity)
    Server.SendNetworkMessage(self, "CameraShake", message, false)

end
