// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======    
//    
// lua\UnitStatusMixin.lua    
//    
//    Created by:   Andreas Urwalek (andi@unknownworlds.com)
//    
// ========= For more information, visit us at http://www.unknownworlds.com =====================    

kUnitStatus = enum({
    'None',
    'Damaged'
})

UnitStatusMixin = CreateMixin(UnitStatusMixin)
UnitStatusMixin.type = "UnitStatus"

function UnitStatusMixin:__initmixin()
    self.unitStatus = kUnitStatus.None
end

function UnitStatusMixin:GetShowUnitStatusFor(forEntity)

    local showUnitStatus = true
    
    if self.GetShowUnitStatusForOverride then
        showUnitStatus = self:GetShowUnitStatusForOverride(forEntity)
    end
    
    if HasMixin(self, "Model") and showUnitStatus then
        showUnitStatus = self:GetWasRenderedLastFrame()
    end
    
    if HasMixin(self, "Live") and showUnitStatus then
        showUnitStatus = self:GetIsAlive()
    end
    
    return showUnitStatus
    
end

function UnitStatusMixin:GetUnitStatus(forEntity)

    local unitStatus = kUnitStatus.None

    // don't show status of opposing team
    if GetAreFriends(forEntity, self) then

        if HasMixin(self, "Live") and self:GetHealthScalar() < 1 and self:GetIsAlive() and (not forEntity.GetCanSeeDamagedIcon or forEntity:GetCanSeeDamagedIcon(self)) then
            
            if forEntity:isa("Avatar") and not self:isa("Avatar") then
                unitStatus = kUnitStatus.Damaged
            end        

        end
    
    end

    return unitStatus

end

function UnitStatusMixin:GetUnitStatusFraction(forEntity)
   
    return 0

end

function UnitStatusMixin:GetUnitHint(forEntity)

    if HasMixin(self, "Tech") then
    
        local hintString = LookupTechData(self:GetTechId(), kTechDataHint, "")

        if self.OverrideHintString then
            hintString = self:OverrideHintString(hintString, forEntity)
        end
        
        if hintString ~= "" then            
            return Locale.ResolveString(hintString)
        end
        
    end
    
    return ""

end

function UnitStatusMixin:GetUnitName(forEntity)
    
    if HasMixin(self, "Tech") then
    
        if self.GetUnitNameOverride then
            return self:GetUnitNameOverride(forEntity)
        end
           
        return self:GetName(forEntity)            
            
    end

    return ""

end

function UnitStatusMixin:GetActionName(forEntity)
   
    return ""

end
