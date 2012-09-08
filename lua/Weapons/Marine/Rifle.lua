// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\Weapons\Rifle.lua
//
//    Created by:   Charlie Cleveland (charlie@unknownworlds.com) and
//                  Max McGuire (max@unknownworlds.com)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/Weapons/Marine/ClipWeapon.lua")
Script.Load("lua/PickupableWeaponMixin.lua")
Script.Load("lua/EntityChangeMixin.lua")
Script.Load("lua/Weapons/ClientWeaponEffectsMixin.lua")

class 'Rifle' (ClipWeapon)

Rifle.kMapName = "rifle"

Rifle.kModelName = PrecacheAsset("models/marine/rifle/rifle.model")
local kViewModelName = PrecacheAsset("models/marine/rifle/rifle_view.model")
local kAnimationGraph = PrecacheAsset("models/marine/rifle/rifle_view.animation_graph")

local kRange = 250
// 4 degrees in NS1
local kSpread = ClipWeapon.kCone3Degrees

local kButtRange = 1.4

local kNumberOfVariants = 3

local kSingleShotSounds = { "sound/NS2.fev/marine/rifle/fire_single", "sound/NS2.fev/marine/rifle/fire_single_2", "sound/NS2.fev/marine/rifle/fire_single_3" }
for k, v in ipairs(kSingleShotSounds) do PrecacheAsset(v) end

local kLoopingSounds = { "sound/NS2.fev/marine/rifle/fire_14_sec_loop", "sound/NS2.fev/marine/rifle/fire_loop_2", "sound/NS2.fev/marine/rifle/fire_loop_3" }
for k, v in ipairs(kLoopingSounds) do PrecacheAsset(v) end

local kRifleEndSound = PrecacheAsset("sound/NS2.fev/marine/rifle/end")

local networkVars =
{
    soundType = "integer (1 to 3)"
}

local kMuzzleEffect = PrecacheAsset("cinematics/marine/rifle/muzzle_flash.cinematic")
local kMuzzleAttachPoint = "fxnode_riflemuzzle"

function Rifle:OnCreate()

    ClipWeapon.OnCreate(self)
    
    InitMixin(self, PickupableWeaponMixin)
    InitMixin(self, EntityChangeMixin)
    
    if Client then
        InitMixin(self, ClientWeaponEffectsMixin)
    end

end

function Rifle:OnInitialized()

    ClipWeapon.OnInitialized(self)
    
    self.soundType = Shared.GetRandomInt(1, kNumberOfVariants)
    
    if Client then
    
        self:SetUpdates(true)
        
        self:SetFirstPersonAttackingEffect(kMuzzleEffect)
        self:SetThirdPersonAttackingEffect(kMuzzleEffect)
        self:SetMuzzleAttachPoint(kMuzzleAttachPoint)
        
    end
    
end

function Rifle:OnHolsterClient()

    ClipWeapon.OnHolsterClient(self)

end

function Rifle:OnDestroy()

    ClipWeapon.OnDestroy(self)

end

function Rifle:OnPrimaryAttack(player)

    if not self:GetIsReloading() then
        ClipWeapon.OnPrimaryAttack(self, player)
    end    

end

function Rifle:OnSecondaryAttack(player)

    if not self.blockingSecondary and not player:GetIsSprinting() then
        ClipWeapon.OnSecondaryAttack(self, player)
    end
    
end

function Rifle:GetAnimationGraphName()
    return kAnimationGraph
end

function Rifle:GetViewModelName()
    return kViewModelName
end

function Rifle:GetDeathIconIndex()

    if self:GetSecondaryAttacking() then
        return kDeathMessageIcon.RifleButt
    end
    return kDeathMessageIcon.Rifle
    
end

function Rifle:GetHUDSlot()
    return kPrimaryWeaponSlot
end

function Rifle:GetClipSize()
    return kRifleClipSize
end

function Rifle:GetReloadTime()
    return kRifleReloadTime
end

function Rifle:GetSpread()
    return kSpread
end

