// ============================================================================
//
// lua\PurpleTeam.lua
//
//    Created by:   Andy Wilson for Proving Grounds
//
// This class is used for teams that are actually playing the game, e.g. Green or Purple.
//
// ===============================================================================

Script.Load("lua/PurpleAvatar.lua")
Script.Load("lua/PlayingTeam.lua")

class 'PurpleTeam' (PlayingTeam)

PurpleTeam.gSandboxMode = false

local kCannotSpawnSound = PrecacheAsset("sound/NS2.fev/marine/voiceovers/commander/need_ip")

function PurpleTeam:ResetTeam()
    
end

function PurpleTeam:OnResetComplete()
    
end

function PurpleTeam:GetTeamType()
    return kPurpleTeamType
end

function PurpleTeam:GetIsPurpleTeam()
    return true 
end

function PurpleTeam:Initialize(teamName, teamNumber)

    PlayingTeam.Initialize(self, teamName, teamNumber)
    
    self.respawnEntity = PurpleAvatar.kMapName
    
end

function PurpleTeam:GetTeamInfoMapName()
    return PurpleTeamInfo.kMapName
end

function PurpleTeam:GetHasAbilityToRespawn()      
    
    return true
    
end

function PurpleTeam:Update(timePassed)

    PlayingTeam.Update(self, timePassed)
   
end

function PurpleTeam:GetSpectatorMapName()
    return MarineSpectator.kMapName
end
