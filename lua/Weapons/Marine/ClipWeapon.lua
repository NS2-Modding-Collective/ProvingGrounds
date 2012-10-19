// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\Weapons\ClipWeapon.lua
//
//    Created by:   Charlie Cleveland (charlie@unknownworlds.com) and
//                  Max McGuire (max@unknownworlds.com)
//
// Basic bullet-based weapon. Handles primary firing only, as child classes have quite different
// secondary attacks.
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/Weapons/Weapon.lua")
Script.Load("lua/Weapons/BulletsMixin.lua")

PrecacheAsset("cinematics/materials/umbra/ricochet.cinematic")

class 'ClipWeapon' (Weapon)

ClipWeapon.kMapName = "clipweapon"

local networkVars =
{
    blockingPrimary = "boolean",
    blockingSecondary = "boolean",
    timeAttackStarted = "time",
    deployed = "boolean",

    clip = "integer (0 to 200)",
    
    reloading = "boolean",
    
    lastTimeSprinted = "time"
}

// Weapon spread - from NS1/Half-life
ClipWeapon.kCone0Degrees  = Math.Radians(0)
ClipWeapon.kCone1Degrees  = Math.Radians(1)
ClipWeapon.kCone2Degrees  = Math.Radians(2)
ClipWeapon.kCone3Degrees  = Math.Radians(3)
ClipWeapon.kCone4Degrees  = Math.Radians(4)
ClipWeapon.kCone5Degrees  = Math.Radians(5)
ClipWeapon.kCone6Degrees  = Math.Radians(6)
ClipWeapon.kCone7Degrees  = Math.Radians(7)
ClipWeapon.kCone8Degrees  = Math.Radians(8)
ClipWeapon.kCone9Degrees  = Math.Radians(9)
ClipWeapon.kCone10Degrees = Math.Radians(10)
ClipWeapon.kCone15Degrees = Math.Radians(15)
ClipWeapon.kCone20Degrees = Math.Radians(20)

function ClipWeapon:OnCreate()

    Weapon.OnCreate(self)
    
    self.primaryAttacking = false
    self.secondaryAttacking = false
    self.blockingPrimary = false
    self.blockingSecondary = false
    self.timeAttackStarted = 0
    self.deployed = false
    self.lastTimeSprinted = 0
    
    InitMixin(self, BulletsMixin)
    
end

local function FillClip(self)
    
    //Fill Clip up directly
    self.clip = self:GetClipSize()
 
end

function ClipWeapon:OnInitialized()

    // Set model to be rendered in 3rd-person
    local worldModel = LookupTechData(self:GetTechId(), kTechDataModel)
    if worldModel ~= nil then
        self:SetModel(worldModel)
    end

    self.clip = 0
    self.reloading = false
    
    FillClip(self)
    
    Weapon.OnInitialized(self)
    
end

function ClipWeapon:GetIsDeployed()
    return self.deployed
end

function ClipWeapon:GetBulletsPerShot()
    return 1
end

function ClipWeapon:GetClipSize()
    return 10
end

// Used to affect spread and change the crosshair
function ClipWeapon:GetInaccuracyScalar(player)
    return ConditionalValue(player and player.GetIsInterrupted and player:GetIsInterrupted(), 8, 1)
end

// Return one of the ClipWeapon.kCone constants above
function ClipWeapon:GetSpread()
    return ClipWeapon.kCone0Degrees
end

function ClipWeapon:GetRange()
    return 8012
end

function ClipWeapon:GetClip()
    return self.clip
end

function ClipWeapon:SetClip(clip)
    self.clip = clip
end

function ClipWeapon:GetAuxClip()
    return 0
end

// Return world position of gun barrel, used for weapon effects.
function ClipWeapon:GetBarrelPoint()

    // TODO: Get this from the model and artwork.
    local player = self:GetParent()
    if player then
        return player:GetOrigin() + Vector(0, 2 * player:GetExtents().y * 0.8, 0) + player:GetCoords().zAxis * 0.5
    end
    
    return self:GetOrigin()
    
end

function ClipWeapon:OnProcessMove(input)

    Weapon.OnProcessMove(self, input)
    
    // We need to clear this out in OnProcessMove (rather than ProcessMoveOnWeapon)
    // since this will get called after the view model has been updated from
    // Player:OnProcessMove. 
    self.secondaryAttacking = false

end

function ClipWeapon:GetBulletDamage(target, endPoint)

    assert(false, "Need to override GetBulletDamage()")
    
    return 0
    
end

function ClipWeapon:GetIsReloading()
    return self.reloading
end

function ClipWeapon:GetPrimaryCanInterruptReload()
    return false
end

function ClipWeapon:GetSecondaryCanInterruptReload()
    return false
end

local function CancelReload(self)

    self.reloading = false
    self:TriggerEffects("reload_cancel")
    
