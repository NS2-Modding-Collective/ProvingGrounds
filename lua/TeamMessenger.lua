// ======= Copyright (c) 2012, Unknown Worlds Entertainment, Inc. All rights reserved. ============
//    
// lua\TeamMessenger.lua    
//    
//    Created by:   Brian Cronin (brianc@unknownworlds.com)    
//    
// ========= For more information, visit us at http://www.unknownworlds.com =====================

kTeamMessageTypes = enum({ 'GameStarted', 'SpawningWait', 'Spawning', 'ResearchComplete', 'ResearchLost',
                            'Beacon'})

local kTeamMessages = { }

kTeamMessages[kTeamMessageTypes.GameStarted] = { text = { [kMarineTeamType] = "MARINE_TEAM_GAME_STARTED", [kRedTeamType] = "ALIEN_TEAM_GAME_STARTED" } }

// This function will generate the string to display based on a location Id.
local locationStringGen = function(locationId, messageString) return string.format(Locale.ResolveString(messageString), Shared.GetString(locationId)) end

// Thos function will generate the string to display based on a research Id.
local researchStringGen = function(researchId, messageString) return string.format(Locale.ResolveString(messageString), GetDisplayNameForTechId(researchId)) end

kTeamMessages[kTeamMessageTypes.SpawningWait] = { text = { [kRedTeamType] = "WAITING_TO_SPAWN" } }

kTeamMessages[kTeamMessageTypes.Spawning] = { text = { [kMarineTeamType] = "SPAWNING", [kRedTeamType] = "SPAWNING" } }

kTeamMessages[kTeamMessageTypes.ResearchComplete] = { text = { [kRedTeamType] = function(data) return researchStringGen(data, "EVOLUTION_AVAILABLE") end } }

kTeamMessages[kTeamMessageTypes.ResearchLost] = { text = { [kRedTeamType] = function(data) return researchStringGen(data, "EVOLUTION_LOST") end } }

kTeamMessages[kTeamMessageTypes.Beacon] = { text = { [kMarineTeamType] = function(data) return locationStringGen(data, "BEACON_TO") end } }

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
    
        if GetGamerules():GetGameStarted() then
        
            local function SendToPlayer(player)
                Server.SendNetworkMessage(player, "TeamMessage", { type = messageType, data = optionalData or 0 }, true)
            end
            
            team:ForEachPlayer(SendToPlayer)
            
        end
        
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
    
    local function TestTeamMessage(client)
    
        local player = client:GetControllingPlayer()
        if player then
            SendPlayersMessage({ player }, kTeamMessageTypes.NoCommander)
        end
        
    end
    
    Event.Hook("Console_ttm", TestTeamMessage)
    
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