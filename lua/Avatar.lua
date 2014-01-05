// =========================================================================================
//
// lua\Avatar.lua
//
//    Created by:   Andy 'Soul Rider' Wilson for Proving Grounds Mod
//
// ================================================================================================

Script.Load("lua/Player.lua")
Script.Load("lua/Mixins/BaseMoveMixin.lua")
Script.Load("lua/Mixins/GroundMoveMixin.lua")
Script.Load("lua/Mixins/JumpMoveMixin.lua")
Script.Load("lua/Mixins/CrouchMoveMixin.lua")
Script.Load("lua/Mixins/CameraHolderMixin.lua")
Script.Load("lua/WallMovementMixin.lua")
Script.Load("lua/ScoringMixin.lua")
Script.Load("lua/UnitStatusMixin.lua")
Script.Load("lua/DissolveMixin.lua")
Script.Load("lua/LOSMixin.lua")
Script.Load("lua/CombatMixin.lua")
Script.Load("lua/RagdollMixin.lua")
Script.Load("lua/Weapons/PredictedProjectile.lua")
Script.Load("lua/AvatarVariantMixin.lua")


if Client then
    Script.Load("lua/TeamMessageMixin.lua")
end

class 'Avatar' (Player)

Avatar.kMapName = "avatar"

if Server then
    Script.Load("lua/Avatar_Server.lua")
elseif Client then
    Script.Load("lua/Avatar_Client.lua")
    Script.Load("lua/ColoredSkinsMixin.lua")
end

Shared.PrecacheSurfaceShader("models/marine/marine.surface_shader")
Shared.PrecacheSurfaceShader("models/marine/marine_noemissive.surface_shader")

Avatar.kChatSound = PrecacheAsset("sound/NS2.fev/marine/common/chat")

Avatar.kEffectNode = "fxnode_playereffect"

Avatar.kHealth = kAvatarHealth

Avatar.kMaxSpeed = 8                // Four miles an hour = 6,437 meters/hour = 1.8 meters/second (increase for FPS tastes)
Avatar.kWalkBackwardSpeedScalar = 1
Avatar.kAcceleration = 100
Avatar.kGroundFrictionForce = 10
Avatar.kAirStrafeWeight = 4

// tracked per techId
Avatar.kAvatarAlertTimeout = 4

//Dodge Variables for Proving Grounds AW
local kDodgeCooldown = 0.8
local kDodgeForce = 4
local kDodgeSpeed = 30
local kDodgeJumpDelay = 0.5
//Wall-Running Variables for Proving Grounds AW
// How big the spheres are that are casted out to find walls, "feelers".
// The size is calculated so the "balls" touch each other at the end of their range
local kNormalWallWalkFeelerSize = 0.25
local kNormalWallWalkRange = 0.3

//Wall-Jump Variables for Proving Grounds AW
// jump is valid when you are close to a wall but not attached yet at this range
local kJumpWallRange = 0.4
local kJumpWallFeelerSize = 0.1
local kWallJumpInterval = 0.4
local kWallJumpForce = 5.2 // scales down the faster you are
local kMinWallJumpForce = 0.1
local kVerticalWallJumpForce = 4.3

local networkVars =
{      
    //Dodge Local Network Variables for Proving Grounds AW
    dodging = "boolean",
    timeDodge = "private compensated time",
    dodgeDirection = "private vector",
    dodgeSpeed = "private compensated interpolated float",
    
    //Wall-Running Local Network Variables for Proving Grounds AW
    wallWalking = "compensated boolean",
    timeLastWallWalkCheck = "private compensated time",
    timeOfLastJumpLand = "private compensated time",
    timeLastWallJump = "private compensated time",
    jumpLandSpeed = "private compensated float",
    
    catpackboost = "private boolean",
    timeCatpackboost = "private time",
        
    hasDoubleJumped = "private compensated boolean",
    
}



AddMixinNetworkVars(BaseMoveMixin, networkVars)
AddMixinNetworkVars(GroundMoveMixin, networkVars)
AddMixinNetworkVars(JumpMoveMixin, networkVars)
AddMixinNetworkVars(CrouchMoveMixin, networkVars)
AddMixinNetworkVars(CameraHolderMixin, networkVars)
AddMixinNetworkVars(DissolveMixin, networkVars)
AddMixinNetworkVars(LOSMixin, networkVars)
AddMixinNetworkVars(CombatMixin, networkVars)
AddMixinNetworkVars(ScoringMixin, networkVars)
AddMixinNetworkVars(AvatarVariantMixin, networkVars)

