// ======= Copyright (c) 2003-2012, Unknown Worlds Entertainment, Inc. All rights reserved. =======
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
Script.Load("lua/Mixins/OverheadMoveMixin.lua")
Script.Load("lua/FollowMoveMixin.lua")
Script.Load("lua/FreeLookSpectatorMode.lua")
Script.Load("lua/OverheadSpectatorMode.lua")
Script.Load("lua/FollowingSpectatorMode.lua")
Script.Load("lua/MinimapMoveMixin.lua")

class 'Spectator' (Player)

------------
-- STATIC --
------------

// Public
Spectator.kMapName = "spectator"
Spectator.kSpectatorMapMode = enum( {'Invisible', 'Small', 'Big'} )
Spectator.kSpectatorMode = enum( {'FreeLook', 'Overhead', 'Following' } )

// Private
local kSpectatorModeClass = 
{
    [Spectator.kSpectatorMode.FreeLook]  = FreeLookSpectatorMode,
    [Spectator.kSpectatorMode.Following] = FollowingSpectatorMode,
    [Spectator.kSpectatorMode.Overhead]  = OverheadSpectatorMode
}

local kDefaultFreeLookSpeed = Player.kWalkMaxSpeed * 3
local kMaxSpeed = Player.kWalkMaxSpeed * 5
local kAcceleration = 100
local kDeltatimeBetweenAction = 0.3

-------------
-- NETWORK --
-------------

local networkVars =
{
    specMode = "enum Spectator.kSpectatorMode"
}

local kTeleportSpectator = 
{
    position = "vector"
}
Shared.RegisterNetworkMessage("TeleportSpectator", kTeleportSpectator)

------------
-- MIXINS --
------------

AddMixinNetworkVars(CameraHolderMixin, networkVars)
AddMixinNetworkVars(BaseMoveMixin, networkVars)
AddMixinNetworkVars(MinimapMoveMixin, networkVars)

for mode, modeClass in pairs(kSpectatorModeClass) do

    if modeClass.mixin then
        AddMixinNetworkVars(modeClass.mixin, networkVars)
    end
    
end

--------------------
-- PRIVATE METHOD --
--------------------

/**
 * Display the map accord to the input
 */
local function UpdateMapDisplay(self, input)

    if Client and not Shared.GetIsRunningPrediction() then

        if self.showMapPressed == 0 and bit.band(input.commands, Move.ShowMap) ~= 0 then

            if self.mapMode == Spectator.kSpectatorMapMode.Big or self.mapMode == Spectator.kSpectatorMapMode.Invisible then                
                self.mapMode = Spectator.kSpectatorMapMode.Small
                self:ShowMap(true, false, true)
                
            elseif self.mapMode == Spectator.kSpectatorMapMode.Small then                
                self.mapMode = Spectator.kSpectatorMapMode.Big
                self:ShowMap(true, true, true)
            end   

        end

        self.showMapPressed = bit.band(input.commands, Move.ShowMap)

    end

end

/**
 * @return the next mode according to the order of
 * kSpectatorMode enumeration and the current mode
 * selected
 */
local function NextSpectatorMode(self, mode)

    if mode == nil then
        mode = self.specMode
    end

    // Get the number of mode
    local modeNumber = 0
    for name, mode in pairs(Spectator.kSpectatorMode) do

        if type(name) ~= "number" then       
            modeNumber = modeNumber + 1
        end

    end

    // return the next valid mode
    local nextMode = ( mode % modeNumber ) + 1    
    if not self:IsValidMode(nextMode) then
        return NextSpectatorMode(self, nextMode)
    else
        return nextMode
    end

end

