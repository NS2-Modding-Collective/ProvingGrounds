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
Script.Load("lua/DissolveMixin.lua")
Script.Load("lua/HiveVisionMixin.lua")
Script.Load("lua/DisorientableMixin.lua")
Script.Load("lua/LOSMixin.lua")
Script.Load("lua/CombatMixin.lua")
Script.Load("lua/SelectableMixin.lua")
Script.Load("lua/ParasiteMixin.lua")
Script.Load("lua/Weapons/Marine/BMFG.lua")

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
Avatar.kGunPickupSound = PrecacheAsset("sound/NS2.fev/marine/common/pickup_gun")
Avatar.kSpendResourcesSoundName = PrecacheAsset("sound/NS2.fev/marine/common/player_spend_nanites")
Avatar.kChatSound = PrecacheAsset("sound/NS2.fev/marine/common/chat")
Avatar.kSoldierLostAlertSound = PrecacheAsset("sound/NS2.fev/marine/voiceovers/soldier_lost")

Avatar.kFlinchEffect = PrecacheAsset("cinematics/marine/hit.cinematic")
Avatar.kFlinchBigEffect = PrecacheAsset("cinematics/marine/hit_big.cinematic")

Avatar.kEffectNode = "fxnode_playereffect"
Avatar.kHealth = kMarineHealth
Avatar.kBaseArmor = kMarineArmor
Avatar.kArmorPerUpgradeLevel = kArmorPerUpgradeLevel
Avatar.kMaxSprintFov = 95
// Player phase delay - players can only teleport this often
Avatar.kPlayerPhaseDelay = 2

Avatar.kWalkMaxSpeed = 7                // Four miles an hour = 6,437 meters/hour = 1.8 meters/second (increase for FPS tastes)
Avatar.kClampMaxSpeed = 12.0               // 10 miles an hour = 16,093 meters/hour = 4.4 meters/second (increase for FPS tastes)

Avatar.kWalkBackwardSpeedScalar = 1

// tracked per techId
Avatar.kAvatarAlertTimeout = 4

local kDropWeaponTimeLimit = 1
local kPickupWeaponTimeLimit = 1

Avatar.kAcceleration = 50

Avatar.kAirStrafeWeight = 2

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
    flashlightOn = "boolean",
    timeOfLastPhase = "private time",
    
    timeOfLastDrop = "private time",
    timeOfLastPickUpWeapon = "private time",
    
    flashlightLastFrame = "private boolean",
    
    timeLastSpitHit = "private time",
    lastSpitDirection = "private vector",

    poisoned = "boolean",
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
AddMixinNetworkVars(SelectableMixin, networkVars)
AddMixinNetworkVars(DissolveMixin, networkVars)
AddMixinNetworkVars(LOSMixin, networkVars)
AddMixinNetworkVars(CombatMixin, networkVars)
AddMixinNetworkVars(ParasiteMixin, networkVars)

function Avatar:OnCreate()

    InitMixin(self, BaseMoveMixin, { kGravity = Player.kGravity })
    InitMixin(self, GroundMoveMixin)
    InitMixin(self, CameraHolderMixin, { kFov = kDefaultFov })
    InitMixin(self, MarineActionFinderMixin)
    InitMixin(self, ScoringMixin, { kMaxScore = kMaxScore })
    InitMixin(self, CombatMixin)
    InitMixin(self, SelectableMixin)
    
    Player.OnCreate(self)
    
    InitMixin(self, DissolveMixin)
    InitMixin(self, EntityChangeMixin)
    InitMixin(self, LOSMixin)
    InitMixin(self, ParasiteMixin)
    
    //self.loopingSprintSoundEntId = Entity.invalidId
    
    if Server then
    
        /*self.loopingSprintSound = Server.CreateEntity(SoundEffect.kMapName)
        self.loopingSprintSound:SetAsset(Avatar.kLoopingSprintSound)
        self.loopingSprintSound:SetParent(self)
        self.loopingSprintSoundEntId = self.loopingSprintSound:GetId()*/
        
        self.timePoisoned = 0
        self.poisoned = false
        //Added for Proving Grounds
        self.timeShadowStep = 0
        self.shadowStepping = false
        self.hasDoubleJumped = false
        
    elseif Client then
    
        self.flashlight = Client.CreateRenderLight()
        
        self.flashlight:SetType( RenderLight.Type_Spot )
        self.flashlight:SetColor( Color(.8, .8, 1) )
        self.flashlight:SetInnerCone( math.rad(30) )
        self.flashlight:SetOuterCone( math.rad(35) )
        self.flashlight:SetIntensity( 10 )
        self.flashlight:SetRadius( 15 ) 
        self.flashlight:SetGoboTexture("models/marine/male/flashlight.dds")
        
        self.flashlight:SetIsVisible(false)
        
        InitMixin(self, TeamMessageMixin, { kGUIScriptName = "GUIMarineTeamMessage" })

        InitMixin(self, DisorientableMixin)
        
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
       
    elseif Client then
    
        InitMixin(self, HiveVisionMixin)
        
        self:AddHelpWidget("GUIMarineHealthRequestHelp", 2)
        self:AddHelpWidget("GUIMarineFlashlightHelp", 2)
        self:AddHelpWidget("GUIBuyShotgunHelp", 2)
        self:AddHelpWidget("GUIMarineWeldHelp", 2)
        self:AddHelpWidget("GUIMapHelp", 1)
        
    end
    
    self.weaponDropTime = 0
    self.timeOfLastPhase = nil
    
    local viewAngles = self:GetViewAngles()
    self.lastYaw = viewAngles.yaw
    self.lastPitch = viewAngles.pitch
    
    // -1 = leftmost, +1 = right-most
    self.horizontalSwing = 0
    // -1 = up, +1 = down
    
    self.timeLastSpitHit = 0
    self.lastSpitDirection = Vector(0,0,0)
    self.timeOfLastDrop = 0
    self.timeOfLastPickUpWeapon = 0
    self.catpackboost = false
    self.timeCatpackboost = 0
    
    self.flashlightLastFrame = false
    
    if Server then

        self.timeLastPoisonDamage = 0
        
        self.lastPoisonAttackerId = Entity.invalidId
        
    end
    
