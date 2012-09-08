// ======= Copyright (c) 2003-2012, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\AlienSpectator.lua
//
//    Created by:   Marc Delorme (marc@unknownworlds.com)
//
// TeamSpectator inherit from Spectator. It's a spectator who belongs to a team, so he should not be able
// to see people of opposit team
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/Spectator.lua")

class 'TeamSpectator' (Spectator)

------------
-- STATIC --
------------

// Public
TeamSpectator.kMapName = "teamspectator"

// Private
local kDeadSound = PrecacheAsset("sound/NS2.fev/common/dead")

-------------
-- NETWORK --
-------------

local networkVars = { }

------------
-- METHOD --
------------

--@Override Spectator
function TeamSpectator:OnInitialized()
    Spectator.OnInitialized(self)

    // TODO
    // Refactor the deadsound in the function which kill the player
    // Should not be in spectator
    if Client then
     
        if Client.GetLocalPlayer() == self then
        
            if self:GetTeamNumber() == kTeam1Index or self:GetTeamNumber() == kTeam2Index then
                Shared.PlaySound(self, kDeadSound)
            end
            
        end
 
    end

end

--@Override Spectator
function TeamSpectator:OnDestroy()

    Spectator.OnDestroy(self)

    if Client then 
        Shared.StopSound(self, kDeadSound)
    end
    
end

--@Override Spectator
function TeamSpectator:OnProcessMove(input)

    // TeamSpectators never allow mode switching. Follow only.
    input.commands = bit.band(input.commands, bit.bnot(bit.bor(Move.Weapon1, Move.Weapon2, Move.Weapon3)))
    
    // Filter change follow target keys while respawning.
    if self:GetIsRespawning() then
        input.commands = bit.band(input.commands, bit.bnot(bit.bor(Move.Jump, Move.PrimaryAttack, Move.SecondaryAttack)))
    end
    
    Spectator.OnProcessMove(self, input)
    
end

--@Override Spectator
function TeamSpectator:IsValidMode(mode)
    return mode == Spectator.kSpectatorMode.Following
end

--@Override Spectator
function TeamSpectator:GetPlayerStatusDesc()    
    return kPlayerStatus.Dead
end

--@Override Spectator
function TeamSpectator:GetIsValidTarget(entity)
    return Spectator.GetIsValidTarget(self, entity) and HasMixin(entity, "Team") and entity:GetTeamNumber() == self:GetTeamNumber()
end

function TeamSpectator:GetHasSayings()
    return true
end

function TeamSpectator:GetSayings()

    if self.showSayings then
    
        local team = self:GetTeamNumber()
        self.showSayingsMenu = ConditionalValue(team == kTeamAlienType, 2, 3)
        
        if self.showSayingsMenu == 2 or self.showSayingsMenu == 3 then
             return GetVoteActionsText(team)
        end
        
        return
        
    end
    
    return nil
    
end

function TeamSpectator:ExecuteSaying(index, menu)

    Spectator.ExecuteSaying(self, index, menu)
    
    if Server then
    
        // Alien and Marine.
        if menu == 2 or menu == 3 then
            GetGamerules():CastVoteByPlayer(voteActionsActions[index], self)
        end
        
    end
    
end

function TeamSpectator:OverrideInput(input)

    if self.OverrideSayingsMenu then
        self:OverrideSayingsMenu(input)
    end
    
    return Spectator.OverrideInput(self, input)
    
end

Shared.LinkClassToMap("TeamSpectator", TeamSpectator.kMapName, networkVars)