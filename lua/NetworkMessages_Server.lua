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

function OnCommandCommMarqueeSelect(client, message)
    
    local player = client:GetControllingPlayer()
    if player:GetIsCommander() then
        player:MarqueeSelectEntities(ParseCommMarqueeSelectMessage(message))
    end
    
end

function OnCommandClearSelection(client, message)

    local player = client:GetControllingPlayer()
    local removeAll, removeId, ctrlPressed = ParseClearSelectionMessage(message)
    
    if player:GetIsCommander() then
        if removeAll then
            player:ClearSelection()
        else
            // TODO: remove entityId, if ctrl pressed remove all entities with same class name as well from selection
        end
    end
    
end

function OnCommandCommSelectId(client, message)

    local player = client:GetControllingPlayer()
    if player:GetIsCommander() then
        player:SelectEntityId(ParseSelectIdMessage(message))
    end

end

function OnCommandCommControlClickSelect(client, message)

    local player = client:GetControllingPlayer()
    if player:GetIsCommander() then
        player:ControlClickSelectEntities(ParseControlClickSelectMessage(message))
    end

end

function OnCommandParseSelectHotkeyGroup(client, message)

    local player = client:GetControllingPlayer()
    if player:GetIsCommander() then
        player:SelectHotkeyGroup(ParseSelectHotkeyGroupMessage(message))
    end
    
end

function OnCommandParseCreateHotkeyGroup(client, message)

    local player = client:GetControllingPlayer()
    if player:GetIsCommander() then
        player:CreateHotkeyGroup(message.groupNumber, player:GetSelection())
    end
    
end

function OnCommandCommAction(client, message)

    local techId = ParseCommActionMessage(message)
    
    local player = client:GetControllingPlayer()
    if player and player:GetIsCommander() then
        player:ProcessTechTreeAction(techId, nil, nil)
    else
        Shared.Message("CommAction message received with invalid player. TechID: " .. EnumToString(kTechId, techId))
    end
    
end

function OnCommandCommTargetedAction(client, message)

    local player = client:GetControllingPlayer()
    if player:GetIsCommander() then
    
        local techId, pickVec, orientation = ParseCommTargetedActionMessage(message)
        player:ProcessTechTreeAction(techId, pickVec, orientation)
    
    end
    
end

function OnCommandCommTargetedActionWorld(client, message)

    local player = client:GetControllingPlayer()
    if player:GetIsCommander() then
    
        local techId, pickVec, orientation = ParseCommTargetedActionMessage(message)
        player:ProcessTechTreeAction(techId, pickVec, orientation, true)
    
    end
    
end

function OnCommandExecuteSaying(client, message)

    local player = client:GetControllingPlayer()
    local sayingIndex, sayingsMenu = ParseExecuteSayingMessage(message)
    player:ExecuteSaying(sayingIndex, sayingsMenu)

end

function OnCommandGorgeSelectStructure(client, message)

    local player = client:GetControllingPlayer()
    local structureIndex = ParseGorgeSelectMessage(message)
    
    local activeWeapon = player:GetActiveWeapon()
    if activeWeapon.SetStructureActive then
        activeWeapon:SetStructureActive(structureIndex)
    end

end

function OnCommandMutePlayer(client, message)

    local player = client:GetControllingPlayer()
    local muteClientIndex, setMute = ParseMutePlayerMessage(message)
    player:SetClientMuted(muteClientIndex, setMute)

end

function OnCommandCommClickSelect(client, message)

    local player = client:GetControllingPlayer()
    if player:GetIsCommander() then
        player:ClickSelectEntities(ParseCommClickSelectMessage(message))
    end
    
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
    
end

local function OnCommandCommPing(client, message)

    if Server then
    
        local player = client:GetControllingPlayer()
        if player then
            local team = player:GetTeam()
            team:SetCommanderPing(message.position)
        end
    
    end

end

Server.HookNetworkMessage("MarqueeSelect", OnCommandCommMarqueeSelect)
Server.HookNetworkMessage("ClickSelect", OnCommandCommClickSelect)
Server.HookNetworkMessage("ClearSelection", OnCommandClearSelection)
Server.HookNetworkMessage("ControlClickSelect", OnCommandCommControlClickSelect)
Server.HookNetworkMessage("SelectHotkeyGroup", OnCommandParseSelectHotkeyGroup)
Server.HookNetworkMessage("CreateHotKeyGroup", OnCommandParseCreateHotkeyGroup)
Server.HookNetworkMessage("CommAction", OnCommandCommAction)
Server.HookNetworkMessage("CommTargetedAction", OnCommandCommTargetedAction)
Server.HookNetworkMessage("CommTargetedActionWorld", OnCommandCommTargetedActionWorld)
Server.HookNetworkMessage("ExecuteSaying", OnCommandExecuteSaying)
Server.HookNetworkMessage("GorgeSelectStructure", OnCommandGorgeSelectStructure)
Server.HookNetworkMessage("MutePlayer", OnCommandMutePlayer)
Server.HookNetworkMessage("SelectId", OnCommandCommSelectId)
Server.HookNetworkMessage("ChatClient", OnChatReceived)
Server.HookNetworkMessage("CommanderPing", OnCommandCommPing)