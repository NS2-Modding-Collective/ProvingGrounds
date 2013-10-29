// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\ReadyRoomTeam.lua
//
//    Created by:   Charlie Cleveland (charlie@unknownworlds.com) and
//                  Max McGuire (max@unknownworlds.com)
//
// This class is used for the team that is for players that are in the ready room.
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/Team.lua")
Script.Load("lua/TeamDeathMessageMixin.lua")

class 'ReadyRoomTeam' (Team)

function ReadyRoomTeam:Initialize(teamName, teamNumber)

    InitMixin(self, TeamDeathMessageMixin)
    
    Team.Initialize(self, teamName, teamNumber)
    
end

function ReadyRoomTeam:GetRespawnMapName(player)

    local mapName = player.kMapName    
    
    if mapName == nil then
        mapName = ReadyRoomPlayer.kMapName
    end
    
    // Use previous life form if dead or in commander chair
    if (mapName == Spectator.kMapName) 
       or (mapName ==  MarineSpectator.kMapName) then 
    
        mapName = player:GetPreviousMapName()
        
    end

    return mapName
    
end

/**
 * Transform player to appropriate team respawn class and respawn them at an appropriate spot for the team.
 */
function ReadyRoomTeam:ReplaceRespawnPlayer(player, origin, angles)

    local mapName = self:GetRespawnMapName(player)
    
    local newPlayer = player:Replace(mapName, self:GetTeamNumber(), false, origin)
       
    self:RespawnPlayer(newPlayer, origin, angles)
    
    newPlayer:ClearGameEffects()
    
    return (newPlayer ~= nil), newPlayer
    
end

function ReadyRoomTeam:TriggerAlert(techId, entity)
    return false
end