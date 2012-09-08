// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\ClientWeaponEffectsMixin.lua
//
//    Created by:   Andreas Urwalek (andi@unknownworlds.com)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

ClientWeaponEffectsMixin = CreateMixin( ClientWeaponEffectsMixin )
ClientWeaponEffectsMixin.type = "ClientWeaponEffects"

ClientWeaponEffectsMixin.optionalCallbacks =
{
    GetTriggerPrimaryEffects = "Control triggering of effects.",
    GetTriggerSecondaryEffects = "Control triggering of effects.",
    GetPrimaryEffectRate = "Primary attacking effect rate.",
    GetSecondaryEffectRate = "Secondary attacking effect rate."
}

ClientWeaponEffectsMixin.expectedCallbacks =
{
    GetPrimaryAttacking = "Required to know if the weapon is being fired.",
    GetSecondaryAttacking = "Required to know if the weapon is being fired."
}

ClientWeaponEffectsMixin.networkVars =
{
}

function ClientWeaponEffectsMixin:__initmixin()

    assert(Client)
    
    self.clientPrimaryAttacking = self:GetPrimaryAttacking()
    self.clientSecondaryAttacking = self:GetSecondaryAttacking()
    self.timeLastPrimaryEffectUpdate = Shared.GetTime()
    self.timeLastSecondaryEffectUpdate = Shared.GetTime()
    
end

function ClientWeaponEffectsMixin:OnClientPrimaryAttackStart()
    TriggerMuzzleCinematic(self, self.firstPersonAttackStart, self.thirdPersonAttackStart, self.muzzleAttachPoint)
end

function ClientWeaponEffectsMixin:OnClientPrimaryAttacking()
    TriggerMuzzleCinematic(self, self.firstPersonAttacking, self.firstPersonAttacking, self.muzzleAttachPoint)
end

function ClientWeaponEffectsMixin:OnClientPrimaryAttackEnd()
end

function ClientWeaponEffectsMixin:OnClientSecondaryAttackStart()
end

function ClientWeaponEffectsMixin:OnClientSecondaryAttacking()
end

function ClientWeaponEffectsMixin:OnClientSecondaryAttackEnd()
end

local function GetTriggerPrimaryEffects(self)

    local triggerEffects = self:GetIsActive()
    if self.GetTriggerPrimaryEffects then
        triggerEffects = triggerEffects and self:GetTriggerPrimaryEffects()
    end   

    return triggerEffects 

end

local function GetTriggerSecondaryEffects(self)

    local triggerEffects = self:GetIsActive()
    if self.GetTriggerSecondaryEffects then
        triggerEffects = triggerEffects and self:GetTriggerSecondaryEffects()
    end   

    return triggerEffects 

end

local function GetPrimaryEffectRate(self)
    if self.GetPrimaryEffectRate then
        return self:GetPrimaryEffectRate()
    end
    return 0.1
end

local function GetSecondaryEffectRate(self)
    if self.GetSecondaryEffectRate then
        return self:GetSecondaryEffectRate()
    end
    return 0.1
end

function ClientWeaponEffectsMixin:UpdateAttackEffects(deltaTime)

    local primaryAttacking = self:GetPrimaryAttacking()
    local secondaryAttacking = self:GetSecondaryAttacking()
    
    local primaryAllowed = GetTriggerPrimaryEffects(self)
    local secondaryAllowed = GetTriggerSecondaryEffects(self)

    if self.clientPrimaryAttacking ~= primaryAttacking then
    
        self.clientPrimaryAttacking = primaryAttacking
        
        if primaryAttacking and primaryAllowed then
            self:OnClientPrimaryAttackStart()
        else
            self:OnClientPrimaryAttackEnd()
        end
        
    end
    
    if self.clientSecondaryAttacking ~= secondaryAttacking then
    
        self.clientSecondaryAttacking = secondaryAttacking
        
        if secondaryAttacking and secondaryAllowed then
            self:OnClientSecondaryAttackStart()
        else
            self:OnClientSecondaryAttackEnd()
        end
        
    end
    
    if primaryAllowed and self.clientPrimaryAttacking and self.timeLastPrimaryEffectUpdate + GetPrimaryEffectRate(self) < Shared.GetTime() then
    
        self.timeLastPrimaryEffectUpdate = Shared.GetTime()
        self:OnClientPrimaryAttacking()
        
    end
    
    if secondaryAllowed and self.clientSecondaryAttacking and self.timeLastSecondaryEffectUpdate + GetSecondaryEffectRate(self) < Shared.GetTime() then
    
        self.timeLastSecondaryEffectUpdate = Shared.GetTime()
        self:OnClientSecondaryAttacking()
        
    end

end

function ClientWeaponEffectsMixin:SetFirstPersonAttackStartEffect(effectName)
    self.firstPersonAttackStart = effectName
end

function ClientWeaponEffectsMixin:SetThirdPersonAttackStartEffect(effectName)
    self.thirdPersonAttackStart = effectName
end

function ClientWeaponEffectsMixin:SetFirstPersonAttackingEffect(effectName)
    self.firstPersonAttacking = effectName
end

function ClientWeaponEffectsMixin:SetThirdPersonAttackingEffect(effectName)
    self.firstPersonAttacking = effectName
end

function ClientWeaponEffectsMixin:SetMuzzleAttachPoint(attachPointName)
    self.muzzleAttachPoint = attachPointName
end

if Client then

    // need to manually update them, weapons can disabled / enable their updates
    local function OnUpdateWeapons(deltaTime)
    
        PROFILE("ClientWeaponEffectsMixin:OnUpdateWeapons")

        for _, weapon in ientitylist( Shared.GetEntitiesWithTag("ClientWeaponEffects") ) do    
            weapon:UpdateAttackEffects(deltaTime)    
        end
        
    end

    Event.Hook("UpdateClient", OnUpdateWeapons)

end