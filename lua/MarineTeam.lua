// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\MarineTeam.lua
//
//    Created by:   Charlie Cleveland (charlie@unknownworlds.com) and
//                  Max McGuire (max@unknownworlds.com)
//
// This class is used for teams that are actually playing the game, e.g. Marines or Aliens.
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/Avatar.lua")
Script.Load("lua/PlayingTeam.lua")

class 'MarineTeam' (PlayingTeam)

function MarineTeam:ResetTeam()

    PlayingTeam.ResetTeam(self)
    
    self.updateMarineArmor = false

end

function MarineTeam:GetTeamType()
    return kMarineTeamType
end

function MarineTeam:GetIsMarineTeam()
    return true 
end

function MarineTeam:Initialize(teamName, teamNumber)

    PlayingTeam.Initialize(self, teamName, teamNumber)
    
    self.respawnEntity = Avatar.kMapName
    
    self.updateMarineArmor = false
    
end

function MarineTeam:GetHasAbilityToRespawn()
    return true
end

// Clear distress flag for all players on team, unless affected by distress beaconing Observatory. 
// This function is here to make sure case with multiple observatories and distress beacons is
// handled properly.

function MarineTeam:Update(timePassed)

    PlayingTeam.Update(self, timePassed)

end

function MarineTeam:InitTechTree()
   
    PlayingTeam.InitTechTree(self)
    
    self.techTree:AddBuyNode(kTechId.Axe,                 kTechId.None,                kTechId.None)
    self.techTree:AddBuyNode(kTechId.Pistol,              kTechId.None,                kTechId.None)
    self.techTree:AddBuyNode(kTechId.Rifle,               kTechId.None,                kTechId.None)
    self.techTree:AddBuyNode(kTechId.Shotgun,             kTechId.None,                kTechId.None)
    self.techTree:AddBuyNode(kTechId.GrenadeLauncher,     kTechId.None,                kTechId.None)
    self.techTree:AddBuyNode(kTechId.Flamethrower,        kTechId.None,		           kTechId.none)
//    self.techTree:AddBuyNode(kTechId.LayMines,            kTechId.None,                kTechId.None)
    self.techTree:AddBuyNode(kTechId.Welder,              kTechId.None,                kTechId.None)
    /*self.techTree:AddBuyNode(kTechId.Armor1,              kTechId.None,                kTechId.None)
    self.techTree:AddBuyNode(kTechId.Weapons1,            kTechId.None,                kTechId.None)
    self.techTree:AddBuyNode(kTechId.Armor2,              kTechId.None,                kTechId.None)
    self.techTree:AddBuyNode(kTechId.Weapons2,            kTechId.None,                kTechId.None)  
    self.techTree:AddBuyNode(kTechId.Armor3,              kTechId.None,                kTechId.None)
    self.techTree:AddBuyNode(kTechId.Weapons3,            kTechId.None,                kTechId.None)
    self.techTree:AddBuyNode(kTechId.Jetpack,             kTechId.None,                kTechId.None)
    self.techTree:AddBuyNode(kTechId.Exosuit,             kTechId.None,                kTechId.None) */
    
    self.techTree:SetComplete()

end

function MarineTeam:GetSpectatorMapName()
    return MarineSpectator.kMapName
end