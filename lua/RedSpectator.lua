// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\MarineSpectator.lua
//
//    Created by:   Andreas Urwalek (a_urwa@sbox.tugraz.at)
//
// Alien spectators can choose their upgrades and lifeform while dead.
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/TeamSpectator.lua")
Script.Load("lua/ScoringMixin.lua")

if Client then
    Script.Load("lua/TeamMessageMixin.lua")
end

class 'RedSpectator' (TeamSpectator)

RedSpectator.kMapName = "redspectator"

local networkVars = { }

--@Override TeamSpectator
function RedSpectator:OnCreate()

    TeamSpectator.OnCreate(self)
    self:SetTeamNumber(2)
    
    InitMixin(self, ScoringMixin, { kMaxScore = kMaxScore })
    
    if Client then
        InitMixin(self, TeamMessageMixin, { kGUIScriptName = "GUIMarineTeamMessage" })
    end
    
end

--@Override TeamSpectator
function RedSpectator:OnInitialized()

    TeamSpectator.OnInitialized(self)
    self:SetTeamNumber(2)
    
end

Shared.LinkClassToMap("RedSpectator", RedSpectator.kMapName, networkVars)