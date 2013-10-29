//=============================================================================
//
// lua/Scoreboard.lua
// 
// Created by Henry Kropf and Charlie Cleveland
// Copyright 2011, Unknown Worlds Entertainment
//
//=============================================================================
Script.Load("lua/Insight.lua")

local playerData = { }

function Insight_SetPlayerHealth(clientIndex, health, maxHealth)
    
    for i = 1, table.maxn(playerData) do
    
        local playerRecord = playerData[i]
        if playerRecord.ClientIndex == clientIndex then
            playerRecord.Health = health
            playerRecord.MaxHealth = maxHealth

        end
        
    end
    
end

function Scoreboard_Clear()

    playerData = { }
    Insight_Clear()
    
end

// Score > Kills > Deaths > Resources
function Scoreboard_Sort()

    function sortByScore(player1, player2)
    
        if player1.Score == player2.Score then
        
            if player1.Kills == player2.Kills then
            
                if player1.Deaths == player2.Deaths then    
                    // Somewhat arbitrary but keeps more coherence and adds players to bottom in case of ties
                    return player1.ClientIndex > player2.ClientIndex                    
                else
                    return player1.Deaths < player2.Deaths
                end
                
            else
                return player1.Kills > player2.Kills
            end
            
        else
            return player1.Score > player2.Score    
        end        
        
    end
    
    // Sort it by entity id
    table.sort(playerData, sortByScore)

end

// Hooks from console commands coming from server
function Scoreboard_OnResetGame()

    // For each player, clear game data (on reset)
    for i = 1, table.maxn(playerData) do
    
        local playerRecord = playerData[i]
        
        playerRecord.EntityId = 0
        playerRecord.EntityTeamNumber = 0
        playerRecord.Score = 0
        playerRecord.Kills = 0
        playerRecord.Deaths = 0
        playerRecord.IsRookie = false
        playerRecord.Status = ""
        playerRecord.IsSpectator = false
        
    end 

end

function Scoreboard_OnClientDisconnect(clientIndex)

    table.removeConditional(  playerData, function (element) return element.ClientIndex == clientIndex end )
    return true
    
end

function Scoreboard_SetPlayerData(clientIndex, entityId, playerName, teamNumber, score, kills, deaths, isRookie, status, isSpectator, assists )

    // Lookup record for player and update it
    for i = 1, table.maxn(playerData) do
    
        local playerRecord = playerData[i]
        
        if playerRecord.ClientIndex == clientIndex then

            // Update entry
            playerRecord.EntityId = entityId
            playerRecord.Name = playerName
            playerRecord.EntityTeamNumber = teamNumber
            playerRecord.Score = score
            playerRecord.Kills = kills
            playerRecord.Assists = assists
            playerRecord.Deaths = deaths
            playerRecord.IsRookie = isRookie
            playerRecord.Status = status
            playerRecord.IsSpectator = isSpectator
            
            Scoreboard_Sort()
            
            return
            
        end
        
    end
        
    // Otherwise insert a new record
    local playerRecord = {}
    playerRecord.ClientIndex = clientIndex
    playerRecord.EntityId = entityId
    playerRecord.Name = playerName
    playerRecord.EntityTeamNumber = teamNumber
    playerRecord.Score = score
    playerRecord.Kills = kills
    playerRecord.Assists = assists
    playerRecord.Deaths = deaths
    playerRecord.IsRookie = isRookie
    playerRecord.Ping = 0
    playerRecord.Status = status
    playerRecord.IsSpectator = isSpectator
    
    table.insert(playerData, playerRecord )
    
    Scoreboard_Sort()
    
end

function Scoreboard_SetPing(clientIndex, ping)

    local setPing = false
    
    for i = 1, table.maxn(playerData) do
    
        local playerRecord = playerData[i]
        if playerRecord.ClientIndex == clientIndex then
            playerRecord.Ping = ping
            setPing = true
        end
        
    end
    
end

function Scoreboard_SetRookieMode(playerName, rookieMode)

    for i = 1, table.maxn(playerData) do
    
        local playerRecord = playerData[i]
        
        if playerRecord.Name == playerName then
            playerRecord.IsRookie = rookieMode
        end
        
    end
    
