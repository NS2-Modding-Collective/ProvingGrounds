// ============================================================================
//
// lua\GreenTeam.lua
//
//    Created by:   Andy Wilson for Proving Grounds
//
// This class is used for teams that are actually playing the game, e.g. Greens or Purples.
//
// ===============================================================================

Script.Load("lua/GreenAvatar.lua")
Script.Load("lua/PlayingTeam.lua")

class 'GreenTeam' (PlayingTeam)

GreenTeam.gSandboxMode = false

local kCannotSpawnSound = PrecacheAsset("sound/NS2.fev/marine/voiceovers/commander/need_ip")

function GreenTeam:ResetTeam()
    
end

function GreenTeam:OnResetComplete()
    
end

function GreenTeam:GetTeamType()
    return kGreenTeamType
end

function GreenTeam:GetIsGreenTeam()
    return true 
end

function GreenTeam:Initialize(teamName, teamNumber)

    PlayingTeam.Initialize(self, teamName, teamNumber)
    
    self.respawnEntity = GreenAvatar.kMapName
    
end

function GreenTeam:GetTeamInfoMapName()
    return GreenTeamInfo.kMapName
end

function GreenTeam:GetHasAbilityToRespawn()      
    
    return true
    
end

function GreenTeam:Update(timePassed)

    PlayingTeam.Update(self, timePassed)
   
end

function GreenTeam:GetSpectatorMapName()
    return MarineSpectator.kMapName
end
