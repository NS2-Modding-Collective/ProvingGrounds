// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======    
//    
// lua\StunMixin.lua    
//    
//    Created by:   Brian Cronin (brianc@unknownworlds.com)    
//    
// ========= For more information, visit us at http://www.unknownworlds.com =====================    

Script.Load("lua/FunctionContracts.lua")

StunMixin = CreateMixin( StunMixin )
StunMixin.type = "Stun"

StunMixin.optionalCallbacks =
{
    OnStun = "Called when a knockback is triggered in OnProcessMove/OnUpdate.",
    OnStunEnd = "Called when a knockback is over in OnProcessMove/OnUpdate.",
    GetIsKnockbackAllowed = "Return true/false to limit knockbacks / stuns only to certain situations."
}

StunMixin.networkVars =
{
    stunTime = "private interpolated float",
    onGroundStunTime = "private interpolated float",
    knockbackVelocity = "private vector",
    triggerStunKnockBack = "private boolean",
    checkImpactOnGround = "private boolean"
}

function StunMixin:__initmixin()

    self.stunTime = 0
    self.onGroundStunTime = 0
    self.knockbackVelocity = Vector(0,0,0)
    self.triggerStunKnockBack = false
    self.checkImpactOnGround = false
    
end

function StunMixin:SetKnockback(duration, onGroundDuration, forceVector, minYVel, maxVel)
    
    local allowed = true
    
    if self.GetIsKnockbackAllowed then
        allowed = self:GetIsKnockbackAllowed()
    end

    if allowed then
    
        self.stunTime = Shared.GetTime() + duration
        self.onGroundStunTime = onGroundDuration
        self.triggerStunKnockBack = true
        forceVector = forceVector / self:GetMass()
        
        if maxVel then
            forceVector.x = Clamp(forceVector.x, -maxVel, maxVel)
            forceVector.y = Clamp(forceVector.y, -maxVel, maxVel)
            forceVector.z = Clamp(forceVector.z, -maxVel, maxVel)
        end
        
        if forceVector.y < minYVel then
            forceVector.y = minYVel
        end
        
        self.knockbackVelocity = forceVector
        
    end
    
end

function StunMixin:GetIsStunned()
    return Shared.GetTime() < self.stunTime
end
AddFunctionContract(StunMixin.GetIsStunned, { Arguments = { "Entity" }, Returns = { "boolean" } })

function StunMixin:OnSetVelocityOverride(velocity)

    // Velocity is dampened when stunned. Downward velocity is not dampened (gravity).
    if self:GetIsStunned() and not self:GetIsCloseToGround(0.2) then
        local accel = Vector(velocity.x * -0.1, 0, velocity.z * -0.1)
        if velocity.y > 0 then
            accel.y = velocity.y * -0.1
        end
        return self:GetVelocity() + accel
    end
    return velocity
    
end
AddFunctionContract(StunMixin.OnSetVelocityOverride, { Arguments = { "Entity", "Vector" }, Returns = { { "Vector", "nil" } } })

local function SharedUpdate(self)

    if self:GetIsStunned() then
    
        if self.triggerStunKnockBack then
            
            // Set origin to trigger onGroundNeedsUpdate
            self:SetOrigin(self:GetOrigin() + Vector(0, 0.21, 0))
            self:SetVelocity(self.knockbackVelocity)
            
            self.triggerStunKnockBack = false
            self.checkImpactOnGround = true
            self.knockbackVelocity = Vector(0,0,0)
            
            if self.OnStun then
                self:OnStun()
            end
    
        elseif self:GetIsCloseToGround(0.15) and self.checkImpactOnGround then

            self:SetVelocity(Vector(0, 0, 0))
            self.checkImpactOnGround = false
            
            if self.OnHitGroundStunned then
                self:OnHitGroundStunned()
            end
            
            // prolong the stun time if an additional on ground time was passed
            if self.onGroundStunTime ~= 0 then
                self.stunTime = Shared.GetTime() + self.onGroundStunTime
            end
            self.onGroundStunTime = 0
    
        end
            
    elseif self.stunTime ~= 0 then
    
        if self.OnStunEnd then
            self:OnStunEnd()
        end
        
        self.stunTime = 0
    
    end

end

function StunMixin:GetRemainingStunTime()
    return self.stunTime - Shared.GetTime()
end

function StunMixin:OnProcessMove(input)
    SharedUpdate(self)
end

// This is only needed on the Server because the local client
// is predicted with OnProcessMove.
if Server then

    function StunMixin:OnUpdate(deltaTime)
        SharedUpdate(self) 
    end
    
end