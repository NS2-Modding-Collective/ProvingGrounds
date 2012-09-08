// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======    
//    
// lua\DigestMixin.lua    
//    
//    Created by:   Andreas Urwalek (andi@unknownworlds.com)
//
//    Allow diggestion of structures. Use server side only.
//    
// ========= For more information, visit us at http://www.unknownworlds.com =====================    

Script.Load("lua/FunctionContracts.lua")

DigestMixin = CreateMixin( DigestMixin )
DigestMixin.type = "Diggestable"

DigestMixin.optionalCallbacks =
{
    GetCanDiggest = "player passed as param."
}

DigestMixin.networkVars =
{
}

function DigestMixin:__initmixin()
    // entity will be destroyed at 1.0
    assert(Server)
    self.diggestAmount = 0
end

local function Digest(self, elapsedTime)

    local diggestDuration = 2
    if self.GetDiggestDuration then
        diggestDuration = self:GetDiggestDuration()
    end    

    // TODO: elapsedTime seems to be wrong, should get tracked down
    self.diggestAmount = self.diggestAmount + elapsedTime * 10
    
    if self.diggestAmount >= diggestDuration then
        self:TriggerEffects("diggest", {effecthostcoords = self:GetCoords()} )
        self.consumed = true
        self:Kill()
    end
    
end

function DigestMixin:OnUse(player, elapsedTime, useAttachPoint, usePoint, useSuccessTable)

    local canDigest = false
    if self.GetCanDiggest then
        canDigest = self:GetCanDiggest(player)
    else
        canDigest = player == self:GetOwner() and player:isa("Gorge") and (not HasMixin(self, "Live") or self:GetIsAlive())
    end
    
    if canDigest then
        Digest(self, elapsedTime)
    end
    
    useSuccessTable.useSuccess = useSuccessTable.useSuccess and canDigest

end









