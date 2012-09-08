// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\JetpackMarine_Server.lua
//
//    Created by:   Andreas Urwalek (a_urwa@sbox.tugraz.at
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

// don't allow purchase of jetpack or exosuit
// TODO: decide if jetpackers are allowed to change their tech to exosuit
function JetpackMarine:AttemptToBuy(techIds)

    local techId = techIds[1]
    
    if techId == kTechId.Jetpack or techId == kTechId.Exosuit then
        return false
    end
    
    return Marine.AttemptToBuy(self, techIds)
    
end