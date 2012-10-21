// ======= Copyright (c) 2003-2012, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\Avatar.lua
//
//    Created by:   Andy 'Soul Rider' Wilson for Proving Grounds
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/Player.lua")
Script.Load("lua/Mixins/BaseMoveMixin.lua")
Script.Load("lua/Mixins/GroundMoveMixin.lua")
Script.Load("lua/Mixins/CameraHolderMixin.lua")
Script.Load("lua/MarineActionFinderMixin.lua")
Script.Load("lua/ScoringMixin.lua")
Script.Load("lua/UnitStatusMixin.lua")
Script.Load("lua/LOSMixin.lua")
Script.Load("lua/CombatMixin.lua")

if Client then
    Script.Load("lua/TeamMessageMixin.lua")
end

class 'Avatar' (Player)

Avatar.kMapName = "avatar"

if Server then
    Script.Load("lua/Avatar_Server.lua")
else
    Script.Load("lua/Avatar_Client.lua")
end

Shared.PrecacheSurfaceShader("models/marine/marine.surface_shader")
Shared.PrecacheSurfaceShader("models/marine/marine_noemissive.surface_shader")

Avatar.kModelName = PrecacheAsset("models/marine/male/male.model")
Avatar.kSpecialModelName = PrecacheAsset("models/marine/male/male_special.model")
Avatar.kAvatarAnimationGraph = PrecacheAsset("models/marine/male/male.animation_graph")

Avatar.kDieSoundName = PrecacheAsset("sound/NS2.fev/marine/common/death")
Avatar.kChatSound = PrecacheAsset("sound/NS2.fev/marine/common/chat")
Avatar.kSoldierLostAlertSound = PrecacheAsset("sound/NS2.fev/marine/voiceovers/soldier_lost")

Avatar.kFlinchEffect = PrecacheAsset("cinematics/marine/hit.cinematic")
Avatar.kFlinchBigEffect = PrecacheAsset("cinematics/marine/hit_big.cinematic")

Avatar.kEffectNode = "fxnode_playereffect"
Avatar.kHealth = kMarineHealth
Avatar.kBaseArmor = kMarineArmor
Avatar.kMaxSprintFov = 95

// tracked per techId
Avatar.kAvatarAlertTimeout = 4

Avatar.kAcceleration = 100

Avatar.kAirStrafeWeight = 1

//Added for Proving Grounds
Avatar.kShadowStepCooldown = 1.5
Avatar.kShadowStepJumpDelay = 0.25
Avatar.kShadowStepForce = 30
Avatar.kShadowStepAirForce = 15
Avatar.kShadowStepDuration = 0.15

// when using shadow step before 1.4 seconds passed it decreases in effectiveness
Avatar.kShadowStepSoftCooldDown = 1.4

local networkVars =
{      

    catpackboost = "private boolean",
    //Added for Proving Grounds
    shadowStepping = "boolean",
    timeShadowStep = "private time",
    shadowStepDirection = "private vector",
    hasDoubleJumped = "private compensated boolean", 
    movementModiferState = "boolean"
}

AddMixinNetworkVars(BaseMoveMixin, networkVars)
AddMixinNetworkVars(GroundMoveMixin, networkVars)
AddMixinNetworkVars(CameraHolderMixin, networkVars)

AddMixinNetworkVars(LOSMixin, networkVars)
AddMixinNetworkVars(CombatMixin, networkVars)

function Avatar:OnCreate()

    InitMixin(self, BaseMoveMixin, { kGravity = Player.kGravity })
    InitMixin(self, GroundMoveMixin)
    InitMixin(self, CameraHolderMixin, { kFov = kDefaultFov })
    InitMixin(self, MarineActionFinderMixin)
    InitMixin(self, ScoringMixin, { kMaxScore = kMaxScore })
    InitMixin(self, CombatMixin)

    
    Player.OnCreate(self)

    InitMixin(self, EntityChangeMixin)
    InitMixin(self, LOSMixin)
    
    //self.loopingSprintSoundEntId = Entity.invalidId
    
    if Server then

        //Added for Proving Grounds
        self.timeShadowStep = 0
        self.shadowStepping = false
        self.hasDoubleJumped = false
        
    elseif Client then

        InitMixin(self, TeamMessageMixin, { kGUIScriptName = "GUIMarineTeamMessage" })
        
    end
    
end

function Avatar:OnInitialized()
    
    // SetModel must be called before Player.OnInitialized is called so the attach points in
    // the Marine are valid to attach weapons to. This is far too subtle...
    self:SetModel(Avatar.kModelName, Avatar.kAvatarAnimationGraph)
    
    Player.OnInitialized(self)
    
    // Calculate max and starting armor differently
    self.armor = 0
    
    if Server then
    
        self.armor = self:GetArmorAmount()
        self.maxArmor = self.armor
    end
    
    local viewAngles = self:GetViewAngles()
    self.lastYaw = viewAngles.yaw
    self.lastPitch = viewAngles.pitch
    
    // -1 = leftmost, +1 = right-most
    self.horizontalSwing = 0
    // -1 = up, +1 = down
    

    self.catpackboost = false
    self.timeCatpackboost = 0

