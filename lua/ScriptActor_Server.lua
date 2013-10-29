// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\ScriptActor_Server.lua
//
//    Created by:   Charlie Cleveland (charlie@unknownworlds.com) and
//                  Max McGuire (max@unknownworlds.com)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

function ScriptActor:OnKill(attacker, doer, point, direction)
    self:ClearAttached()
end

function ScriptActor:OnDestroy()

    Entity.OnDestroy(self)
    
    self:ClearAttached()
    
end

function ScriptActor:ClearAttached()

    // Call attached entity's ClearAttached function
    local entity = Shared.GetEntity(self.attachedId)
    if entity ~= nil then
    
        if self.attachedId ~= Entity.invalidId and self.OnDetached then
            self:OnDetached()
        end

        // Set first so we don't call infinitely
        self.attachedId = Entity.invalidId    
        
        if entity:isa("ScriptActor") then
            entity:ClearAttached()
        end
        
    end
    
end

function ScriptActor:GetIsTargetValid(target)
    return target ~= self and target ~= nil
end

// Return valid taret within attack distance, if any
function ScriptActor:FindTarget(attackDistance)

    // Find enemy in range
    local enemyTeamNumber = GetEnemyTeamNumber(self:GetTeamNumber())
    local potentialTargets = GetEntitiesWithMixinForTeamWithinRange("Live", enemyTeamNumber, self:GetOrigin(), attackDistance)
    
    local nearestTarget = nil
    local nearestTargetDistance = 0
    
    // Get closest target
    for index, currentTarget in ipairs(potentialTargets) do
    
        if(self:GetIsTargetValid(currentTarget)) then
        
            local distance = self:GetDistance(currentTarget)
            if(nearestTarget == nil or distance < nearestTargetDistance) then
            
                nearestTarget = currentTarget
                nearestTargetDistance = distance
                
            end    
            
        end
        
    end

    return nearestTarget    
    
end

// A structure can be attached to another structure (ie, resource tower to resource nozzle)
function ScriptActor:SetAttached(structure)
    
    if structure then
    
        // Because they'll call SetAttached back on us
        if structure:GetId() ~= self.attachedId then
        
            self:ClearAttached()
            self.attachedId = structure:GetId()            
            structure:SetAttached(self)
            
            if self.OnAttached then
                self:OnAttached(structure)
            end
            
        end
        
    else

        if self.attachedId ~= Entity.invalidId and self.OnDetached then
            self:OnDetached(structure)
        end
        
        self.attachedId = Entity.invalidId
        
    end

end

function ScriptActor:SetLocationName(locationName, silent)

    local success = false
    
    self:OnLocationChange(locationName)
    
    self.locationId = Shared.GetStringIndex(locationName)
    
    if self.locationId ~= 0 then
        success = true
    elseif not silent then
        Print("%s:SetLocationName(%s): String not precached.", self:GetClassName(), ToString(locationName))
    end

    return success
    
end

// Called after all entities are loaded. Put code in here that depends on other entities being loaded.
function ScriptActor:OnMapPostLoad()
    self:ComputeLocation()
end
