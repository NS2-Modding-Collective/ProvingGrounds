// ======= Copyright (c) 2012, Unknown Worlds Entertainment, Inc. All rights reserved. ============
//    
// lua\TeamMessenger.lua    
//    
//    Created by:   Brian Cronin (brianc@unknownworlds.com)    
//    
// ========= For more information, visit us at http://www.unknownworlds.com =====================

kTeamMessageTypes = enum({ 'GameStarted', 'TeamsUnbalanced',
                           'TeamsBalanced' })

local kTeamMessages = { }

kTeamMessages[kTeamMessageTypes.GameStarted] = { text = { [kGreenTeamType] = "MARINE_TEAM_GAME_STARTED", [kPurpleTeamType] = "ALIEN_TEAM_GAME_STARTED" } }

// This function will generate the string to display based on a location Id.
local locationStringGen = function(locationId, messageString) return string.format(Locale.ResolveString(messageString), Shared.GetString(locationId)) end

// Thos function will generate the string to display based on a research Id.
local researchStringGen = function(researchId, messageString) return string.format(Locale.ResolveString(messageString), GetDisplayNameForTechId(researchId)) end

kTeamMessages[kTeamMessageTypes.TeamsUnbalanced] = { text = { [kGreenTeamType] = "TEAMS_UNBALANCED", [kPurpleTeamType] = "TEAMS_UNBALANCED" } }

kTeamMessages[kTeamMessageTypes.TeamsBalanced] = { text = { [kGreenTeamType] = "TEAMS_BALANCED", [kPurpleTeamType] = "TEAMS_BALANCED" } }

// Silly name but it fits the convention.
local kTeamMessageMessage =
{
    type = "enum kTeamMessageTypes",
    data = "integer"
}

Shared.RegisterNetworkMessage("TeamMessage", kTeamMessageMessage)

if Server then

    /**
     * Sends every team the passed in message for display.
     */
    function SendGlobalMessage(messageType, optionalData)
    
        if GetGamerules():GetGameStarted() then
        
            local teams = GetGamerules():GetTeams()
            for t = 1, #teams do
                SendTeamMessage(teams[t], messageType, optionalData)
            end
            
        end
        
    end
    
    /**
     * Sends every player on the passed in team the passed in message for display.
     */
    function SendTeamMessage(team, messageType, optionalData)
    
        local function SendToPlayer(player)
            Server.SendNetworkMessage(player, "TeamMessage", { type = messageType, data = optionalData or 0 }, true)
        end
        
        team:ForEachPlayer(SendToPlayer)
        
    end
    
    /**
     * Sends the passed in message to the players passed in.
     */
    function SendPlayersMessage(playerList, messageType, optionalData)
    
        if GetGamerules():GetGameStarted() then
        
            for p = 1, #playerList do
                Server.SendNetworkMessage(playerList[p], "TeamMessage", { type = messageType, data = optionalData or 0 }, true)
            end
            
        end
        
    end    
end

if Client then

    local function SetTeamMessage(messageType, messageData)
    
        local player = Client.GetLocalPlayer()
        if player and HasMixin(player, "TeamMessage") then
        
            local displayText = kTeamMessages[messageType].text[player:GetTeamType()]
            
            if displayText then
            
                if type(displayText) == "function" then
                    displayText = displayText(messageData)
                else
                    displayText = Locale.ResolveString(displayText)
                end
                
                assert(type(displayText) == "string")
                player:SetTeamMessage(string.upper(displayText))
                
            end
            
        end
        
    end
    
    function OnCommandTeamMessage(message)
        SetTeamMessage(message.type, message.data)
    end
    
    Client.HookNetworkMessage("TeamMessage", OnCommandTeamMessage)
    
end