end

local blockBlackArmor = false
if Server then
    Event.Hook("Console_blockblackarmor", function() if Shared.GetCheatsEnabled() then blockBlackArmor = not blockBlackArmor end end)
end

function Avatar:GetArmorLevel()

    local armorLevel = 0
    return armorLevel

end

function Avatar:GetWeaponLevel()

    local weaponLevel = 0
    return weaponLevel

end

function Avatar:MakeSpecialEdition()

    if not blockBlackArmor then
        self:SetModel(Avatar.kSpecialModelName, Avatar.kAvatarAnimationGraph)
    end
    
end

function Avatar:GetArmorAmount()
    return Avatar.kBaseArmor  
end

function Avatar:OnDestroy()

    Player.OnDestroy(self)
        
    if Client then
        
        
        if self.avatarHUD then
        
            GetGUIManager():DestroyGUIScript(self.avatarHUD)
            self.avatarHUD = nil
            
        end
        
    end
    
end

function Avatar:GetGroundFrictionForce()
    return ConditionalValue(self:GetIsShadowStepping(), 0, 9)
end

function Avatar:HandleButtons(input)

    PROFILE("Avatar:HandleButtons")
    
    Player.HandleButtons(self, input)
    
    if self:GetCanControl() then
    
        // Update sprinting state
        local newMovementState = bit.band(input.commands, Move.MovementModifier) ~= 0
        if newMovementState ~= self.movementModiferState and self.movementModiferState ~= nil then
            self:MovementModifierChanged(newMovementState, input)
        end
    
        self.movementModiferState = newMovementState
        
    end
    
end

function Avatar:GetOnGroundRecently()
    return (self.timeLastOnGround ~= nil and Shared.GetTime() < self.timeLastOnGround + 0.4) 
end

function Avatar:OnClampSpeed(input, velocity)
end

function Avatar:GetFootstepSpeedScalar()
    return Clamp(self:GetVelocityLength() / (Avatar.kWalkMaxSpeed * self:GetCatalystMoveSpeedModifier()), 0, 1)
end

function Avatar:GetAirMoveScalar()
    return 0.5
end

function Avatar:GetAirFrictionForce()
    return 0
end

function Avatar:GetJumpHeight()
    return Player.kJumpHeight
end

function Avatar:GetCanBeWeldedOverride()
    return self:GetArmor() < self:GetMaxArmor(), false
end

function Avatar:GetAcceleration()

    if self:GetIsShadowStepping() then
        return 0
    end

    local acceleration = Avatar.kAcceleration 

    return acceleration * self:GetCatalystMoveSpeedModifier()

end

// Returns -1 to 1
function Avatar:GetWeaponSwing()
    return self.horizontalSwing
end

function Avatar:GetCatalystFireModifier()
    return ConditionalValue(self:GetHasCatpackBoost(), CatPack.kAttackSpeedModifier, 1)
end

function Avatar:GetCatalystMoveSpeedModifier()
    return ConditionalValue(self:GetHasCatpackBoost(), CatPack.kMoveSpeedScalar, 1)
end

function Avatar:GetHasSayings()
    return true
end

// Other
function Avatar:GetSayings()

    if(self.showSayings) then
    
        if(self.showSayingsMenu == 1) then
            return marineRequestSayingsText
        end
        if(self.showSayingsMenu == 2) then
            return marineGroupSayingsText
        end
        if(self.showSayingsMenu == 3) then
            return GetVoteActionsText(self:GetTeamNumber())
        end
        
    end
    
    return nil
    
end

function Avatar:GetChatSound()
    return Avatar.kChatSound
end

function Avatar:GetDeathMapName()
    return MarineSpectator.kMapName
end

// Returns the name of the primary weapon
function Avatar:GetPlayerStatusDesc()

    local status = kPlayerStatus.Void
    
    if (self:GetIsAlive() == false) then
        return kPlayerStatus.Dead
    end
    
    local weapon = self:GetWeaponInHUDSlot(1)
    if (weapon) then
        if (weapon:isa("GrenadeLauncher")) then
            return kPlayerStatus.GrenadeLauncher
        elseif (weapon:isa("Rifle")) then
            return kPlayerStatus.Rifle
        elseif (weapon:isa("Shotgun")) then
            return kPlayerStatus.Shotgun
        elseif (weapon:isa("Flamethrower")) then
            return kPlayerStatus.Flamethrower
        end
    end
    
    return status
end

function Avatar:GetCanDropWeapon(weapon, ignoreDropTimeLimit)

    return false
    
end



function Avatar:GetWeldPercentageOverride()
    return self:GetArmor() / self:GetMaxArmor()
end

function Avatar:OnWeldOverride(doer, elapsedTime)

    if self:GetArmor() < self:GetMaxArmor() then
    
        local addArmor = Avatar.kArmorWeldRate * elapsedTime
        self:SetArmor(self:GetArmor() + addArmor)
        
    end
    
end

function Avatar:GetCanChangeViewAngles()
    return true
end    

function Avatar:GetPlayFootsteps()

    return self:GetVelocityLength() > .75 and self:GetIsOnGround()
    
