// ======= Copyright (c) 2003-2012, Unknown Worlds Entertainment, Inc. All rights reserved. =====
//
// lua\Spectator.lua
//
//    Created by:   Charlie Cleveland (charlie@unknownworlds.com) and
//                  Max McGuire (max@unknownworlds.com)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/Player.lua")
Script.Load("lua/Mixins/BaseMoveMixin.lua")
Script.Load("lua/Mixins/CameraHolderMixin.lua")
Script.Load("lua/Mixins/FreeLookMoveMixin.lua")
Script.Load("lua/FollowMoveMixin.lua")
Script.Load("lua/FreeLookSpectatorMode.lua")
Script.Load("lua/FollowingSpectatorMode.lua")
Script.Load("lua/FirstPersonSpectatorMode.lua")

class 'Spectator' (Player)

Spectator.kMapName = "spectator"

local kSpectatorModeClass = 
{
    [kSpectatorMode.FreeLook] = FreeLookSpectatorMode,
/*    [kSpectatorMode.Following] = FollowingSpectatorMode,
    [kSpectatorMode.FirstPerson] = FirstPersonSpectatorMode,
*/
}

local kDefaultFreeLookSpeed = Player.kWalkMaxSpeed * 3
local kMaxSpeed = Player.kWalkMaxSpeed * 5
local kAcceleration = 100
local kDeltatimeBetweenAction = 0.3

local networkVars =
{
    specMode = "private enum kSpectatorMode",
    selectedId = "private entityid"
}

AddMixinNetworkVars(CameraHolderMixin, networkVars)
AddMixinNetworkVars(BaseMoveMixin, networkVars)
AddMixinNetworkVars(FreeLookMoveMixin, networkVars)
AddMixinNetworkVars(FollowMoveMixin, networkVars)

/**
 * Return the next mode according to the order of
 * kSpectatorMode enumeration and the current mode
 * selected
 */
local function NextSpectatorMode(self, mode)

    if mode == nil then
        mode = self.specMode
    end
    
    local numModes = 0
    for name, _ in pairs(kSpectatorMode) do
    
        if type(name) ~= "number" then
            numModes = numModes + 1
        end
        
    end
    
    local nextMode = (mode % numModes) + 1
    // Following is only used directly through SetSpectatorMode(), never in this function.
    if not self:IsValidMode(nextMode) /*or nextMode == kSpectatorMode.Following*/ then
        return NextSpectatorMode(self, nextMode)
    else
        return nextMode
    end
    
end

// First Person mode switching handled at:
// GUIFirstPersonSpectate:SendKeyEvent(key, down)
local function UpdateSpectatorMode(self, input)

    assert(Server)
    
    self.timeFromLastAction = self.timeFromLastAction + input.time
    if self.timeFromLastAction > kDeltatimeBetweenAction then
    
/*        if bit.band(input.commands, Move.Jump) ~= 0 then
        
            self:SetSpectatorMode(NextSpectatorMode(self))
            self.timeFromLastAction = 0
            
     else*/ if bit.band(input.commands, Move.Weapon1) ~= 0 then
        
            self:SetSpectatorMode(kSpectatorMode.FreeLook)
            self.timeFromLastAction = 0
            
/*        elseif bit.band(input.commands, Move.Weapon2) ~= 0 then
        
            self:SetSpectatorMode(kSpectatorMode.FirstPerson)
            self.timeFromLastAction = 0
*/            
        end
        
    end
    
    // Switch away from following mode ASAP while on a playing team.
    // Prefer first person mode in this case.
/*    if self:GetIsOnPlayingTeam() and self:GetIsFollowing() then
    
        local followTarget = Shared.GetEntity(self:GetFollowTargetId())
        // Disallow following a Player in this case. Allow following Eggs and IPs
        // for example.
        if not followTarget or followTarget:isa("Player") then
            self:SetSpectatorMode(kSpectatorMode.FirstPerson)
        end
        
    end*/
    
end

function Spectator:OnCreate()

    Player.OnCreate(self)
    
    InitMixin(self, CameraHolderMixin, { kFov = kDefaultFov })
    InitMixin(self, BaseMoveMixin, { kGravity = Player.kGravity })
    InitMixin(self, FreeLookMoveMixin)