end

// Set local data for player so scoreboard updates instantly
function Scoreboard_SetLocalPlayerData(playerName, index, data)
    
    for i = 1, table.maxn(playerData) do
    
        local playerRecord = playerData[i]
        
        if playerRecord.Name == playerName then
        
            playerRecord[index] = data

            break
            
        end
        
    end
    
end

function Scoreboard_GetPlayerRecord(clientIndex)

    for i = 1, table.maxn(playerData) do
    
        local playerRecord = playerData[i]
        
        if playerRecord.ClientIndex == clientIndex then

            return playerRecord
            
        end

    end
    
    return nil
    
end

function Scoreboard_GetPlayerName(clientIndex)

    local record = Scoreboard_GetPlayerRecord(clientIndex)
    return record and record.Name
    
end

function Scoreboard_GetPlayerList()

    local playerList = { }
    for p = 1, #playerData do
    
        local playerRecord = playerData[p]
        table.insert(playerList, { name = playerRecord.Name, client_index = playerRecord.ClientIndex })
        
    end
    
    return playerList
    
end

function Scoreboard_GetPlayerData(clientIndex, dataType)

    local playerRecord = Scoreboard_GetPlayerRecord(clientIndex)
    
    if playerRecord then
    
        return playerRecord[dataType]
        
    end
    
    return nil    
    
end

/**
 * Get table of scoreboard player recrods for all players with team numbers in specified table.
 */
function GetScoreData(teamNumberTable)

    local scoreData = { }
    
    for index, playerRecord in ipairs(playerData) do
        if table.find(teamNumberTable, playerRecord.EntityTeamNumber) then
        
            table.insert(scoreData, playerRecord)
               
        end
    end
        
    return scoreData
    
end

/**
 * Get score data for the green team
 */
function ScoreboardUI_GetGreenScores()
    return GetScoreData({ kTeam1Index })
end

/**
 * Get score data for the purple team
 */
function ScoreboardUI_GetPurpleScores()
    return GetScoreData({ kTeam2Index })
end

/**
 * Get score data for everyone not playing.
 */
function ScoreboardUI_GetSpectatorScores()
    return GetScoreData({ kTeamReadyRoom, kSpectatorIndex })
end

function ScoreboardUI_GetAllScores()
    return GetScoreData({ kTeam1Index, kTeam2Index, kTeamReadyRoom, kSpectatorIndex })
end

/**
 * Get the name of the blue team
 */
function ScoreboardUI_GetGreenTeamName()
    return kTeam1Name
end

/**
 * Get the name of the red team
 */
function ScoreboardUI_GetPurpleTeamName()
    return kTeam2Name
end

/**
 * Get the name of the spectator team
 */
function ScoreboardUI_GetSpectatorTeamName()
    return kSpectatorTeamName
end

/**
 * Return true if playerName is a local player.
 */
function ScoreboardUI_IsPlayerLocal(playerName)
    
    local player = Client.GetLocalPlayer()
    
    // Get entry with this name and check entity id
    if player then
    
        for i = 1, table.maxn(playerData) do

            local playerRecord = playerData[i]        
            if playerRecord.Name == playerName then

                return (player:GetClientIndex() == playerRecord.ClientIndex)
                
            end
            
        end    
        
    end
    
    return false
    
end

function ScoreboardUI_IsPlayerRookie(playerName)

    for i = 1, table.maxn(playerData) do

        local playerRecord = playerData[i]        
        if playerRecord.Name == playerName then
            return playerRecord.IsRookie
        end
        
    end  
    
    return false
    
end

function ScoreboardUI_GetDrawRookie(playerName, forPlayer)

    for i = 1, table.maxn(playerData) do

        local playerRecord = playerData[i]        
        if playerRecord.Name == playerName then
            return playerRecord.IsRookie and ((forPlayer:GetTeamNumber() == playerRecord.EntityTeamNumber) or (forPlayer:GetTeamNumber() == kSpectatorIndex))
        end
        
    end  
    
    return false
    
end