end

local blockBlackArmor = false
if Server then
    Event.Hook("Console_blockblackarmor", function() if Shared.GetCheatsEnabled() then blockBlackArmor = not blockBlackArmor end end)
end

function Avatar:GetArmorLevel()

    local armorLevel = 0
    local techTree = self:GetTechTree()

    if techTree then
    
        local armor3Node = techTree:GetTechNode(kTechId.Armor3)
        local armor2Node = techTree:GetTechNode(kTechId.Armor2)
        local armor1Node = techTree:GetTechNode(kTechId.Armor1)
    
        if armor3Node and armor3Node:GetResearched() then
            armorLevel = 3
        elseif armor2Node and armor2Node:GetResearched()  then
            armorLevel = 2
        elseif armor1Node and armor1Node:GetResearched()  then
            armorLevel = 1
        end
        
    end

    return armorLevel

end

function Avatar:GetWeaponLevel()

    local weaponLevel = 0
    local techTree = self:GetTechTree()

    if techTree then
        
            local weapon3Node = techTree:GetTechNode(kTechId.Weapons3)
            local weapon2Node = techTree:GetTechNode(kTechId.Weapons2)
            local weapon1Node = techTree:GetTechNode(kTechId.Weapons1)
        
            if weapon3Node and weapon3Node:GetResearched() then
                weaponLevel = 3
            elseif weapon2Node and weapon2Node:GetResearched()  then
                weaponLevel = 2
            elseif weapon1Node and weapon1Node:GetResearched()  then
                weaponLevel = 1
            end
            
    end

    return weaponLevel

end

function Avatar:MakeSpecialEdition()

    if not blockBlackArmor then
        self:SetModel(Avatar.kSpecialModelName, Avatar.kAvatarAnimationGraph)
    end
    
end

// Currently there are some issues with a jumping Marine getting disrupted (weapons becoming locked).
// not using now toss, only stun. maybe that already fixed it
function Avatar:GetCanBeDisrupted()
    return true
    //return not self:GetIsJumping()
end

function Avatar:GetCanRepairOverride(target)
    return self:GetWeapon(Welder.kMapName) and HasMixin(target, "Weldable") and ( (target:isa("Avatar") and target:GetArmor() < target:GetMaxArmor()) or (not target:isa("Avatar") and target:GetHealthScalar() < 0.9) )
end

function Avatar:GetSlowOnLand()
    return false
end

function Avatar:GetArmorAmount()

    local armorLevels = 0
    
    if(GetHasTech(self, kTechId.Armor3, true)) then
        armorLevels = 3
    elseif(GetHasTech(self, kTechId.Armor2, true)) then
        armorLevels = 2
    elseif(GetHasTech(self, kTechId.Armor1, true)) then
        armorLevels = 1
    end
    
    return Avatar.kBaseArmor + armorLevels*Avatar.kArmorPerUpgradeLevel
    
end

function Avatar:GetNanoShieldOffset()
    return Vector(0, -0.1, 0)
end

