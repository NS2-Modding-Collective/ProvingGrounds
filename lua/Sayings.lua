// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\Sayings.lua
//
//    Created by:   Charlie Cleveland (charlie@unknownworlds.com) and
//                  Max McGuire (max@unknownworlds.com)
//
// Sayings menus and sounds.
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

marineRequestSayingsText = {"1. Acknowledged", "2. Need medpack", "3. Need ammo", "4. Need orders"}
marineRequestSayingsSounds = {"sound/NS2.fev/marine/voiceovers/ack", "sound/NS2.fev/marine/voiceovers/medpack", "sound/NS2.fev/marine/voiceovers/ammo", "sound/NS2.fev/marine/voiceovers/need_orders" }
marineRequestActions = {kTechId.MarineAlertAcknowledge, kTechId.MarineAlertNeedMedpack, kTechId.MarineAlertNeedAmmo, kTechId.MarineAlertNeedOrder}

marineGroupSayingsText  = {"1. Follow me", "2. Let's move", "3. Covering you", "4. Hostiles", "5. Taunt"}
marineGroupSayingsSounds = {"sound/NS2.fev/marine/voiceovers/follow_me", "sound/NS2.fev/marine/voiceovers/lets_move", "sound/NS2.fev/marine/voiceovers/covering", "sound/NS2.fev/marine/voiceovers/hostiles", "sound/NS2.fev/marine/voiceovers/taunt"}
marineGroupRequestActions = {kTechId.None, kTechId.None, kTechId.None, kTechId.MarineAlertHostiles, kTechId.None}

// Precache all sayings
function precacheSayingsTable(sayings)
    for index, saying in ipairs(sayings) do
        Shared.PrecacheSound(saying)
    end
end

precacheSayingsTable(marineRequestSayingsSounds)
precacheSayingsTable(marineGroupSayingsSounds)
