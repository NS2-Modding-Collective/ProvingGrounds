// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\Weapons\Alien\SwipeBlink.lua
//
//    Created by:   Charlie Cleveland (charlie@unknownworlds.com) and
//                  Max McGuire (max@unknownworlds.com)
//
// Swipe/blink - Left-click to attack, right click to show ghost. When ghost is showing,
// right click again to go there. Left-click to cancel. Attacking many times in a row will create
// a cool visual "chain" of attacks, showing the more flavorful animations in sequence.
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/Weapons/Alien/Blink.lua")

class 'SwipeBlink' (Blink)
SwipeBlink.kMapName = "swipe"

local networkVars =
{
    lastSwipedEntityId = "entityid",
    attacking = "boolean"
}

// Make sure to keep damage vs. structures less then Skulk
SwipeBlink.kSwipeEnergyCost = kSwipeEnergyCost
SwipeBlink.kDamage = kSwipeDamage
SwipeBlink.kRange = 1.6

local kAnimationGraph = PrecacheAsset("models/alien/fade/fade_view.animation_graph")

function SwipeBlink:OnCreate()

    Blink.OnCreate(self)
    
    self.lastSwipedEntityId = Entity.invalidId
    self.attacking = false

end

function SwipeBlink:GetAnimationGraphName()
    return kAnimationGraph
end

function SwipeBlink:GetEnergyCost(player)
    return SwipeBlink.kSwipeEnergyCost
end

function SwipeBlink:GetHUDSlot()
    return 1
end

function SwipeBlink:GetIconOffsetY(secondary)
    return kAbilityOffset.SwipeBlink
end

function SwipeBlink:GetPrimaryAttackRequiresPress()
    return false
end

function SwipeBlink:GetDeathIconIndex()
    return kDeathMessageIcon.SwipeBlink
end

function SwipeBlink:GetBlinkAllowed()
    return true
end

function SwipeBlink:OnPrimaryAttack(player)

    if not self:GetIsBlinking() and player:GetEnergy() >= self:GetEnergyCost() then
        self:PerformPrimaryAttack(player)
    else
        self.attacking = false
    end
    
end

// Claw attack, or blink if we're in that mode
function SwipeBlink:PerformPrimaryAttack(player)

    self.attacking = true
    
    // Check if the swipe may hit an entity. Don't actually do any damage yet.
    local didHit, trace = CheckMeleeCapsule(self, player, SwipeBlink.kDamage, SwipeBlink.kRange)
    self.lastSwipedEntityId = Entity.invalidId
    if didHit and trace and trace.entity then
        self.lastSwipedEntityId = trace.entity:GetId()
    end
    
    return true
    
end

function SwipeBlink:OnPrimaryAttackEnd()
    
    Blink.OnPrimaryAttackEnd(self)
    
    self.attacking = false
    
end

function SwipeBlink:OnHolster(player)

    Blink.OnHolster(self, player)
    
    self.attacking = false
    
end

function SwipeBlink:OnTag(tagName)

    PROFILE("SwipeBlink:OnTag")

    if self.attacking and tagName == "start" then
    
        local player = self:GetParent()
        if player then
            player:DeductAbilityEnergy(self:GetEnergyCost())
        end
        
        self:TriggerEffects("swipe_attack")
        
    end
    
    if tagName == "hit" then
        self:PerformMeleeAttack()
    end

end

function SwipeBlink:PerformMeleeAttack()

    local player = self:GetParent()
    if player then
        local didHit, hitObject, endPoint, surface = AttackMeleeCapsule(self, player, SwipeBlink.kDamage, SwipeBlink.kRange)
    end
    
end

function SwipeBlink:GetEffectParams(tableParams)

    Blink.GetEffectParams(self, tableParams)
    
    // There is a special case for biting structures.
    if self.lastSwipedEntityId ~= Entity.invalidId then
    
        local lastSwipedEntity = Shared.GetEntity(self.lastSwipedEntityId)
        if lastSwipedEntity and GetReceivesStructuralDamage(lastSwipedEntity) then
            tableParams[kEffectFilterHitSurface] = "structure"
        end
        
    end
    
end

function SwipeBlink:OnUpdateAnimationInput(modelMixin)

    PROFILE("SwipeBlink:OnUpdateAnimationInput")

    Blink.OnUpdateAnimationInput(self, modelMixin)
    
    modelMixin:SetAnimationInput("ability", "swipe")
    
    local activityString = (self.attacking and "primary") or "none"
    modelMixin:SetAnimationInput("activity", activityString)
    
end

Shared.LinkClassToMap("SwipeBlink", SwipeBlink.kMapName, networkVars)