function Avatar:OnDestroy()

    Player.OnDestroy(self)
    
    if Server then
    
        // The loopingSprintSound was already destroyed at this point, clear the reference.
        //self.loopingSprintSound = nil
        
    elseif Client then
        
        if self.flashlight ~= nil then
            Client.DestroyRenderLight(self.flashlight)
        end
        
        if self.marineHUD then
        
            GetGUIManager():DestroyGUIScript(self.marineHUD)
            self.marineHUD = nil
            
        end
        
        if self.poisonedGUI then
        
            GetGUIManager():DestroyGUIScript(self.poisonedGUI)
            self.poisonedGUI = nil
            
        end
        
        if self.pickups then
        
            GetGUIManager():DestroyGUIScript(self.pickups)
            self.pickups = nil
            
        end

        if self.hints then
        
            GetGUIManager():DestroyGUIScript(self.hints)
            self.hints = nil
            
        end        
        
        if self.guiOrders then
            GetGUIManager():DestroyGUIScript(self.guiOrders)
            self.guiOrders = nil
        end
        
        if self.buyMenu then
        
            GetGUIManager():DestroyGUIScript(self.buyMenu)
            self.buyMenu = nil
            MouseTracker_SetIsVisible(false)
            
        end
        
        if self.sensorBlips then
        
            GetGUIManager():DestroyGUIScript(self.sensorBlips)
            self.sensorBlips = nil
            
        end
        
        if self.objectiveDisplay then
        
            GetGUIManager():DestroyGUIScript(self.objectiveDisplay)
            self.objectiveDisplay = nil
            
        end
        
        if self.progressDisplay then
        
            GetGUIManager():DestroyGUIScript(self.progressDisplay)
            self.progressDisplay = nil
            
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

function Avatar:SetFlashlightOn(state)
    self.flashlightOn = state
end

function Avatar:GetFlashlightOn()
    return self.flashlightOn
end

function Avatar:GetInventorySpeedScalar()
    return 1
end

function Avatar:GetCrouchSpeedScalar()
    return Player.kCrouchSpeedScalar
end

function Avatar:GetMaxSpeed(possible)

    if possible then
        return Avatar.kWalkMaxSpeed
    end

    local onInfestation = self:GetGameEffectMask(kGameEffect.OnInfestation)
    local sprintingScalar = self:GetSprintingScalar()
    local maxSprintSpeed = ConditionalValue(onInfestation, Avatar.kWalkMaxSpeed + (Avatar.kRunInfestationMaxSpeed - Avatar.kWalkMaxSpeed)*sprintingScalar, Avatar.kWalkMaxSpeed + (Avatar.kRunMaxSpeed - Avatar.kWalkMaxSpeed)*sprintingScalar)
    local maxSpeed = ConditionalValue(self:GetIsSprinting(), maxSprintSpeed, Avatar.kWalkMaxSpeed)
    
    // Take into account our weapon inventory and current weapon. Assumes a vanilla marine has a scalar of around .8.
    local inventorySpeedScalar = self:GetInventorySpeedScalar() + .17

    // Take into account crouching
    if not self:GetIsJumping() then
        maxSpeed = ( 1 - self:GetCrouchAmount() * self:GetCrouchSpeedScalar() ) * maxSpeed
    end

    local adjustedMaxSpeed = maxSpeed * self:GetCatalystMoveSpeedModifier()
    //Print("Adjusted max speed => %.2f (without inventory: %.2f)", adjustedMaxSpeed, adjustedMaxSpeed / inventorySpeedScalar )
    return adjustedMaxSpeed
    
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
    return not self:GetIsVortexed() and self:GetArmor() < self:GetMaxArmor(), false
end

function Avatar:GetAcceleration()

    if self:GetIsShadowStepping() then
        return 0
    end

    local acceleration = Avatar.kAcceleration 

    acceleration = acceleration * self:GetInventorySpeedScalar()

    /*
    if self.timeLastSpitHit + Avatar.kSpitSlowDuration > Shared.GetTime() then
        acceleration = acceleration * 0.5
    end
    */

    return acceleration * self:GetCatalystMoveSpeedModifier()

end

// Returns -1 to 1
function Avatar:GetWeaponSwing()
    return self.horizontalSwing
end

function Avatar:GetWeaponDropTime()
    return self.weaponDropTime
end

local marineTechButtons = { kTechId.Attack, kTechId.Move, kTechId.Defend  }
function Avatar:GetTechButtons(techId)

    local techButtons = nil
    
    if techId == kTechId.RootMenu then
        techButtons = marineTechButtons
    end
    
    return techButtons
 
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

    if not weapon then
        weapon = self:GetActiveWeapon()
    end
    
    if weapon ~= nil and weapon.GetIsDroppable and weapon:GetIsDroppable() then
    
        // Don't drop weapons too fast.
        if ignoreDropTimeLimit or (Shared.GetTime() > (self.timeOfLastDrop + kDropWeaponTimeLimit)) then
            return true
        end
        
    end
    
    return false
    
