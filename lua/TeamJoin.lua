// ======= Copyright (c) 2003-2012, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\TeamJoin.lua
//
//    Created by:   Charlie Cleveland (charlie@unknownworlds.com) and
//                  Max McGuire (max@unknownworlds.com)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

class 'TeamJoin' (Trigger)

TeamJoin.kMapName = "team_join"

function TeamJoin:OnInitialized()

    Trigger.OnInitialized(self)
    
    self:SetPropagate(Actor.Propagate_Never)
    
    self:SetIsVisible(false)
    
    self:SetTriggerCollisionEnabled(true)
    
end

function JoinRandomTeam(player)

    // Join team with less players or random.
    local team1Players = GetGamerules():GetTeam(kTeam1Index):GetNumPlayers()
    local team2Players = GetGamerules():GetTeam(kTeam2Index):GetNumPlayers()
    
    // Join team with least.
    if team1Players < team2Players then
        Server.ClientCommand(player, "jointeamone")
    elseif team2Players < team1Players then
        Server.ClientCommand(player, "jointeamtwo")
    else
    
        // Join random otherwise.
        if math.random() < 0.5 then
            Server.ClientCommand(player, "jointeamone")
        else
            Server.ClientCommand(player, "jointeamtwo")
        end
        
    end
    
end

function TeamJoin:OnTriggerEntered(enterEnt, triggerEnt)

    if enterEnt:isa("Player") then
    
        if self.teamNumber == kTeamReadyRoom then
            Server.ClientCommand(enterEnt, "spectate")
        elseif self.teamNumber == kTeam1Index then
            Server.ClientCommand(enterEnt, "jointeamone")
        elseif self.teamNumber == kTeam2Index then
            Server.ClientCommand(enterEnt, "jointeamtwo")
        elseif self.teamNumber == kRandomTeamType then
            JoinRandomTeam(enterEnt)
        end
        
    end
        
end

Shared.LinkClassToMap("TeamJoin", TeamJoin.kMapName, {})