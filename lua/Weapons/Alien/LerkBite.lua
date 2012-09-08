// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\Weapons\Alien\LerkBite.lua
//
//    Created by:   Andreas Urwalek (andi@unknownworlds.com)
// 
// Bite is main attack, spikes is secondary.
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/Weapons/Alien/Ability.lua")
Script.Load("lua/Weapons/Alien/SpikesMixin.lua")
Script.Load("lua/Weapons/ClientWeaponEffectsMixin.lua")

Shared.PrecacheSurfaceShader("materials/effects/mesh_effects/view_blood.surface_shader")

// kRange is now the range from eye to edge of attack range, ie its independent of the size of
// the melee box, so for the skulk, it needs to increase to 1.2 to say at its previous range.
// previously this value had an offset, which caused targets to be behind the melee attack (too close to the target and you missed)
local kRange = 1.6

local kStructureHitEffect = PrecacheAsset("cinematics/alien/lerk/bite_view_structure.cinematic")
local kMarineHitEffect = PrecacheAsset("cinematics/alien/lerk/bite_view_marine.cinematic")

class 'LerkBite' (Ability)

LerkBite.kMapName = "lerkbite"

local kAnimationGraph = PrecacheAsset("models/alien/lerk/lerk_view.animation_graph")
local attackEffectMaterial = nil

if Client then
    attackEffectMaterial = Client.CreateRenderMaterial()
    attackEffectMaterial:SetMaterial("materials/effects/mesh_effects/view_blood.material")
end

local networkVars =
{
    lastBittenEntityId = "entityid",
    firingPrimary = "boolean"
}

AddMixinNetworkVars(SpikesMixin, networkVars)

function LerkBite:OnCreate()

    Ability.OnCreate(self)
    
    InitMixin(self, SpikesMixin)
    
    self.lastBittenEntityId = Entity.invalidId
    self.firingPrimary = false
    
    if Client then
        InitMixin(self, ClientWeaponEffectsMixin)
    end

end

function LerkBite:GetAnimationGraphName()
    return kAnimationGraph
end

function LerkBite:GetEnergyCost(player)
    return kLerkBiteEnergyCost
end

function LerkBite:GetHUDSlot()
    return 1
end

function LerkBite:GetIconOffsetY(secondary)
    return kAbilityOffset.PoisonBite
end

function LerkBite:GetRange()
    return kRange
end

function LerkBite:GetDeathIconIndex()

    if self.firingPrimary then
        return kDeathMessageIcon.Bite
    else
        return kDeathMessageIcon.Spikes
    end
    
end

function LerkBite:OnPrimaryAttack(player)

    if player:GetEnergy() >= self:GetEnergyCost() then
        self.firingPrimary = true
    else
        self.firingPrimary = false
    end
    
end

function LerkBite:OnPrimaryAttackEnd()
    
    Ability.OnPrimaryAttackEnd(self)
    
    self.firingPrimary = false
    
end

function LerkBite:GetEffectParams(tableParams)

    Ability.GetEffectParams(self, tableParams)
    
    // There is a special case for biting structures.
    if self.lastBittenEntityId ~= Entity.invalidId then
    
        local lastBittenEntity = Shared.GetEntity(self.lastBittenEntityId)
        if lastBittenEntity and GetReceivesStructuralDamage(lastBittenEntity) then
            tableParams[kEffectFilterHitSurface] = "structure"
        end
        
    end
    
end

function LerkBite:GetMeleeBase()
    return 1, 0.6
end

function LerkBite:GetMeleeOffset()
    return 0.0
end

function LerkBite:OnTag(tagName)

    PROFILE("LerkBite:OnTag")

    if tagName == "hit" then
    
        local player = self:GetParent()
        
        if player then  
        
            player:DeductAbilityEnergy(self:GetEnergyCost())            
            self:TriggerEffects("lerkbite_attack")
        
            local didHit, target = AttackMeleeCapsule(self, player, kLerkBiteDamage, kRange)
            
            if didHit and target then
            
                if Server then
                    if target:isa("Marine") and target:GetCanTakeDamage() then
                        target:SetPoisoned(player)
                    end
                elseif Client then
                    self:TriggerFirstPersonHitEffects(player, target)
                end
            
            end
            
            if target and HasMixin(target, "Live") and not target:GetIsAlive() then
                self:TriggerEffects("bite_kill")
            end
            
        end
        
    end
    
end

if Client then

    function LerkBite:TriggerFirstPersonHitEffects(player, target)

        if player == Client.GetLocalPlayer() and target then
            
            local cinematicName = kStructureHitEffect
            if target:isa("Marine") then
                self:CreateBloodEffect(player)        
                cinematicName = kMarineHitEffect
            end
        
            local cinematic = Client.CreateCinematic(RenderScene.Zone_ViewModel)
            cinematic:SetCinematic(cinematicName)
        
        
        end

    end

    function LerkBite:CreateBloodEffect(player)
    
        if not Shared.GetIsRunningPrediction() then

            local model = player:GetViewModelEntity():GetRenderModel()

            model:RemoveMaterial(attackEffectMaterial)
            model:AddMaterial(attackEffectMaterial)
            attackEffectMaterial:SetParameter("attackTime", Shared.GetTime())

        end
        
    end

end

function LerkBite:OnUpdateAnimationInput(modelMixin)

    PROFILE("Spikes:OnUpdateAnimationInput")

    if not self:GetIsSecondaryBlocking() then
        
        local activityString = "none"
        if self.firingPrimary then
            modelMixin:SetAnimationInput("ability", "bite")
            activityString = "primary"
        end        
        
        modelMixin:SetAnimationInput("activity", activityString)
    
    end
    
end

Shared.LinkClassToMap("LerkBite", LerkBite.kMapName, networkVars)