// ======= Copyright (c) 2003-2012, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\TechTreeButtons.lua
//
//    Created by:   Charlie Cleveland (charlie@unknownworlds.com)
//
// Hard-coded data which maps tech tree constants to indices into a texture. Used to display
// icons in the commander build menu and alien buy menu.
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

// These are the icons that appear next to alerts or as hotkey icons.
// Icon size should be 20x20. Also used for the alien buy menu.

// Init icon offsets.
local kTechIdToMaterialOffset = {}

kTechIdToMaterialOffset[kTechId.Avatar] = 24
kTechIdToMaterialOffset[kTechId.GreenAvatar] = 24
kTechIdToMaterialOffset[kTechId.PurpleAvatar] = 24

kTechIdToMaterialOffset[kTechId.Shotgun] = 85
kTechIdToMaterialOffset[kTechId.Flamethrower] = 86
kTechIdToMaterialOffset[kTechId.GrenadeLauncher] = 87
kTechIdToMaterialOffset[kTechId.AmmoPack] = 91
kTechIdToMaterialOffset[kTechId.MedPack] = 92
kTechIdToMaterialOffset[kTechId.CatPack] = 164

function GetMaterialXYOffset(techId)

    local index = nil
    
    local columns = 12
    index = kTechIdToMaterialOffset[techId]
    
    if index == nil then
        Print("Warning: %s did not define kTechIdToMaterialOffset ", EnumToString(kTechId, techId) )
    end

    if(index ~= nil) then
    
        local x = index % columns
        local y = math.floor(index / columns)
        return x, y
        
    end
    
    return nil, nil
    
end

function GetPixelCoordsForIcon(ent, forMarine)
    
    if ent and HasMixin(ent, "Tech") then
    
        local techId = ent:GetTechId()        
        if techId ~= kTechId.None then
            
            local xOffset, yOffset = GetMaterialXYOffset(techId, forMarine)
            return {xOffset, yOffset}
            
        end
                    
    end
    
    return nil
    
end