function Avatar:OnCreate()

    InitMixin(self, BaseMoveMixin, { kGravity = Player.kGravity })
    InitMixin(self, GroundMoveMixin)
    InitMixin(self, JumpMoveMixin)
    InitMixin(self, CrouchMoveMixin)
    InitMixin(self, CameraHolderMixin, { kFov = kDefaultFov })
    InitMixin(self, WallMovementMixin)
    InitMixin(self, ScoringMixin, { kMaxScore = kMaxScore })
    InitMixin(self, CombatMixin)
    
    Player.OnCreate(self)
    
    InitMixin(self, DissolveMixin)
    InitMixin(self, LOSMixin)
    InitMixin(self, RagdollMixin)
    InitMixin(self, PredictedProjectileShooterMixin)
    InitMixin(self, AvatarVariantMixin)
    if Client then
        InitMixin(self, ColoredSkinsMixin) //Client only
    end
    
    self.dodgeDirection = Vector()
    self.hasDoubleJumped = false

    if Server then
        self.timeDodge = 0
        self.dodging = false
    end
    
end

function Avatar:OnInitialized()

    // Note: This needs to be initialized BEFORE calling SetModel() below
    // as SetModel() will call GetHeadAngles() through SetPlayerPoseParameters()
    // which will cause a script error if the Avatar is wall running BEFORE
    // the Avatar is initialized on the client.
    self.currentWallWalkingAngles = Angles(0.0, 0.0, 0.0)
        
    // SetModel must be called before Player.OnInitialized is called so the attach points in
    // the Marine are valid to attach weapons to. This is far too subtle...
    self:SetModel(self:GetVariantModel(), AvatarVariantMixin.kMarineAnimationGraph)
    
    Player.OnInitialized(self)
    
    //Set-Up Wall-Running variables
    self.wallWalking = false
    self.wallWalkingNormalGoal = Vector.yAxis
            
    local viewAngles = self:GetViewAngles()
    self.lastYaw = viewAngles.yaw
    self.lastPitch = viewAngles.pitch
    
    // -1 = leftmost, +1 = right-most
    self.horizontalSwing = 0
    // -1 = up, +1 = down
    
    //Cat Pack Boost is given to players on Melee kill - Proving Grounds AW
    self.catpackboost = false
    self.timeCatpackboost = 0
    
    //Wall-Jump Variable
    self.timeLastWallJump = 0

end

local blockBlackArmor = false
if Server then
    Event.Hook("Console_blockblackarmor", function() if Shared.GetCheatsEnabled() then blockBlackArmor = not blockBlackArmor end end)
end

function Avatar:GetSlowOnLand()
    return false
end

function Avatar:OnDestroy()

    Player.OnDestroy(self)
    
end

function Avatar:HandleButtons(input)

    PROFILE("Avatar:HandleButtons")
    
    local movementSpecialPressed = bit.band(input.commands, Move.MovementModifier) ~= 0
    
    if movementSpecialPressed then
        self:TriggerDodge(input.move)
    end
    
    local crouchPressed = bit.band(input.commands, Move.Crouch) ~= 0
    
    /*if crouchPressed then
    end*/
    
    Player.HandleButtons(self, input)
    
end

function Avatar:GetCrouchSpeedScalar()
    return Player.kCrouchSpeedScalar
end

function Avatar:ModifyGroundFraction(groundFraction)
    return groundFraction > 0 and 1 or 0
end

function Avatar:OverrideUpdateOnGround(onGround)
    return onGround or self:GetIsWallWalking()
end

function Avatar:ModifyGravityForce(gravityTable)

    if self:GetIsWallWalking() then
        gravityTable.gravity = 0

    elseif self:GetIsOnGround() then
        gravityTable.gravity = 0
    end

end

function Avatar:GetIsDodging()
    return self.dodging
end

function Avatar:GetMaxSpeed(possible)

    if possible then
        return Avatar.kMaxSpeed
    end
    
    local maxSpeed = Avatar.kMaxSpeed
    
    if self:GetIsWallWalking() then
        maxSpeed = maxSpeed + 0.25
    end
    
    if self.catpackboost then
        maxSpeed = maxSpeed + kCatPackMoveAddSpeed
    end
    
    return maxSpeed 
    
end

function Avatar:GetFootstepSpeedScalar()
    return Clamp(self:GetVelocityLength() / (Avatar.kMaxSpeed * self:GetCatalystMoveSpeedModifier()), 0, 1)
end

// Maximum speed a player can move backwards
function Avatar:GetMaxBackwardSpeedScalar()
    return Avatar.kWalkBackwardSpeedScalar
end

function Avatar:GetPlayerControllersGroup()
    return PhysicsGroup.BigPlayerControllersGroup
end

function Avatar:GetRecentlyWallJumped()
    return self.timeLastWallJump + kWallJumpInterval > Shared.GetTime()
end

function Avatar:GetCanWallJump()

    local wallWalkNormal = self:GetAverageWallWalkingNormal(kJumpWallRange, kJumpWallFeelerSize)
    if wallWalkNormal then
        return wallWalkNormal.y < 0.5
    end
    
    return false

