// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\CommandStructure_Server.lua
//
//    Created by:   Charlie Cleveland (charlie@unknownworlds.com) and
//                  Max McGuire (max@unknownworlds.com)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

function CommandStructure:SetCustomPhysicsGroup()
    self:SetPhysicsGroup(PhysicsGroup.BigStructuresGroup)
end

function CommandStructure:OnKill(attacker, doer, point, direction)

    ScriptActor.OnKill(self, attacker, doer, point, direction)

end

function CommandStructure:OnSighted(sighted)

    local attached = self:GetAttached()
    if attached and sighted then
        attached.showObjective = true
    end

end

// Children should override this
function CommandStructure:GetTeamType()
    return kNeutralTeamType
end

local function CheckForLogin(self)

    self:UpdateCommanderLogin()
    return true
    
end

function CommandStructure:OnInitialized()

    ScriptActor.OnInitialized(self)
    
    self.commanderId = Entity.invalidId
    
    self.occupied = true
    
end

function CommandStructure:OnDestroy()

    if self.occupied then
        self:Logout()
    end
    
    if self.objectiveInfoEntId and self.objectiveInfoEntId ~= Entity.invalidId then
    
        DestroyEntity(Shared.GetEntity(self.objectiveInfoEntId))
        self.objectiveInfoEntId = Entity.invalidId
        
    end

    ScriptActor.OnDestroy(self)                        
            
end

function CommandStructure:GetCommanderClassName()
    return Commander.kMapName   
end

function CommandStructure:GetWaitForCloseToLogin()
    return true
end

function CommandStructure:GetIsPlayerValidForCommander(player)
    return false
end

function CommandStructure:UpdateCommanderLogin(force)
   
end

function CommandStructure:OnCommanderLogin()
end

function CommandStructure:LoginPlayer(player)

    local commanderStartOrigin = Vector(player:GetOrigin())
    
    if player.OnCommanderStructureLogin then
        player:OnCommanderStructureLogin(self)
    end
    
    // Create Commander player
    local commanderPlayer = player:Replace(self:GetCommanderClassName(), player:GetTeamNumber(), true, commanderStartOrigin)
    
    // Set all child entities and view model invisible
    function SetInvisible(childEntity) 
        childEntity:SetIsVisible(false)
    end
    commanderPlayer:ForEachChild(SetInvisible)
    
    if commanderPlayer:GetViewModelEntity() then
        commanderPlayer:GetViewModelEntity():SetModel("")
    end
    
    // Clear game effects on player
    commanderPlayer:ClearGameEffects()    
    
    // Make this structure the first hotgroup if we don't have any yet
    if commanderPlayer:GetNumHotkeyGroups() == 0 then
        commanderPlayer:CreateHotkeyGroup(1, { self:GetId() })
    end
    
    commanderPlayer:SetCommandStructure(self)
    
    // Save origin so we can restore it on logout
    commanderPlayer.lastGroundOrigin = Vector(commanderStartOrigin)

    self.commanderId = commanderPlayer:GetId()
    
    // Must reset offset angles once player becomes commander
    commanderPlayer:SetOffsetAngles(Angles(0, 0, 0))
    
    return commanderPlayer

end

function CommandStructure:GetCommander()
    return Shared.GetEntity(self.commanderId)
end

// Put player into Commander mode
function CommandStructure:OnUse(player, elapsedTime, useAttachPoint, usePoint, useSuccessTable)

   return false
    
end

function CommandStructure:OnEntityChange(oldEntityId, newEntityId)

    if self.commanderId == oldEntityId then
    
        self.commanderId = Entity.invalidId
        
    end
    
end

/**
 * Returns the logged out player if there is currently one logged in.
 */


function CommandStructure:OnOverrideOrder(order)

    // Convert default to set rally point.
    if order:GetType() == kTechId.Default then
        order:SetType(kTechId.SetRally)
    end
    
end

function CommandStructure:OnTag(tagName)

    PROFILE("CommandStructure:OnTag")
    
    if tagName == "closed" then
        self.closedTime = Shared.GetTime()
    end
    
end