//    InitMixin(self, FollowMoveMixin)
    
    // Default all move mixins to off.
    self:SetFreeLookMoveEnabled(false)
//    self:SetFollowMoveEnabled(false)
    
    self.specMode = NextSpectatorMode(self)
    
    if Client then
    
        self.showInsight = true
        
    end
    
end

function Spectator:OnInitialized()

    Player.OnInitialized(self)
    
    self.selectedId = Entity.invalidId
    
    if Server then
    
        self.timeFromLastAction = 0
        self:SetIsVisible(false)
        self:SetIsAlive(false)
        // Start us off by appearing in FreeLook mode.
        self:SetSpectatorMode(kSpectatorMode.FreeLook)
        
    end
    
    // Remove physics
    self:DestroyController()
    
    // Other players never see a spectator.
    self:SetPropagate(Entity.Propagate_Never)
    
end

function Spectator:OnDestroy()

    Player.OnDestroy(self)
    
    if self.modeInstance then
        self.modeInstance:Uninitialize(self)
    end
    
end

function Spectator:OnClientUpdated(client)

    Player.OnClientUpdated(self, client)
    
    if client and self.modeInstance and self.modeInstance.FindTarget then
        self.modeInstance:FindTarget(self)
    end
    
end

function Spectator:CycleSpectatingPlayer(spectatingPlayer, forward)

    if self.modeInstance and self.modeInstance.CycleSpectatingPlayer then
    
        local spectatorClient = Server.GetOwner(self)
        return self.modeInstance:CycleSpectatingPlayer(spectatingPlayer, self, spectatorClient, forward)
        
    end
    
    return false
    
end

function Spectator:OnGetIsVisible(visibleTable)
    visibleTable.Visible = false
end

function Spectator:OnProcessMove(input)

    self:UpdateMove(input)
    
    if Server then
    
        if not self:GetIsRespawning() then
            UpdateSpectatorMode(self, input)
        end
        
    elseif Client then
    
        self:UpdateCrossHairTarget()
        
        // Toggle the insight GUI.
        if self:GetTeamNumber() == kSpectatorIndex then
        
            if bit.band(input.commands, Move.Weapon4) ~= 0 then
            
                self.showInsight = not self.showInsight
                ClientUI.GetScript("GUISpectator"):SetIsVisible(self.showInsight)
                
            end
            
        end
        
        // This flag must be cleared inside OnProcessMove. See explaination in Commander:OverrideInput().
        self.setScrollPosition = false
        
    end
    
    self:OnUpdatePlayer(input.time)
    
    Player.UpdateMisc(self, input)
    
end

/**
 * Override this function to enable/disable mode for
 * a type of Player (for Example TeamSpectator)
 */
function Spectator:IsValidMode(mode)
    return true
end

function Spectator:SetSpectatorMode(mode)

    if not self.modeInstance or kSpectatorModeClass[mode].name ~= self.modeInstance.name then
    
        local oldMode = self.modeInstance
        local newMode = kSpectatorModeClass[mode]()
        
        if oldMode then
            oldMode:Uninitialize(self)
        end
        newMode:Initialize(self)
        
        self.modeInstance = newMode
        self.specMode = mode
        
        if Server and Server.GetOwner(self) and self.modeInstance and self.modeInstance.FindTarget then
            self.modeInstance:FindTarget(self)
        end
        
    end
    
    if Server then
        self:UpdateClientRelevancyMask()
    end
    
end

function Spectator:GetSpectatorMode()
    return self.modeInstance
end

function Spectator:GetFollowMoveCameraDistance()

    local followTarget = Shared.GetEntity(self:GetFollowTargetId())
    // Follow Players closer than other units.
    if followTarget and followTarget:isa("Player") then
        return 2.5
    end
    
    return 5
    
end

function Spectator:GetAnimateDeathCamera()
    return false
end

function Spectator:GetIsRespawning()
    return self.isRespawning
end

function Spectator:SetIsRespawning(isRespawning)
    self.isRespawning = isRespawning
