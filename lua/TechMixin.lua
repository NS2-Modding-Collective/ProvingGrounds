// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\TechMixin.lua
//
//    Created by:   Brian Cronin (brianc@unknownworlds.com) and
//                  Andreas Urwalek (andi@unknownworlds.com)
//
//    Updates tech availability.
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================
Script.Load("lua/TechTreeConstants.lua")
Script.Load("lua/MixinUtility.lua")

TechMixin = CreateMixin(TechMixin)
TechMixin.type = "Tech"

TechMixin.optionalCallbacks =
{
    OnTechIdSet = "Will be called after the tech id is set inside SetTechId."
}

TechMixin.expectedCallbacks = 
{
    GetMapName = "Map name for looking up tech id"
}

TechMixin.networkVars =
{
    techId = string.format("integer (0 to %d)", kTechIdMax)
}

function TechMixin:__initmixin()
    self.techId = LookupTechId(self:GetMapName(), kTechDataMapName, kTechId.None)
end

function TechMixin:SetTechId(techId)

    if Server then

        if techId ~= self.techId then
        
            self.techId = techId
            
        end
        
    end

end

// Return techId that is the technology this entity represents. This is used to choose an icon to display to represent
// this entity and also to lookup max health, spawn heights, etc.
function TechMixin:GetTechId()
    return self.techId
end