local function UpdateSpectatorMode(self, input)

    self.movementModifierState = bit.band(input.commands, Move.MovementModifier) ~= 0 --movement modifier for fast freelook cam

    if Server then
    
        self.timeFromLastAction = self.timeFromLastAction + input.time
        if self.timeFromLastAction > kDeltatimeBetweenAction then

            if bit.band(input.commands, Move.Jump) ~= 0 then

                local nextMode = NextSpectatorMode(self)
                self:SetSpectatorMode(nextMode)

                self.timeFromLastAction = 0

            elseif bit.band(input.commands, Move.Weapon1) ~= 0 then

                self:SetSpectatorMode(Spectator.kSpectatorMode.FreeLook)
                self.timeFromLastAction = 0
                
            elseif bit.band(input.commands, Move.Weapon2) ~= 0 then

                self:SetSpectatorMode(Spectator.kSpectatorMode.Overhead)
                self.timeFromLastAction = 0
                
            elseif bit.band(input.commands, Move.Weapon3) ~= 0 then

                self:SetSpectatorMode(Spectator.kSpectatorMode.Following)
                self.timeFromLastAction = 0

            end

        end

    end

end

-------------------
-- PUBLIC METHOD --
-------------------

--@Overload Player
function Spectator:OnCreate()

    Player.OnCreate(self)
    
    InitMixin(self, CameraHolderMixin, { kFov = kDefaultFov })
    InitMixin(self, BaseMoveMixin, { kGravity = Player.kGravity })
    InitMixin(self, MinimapMoveMixin)
    
    self.specMode     = NextSpectatorMode(self)
    self.modeInstance = kSpectatorModeClass[self.specMode]()
    self.modeInstance:Initialize(self)
    
    if Client then    
    
        self.mapButtonPressed = false
        self.mapMode = Spectator.kSpectatorMapMode.Small
        self.showInsight = true
        
    end
    
end

--@Overload Player
function Spectator:OnInitialized()

    Player.OnInitialized(self)
    
    // Spectator cannot have orders.
    // Todo: Move OrdersMixin out of Player and into leaf classes.
    // Don't include the OrdersMixin on Spectators.
    self:SetIgnoreOrders(true)
    
    self.lastTargetId = Entity.invalidId
    self.specTargetId = Entity.invalidId
    self.timeFromLastAction = 0
    self.movementModifierState = false
    
    if Server then
        
        self:SetIsVisible(false)       
        self:SetIsAlive(false)

    end
    
    self:DestroyController() // Remove physics
    self:SetPropagate(Entity.Propagate_Never) // A spectator is not sync with other player

end

--@Overload Player
function Spectator:OnDestroy()

    if Client then

        if self.guiSpectator then
            GetGUIManager():DestroyGUIScriptSingle("GUISpectator")
            self.guiSpectator = nil
        end

    end
    
    self.modeInstance:Uninitialize(self) 
    Player.OnDestroy(self) 

end

--@Overload Player
function Spectator:OnProcessMove(input)

	if self.UpdateMove == nil then
		local newMode = kSpectatorModeClass[Spectator.kSpectatorMode.FreeLook]()
		newMode:Initialize(self)
		self.modeInstance = newMode    
		self.specMode = Spectator.kSpectatorMode.FreeLook 
	end
    self:UpdateMove(input)

    self:UpdateScoreboardDisplay(input)
    self.modeInstance:Update(input)
    UpdateMapDisplay(self, input)
    UpdateSpectatorMode(self, input)
    
    if Client and not Shared.GetIsRunningPrediction() then

        self:UpdateCrossHairTarget()
        self:UpdateChat(input)
        
        if bit.band(input.commands, Move.Weapon4) ~= 0 then // Toggle the insight GUI

            self.showInsight = not self.showInsight
            self.guiSpectator:SetIsVisible(self.showInsight)
        
            if self.showInsight then
            
                self.mapMode = Spectator.kSpectatorMapMode.Small
                self:ShowMap(true, false, true)
                
            else
            
                self.mapMode = Spectator.kSpectatorMapMode.Invisible
                self:ShowMap(false, false, true)
                
            end
            
        end

    end
    
    self:OnUpdatePlayer(input.time)
    Player.UpdateMisc(self,input) 

