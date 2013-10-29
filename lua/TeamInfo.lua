// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua/TeamInfo.lua
//
// TeamInfo is used to sync information about a team to clients.
// A client on team 1 or 2 will only receive team info regarding their
// own team while a client on the kSpectatorIndex team will receive both
// teams info.
//
// Created by Brian Cronin (brianc@unknownworlds.com)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/TeamMixin.lua")

class 'TeamInfo' (Entity)

TeamInfo.kMapName = "TeamInfo"

local networkVars =
{

    playerCount = "integer (0 to " .. kMaxPlayers - 1 .. ")",
    kills = "integer (0 to 9999)"
}

AddMixinNetworkVars(TeamMixin, networkVars)

function TeamInfo:OnCreate()

    Entity.OnCreate(self)
    
    if Server then
    
        self:SetUpdates(true)
        
        self.playerCount = 0
        self.kills = 0
        
    end
    
    InitMixin(self, TeamMixin)
    
end

if Server then

    function TeamInfo:Reset()
    

        self.playerCount = 0
        self.kills = 0
    
    end


end
local function UpdateInfo(self)

    if self.team then
    
        self:SetTeamNumber(self.team:GetTeamNumber())
        self.playerCount = Clamp(self.team:GetNumPlayers(), 0, 31)

        self.kills = self.team:GetKills()
        
    end
    
end

function TeamInfo:SetWatchTeam(team)

    self.team = team
    self:SetTeamNumber(team:GetTeamNumber())
    UpdateInfo(self)
    self:SetPropagate(Entity.Propagate_Mask)
    self:UpdateRelevancy()
    
end

function TeamInfo:GetKills()
    return self.kills
end

function TeamInfo:UpdateRelevancy()

    self:SetRelevancyDistance(Math.infinity)
    
    local mask = 0
    
    if self:GetTeamNumber() == kTeam1Index then
        mask = kRelevantToTeam1
    elseif self:GetTeamNumber() == kTeam2Index then
        mask = kRelevantToTeam2
    end
        
    self:SetExcludeRelevancyMask(mask)

end

function TeamInfo:OnUpdate(deltaTime)
    UpdateInfo(self)
end

function TeamInfo:GetPlayerCount()
    return self.playerCount
end

Shared.LinkClassToMap("TeamInfo", TeamInfo.kMapName, networkVars)
