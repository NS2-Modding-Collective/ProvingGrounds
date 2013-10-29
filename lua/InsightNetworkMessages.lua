// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\InsightNetworkMessages.lua
//
// Created by: Jon Hughes (jon@jhuze.com)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

local kHealthMessage =
{
    clientIndex = "entityid",
    health = "integer",
    maxHealth = "integer",

}

function BuildHealthMessage(player)

    local t = {}

    t.clientIndex       = player:GetClientIndex()
    t.health            = player:GetHealth()
    t.maxHealth         = player:GetMaxHealth()

    return t

end

Shared.RegisterNetworkMessage( "Health", kHealthMessage )

-- empty network message for game reset
Shared.RegisterNetworkMessage( "Reset" )