end

/**
 * Override this function to enable/disable mode for
 * a type of Player (for Example TeamSpectator)
 */
function Spectator:IsValidMode(mode)
    return true
end

/**
 * Change the spectator mode
 * 
 * @param mode is a valid class inheritate from SpectatorMode class
 */
function Spectator:SetSpectatorMode(mode)

    if kSpectatorModeClass[mode].name ~= self.modeInstance.name then
    
        local oldMode = self.modeInstance
        local newMode = kSpectatorModeClass[mode]()
        
        oldMode:Uninitialize()
        newMode:Initialize(self)
        
        self.modeInstance = newMode
        self.specMode = mode
        
    end
    
    if Server then self:UpdateClientRelevancyMask() end

end

function Spectator:GetAnimateDeathCamera()
    return false
end

function Spectator:GetIsRespawning()
    return self.isRespawning
end

function Spectator:SetIsRespawning(value, entityId)
    self.isRespawning = value
    self.respawnHostId = entityId
end

function Spectator:GetRespawnOrigin()

    local respawnOrigin = nil
    
    if self.respawnHostId and Shared.GetEntity(self.respawnHostId) then
        respawnOrigin = Shared.GetEntity(self.respawnHostId):GetOrigin()
    end
    
    return respawnOrigin

end

--@Override Player
function Spectator:GetPlayFootsteps()
    return false
end

--@Override Player
function Spectator:GetMovePhysicsMask()
    return PhysicsMask.All
end

--@Override Player
function Spectator:GetTraceCapsule()
    return 0, 0
end

--@Override Player
function Spectator:GetMaxSpeed(possible)
    if self.specMode == Spectator.kSpectatorMode.FreeLook and not self.movementModifierState then
        return kDefaultFreeLookSpeed
    else
    return kMaxSpeed
end
end

--@Override Player
function Spectator:GetAcceleration()
    return kAcceleration
end

function Spectator:GetTechId()
    return kTechId.Spectator
end

function Spectator:GetIsOverhead()
    return self.specMode == Spectator.kSpectatorMode.Overhead
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

-- ERASE OR REFACTOR
// Handle player transitions to egg, new lifeforms, etc.
function Spectator:OnEntityChange(oldEntityId, newEntityId)

    if oldEntityId ~= Entity.invalidId and oldEntityId ~= nil then
    
        if oldEntityId == self.specTargetId then
            self.specTargetId = newEntityId
        end
        
        if oldEntityId == self.lastTargetId then
            self.lastTargetId = newEntityId
        end
       
    end
    
end

/**
 * Override this method to restrict or allow a target in follow mode.
 */
function Spectator:GetIsValidTarget(entity)

    local isValid = entity and not entity:isa("Commander") and (HasMixin(entity, "Live") and entity:GetIsAlive())
    isValid = isValid and (entity:GetTeamNumber() ~= kTeamReadyRoom and entity:GetTeamNumber() ~= kSpectatorIndex)
    
    return isValid
    
end

/**
 * Return target the player can follow
 * Override this method to restrict or increase target
 * in following move
 */
function Spectator:GetTargetsToFollow(includeCommandStructure)

    local potentialTargets = EntityListToTable(Shared.GetEntitiesWithClassname("Player"))
      
    if includeCommandStructure then
        table.addtable(EntityListToTable(Shared.GetEntitiesWithClassname("CommandStructure")), potentialTargets)
    end
    
    local targets = {}
    for index, target in ipairs(potentialTargets) do
    
        if self:GetIsValidTarget(target) then
            table.insert(targets, target)
        end
        
    end

    // Include command station if there is no target
    if table.count(targets) < 1 and not includeCommandStructure then
        return self:GetTargetsToFollow(true)
    else        
        return targets
    end

end

--@Override Player
function Spectator:GetPlayerStatusDesc()    
    return kPlayerStatus.Spectator
end