end

function Avatar:GetIsWallWalking()
    return self.wallWalking
end

function Avatar:GetIsWallWalkingPossible() 
    return self:GetCrouching()
end

local function PredictGoal(self, velocity)

    PROFILE("Avatar:PredictGoal")

    local goal = self.wallWalkingNormalGoal
    if velocity:GetLength() > 1 and not self:GetIsOnSurface() then

        local movementDir = GetNormalizedVector(velocity)
        local trace = Shared.TraceCapsule(self:GetOrigin(), movementDir * 2.5, Skulk.kXExtents, 0, CollisionRep.Move, PhysicsMask.Movement, EntityFilterOne(self))

        if trace.fraction < 1 and not trace.entity then
            goal = trace.normal    
        end

    end

    return goal

end

function Avatar:GetJumpHeight()
    return Player.kJumpHeight
end

function Avatar:GetPerformsVerticalMove()
    return self:GetIsWallWalking()
end

function Avatar:GetAirControl()
    return 100
end 

function Avatar:GetGroundTransistionTime()
    return 0.1
end

function Avatar:GetAirAcceleration()
    return 9
end

function Avatar:GetAirFriction()
    return 0.055
end 

function Avatar:GetHasDodgeCooldown()
    return self.timeDodge + kDodgeCooldown > Shared.GetTime()
end

// Update wall-walking from current origin
function Avatar:PreUpdateMove(input, runningPrediction)

    PROFILE("Avatar:PreUpdateMove")

    if self:GetCrouching() then
        self.wallWalking = false
    end

    if self.wallWalking then

        // Most of the time, it returns a fraction of 0, which means
        // trace started outside the world (and no normal is returned)           
        local goal = self:GetAverageWallWalkingNormal(kNormalWallWalkRange, kNormalWallWalkFeelerSize)
        if goal ~= nil then
        
            self.wallWalkingNormalGoal = goal
            self.wallWalking = true

        else
            self.wallWalking = false
        end
    
    end
    
    if not self:GetIsWallWalking() then
        // When not wall walking, the goal is always directly up (running on ground).
        self.wallWalkingNormalGoal = Vector.yAxis
    end
    
    self.currentWallWalkingAngles = self:GetAnglesFromWallNormal(self.wallWalkingNormalGoal or Vector.yAxis) or self.currentWallWalkingAngles

end

function Avatar:GetRollSmoothRate()
    return 5
end

function Avatar:GetPitchSmoothRate()
    return 3
end

function Avatar:GetSlerpSmoothRate()
    return 5
end

function Avatar:GetAngleSmoothRate()
    return 6
end

function Avatar:GetCollisionSlowdownFraction()
    return 0.05
end

function Avatar:GetDesiredAngles(deltaTime)
    return self.currentWallWalkingAngles
end 

function Avatar:GetHeadAngles()

    if self:GetIsWallWalking() then
        return self.currentWallWalkingAngles
    else
        return self:GetViewAngles()
    end

end

function Avatar:GetAngleSmoothingMode()

    if self:GetIsWallWalking() then
        return "quatlerp"
    else
        return "euler"
    end

end

function Avatar:GetIsUsingBodyYaw()
    return not self:GetIsWallWalking()
end

function Avatar:TriggerDodge(direction)

    if direction.x ~= 0 then
    
        local movementDirection = self:GetViewCoords():TransformVector(direction)    
        movementDirection:Normalize()

        if not self:GetHasDodgeCooldown() then
    
            // add small force in the direction we are dodging
            local currentSpeed = movementDirection:DotProduct(self:GetVelocity())
            local dodgeStrength = math.max(currentSpeed, 11) + 0.5
            self:SetVelocity(movementDirection * dodgeStrength)
        
            self.timeDodge = Shared.GetTime()
            self.dodgeSpeed = kDodgeSpeed
            self.dodging = true
            self.dodgeDirection = Vector(movementDirection)
                
        end
    end
end

// Returns -1 to 1
function Avatar:GetWeaponSwing()
    return self.horizontalSwing
end

function Avatar:GetWeaponDropTime()
    return self.weaponDropTime
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
    
    return status
end

function Avatar:GetCanDropWeapon(weapon, ignoreDropTimeLimit)
   
    return false
    
end

function Avatar:GetCanUseCatPack()

    local enoughTimePassed = self.timeCatpackboost + 6 < Shared.GetTime()
    return not self.catpackboost or enoughTimePassed
    
end

function Avatar:GetCanChangeViewAngles()
    return true
end    

function Avatar:OnUseTarget(target)

end

function Avatar:OnUseEnd() 

end