end

function Spectator:GetPlayFootsteps()
    return false
end

function Spectator:GetMovePhysicsMask()
    return PhysicsMask.All
end

function Spectator:GetTraceCapsule()
    return 0, 0
end

// Needed so player origin is same as camera for selection
function Spectator:GetViewOffset()

    if self:GetIsOverhead() then
        return Vector(0, 0, 0)
    else
        return Player.GetViewOffset(self)
    end
     
end

function Spectator:GetMaxSpeed(possible)
    return kMaxSpeed
end

function Spectator:GetAcceleration()
    return kAcceleration
end

function Spectator:GetTechId()
    return kTechId.Spectator
end

function Spectator:GetIsFollowing()
    return self.specMode == kSpectatorMode.Following
end

function Spectator:GetIsFirstPerson()
    return false //self.specMode == kSpectatorMode.FirstPerson
end

/**
 * Spectator cannot take damage or die.
 */
function Spectator:GetCanTakeDamageOverride()
    return false
end

function Spectator:GetCanDieOverride()
    return false
end

function Spectator:AdjustGravityForce(input, gravity)
    return 0
end

/**
 * Override this method to restrict or allow a target in follow mode.
 */
function Spectator:GetIsValidTarget(entity)

    local isValid = entity and (HasMixin(entity, "Live") and entity:GetIsAlive())
    isValid = isValid and (entity:GetTeamNumber() ~= kTeamReadyRoom and entity:GetTeamNumber() ~= kSpectatorIndex)
    
    return isValid
    
end

/**
 * Return target the player can follow
 * Override this method to restrict or increase target
 * in following move
 */
function Spectator:GetTargetsToFollow()

    local potentialTargets = EntityListToTable(Shared.GetEntitiesWithClassname("Player"))
        
    local targets = { }
    for index, target in ipairs(potentialTargets) do
    
        if self:GetIsValidTarget(target) then
            table.insert(targets, target)
        end
        
    end

    if table.count(targets) < 1 then
        
        self.specMode = kSpectatorMode.FreeLook
        return self:GetTargetsToFollow(false)
        
    else
        return targets
    end
    
end

function Spectator:GetPlayerStatusDesc()
    return kPlayerStatus.Spectator
end

function Spectator:SelectEntity(entityId)
    if entityId then
        self.selectedId = entityId
    else
        self.selectedId = Entity.invalidId
    end
end

function Spectator:GetFollowingPlayerId()

    local playerId = Entity.invalidId
    
    if self.specMode == kSpectatorMode.Following or
       self.specMode == kSpectatorMode.FirstPerson then
    
        playerId = self.selectedId
        
    end
    
    return playerId
    
end

if Client then

    function Spectator:GetShowAtmosphericLight()
        return true
    end

    function Spectator:GetDisplayUnitStates()
        return self.specMode == kSpectatorMode.FreeLook
    end
    
    function Spectator:OnPreUpdate()
    
        Player.OnPreUpdate(self)
        
        if self.specMode ~= self.clientSpecMode then
        
            self:SetSpectatorMode(self.specMode)
            self.clientSpecMode = self.specMode
            
        end
        
    end
    
    
    function Spectator:GetCrossHairTarget()
    
/*        if self.specMode == kSpectatorMode.Following then
            return Shared.GetEntity(self.selectedId)
        end
*/        
        return Player.GetCrossHairTarget(self)
        
    end
    
    function Spectator:UpdateClientEffects(deltaTime, isLocal)
    
        Player.UpdateClientEffects(self, deltaTime, isLocal)
        
        self:SetIsVisible(false)
        
        local activeWeapon = self:GetActiveWeapon()
        if activeWeapon ~= nil then
            activeWeapon:SetIsVisible(false)
        end
        
        local viewModel = self:GetViewModelEntity()
        if viewModel ~= nil then
            viewModel:SetIsVisible(false)
        end
        
    end
    
    function Spectator:GetCrossHairText()
            
        return self.crossHairText
        
    end
    
end

Shared.LinkClassToMap("Spectator", Spectator.kMapName, networkVars)