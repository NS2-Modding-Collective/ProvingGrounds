// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\Weapons\Marine\AntiMatterSword.lua
//
//    Created by:   Andreas Urwalek (a_urwa@sbox.tugraz.at)
//
//    Weapon used for repairing structures and armor of friendly players (marines, exosuits, jetpackers).
//    Uses hud slot 3 (replaces axe)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/Weapons/Weapon.lua")

class 'AntiMatterSword' (Weapon)

AntiMatterSword.kMapName = "antimattersword"

AntiMatterSword.kModelName = PrecacheAsset("models/marine/welder/welder.model")
local kViewModelName = PrecacheAsset("models/marine/welder/welder_view.model")
local kAnimationGraph = PrecacheAsset("models/marine/welder/welder_view.animation_graph")

kAntiMatterSwordHUDSlot = 5

local kAntiMatterSwordTraceExtents = Vector(0.4, 0.4, 0.4)

local networkVars =
{
    welding = "boolean",
    loopingSoundEntId = "entityid"
}

local kAMSRange = 1.0

local kAntiMatterSwordEffectRate = 0.45

local kFireLoopingSound = PrecacheAsset("sound/NS2.fev/marine/welder/weld")

function AntiMatterSword:OnCreate() 

    Weapon.OnCreate(self)
    
    self.welding = false
     
    self.loopingSoundEntId = Entity.invalidId
    
    if Server then
    
        self.loopingFireSound = Server.CreateEntity(SoundEffect.kMapName)
        self.loopingFireSound:SetAsset(kFireLoopingSound)
        // SoundEffect will automatically be destroyed when the parent is destroyed (the Welder).
        self.loopingFireSound:SetParent(self)
        self.loopingSoundEntId = self.loopingFireSound:GetId()
        
    end
    
end

function AntiMatterSword:OnInitialized()

    self:SetModel(AntiMatterSword.kModelName)
    
    Weapon.OnInitialized(self)
    
    self.timeWeldStarted = 0
    self.timeLastWeld = 0
    
end

function AntiMatterSword:GetViewModelName()
    return kViewModelName
end

function AntiMatterSword:GetAnimationGraphName()
    return kAnimationGraph
end

function AntiMatterSword:GetHUDSlot()
    return kAntiMatterSwordHUDSlot
end

function AntiMatterSword:OnHolster(player)

    Weapon.OnHolster(self, player)
    
    self.welding = false
    // cancel muzzle effect
    self:TriggerEffects("welder_holster")

    if Server then
        self.loopingFireSound:Stop()
    end
    
end

function AntiMatterSword:OnDraw(player, previousWeaponMapName)

    Weapon.OnDraw(self, player, previousWeaponMapName)
    
    self:SetAttachPoint(Weapon.kHumanAttachPoint)
    self.welding = true
    
    self:TriggerEffects("welder_start")
    self.timeWeldStarted = Shared.GetTime()
    
    local hitPoint = nil
    
    if self.timeLastWeld + kAntiMatterSwordFireDelay < Shared.GetTime () then
    
        hitPoint = self:PerformWeld(player)
        self.timeLastWeld = Shared.GetTime()
        
    end
    
    if not self.timeLastWeldEffect or self.timeLastWeldEffect + kAntiMatterSwordEffectRate < Shared.GetTime() then
    
        self:TriggerEffects("welder_muzzle")
        self.timeLastWeldEffect = Shared.GetTime()
        
    end
    
    if Server then
    
        if (not self.timeLastWeldHitEffect or self.timeLastWeldHitEffect + 0.15 < Shared.GetTime()) and hitPoint then
        
            local coords = Coords.GetTranslation(hitPoint)
            self:TriggerEffects("welder_hit", {effecthostcoords = coords})
            self.timeLastWeldHitEffect = Shared.GetTime()
            
        end
        
    end
        
    if Server then
        self.loopingFireSound:Start()
    end
    
end

// for marine third person model pose, "builder" fits perfectly for this.
function AntiMatterSword:OverrideWeaponName()
    return "builder"
end

function AntiMatterSword:GetDeathIconIndex()
    return kDeathMessageIcon.AntiMatterSword
end

function AntiMatterSword:OnPrimaryAttackEnd(player)

    if self.welding then
        self:TriggerEffects("welder_end")
    end
    
    self.welding = false
    
    if Server then
        self.loopingFireSound:Stop()
    end
    
end

function AntiMatterSword:GetRange()
    return kAMSRange
end

function AntiMatterSword:GetMeleeBase()
    return 2, 2
end

function AntiMatterSword:PerformWeld(player)

    local attackDirection = player:GetViewCoords().zAxis
    local success = false
    local didHit, target, endPoint, direction, surface = CheckMeleeCapsule(self, player, 0, self:GetRange(), nil, true)
    
    local trace = TraceMeleeBox(self, player:GetEyePos(), attackDirection, kAntiMatterSwordTraceExtents, self:GetRange(), PhysicsMask.Melee, EntityFilterTwo(self, player))
    
    if didHit and target and HasMixin(target, "Live") then
        
        if GetAreEnemies(player, target) then
            self:DoDamage(kAntiMatterSwordDamagePerSecond * kAntiMatterSwordFireDelay, target, endPoint, attackDirection)
            success = true     
        end
        
    end
    
    if success then    
        return endPoint
    end
    
end

function AntiMatterSword:GetShowDamageIndicator()
    return true
end

/*function AntiMatterSword:GetReplacementWeaponMapName()
    return Axe.kMapName
end*/

function AntiMatterSword:OnUpdateAnimationInput(modelMixin)

    PROFILE("AntiMatterSword:OnUpdateAnimationInput")
    
    modelMixin:SetAnimationInput("activity", ConditionalValue(self.welding, "primary", "none"))
    modelMixin:SetAnimationInput("welder", true)
    
end

function AntiMatterSword:UpdateViewModelPoseParameters(viewModel)
    viewModel:SetPoseParam("welder", 1)    
end

function AntiMatterSword:OnUpdatePoseParameters(viewModel)

    PROFILE("AntiMatterSword:OnUpdatePoseParameters")
    self:SetPoseParam("welder", 1)
    
end

Shared.LinkClassToMap("AntiMatterSword", AntiMatterSword.kMapName, networkVars)