end

function ClipWeapon:GetNeedsAmmo(includeClip)
    return (includeClip and (self:GetClip() < self:GetClipSize()))
end

function ClipWeapon:GetWarmupTime()
    return 0
end

function ClipWeapon:GetPrimaryAttackRequiresPress()
    return false
end

function ClipWeapon:GetForcePrimaryAttackAnimation()
    return true
end

function ClipWeapon:GetIsPrimaryAttackAllowed(player)

    if not player then
        return false
    end    

    local attackAllowed = (not self:GetPrimaryAttackRequiresPress() or not player:GetPrimaryAttackLastFrame())
    attackAllowed = attackAllowed and (not self:GetIsReloading() or self:GetPrimaryCanInterruptReload())
    attackAllowed = attackAllowed and not self.blockingSecondary
    attackAllowed = attackAllowed and (not self:GetPrimaryIsBlocking() or not self.blockingPrimary)
    
    return self:GetIsDeployed() and attackAllowed

end

function ClipWeapon:OnPrimaryAttack(player)

    if self:GetIsPrimaryAttackAllowed(player) then
    
        if self.clip > 0 then
        
            local warmingUp = Shared.GetTime() < (self.timeAttackStarted + self:GetWarmupTime())
            if not warmingUp then
            
                if self:GetIsReloading() then
                    CancelReload(self)
                end
                
                self.primaryAttacking = true
                self.timeAttackStarted = Shared.GetTime()
                
                if self:GetPrimaryIsBlocking() then
                    self.blockingPrimary = true
                end
                
            end
            
        elseif self.clip == 0 then        
            self:OnPrimaryAttackEnd(player)
            // Automatically reload if we're out of ammo.
            player:Reload()
            
        else
        
            // Once the ClipWeapon empty animations are working again, this
            // should be added back and should only play on a tag.
            //self:TriggerEffects("clipweapon_empty")
            self:OnPrimaryAttackEnd(player)
            
        end
        
    else
        self:OnPrimaryAttackEnd(player)
    end
    
end

function ClipWeapon:OnPrimaryAttackEnd(player)

    if self.primaryAttacking then
    
        Weapon.OnPrimaryAttackEnd(self, player)
        
        self.primaryAttacking = false
        
    end
    
end

function ClipWeapon:CreatePrimaryAttackEffect(player)
end

function ClipWeapon:GetHasSecondary(player)
    return true
end

function ClipWeapon:OnSecondaryAttack(player)

    local attackAllowed = (not self:GetIsReloading() or self:GetSecondaryCanInterruptReload()) and (not self:GetSecondaryAttackRequiresPress() or not player:GetSecondaryAttackLastFrame())
    attackAllowed = attackAllowed and (not self:GetPrimaryIsBlocking() or not self.blockingPrimary) and not self.blockingSecondary
    
    if self:GetIsDeployed() and attackAllowed and not self.primaryAttacking then
    
        self.secondaryAttacking = true
        
        if self:GetIsReloading() then
            CancelReload(self)
        end
        
        Weapon.OnSecondaryAttack(self, player)
        
        self.blockingSecondary = true
        self.timeAttackStarted = Shared.GetTime()
        
        return true
        
    end
    
    return false
    
end

function ClipWeapon:GetPrimaryAttacking()

    if self:GetPrimaryIsBlocking() then
        return self.blockingPrimary
    else
        return self.primaryAttacking
    end
    
end

function ClipWeapon:GetSecondaryAttacking()
    return self.blockingSecondary
end

/**
 * By default, primary attack does not block anything else.
 * Child classes can override this behavior by returning true here.
 */
function ClipWeapon:GetPrimaryIsBlocking()
    return false
end

/**
 * Fires the specified number of bullets in a cone from the player's current view.
 */
