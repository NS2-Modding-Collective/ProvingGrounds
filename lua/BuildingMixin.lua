// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======    
//    
// lua\BuildingMixin.lua    
//    
//    Created by:   Andrew Spiering (andrew@unknownworlds.com)    
//    
// ========= For more information, visit us at http://www.unknownworlds.com =====================    

BuildingMixin = { }
BuildingMixin.type = "Building"

function BuildingMixin:__initmixin()    
end

local function EvalBuildIsLegal(self, techId, origin, builderEntity, pickVec)

    PROFILE("EvalBuildIsLegal")

    local legalBuildPosition = false
    local position = nil
    local attachEntity = nil
    
    if pickVec == nil then
    
        // When Drifters and MACs build, or untargeted build/buy actions, no pickVec. Trace from order point down to see
        // if they're trying to build on top of anything and if that's OK.
        local trace = Shared.TraceRay(Vector(origin.x, origin.y + .1, origin.z), Vector(origin.x, origin.y - .2, origin.z), CollisionRep.Select, PhysicsMask.CommanderBuild, EntityFilterOne(builderEntity))
        legalBuildPosition, position, attachEntity = GetIsBuildLegal(techId, trace.endPoint, kStructureSnapRadius, self:GetOwner(), builderEntity)
        
    else
    
        local commander = self:GetOwner()
        if commander == nil then
            commander = self
        end
        legalBuildPosition, position, attachEntity = GetIsBuildLegal(techId, origin, kStructureSnapRadius, commander, builderEntity)
        
    end
    
    return legalBuildPosition, position, attachEntity
    
end

// Returns true or false, as well as the entity id of the new structure (or -1 if false)
// pickVec optional (for AI units). In those cases, builderEntity will be the entity doing the building.
function BuildingMixin:AttemptToBuild(techId, origin, normal, orientation, pickVec, buildTech, builderEntity, trace, owner)

    local legalBuildPosition = false
    local position = nil
    local attachEntity = nil
    local coordsMethod = LookupTechData(techId, kTechDataOverrideCoordsMethod, nil)

    legalBuildPosition, position, attachEntity = EvalBuildIsLegal(self, techId, origin, builderEntity, pickVec)
    
    if legalBuildPosition then
    
        local commander = self:GetOwner()
        if commander == nil then
            commander = self
        end
        
        if owner ~= nil then
            commander = owner
        end
        
        local newEnt = nil
        if builderEntity and builderEntity.OverrideBuildEntity then
            newEnt = builderEntity:OverrideBuildEntity(techId, position, commander)
        end
        
        if not newEnt then
            newEnt = CreateEntityForCommander(techId, position, commander)
        end
        
        if newEnt ~= nil then
        
            // Use attach entity orientation 
            if attachEntity then
                orientation = attachEntity:GetAngles().yaw
            end
            
            if coordsMethod then
            
                local coords = coordsMethod( newEnt:GetCoords() )
                newEnt:SetCoords(coords)
            
            // If orientation yaw specified, set it
            elseif orientation then
            
                local angles = Angles(0, orientation, 0)
                local coords = Coords.GetLookIn(newEnt:GetOrigin(), angles:GetCoords().zAxis)
                newEnt:SetCoords(coords)
            
            else
            
                // align it with the surface (normal)
                local coords = Coords.GetLookIn(newEnt:GetOrigin(), Vector.zAxis, normal)
                newEnt:SetCoords(coords)
                
            end

            self:TriggerEffects("commander_create_local", { ismarine = GetIsMarineUnit(newEnt), isalien = GetIsAlienUnit(newEnt) })
            
            return true, newEnt:GetId()
            
        end
        
    end
    
    return false, -1
    
end