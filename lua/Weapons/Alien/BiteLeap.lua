// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\Weapons\Alien\BiteLeap.lua
//
//    Created by:   Charlie Cleveland (charlie@unknownworlds.com) and
//                  Max McGuire (max@unknownworlds.com)
// 
// Bite is main attack, leap is secondary.
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/Weapons/Alien/Ability.lua")
Script.Load("lua/Weapons/Alien/LeapMixin.lua")

Shared.PrecacheSurfaceShader("materials/effects/mesh_effects/view_blood.surface_shader")

// kRange is now the range from eye to edge of attack range, ie its independent of the size of
// the melee box, so for the skulk, it needs to increase to 1.2 to say at its previous range.
// previously this value had an offset, which caused targets to be behind the melee attack (too close to the target and you missed)
local kRange = 1.5

local kStructureHitEffect = PrecacheAsset("cinematics/alien/skulk/bite_view_structure.cinematic")
local kMarineHitEffect = PrecacheAsset("cinematics/alien/skulk/bite_view_marine.cinematic")

class 'BiteLeap' (Ability)

BiteLeap.kMapName = "bite"

local kAnimationGraph = PrecacheAsset("models/alien/skulk/skulk_view.animation_graph")
local attackEffectMaterial = nil

if Client then

    attackEffectMaterial = Client.CreateRenderMaterial()
    attackEffectMaterial:SetMaterial("materials/effects/mesh_effects/view_blood.material")
    
end

local networkVars =
{
    lastBittenEntityId = "entityid"
}

function BiteLeap:OnCreate()

    Ability.OnCreate(self)
    
    InitMixin(self, LeapMixin)
    
    self.lastBittenEntityId = Entity.invalidId
    self.primaryAttacking = false

end

function BiteLeap:GetAnimationGraphName()
    return kAnimationGraph
end

function BiteLeap:GetEnergyCost(player)
    return kBiteEnergyCost
end

function BiteLeap:GetHUDSlot()
    return 1
end

function BiteLeap:GetIconOffsetY(secondary)
    return kAbilityOffset.Bite
end

function BiteLeap:GetRange()
    return kRange
end

function BiteLeap:GetDeathIconIndex()
    return kDeathMessageIcon.Bite
end

function BiteLeap:OnPrimaryAttack(player)

    if player:GetEnergy() >= self:GetEnergyCost() then
        self.primaryAttacking = true
    else
        self.primaryAttacking = false
    end
    
end

function BiteLeap:OnPrimaryAttackEnd()
    
    Ability.OnPrimaryAttackEnd(self)
    
    self.primaryAttacking = false
    
end

function BiteLeap:GetEffectParams(tableParams)

    Ability.GetEffectParams(self, tableParams)
    
    // There is a special case for biting structures.
    if self.lastBittenEntityId ~= Entity.invalidId then
    
        local lastBittenEntity = Shared.GetEntity(self.lastBittenEntityId)
        if lastBittenEntity and GetReceivesStructuralDamage(lastBittenEntity) then
            tableParams[kEffectFilterHitSurface] = "structure"
        end
        
    end
    
end

function BiteLeap:GetMeleeBase()
    return 0.5, 1
end

function BiteLeap:GetMeleeOffset()
    return 0.0
end

function BiteLeap:OnTag(tagName)

    PROFILE("BiteLeap:OnTag")

    if tagName == "hit" then
    
        local player = self:GetParent()
        
        if player then  
        
            local didHit, target, endPoint = AttackMeleeCapsule(self, player, kBiteDamage, kRange, nil, false)
            
            if Client and didHit then
                self:TriggerFirstPersonHitEffects(player, target)  
            end
            
            if target and HasMixin(target, "Live") and not target:GetIsAlive() then
                self:TriggerEffects("bite_kill")
            elseif Server and target and target.TriggerEffects and GetReceivesStructuralDamage(target) then
                target:TriggerEffects("bite_structure", {effecthostcoords = Coords.GetTranslation(endPoint)})
            end
            
        end
        
    end
    
    if self.primaryAttacking and tagName == "start" then
    
        local player = self:GetParent()
        if player then
            player:DeductAbilityEnergy(self:GetEnergyCost())
        end
        
        self:TriggerEffects("bite_attack")
        
    end
    
end

if Client then

    function BiteLeap:TriggerFirstPersonHitEffects(player, target)

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

    function BiteLeap:CreateBloodEffect(player)
    
        if not Shared.GetIsRunningPrediction() then

            local model = player:GetViewModelEntity():GetRenderModel()

            model:RemoveMaterial(attackEffectMaterial)
            model:AddMaterial(attackEffectMaterial)
            attackEffectMaterial:SetParameter("attackTime", Shared.GetTime())

        end
        
    end
    
    function BiteLeap:OnClientPrimaryAttackStart()
    end

end

function BiteLeap:OnUpdateAnimationInput(modelMixin)

    PROFILE("BiteLeap:OnUpdateAnimationInput")

    modelMixin:SetAnimationInput("ability", "bite")
    
    local activityString = (self.primaryAttacking and "primary") or "none"
    modelMixin:SetAnimationInput("activity", activityString)
    
end

Shared.LinkClassToMap("BiteLeap", BiteLeap.kMapName, networkVars)