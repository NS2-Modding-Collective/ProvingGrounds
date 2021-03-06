// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\NetworkMessages_Server.lua
//
//    Created by:   Charlie Cleveland (charlie@unknownworlds.com) and
//                  Max McGuire (max@unknownworlds.com)
//
// See the Messages section of the Networking docs in Spark Engine scripting docs for details.
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

function OnCommandMutePlayer(client, message)

    local player = client:GetControllingPlayer()
    local muteClientIndex, setMute = ParseMutePlayerMessage(message)
    player:SetClientMuted(muteClientIndex, setMute)
    
end

local kChatsPerSecondAdded = 1
local kMaxChatsInBucket = 5
local function CheckChatAllowed(client)

    client.chatTokenBucket = client.chatTokenBucket or CreateTokenBucket(kChatsPerSecondAdded, kMaxChatsInBucket)
    // Returns true if there was a token to remove.
    return client.chatTokenBucket:RemoveTokens(1)
    
end

local function GetChatPlayerData(client)

    local playerName = "Admin"
    local playerLocationId = -1
    local playerTeamNumber = kTeamReadyRoom
    local playerTeamType = kNeutralTeamType
    
    if client then
    
        local player = client:GetControllingPlayer()
        if not player then
            return
        end
        playerName = player:GetName()
        playerLocationId = player.locationId
        playerTeamNumber = player:GetTeamNumber()
        playerTeamType = player:GetTeamType()
        
    end
    
    return playerName, playerLocationId, playerTeamNumber, playerTeamType
    
end

local function OnChatReceived(client, message)

    if not CheckChatAllowed(client) then
        return
    end
    
    chatMessage = string.sub(message.message, 1, kMaxChatLength)
    if chatMessage and string.len(chatMessage) > 0 then
    
        local playerName, playerLocationId, playerTeamNumber, playerTeamType = GetChatPlayerData(client)
        
        if playerName then
        
            if message.teamOnly then
            
                local players = GetEntitiesForTeam("Player", playerTeamNumber)
                for index, player in ipairs(players) do
                    Server.SendNetworkMessage(player, "Chat", BuildChatMessage(true, playerName, playerLocationId, playerTeamNumber, playerTeamType, chatMessage), true)
                end
                
            else
                Server.SendNetworkMessage("Chat", BuildChatMessage(false, playerName, playerLocationId, playerTeamNumber, playerTeamType, chatMessage), true)
            end
            
            Shared.Message("Chat " .. (message.teamOnly and "Team - " or "All - ") .. playerName .. ": " .. chatMessage)
            
            // We save a history of chat messages received on the Server.
            Server.AddChatToHistory(chatMessage, playerName, client:GetUserId(), playerTeamNumber, message.teamOnly)
            
        end
        
    end
    
    // handle tournament mode commands
    if client then  
  
        local player = client:GetControllingPlayer()
        if player then        
            ProcessSayCommand(player, chatMessage)
        end
    
    end
    
end

local function OnCommandSetRookieMode(client, networkMessage)

    if client ~= nil then
    
        local player = client:GetControllingPlayer()
        if player then 
        
            local rookieMode = ParseRookieMessage(networkMessage)
            player:SetRookieMode(rookieMode)
            
        end
        
    end

end

local function OnCommandSetCommStatus(client, networkMessage)

    if client ~= nil then
    
        local player = client:GetControllingPlayer()
        if player then 
        
            local commStatus = ParseCommunicationStatus(networkMessage)
            player:SetCommunicationStatus(commStatus)
            
        end
        
    end

end

local function OnSetNameMessage(client, message)

    local name = message.name
    if client ~= nil and name ~= nil then
    
        local player = client:GetControllingPlayer()
        
        name = TrimName(name)
        
        // Treat "NsPlayer" as special.
        if name ~= player:GetName() and name ~= kDefaultPlayerName and string.len(name) > 0 then
        
            local prevName = player:GetName()
            player:SetName(name)
            
            if prevName == kDefaultPlayerName then
                Server.Broadcast(nil, string.format("%s connected.", player:GetName()))
            elseif prevName ~= player:GetName() then
                Server.Broadcast(nil, string.format("%s is now known as %s.", prevName, player:GetName()))
            end
            
        end
        
    end
    
end
Server.HookNetworkMessage("SetName", OnSetNameMessage)

local function onSpectatePlayer(client, message)

    local spectatorPlayer = client:GetControllingPlayer()
    if spectatorPlayer then

        // This only works for players on the spectator team.
        if spectatorPlayer:GetTeamNumber() == kSpectatorIndex then
            client:GetControllingPlayer():SelectEntity(message.entityId)
        end
        
    end
    
end
Server.HookNetworkMessage("SpectatePlayer", onSpectatePlayer)

local function OnSwitchFromFirstPersonSpectate(client, message)

    local spectatorPlayer = client:GetControllingPlayer()
    if client:GetSpectatingPlayer() and spectatorPlayer then
    
        // This only works for players on the spectator team.
        if spectatorPlayer:GetTeamNumber() == kSpectatorIndex then
            client:GetControllingPlayer():SetSpectatorMode(message.mode)
        end
        
    end
    
end
Server.HookNetworkMessage("SwitchFromFirstPersonSpectate", OnSwitchFromFirstPersonSpectate)

local function OnSwitchFirstPersonSpectatePlayer(client, message)

    if client:GetSpectatingPlayer() and client:GetControllingPlayer() then
    
        if client:GetControllingPlayer().CycleSpectatingPlayer then
            client:GetControllingPlayer():CycleSpectatingPlayer(client:GetSpectatingPlayer(), message.forward)
        end
        
    end
    
end
Server.HookNetworkMessage("SwitchFirstPersonSpectatePlayer", OnSwitchFirstPersonSpectatePlayer)

local function OnSetPlayerVariant(client, message)

    if client then

        client.variantData = message
        
        local player = client:GetControllingPlayer()
        if player then
            player:OnClientUpdated(client)
        end
        
    end
    
end

local function OnConnectMessage(client, message)
    OnSetPlayerVariant( client, message )
end

Server.HookNetworkMessage("SetPlayerVariant", OnSetPlayerVariant)
Server.HookNetworkMessage("MutePlayer", OnCommandMutePlayer)
Server.HookNetworkMessage("ChatClient", OnChatReceived)
Server.HookNetworkMessage("SetRookieMode", OnCommandSetRookieMode)
Server.HookNetworkMessage("SetCommunicationStatus", OnCommandSetCommStatus)
Server.HookNetworkMessage("ConnectMessage", OnConnectMessage)