local function FireBullets(self, player)

    PROFILE("FireBullets")

    local viewAngles = player:GetViewAngles()
    local shootCoords = viewAngles:GetCoords()
    
    // Filter ourself out of the trace so that we don't hit ourselves.
    local filter = EntityFilterTwo(player, self)
    local range = self:GetRange()
    
    if GetIsVortexed(player) then
        range = 5
    end
    
    local numberBullets = self:GetBulletsPerShot()
    local startPoint = player:GetEyePos()
    
    for bullet = 1, numberBullets do
    
        local spreadDirection = CalculateSpread(shootCoords, self:GetSpread(bullet) * self:GetInaccuracyScalar(player), NetworkRandom)
        
        local endPoint = startPoint + spreadDirection * range
        
        local trace = Shared.TraceRay(startPoint, endPoint, CollisionRep.Damage, PhysicsMask.Bullets, filter)
        
        local damage = 0

        /*
        // Check prediction
        local values = GetPredictionValues(startPoint, endPoint, trace)
        if not CheckPredictionData( string.format("attack%d", bullet), true, values ) then
            Server.PlayPrivateSound(player, "sound/NS2.fev/marine/voiceovers/game_start", player, 1.0, Vector(0, 0, 0))
        end
        */
            
        // don't damage 'air'..
        if trace.fraction < 1 or GetIsVortexed(player) then
        
            local direction = (trace.endPoint - startPoint):GetUnit()
            local impactPoint = trace.endPoint - direction * kHitEffectOffset
            local surfaceName = trace.surface

            local target = trace.entity
                
            if target then            
                damage = self:GetBulletDamage(trace.entity, trace.endPoint)                
            end
            
            local effectFrequency = self:GetTracerEffectFrequency()
            local showTracer = math.random() < effectFrequency
            
            self:ApplyBulletGameplayEffects(player, trace.entity, impactPoint, direction, damage, trace.surface, showTracer)

        end
        
        local client = Server and player:GetClient() or Client
        if not Shared.GetIsRunningPrediction() and client.hitRegEnabled then
            RegisterHitEvent(player, bullet, startPoint, trace, damage)
        end
        
    end
    
end

function ClipWeapon:FirePrimary(player)
    FireBullets(self, player)
end

// Play tracer sound/effect every %d bullets
function ClipWeapon:GetTracerEffectFrequency()
    return 0.5
end

function ClipWeapon:GetIsDroppable()
    return false
end

function ClipWeapon:CanReload()
    return self.clip < self:GetClipSize() and not self.reloading and not self.blockingSecondary
end

function ClipWeapon:OnReload(player)

    if self:CanReload() then
    
        self:TriggerEffects("reload")
        self.reloading = true
        
    end
    
end

function ClipWeapon:OnDraw(player, previousWeaponMapName)

    Weapon.OnDraw(self, player, previousWeaponMapName)
    
    // Attach weapon to parent's hand
    self:SetAttachPoint(Weapon.kHumanAttachPoint)
    
end

function ClipWeapon:OnHolster(player)

    Weapon.OnHolster(self, player)
    
    self.deployed = false
    self.blockingPrimary = false
    self.blockingSecondary = false
    self.reloading = false
    
end

function ClipWeapon:GetEffectParams(tableParams)

    Weapon.GetEffectParams(self, tableParams)
    
    tableParams[kEffectFilterEmpty] = (self.clip == 0)
    
end

function ClipWeapon:OnTag(tagName)

    PROFILE("ClipWeapon:OnTag")

    if tagName == "shoot" then
    
        local player = self:GetParent()
        
        // We can get a shoot tag even when the clip is empty if the frame rate is low
        // and the animation loops before we have time to change the state.
        if player and self.clip > 0 then
        
            self:FirePrimary(player)
            
            // Don't decrement ammo in Darwin mode
            if not player or not player:GetDarwinMode() then
                self.clip = self.clip - 1
            end
            
            self:CreatePrimaryAttackEffect(player)
            
            Weapon.OnPrimaryAttack(self, player)
            
        end
        
    elseif tagName == "reload" then
        FillClip(self)
    elseif tagName == "deploy_end" then
        self.deployed = true
    elseif tagName == "reload_end" then
        self.reloading = false
    elseif tagName == "attack_end" then
        self.blockingPrimary = false
    elseif tagName == "alt_attack_end" then
        self.blockingSecondary = false
    end
    
end

function ClipWeapon:OnUpdateAnimationInput(modelMixin)

    PROFILE("ClipWeapon:OnUpdateAnimationInput")
    
    local stunned = false
    local interrupted = false
    local player = self:GetParent()
    if player then
    
        if HasMixin(player, "Stun") and player:GetIsStunned() then
            stunned = true
        end
        
        if player.GetIsInterrupted and player:GetIsInterrupted() then
            interrupted = true
        end
        
    end
    
    local activity = "none"
    if not stunned then
    
        if self:GetIsReloading() then
            activity = "reload"
        elseif self.primaryAttacking then
            activity = "primary"
        elseif self.secondaryAttacking then
            activity = "secondary"
        end
        
    end
    
    modelMixin:SetAnimationInput("activity", activity)
    modelMixin:SetAnimationInput("flinch_gore", interrupted)
    modelMixin:SetAnimationInput("empty", (self.clip) == 0)

end

// override if weapon should drop reserve ammo as separate entity
function ClipWeapon:GetAmmoPackMapName()
    return nil
end    

if Client then

    function ClipWeapon:GetTriggerPrimaryEffects()
        return not self:GetIsReloading()
    end
    
    function ClipWeapon:GetTriggerSecondaryEffects()
        return not self:GetIsReloading()
    end

end

Shared.LinkClassToMap("ClipWeapon", ClipWeapon.kMapName, networkVars)