function Avatar:OnUpdateAnimationInput(modelMixin)

    PROFILE("Avatar:OnUpdateAnimationInput")
    
    Player.OnUpdateAnimationInput(self, modelMixin)
        
    local catalystSpeed = 1
    if self.catpackboost then
        catalystSpeed = kCatPackWeaponSpeed
    end
    modelMixin:SetAnimationInput("reload_time", kReloadTime)
    modelMixin:SetAnimationInput("catalyst_speed", catalystSpeed)
    
end

function Avatar:GetDeflectMove()
    return true
end 

function Avatar:GetCanJump()
    return not self.hasDoubleJumped and self.timeDodge + kDodgeJumpDelay < Shared.GetTime()
end

function Avatar:ModifyJump(input, velocity, jumpVelocity)

    jumpVelocity.y = jumpVelocity.y * 1.6
    
    /*if self:GetCanWallJump() then
    
        local direction = input.move.z == -1 and -1 or 1
    
        // we add the bonus in the direction the move is going
        local viewCoords = self:GetViewAngles():GetCoords()
        self.bonusVec = viewCoords.zAxis * direction
        self.bonusVec.y = 0
        self.bonusVec:Normalize()
        
        jumpVelocity.y = 3 + math.min(1, 1 + viewCoords.zAxis.y) * 2
        
        local force = math.max(kMinWallJumpForce, kWallJumpForce)
          
        self.bonusVec:Scale(force)      

        if not self:GetRecentlyWallJumped() then
        
            self.bonusVec.y = viewCoords.zAxis.y * kVerticalWallJumpForce
            jumpVelocity:Add(self.bonusVec)

        end
        
        self.timeLastWallJump = Shared.GetTime()
        
    end*/

end

function Avatar:OnJump()

    if not self:GetIsOnGround() or not self:GetIsWallWalking() then
        self.hasDoubleJumped = true           
    end
    
    self.wallWalking = false
    
    local jumpEffectName = "jump"
    
    local velocityLength = self:GetVelocity():GetLengthXZ()
    
    if velocityLength > 11 then
        jumpEffectName = "jump_best"            
    elseif velocityLength > 8.5 then
        jumpEffectName = "jump_good"
    end

    self:TriggerEffects(jumpEffectName, {surface = self:GetMaterialBelowPlayer()})
    
end

function Avatar:OnWorldCollision(normal, impactForce, newVelocity)

    PROFILE("Avatar:OnWorldCollision")

    self.wallWalking = self:GetIsWallWalkingPossible() and normal.y < 0.5
    
end

function Avatar:OnProcessMove(input)

    if self.catpackboost then
        self.catpackboost = Shared.GetTime() - self.timeCatpackboost < kCatPackDuration
    end
   
    Player.OnProcessMove(self, input)
    
    // move without manipulating velocity
    if self:GetIsDodging() then
    
        self.dodgeSpeed = math.max(0, self.dodgeSpeed - input.time * 90)
        local completedMove, hitEntities, averageSurfaceNormal = self:PerformMovement(self.dodgeDirection * self.dodgeSpeed * input.time, 3)
        local breakDodge = false
        
        //stop when colliding with an enemy player
        if hitEntities then
        
            for _, entity in ipairs(hitEntities) do
            
                if entity:isa("Player") and GetAreEnemies(self, entity) then
                
                    breakDodge = true
                    break
                    
                end
            
            end
            
        end
        
        local enemyTeamNumber = GetEnemyTeamNumber(self:GetTeamNumber())
        
        local function FilterFriendAndDead(entity)
            return HasMixin(entity, "Team") and entity:GetTeamNumber() == enemyTeamNumber and HasMixin(entity, "Live") and entity:GetIsAlive()
        end        
        
        // trigger break when enemy player is nearby
        if not breakDodge and self.dodgeSpeed < 35 then
            breakDodge = #Shared.GetEntitiesWithTagInRange("class:Player", self:GetOrigin(), 1.8, FilterFriendAndDead) > 0
        end
        
        if breakDodge then
        
            self.dodging = false
            self.dodgeSpeed = 0
            local velocity = self:GetVelocity()
            velocity.x = 0
            velocity.z = 0
            self:SetVelocity(velocity)
            
        end
        
    end
    
end

function Avatar:GetHasCatpackBoost()
    return self.catpackboost
end

function Avatar:PostUpdateMove(input, runningPrediction)

    if self.dodgeSpeed == 0 then
        self.dodging = false
    end
    
    if self:GetIsOnGround() then
        self.hasDoubleJumped = false
    end
end

function Avatar:GetCrouchShrinkAmount()
    return 0
end

function Avatar:GetExtentsCrouchShrinkAmount()
    return 0
end

function Avatar:GetCrouchCameraAnimationAllowed(result)
    result.allowed = false
end

Shared.LinkClassToMap("Avatar", Avatar.kMapName, networkVars, true)