function SpectatorUI_IsOverhead()
    local player = Client.GetLocalPlayer()
    if player ~= nil and player:isa("Spectator") then
        return player:GetIsOverhead()
    end
    
    return false
end

-------------------
-- CLIENT METHOD --
-------------------

if Client then

    function Spectator:GetDisplayUnitStates()
        return self.specMode == Spectator.kSpectatorMode.FreeLook
    end

    --@Override Player
    function Spectator:OnSynchronized()
        Player.OnSynchronized(self)

        self:OnSpectatorModeSynchronized()      
    end

    --@Override Player
    function Spectator:OverrideInput(input)
    
        if self.specMode == Spectator.kSpectatorMode.Overhead then

            -- Move to position if minimap clicked
            if self.setScrollPosition then
            
                input.move.x = 0
                input.move.y = 0
                input.move.z = 0
            
                input.commands = bit.bor(input.commands, Move.Minimap)
                
                -- Put in yaw and pitch because they are 16 bits
                -- each. Without them we get a "settling" after
                -- clicking the minimap due to differences after
                -- sending to the server
                input.yaw = self.minimapNormX
                input.pitch = self.minimapNormY
                
                self.setScrollPosition = false

            else
        AdjustInputForInversion(input)
            end
            
        else
        
            AdjustInputForInversion(input)
            
        end
        
        ClampInputPitch(input)
        
        if self.OverrideMove then
            input = self:OverrideMove(input)
        end
        
        return input
        
    end

    function Spectator:OnSpectatorModeSynchronized()

        if self.specMode ~= self.clientSpecMode then

            self:SetSpectatorMode(self.specMode)
            self.clientSpecMode = self.specMode

        end        

    end
    
    function Spectator:OnInitLocalClient()
        Player.OnInitLocalClient(self)    
        
        if self:GetTeamNumber() == kSpectatorIndex then
        
            self:ShowMap(true, false, true)
        
            if self.guiSpectator == nil then
                self.guiSpectator = GetGUIManager():CreateGUIScriptSingle("GUISpectator")
            end

        end
    end

    function Spectator:GetCrossHairTarget()
        if self.specMode == Spectator.kSpectatorMode.Following then
            return Shared.GetEntity(self.specTargetId)
        elseif self.specMode == Spectator.kSpectatorMode.Overhead then
            return self.entityUnderCursor
        end
        
        return Player.GetCrossHairTarget(self)
    end  

    // Don't change visibility on client
    function Spectator:UpdateClientEffects(deltaTime, isLocal)
        
        Player.UpdateClientEffects(self, deltaTime, isLocal)
        
        self:SetIsVisible(false)
        
        local activeWeapon = self:GetActiveWeapon()
        if (activeWeapon ~= nil) then
            activeWeapon:SetIsVisible( false )
        end
        
        local viewModel = self:GetViewModelEntity()    
        if(viewModel ~= nil) then
            viewModel:SetIsVisible( false )
        end

    end

    function Spectator:GetCrossHairText()
        if self.specMode == Spectator.kSpectatorMode.Overhead then
            return nil
        end
        
        return self.crossHairText
    end

end


-------------------
-- SERVER METHOD --
-------------------
if Server then
    
    function Spectator:GetFollowingPlayerId()    
        local playerId = Entity.invalidId
        
        if (self.specMode == Spectator.kSpectatorMode.Following) then
            playerId = self.specTargetId
        end
        
        return playerId        
    end
    

    // Marines spawn at predetermined time at IP but allow them to spawn manually if cheats are on
    function Spectator:SpawnPlayerOnAttack()
    
        if Shared.GetCheatsEnabled() and ((self.timeOfDeath == nil) or (Shared.GetTime() > self.timeOfDeath + kFadeToBlackTime)) then
            return self:GetTeam():ReplaceRespawnPlayer(self)
        end
        
        return false, nil
        
    end
   
end

Shared.LinkClassToMap("Spectator", Spectator.kMapName, networkVars)