end

function Avatar:OnUpdateAnimationInput(modelMixin)

    PROFILE("Avatar:OnUpdateAnimationInput")
    
    Player.OnUpdateAnimationInput(self, modelMixin) 

   /* if self:GetIsDiving() then
        modelMixin:SetAnimationInput("move", "toss") 
    end*/
    modelMixin:SetAnimationInput("attack_speed", self:GetCatalystFireModifier())
    
end

function Avatar:ModifyVelocity(input, velocity)

    Player.ModifyVelocity(self, input, velocity)
    
    if not self:GetIsOnGround() and input.move:GetLength() ~= 0 then
    
        local moveLengthXZ = velocity:GetLengthXZ()
        local previousY = velocity.y
        local adjustedZ = false
        local viewCoords = self:GetViewCoords()
        
        if input.move.x ~= 0  then
        
            local redirectedVelocityX = GetNormalizedVectorXZ(self:GetViewCoords().xAxis) * input.move.x
            redirectedVelocityX = redirectedVelocityX * input.time * Avatar.kAirStrafeWeight + GetNormalizedVectorXZ(velocity)
            
            redirectedVelocityX:Normalize()            
            redirectedVelocityX:Scale(moveLengthXZ)
            redirectedVelocityX.y = previousY            
            VectorCopy(redirectedVelocityX,  velocity)
            
        end
        
    end
    
end

function Avatar:OnProcessMove(input)

    if Server then
    
        self.catpackboost = Shared.GetTime() - self.timeCatpackboost < CatPack.kDuration
        
       
        
    end
    
    Player.OnProcessMove(self, input)
    
end

function Avatar:GetHasCatpackBoost()
    return self.catpackboost
end

//Proving Grounds New Functions

function Avatar:MovementModifierChanged(newMovementModifierState, input)

    if newMovementModifierState then
        self:TriggerShadowStep(input.move)
    end

end

function Avatar:TriggerShadowStep(direction)

    if direction:GetLength() == 0 then
        return
    end   

    direction:Normalize() 

    local movementDirection = self:GetViewCoords():TransformVector( direction )

    local canShadowStep = true
    
    if canShadowStep and not self:GetRecentlyJumped() and not self:GetHasShadowStepCooldown() then

        local velocity = self:GetVelocity()
        
        local shadowStepStrength = ConditionalValue(self:GetIsOnGround(), Avatar.kShadowStepForce, Avatar.kShadowStepAirForce)
        self:SetVelocity(velocity * 0.5 + movementDirection * shadowStepStrength)
        
        self.timeShadowStep = Shared.GetTime()
        self.shadowStepping = true
        self.shadowStepDirection = direction
        
        self:TriggerEffects("shadow_step", {effecthostcoords = Coords.GetLookIn(self:GetOrigin(), movementDirection)})
        
        /*
        if Client and Client.GetLocalPlayer() == self then
            self:TriggerFirstPersonMiniBlinkEffect(direction)
        end
        */
    
    end

end

function Avatar:GetHasShadowStepCooldown()
    return self.timeShadowStep + Avatar.kShadowStepCooldown > Shared.GetTime()
end

function Avatar:GetCanJump()
    return not self.hasDoubleJumped and self.timeShadowStep + Avatar.kShadowStepJumpDelay < Shared.GetTime()
end

function Avatar:GetIsShadowStepping()
    return self.shadowStepping
end

function Avatar:GetMoveDirection(moveVelocity)

    if self:GetIsShadowStepping() then
        
        local direction = GetNormalizedVector(moveVelocity)
        
        // check if we attempt to blink into the ground
        // TODO: get rid of this hack here once UpdatePosition is adjusted for blink
        if direction.y < 0 then
        
            local trace = Shared.TraceRay(self:GetOrigin() + kBlinkTraceOffset, self:GetOrigin() + kBlinkTraceOffset + direction * 1.7, CollisionRep.Move, PhysicsMask.Movement, EntityFilterAll())
            if trace.fraction ~= 1 then
                direction.y = 0.1
            end
            
        end
        
        return direction
        
    end

    return Player.GetMoveDirection(self, moveVelocity)    

end


function Avatar:OverrideInput(input)

    Player.OverrideInput(self, input)
    
    if self:GetIsShadowStepping() then
        input.move = self.shadowStepDirection
    end
    
    return input
    
end

function Avatar:PreUpdateMove(input, runningPrediction)
    self.shadowStepping = self.timeShadowStep + Avatar.kShadowStepDuration > Shared.GetTime()
end

function Avatar:GetRecentlyJumped()
    return self.timeOfLastJump ~= nil and self.timeOfLastJump + 0.15 > Shared.GetTime()
end

function Avatar:OnJumpLand(landIntensity, slowDown)
    Player.OnJumpLand(self, landIntensity, slowDown)
    self.hasDoubleJumped = false    
end
function Avatar:OnJump()
    if not self:GetIsOnGround() then
        self.hasDoubleJumped = true
    end    
end
Shared.LinkClassToMap("Avatar", Avatar.kMapName, networkVars)