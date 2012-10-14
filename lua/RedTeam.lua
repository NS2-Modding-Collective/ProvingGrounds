// ======= Copyright (c) 2012, SoulRider - ModBeans,  All rights reserved. =======
//
// lua\RedTeam.lua
//
//    Created by:   Andy Wilson - SoulRider@ModBeans.com
//
// ========= For more information, visit us at http://www.modbeans.com =====================

Script.Load("lua/Avatar.lua")
Script.Load("lua/PlayingTeam.lua")

class 'RedTeam' (PlayingTeam)

function RedTeam:ResetTeam()

    PlayingTeam.ResetTeam(self)
    
    self.updateMarineArmor = false

end

function RedTeam:GetTeamType()
    return kRedTeamType
end

function RedTeam:GetIsRedTeam()
    return true 
end

function RedTeam:Initialize(teamName, teamNumber)

    PlayingTeam.Initialize(self, teamName, teamNumber)
    
    self.respawnEntity = Avatar.kMapName
    
    self.updateMarineArmor = false
    
end

function RedTeam:GetHasAbilityToRespawn()
    return true
end

// Clear distress flag for all players on team, unless affected by distress beaconing Observatory. 
// This function is here to make sure case with multiple observatories and distress beacons is
// handled properly.

function RedTeam:Update(timePassed)

    PlayingTeam.Update(self, timePassed)

end

function RedTeam:InitTechTree()
   
   PlayingTeam.InitTechTree(self)
    
    self.techTree:AddBuyNode(kTechId.Axe,                 kTechId.None,                kTechId.None)
    self.techTree:AddBuyNode(kTechId.Pistol,              kTechId.None,                kTechId.None)
    self.techTree:AddBuyNode(kTechId.Rifle,               kTechId.None,                kTechId.None)
    self.techTree:AddBuyNode(kTechId.Shotgun,             kTechId.None,                kTechId.None)
    self.techTree:AddBuyNode(kTechId.GrenadeLauncher,     kTechId.None,                kTechId.None)
    self.techTree:AddBuyNode(kTechId.Flamethrower,        kTechId.None,		           kTechId.none)
    
    self.techTree:SetComplete()

end

function RedTeam:GetSpectatorMapName()
    return RedSpectator.kMapName
end