end

// Do basic prediction of the weapon drop on the client so that any client
// effects for the weapon can be dealt with
function Avatar:Drop(weapon, ignoreDropTimeLimit, ignoreReplacementWeapon)

    local activeWeapon = self:GetActiveWeapon()
    
    if not weapon then
        weapon = activeWeapon
    end
    
    if self:GetCanDropWeapon(weapon, ignoreDropTimeLimit) then
        
        if weapon == activeWeapon then
            self:SelectNextWeapon()
        end
    
        weapon:OnPrimaryAttackEnd(self)
    
        // Remove from player's inventory
        if Server then
            self:RemoveWeapon(weapon)
        end
        
        if Server then
        
            local weaponSpawnCoords = self:GetAttachPointCoords(Weapon.kHumanAttachPoint)
            weapon:SetCoords(weaponSpawnCoords)
            
        end
        
        // Tell weapon not to be picked up again for a bit
        weapon:Dropped(self)
        
        // Set activity end so we can't drop like crazy
        self.timeOfLastDrop = Shared.GetTime() 
        
        if Server then
        
            if ignoreReplacementWeapon ~= true and weapon.GetReplacementWeaponMapName then
                self:GiveItem(weapon:GetReplacementWeaponMapName(), false)
                // the client expects the next weapon is going to be selected (does not know about the replacement).
                self:SelectNextWeaponInDirection(1)
            end
        
        end
        
        return true
        
    end
    
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

function Avatar:OnSpitHit(direction)

    if Server then
        self.timeLastSpitHit = Shared.GetTime()
        self.lastSpitDirection = direction  
    end

end

function Avatar:GetCanChangeViewAngles()
    return true
end    

function Avatar:GetPlayFootsteps()

    return self:GetVelocityLength() > .75 and self:GetIsOnGround()
    
end

function Avatar:OnUseTarget(target)

    local activeWeapon = self:GetActiveWeapon()

    if target and HasMixin(target, "Construct") and ( target:GetCanConstruct(self) or (target.CanBeWeldedByBuilder and target:CanBeWeldedByBuilder()) ) then
    
        if activeWeapon and activeWeapon:GetMapName() ~= Builder.kMapName then
            self:SetActiveWeapon(Builder.kMapName)
            self.weaponBeforeUse = activeWeapon:GetMapName()
        end
        
    else
        if activeWeapon and activeWeapon:GetMapName() == Builder.kMapName and self.weaponBeforeUse then
            self:SetActiveWeapon(self.weaponBeforeUse)
        end    
    end

end

function Avatar:OnUseEnd() 

    local activeWeapon = self:GetActiveWeapon()

    if activeWeapon and activeWeapon:GetMapName() == Builder.kMapName and self.weaponBeforeUse then
        self:SetActiveWeapon(self.weaponBeforeUse)
    end

end

function Avatar:GetOverrideMaxDisruptDuration()
    return 0
end

function Avatar:OnUpdateAnimationInput(modelMixin)

    PROFILE("Avatar:OnUpdateAnimationInput")
    
    Player.OnUpdateAnimationInput(self, modelMixin)    
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
        
        if self.poisoned then
        
            if self:GetIsAlive() and self.timeLastPoisonDamage + 1 < Shared.GetTime() then
            
                local attacker = Shared.GetEntity(self.lastPoisonAttackerId)
            
                local currentHealth = self:GetHealth()
                local poisonDamage = kBitePoisonDamage
                
                // never kill the marine with poison only
                if currentHealth - poisonDamage < kPoisonDamageThreshhold then
                    poisonDamage = math.max(0, currentHealth - kPoisonDamageThreshhold)
                end
                
                self:DeductHealth(poisonDamage, attacker, nil, true)
                self.timeLastPoisonDamage = Shared.GetTime()   
                
            end
            
            if self.timePoisoned + kPoisonBiteDuration < Shared.GetTime() then
            
                self.timePoisoned = 0
                self.poisoned = false
                
            end
            
        end
        
    end
    
    Player.OnProcessMove(self, input)
    
end

function Avatar:GetHasCatpackBoost()
    return self.catpackboost
end

//Proving Grounds New Functions
function Avatar:SelectNextWeapon()
    //todo - create function to select from list of ammo types
end

function Avatar:SelectPrevWeapon()
    //todo - create function to select from list of ammo types
end

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