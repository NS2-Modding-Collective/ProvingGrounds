// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\InsightNetworkMessages_Client.lua
//
// Created by: Jon Hughes (jon@jhuze.com)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

function OnCommandHealth(healthTable)

    Insight_SetPlayerHealth(healthTable.clientIndex, healthTable.health, healthTable.maxHealth)

end

Client.HookNetworkMessage("Health", OnCommandHealth)

function OnCommandReset()

    DeathMsgUI_ResetStats()

end

Client.HookNetworkMessage("Reset", OnCommandReset)