function Rifle:GetBulletDamage(target, endPoint)
    return kRifleDamage
end

function Rifle:GetRange()
    return kRange
end

function Rifle:GetWeight()
    return kRifleWeight
end

function Rifle:GetSecondaryCanInterruptReload()
    return true
end

function Rifle:GetBarrelSmokeEffect()
    return Rifle.kBarrelSmokeEffect
end

function Rifle:GetShellEffect()
    return chooseWeightedEntry ( Rifle.kShellEffectTable )
end

function Rifle:PerformMeleeAttack(player)

    self:TriggerEffects("rifle_alt_attack")

    // Perform melee attack
    local didHit, hitObject, endPoint, surface = AttackMeleeCapsule(self, player, kRifleMeleeDamage, kButtRange, nil, true)
    
    if Server and didHit then
    
        if hitObject and GetGamerules():CanEntityDoDamageTo(player, hitObject) then
        
            // Rifle melee attack will cause the hitObject to be knocked back in some cases.
            if HasMixin(hitObject, "Stun") then
            
                local direction = hitObject:GetOrigin() - player:GetOrigin()
                direction:Normalize()
                // trigger knockback on hitObject which will be executed in the next tick
                hitObject:SetKnockback(1, 0, direction * 2500, 120, 120)
                
            end
            
        end
        
    end
    
end

function Rifle:OnTag(tagName)

    PROFILE("Rifle:OnTag")

    ClipWeapon.OnTag(self, tagName)
    
    if tagName == "hit" then
    
        local player = self:GetParent()
        if player then
            self:PerformMeleeAttack(player)
        end
        
    end

end

function Rifle:SetGunLoopParam(viewModel, paramName, rateOfChange)

    local current = viewModel:GetPoseParam(paramName)
    // 0.5 instead of 1 as full arm_loop is intense.
    local new = Clamp(current + rateOfChange, 0, 0.5)
    viewModel:SetPoseParam(paramName, new)
    
end

function Rifle:UpdateViewModelPoseParameters(viewModel)

    viewModel:SetPoseParam("hide_gl", 1)
    viewModel:SetPoseParam("gl_empty", 1)

    local attacking = self:GetPrimaryAttacking()
    local sign = (attacking and 1) or 0

    self:SetGunLoopParam(viewModel, "arm_loop", sign)
    
end

function Rifle:Dropped(prevOwner)

    ClipWeapon.Dropped(self, prevOwner)
    
end

function Rifle:OnUpdateAnimationInput(modelMixin)
    
    PROFILE("Rifle:OnUpdateAnimationInput")
    ClipWeapon.OnUpdateAnimationInput(self, modelMixin)

    modelMixin:SetAnimationInput("gl", false)
    
end

function Rifle:GetAmmoPackMapName()
    return RifleAmmo.kMapName
end

if Client then

    function Rifle:OnClientPrimaryAttackStart()
    
        // Fire off a single shot on the first shot. Pew.
        Shared.PlaySound(self, kSingleShotSounds[self.soundType])
        // Start the looping sound for the rest of the shooting. Pew pew pew...
        Shared.PlaySound(self, kLoopingSounds[self.soundType])
    
    end
    
    function Rifle:OnClientPrimaryAttackEnd()
    
        // Just assume the looping sound is playing.
        Shared.StopSound(self, kLoopingSounds[self.soundType])
        Shared.PlaySound(self, kRifleEndSound)

    end

    function Rifle:GetPrimaryEffectRate()
        return 0.08
    end
    
    function Rifle:GetPreventCameraAnimation()
        return self:GetIsReloading()
    end

    function Rifle:GetBarrelPoint()

        local player = self:GetParent()
        if player then
        
            local origin = player:GetEyePos()
            local viewCoords= player:GetViewCoords()
        
            return origin + viewCoords.zAxis * 0.4 + viewCoords.xAxis * -0.2 + viewCoords.yAxis * -0.22
        end
        
        return self:GetOrigin()
        
    end  

end

Shared.LinkClassToMap("Rifle", Rifle.kMapName, networkVars)