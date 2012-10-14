//======= Copyright (c) 2003-2012, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\NS2Utility.lua
//
//    Created by:   Charlie Cleveland (charlie@unknownworlds.com)
//
// NS2-specific utility functions.
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================
Script.Load("lua/Table.lua")
Script.Load("lua/Utility.lua")
Script.Load("lua/FunctionContracts.lua")

if Server then
    Script.Load("lua/NS2Utility_Server.lua")
end

function GetGameInfoEntity()

    local entityList = Shared.GetEntitiesWithClassname("GameInfo")
    if entityList:GetSize() > 0 then    
        return entityList:GetEntityAtIndex(0)
    end    

end
function GetIsTargetDetected(target)
    return HasMixin(target, "Detectable") and target:GetIsDetected()
end

function GetIsParasited(target)
    return target ~= nil and HasMixin(target, "ParasiteAble") and target:GetIsParasited()
end

function GetPlayerCanUseEntity(player, target)

    local useSuccessTable = { useSuccess = false }

    if target.GetCanBeUsed then
        useSuccessTable.useSuccess = true
        target:GetCanBeUsed(player, useSuccessTable)
    end
    
    //Print("GetPlayerCanUseEntity(%s, %s) returns %s", ToString(player), ToString(target), ToString(useSuccessTable.useSuccess))

    return useSuccessTable.useSuccess

end

function GetIsClassHasEnergyFor(className, entity, techId, techNode, commander)

    local hasEnergy = false
    
    if entity:isa(className) and HasMixin(entity, "Energy") and entity:GetTechAllowed(techId, techNode, commander) then
        local cost = LookupTechData(techId, kTechDataCostKey, 0)
        hasEnergy = entity:GetEnergy() >= cost
    end        
    
    return hasEnergy

end

function GetIsUnitActive(unit, debug)


    local alive = not HasMixin(unit, "Live") or unit:GetIsAlive()
    
    if debug then
        Print("------------ GetIsUnitActive(%s) -----------------", ToString(unit))
        Print("alive: %s", ToString(alive))
        Print("-----------------------------")
    end
    
    return alive
    
end

function GetAnyNearbyUnitsInCombat(origin, radius, teamNumber)

    local nearbyUnits = GetEntitiesWithMixinForTeamWithinRange("Combat", teamNumber, origin, radius)
    for e = 1, #nearbyUnits do
    
        if nearbyUnits[e]:GetIsInCombat() then
            return true
        end
        
    end
    
    return false
    
end

function GetCircleSizeForEntity(entity)

    local size = ConditionalValue(entity:isa("Player"),2.0, 2)

    return size
    
end

gMaxHeightOffGround = 0.0

function GetAttachEntity(techId, position, snapRadius)

    local attachClass = LookupTechData(techId, kStructureAttachClass)    

    if attachClass then
    
        for index, currentEnt in ipairs( GetEntitiesWithinRange(attachClass, position, ConditionalValue(snapRadius, snapRadius, .5)) ) do
        
            if not currentEnt:GetAttached() then
            
                return currentEnt
                
            end
            
        end
        
    end
    
    return nil
    
end

function CheckForFlatSurface(origin, boxExtents)

    local valid = true
    
    // Perform trace at center, then at each of the extent corners
    if boxExtents then
    
        local tracePoints = {   origin + Vector(-boxExtents, 0.5, -boxExtents),
                                origin + Vector(-boxExtents, 0.5,  boxExtents),
                                origin + Vector( boxExtents, 0.5, -boxExtents),
                                origin + Vector( boxExtents, 0.5,  boxExtents) }
                                
        for index, point in ipairs(tracePoints) do
        
            local trace = Shared.TraceRay(tracePoints[index], tracePoints[index] - Vector(0, 0.7, 0), CollisionRep.Move, PhysicsMask.AllButPCs, EntityFilterOne(nil))
            if (trace.fraction == 1) then
            
                valid = false
                break
                
            end
            
        end
        
    end 
    
    return valid

end

/**
 * Returns the spawn point on success, nil on failure.
 */
local function ValidateSpawnPoint(spawnPoint, capsuleHeight, capsuleRadius, filter, origin)

    local center = Vector(0, capsuleHeight * 0.5 + capsuleRadius, 0)
    local spawnPointCenter = spawnPoint + center
    
    // Make sure capsule isn't interpenetrating something.
    local spawnPointBlocked = Shared.CollideCapsule(spawnPointCenter, capsuleRadius, capsuleHeight, CollisionRep.Default, PhysicsMask.AllButPCs, nil)
    if not spawnPointBlocked then

        // Trace capsule to ground, making sure we're not on something like a player or structure
        local trace = Shared.TraceCapsule(spawnPointCenter, spawnPoint - Vector(0, 10, 0), capsuleRadius, capsuleHeight, CollisionRep.Move, PhysicsMask.AllButPCs)            
        if trace.fraction < 1 and (trace.entity == nil or not trace.entity:isa("ScriptActor")) then
        
            VectorCopy(trace.endPoint, spawnPoint)
            
            local endPoint = trace.endPoint + Vector(0, capsuleHeight / 2, 0)
            // Trace in both directions to make sure no walls are being ignored.
            trace = Shared.TraceRay(endPoint, origin, CollisionRep.Move, PhysicsMask.AllButPCs, filter)
            local traceOriginToEnd = Shared.TraceRay(origin, endPoint, CollisionRep.Move, PhysicsMask.AllButPCs, filter)
            
            if trace.fraction == 1 and traceOriginToEnd.fraction == 1 then
                return spawnPoint - Vector(0, capsuleHeight / 2, 0)
            end
            
        end
        
    end
    
    return nil
    
end

// Find place for player to spawn, within range of origin. Makes sure that a line can be traced between the two points
// without hitting anything, to make sure you don't spawn on the other side of a wall. Returns nil if it can't find a 
// spawn point after a few tries.
function GetRandomSpawnForCapsule(capsuleHeight, capsuleRadius, origin, minRange, maxRange, filter)

    ASSERT(capsuleHeight > 0)
    ASSERT(capsuleRadius > 0)
    ASSERT(origin ~= nil)
    ASSERT(type(minRange) == "number")
    ASSERT(type(maxRange) == "number")
    ASSERT(maxRange > minRange)
    ASSERT(minRange > 0)
    ASSERT(maxRange > 0)
    
    local maxHeight = 10
    
    for i = 0, 10 do
    
        local spawnPoint = nil
        local points = GetRandomPointsWithinRadius(origin, minRange, maxRange, maxHeight, 1, 1)
        if #points == 1 then
            spawnPoint = points[1]
        else
            Print("GetRandomPointsWithinRadius() failed inside of GetRandomSpawnForCapsule()")
        end
        
        if spawnPoint then
        
        
            // The spawn point returned by GetRandomPointsWithinRadius() may be too close to the ground.
            // Move it up a bit so there is some "wiggle" room. ValidateSpawnPoint() traces down anyway.
            spawnPoint = spawnPoint + Vector(0, 0.5, 0)
            local validSpawnPoint = ValidateSpawnPoint(spawnPoint, capsuleHeight, capsuleRadius, filter, origin)
            if validSpawnPoint then
                return validSpawnPoint
            end
            
        end
        
    end
    
    return nil
    
end

function GetExtents(techId)

    local extents = LookupTechData(techId, kTechDataMaxExtents)
    if not extents then
        extents = Vector(.5, .5, .5)
    end
    return extents

end

function CreateFilter(entity1, entity2)

    local filter = nil
    if entity1 and entity2 then
        filter = EntityFilterTwo(entity1, entity2)
    elseif entity1 then
        filter = EntityFilterOne(entity1)
    elseif entity2 then
        filter = EntityFilterOne(entity2)
    end
    return filter
    
end

function GetGroundAtPointWithCapsule(position, extents, physicsGroupMask, filter)

    local kCapsuleSize = 0.1
    
    local topOffset = extents.y + kCapsuleSize
    local startPosition = position + Vector(0, topOffset, 0)
    local endPosition = position - Vector(0, 1000, 0)
    
    local trace
    if filter == nil then
        trace = Shared.TraceCapsule(startPosition, endPosition, kCapsuleSize, 0, CollisionRep.Move, physicsGroupMask)    
    else    
        trace = Shared.TraceCapsule(startPosition, endPosition, kCapsuleSize, 0, CollisionRep.Move, physicsGroupMask, filter)    
    end
    
    // If we didn't hit anything, then use our existing position. This
    // prevents objects from constantly moving downward if they get outside
    // of the bounds of the map.
    if trace.fraction ~= 1 then
        return trace.endPoint - Vector(0, 2 * kCapsuleSize, 0)
    else
        return position
    end

end

/**
 * Return the passed in position casted down to the ground.
 */
function GetGroundAt(entity, position, physicsGroupMask, filter)
    if filter then
        return GetGroundAtPointWithCapsule(position, entity:GetExtents(), physicsGroupMask, filter)
    end

    return GetGroundAtPointWithCapsule(position, entity:GetExtents(), physicsGroupMask, EntityFilterOne(entity))
    
end

/**
 * Return the ground below position, using a TraceBox with the given extents, mask and filter.
 * Returns position if nothing hit.
 *
 * filter defaults to nil
 * extents defaults to a 0.1x0.1x0.1 box (ie, extents 0.05x...)
 * physicGroupsMask defaults to PhysicsMask.Movement
 */
function GetGroundAtPosition(position, filter, physicsGroupMask, extents)

    physicsGroupMask = physicsGroupMask or PhysicsMask.Movement
    extents = extents or Vector(0.05, 0.05, 0.05)
    
    local topOffset = extents.y + 0.1
    local startPosition = position + Vector(0, topOffset, 0)
    local endPosition = position - Vector(0, 1000, 0)
    
    local trace = Shared.TraceBox(extents, startPosition, endPosition, CollisionRep.Move, physicsGroupMask, filter)
    
    // If we didn't hit anything, then use our existing position. This
    // prevents objects from constantly moving downward if they get outside
    // of the bounds of the map.
    if trace.fraction ~= 1 then
        return trace.endPoint - Vector(0, extents.y, 0)
    else
        return position
    end

end

function GetHoverAt(entity, position, filter)

    local ground = GetGroundAt(entity, position, PhysicsMask.AIMovement, filter)
    local resultY = position.y
    // if we have a hover height, use it to find our minimum height above ground, otherwise use zero
    
    local minHeightAboveGround = 0
    if entity.GetHoverHeight then      
      minHeightAboveGround = entity:GetHoverHeight()
    end

    local heightAboveGround = resultY  - ground.y
    
    // always snap "up", snap "down" only if not flying
    if heightAboveGround <= minHeightAboveGround or not entity:GetIsFlying() then
        resultY = resultY + minHeightAboveGround - heightAboveGround              
    end   

    if resultY ~= position.y then
        return Vector(position.x, resultY, position.z)
    end

    return position

end

function GetTriggerEntity(position, teamNumber)

    local triggerEntity = nil
    local minDist = nil
    local ents = GetEntitiesWithMixinForTeamWithinRange("Live", teamNumber, position, .5)
    
    for index, ent in ipairs(ents) do
    
        local dist = (ent:GetOrigin() - position):GetLength()
        
        if not minDist or (dist < minDist) then
        
            triggerEntity = ent
            minDist = dist
            
        end
    
    end
    
    return triggerEntity
    
end

// TODO: use what is defined in the material file
function GetSurfaceFromEntity(entity)
    return "thin_metal"   
end

function GetSurfaceAndNormalUnderEntity(entity, axis)

    if not axis then
        axis = entity:GetCoords().yAxis
    end

    local trace = Shared.TraceRay(entity:GetOrigin() + axis * 0.2, entity:GetOrigin() - axis * 10, CollisionRep.Default, PhysicsMask.Bullets, EntityFilterAll() )
    
    if trace.fraction ~= 1 then
        return trace.surface, trace.normal
    end
    
    return "thin_metal", Vector(0, 1, 0)

end

// Trace line to each target to make sure it's not blocked by a wall. 
// Returns true/false, along with distance traced 
function GetWallBetween(startPoint, endPoint, targetEntity)

    // Filter out all entities except the targetEntity on this trace.
    local trace = Shared.TraceRay(startPoint, endPoint, CollisionRep.Move, PhysicsMask.Bullets, EntityFilterOnly(targetEntity))        
    local dist = (startPoint - endPoint):GetLength()
    local hitWorld = false
    
    // Hit nothing?
    if trace.fraction == 1 then
        hitWorld = false
    // Hit the world?
    elseif not trace.entity then
    
        dist = (startPoint - trace.endPoint):GetLength()
        hitWorld = true
        
    elseif trace.entity == targetEntity then
    
        // Hit target entity, return traced distance to it.
        dist = (startPoint - trace.endPoint):GetLength()
        hitWorld = false
        
    end
    
    return hitWorld, dist
    
end

// Get damage type description text for tooltips
function DamageTypeDesc(damageType)
    if table.count(kDamageTypeDesc) >= damageType then
        if kDamageTypeDesc[damageType] ~= "" then
            return string.format("(%s)", kDamageTypeDesc[damageType])
        end
    end
    return ""
end

function GetHealthColor(scalar)

    local kHurtThreshold = .7
    local kNearDeadThreshold = .4
    local minComponent = 191
    local spreadComponent = 255 - minComponent

    scalar = Clamp(scalar, 0, 1)
    
    if scalar <= kNearDeadThreshold then
    
        // Faded red to bright red
        local r = minComponent + (scalar / kNearDeadThreshold) * spreadComponent
        return {r, 0, 0}
        
    elseif scalar <= kHurtThreshold then
    
        local redGreen = minComponent + ( (scalar - kNearDeadThreshold) / (kHurtThreshold - kNearDeadThreshold) ) * spreadComponent
        return {redGreen, redGreen, 0}
        
    else
    
        local g = minComponent + ( (scalar - kHurtThreshold) / (1 - kHurtThreshold) ) * spreadComponent
        return {0, g, 0}
        
    end
    
end

function GetEntsWithTechId(techIdTable, attachRange, position)

    local ents = {}
    
    local entities = nil
    
    if attachRange and position then        
        entities = GetEntitiesWithMixinWithinRange("Tech", position, attachRange)        
    else
        entities = GetEntitiesWithMixin("Tech")
    end
    
    for index, entity in ipairs(entities) do
    
        if table.find(techIdTable, entity:GetTechId()) then
            table.insert(ents, entity)
        end
        
    end
    
    return ents
    
end

function GetEntsWithTechIdIsActive(techIdTable, attachRange, position)

    local ents = {}
    
    local entities = nil
    
    if attachRange and position then        
        entities = GetEntitiesWithMixinWithinRange("Tech", position, attachRange)        
    else
        entities = GetEntitiesWithMixin("Tech")
    end
    
    for index, entity in ipairs(entities) do
    
        if table.find(techIdTable, entity:GetTechId()) and GetIsUnitActive(entity) then
            table.insert(ents, entity)
        end
        
    end
    
    return ents
    
end

function GetFreeAttachEntsForTechId(techId)

    local freeEnts = {}

    local attachClass = LookupTechData(techId, kStructureAttachClass)

    if attachClass ~= nil then    
    
        for index, ent in ientitylist(Shared.GetEntitiesWithClassname(attachClass)) do
        
            if ent ~= nil and ent:GetAttached() == nil then
                table.insert(freeEnts, ent)
            end
            
        end
        
    end
    
    return freeEnts
    
end

function GetNearestFreeAttachEntity(techId, origin, range)

    local nearest = nil
    local nearestDist = nil
    
    for index, ent in ipairs(GetFreeAttachEntsForTechId(techId)) do
    
        local dist = (ent:GetOrigin() - origin):GetLengthXZ()
        
        if (nearest == nil or dist < nearestDist) and (range == nil or dist <= range) then
        
            nearest = ent
            nearestDist = dist
            
        end
        
    end
    
    return nearest
    
end

function GetAreEnemies(entityOne, entityTwo)
    return entityOne and entityTwo and HasMixin(entityOne, "Team") and HasMixin(entityTwo, "Team") and (
            (entityOne:GetTeamNumber() == kMarineTeamType and entityTwo:GetTeamNumber() == kRedTeamType) or
            (entityOne:GetTeamNumber() == kRedTeamType and entityTwo:GetTeamNumber() == kMarineTeamType)
           )
end

function GetAreFriends(entityOne, entityTwo)
    return entityOne and entityTwo and HasMixin(entityOne, "Team") and HasMixin(entityTwo, "Team") and
            entityOne:GetTeamNumber() == entityTwo:GetTeamNumber()
end

function GetIsMarineUnit(entity)
    return entity and HasMixin(entity, "Team") and entity:GetTeamType() == kMarineTeamType
end

function GetIsAlienUnit(entity)
    return entity and HasMixin(entity, "Team") and entity:GetTeamType() == kRedTeamType
end

function GetEnemyTeamNumber(entityTeamNumber)

    if(entityTeamNumber == kTeam1Index) then
        return kTeam2Index
    elseif(entityTeamNumber == kTeam2Index) then
        return kTeam1Index
    else
        return kTeamInvalid
    end    
    
end

function SpawnPlayerAtPoint(player, origin, angles)

    player:SetOrigin(origin)
    
    if angles then
        player:SetViewAngles(angles)
    end        
    
end

/**
 * Returns the passed in point traced down to the ground. Ignores all entities.
 */
function DropToFloor(point)

    local trace = Shared.TraceRay(point, Vector(point.x, point.y - 1000, point.z), CollisionRep.Move, PhysicsMask.All)
    if trace.fraction < 1 then
        return trace.endPoint
    end
    
    return point
    
end

function GetNearestTechPoint(origin, availableOnly)

    // Look for nearest empty tech point to use instead
    local nearestTechPoint = nil
    local nearestTechPointDistance = 0
    
    for index, techPoint in ientitylist(Shared.GetEntitiesWithClassname("TechPoint")) do
    
        // Only use unoccupied tech points that are neutral or marked for use with our team
        local techPointTeamNumber = techPoint:GetTeamNumberAllowed()        
        if not availableOnly or techPoint:GetAttached() == nil then
        
            local distance = (techPoint:GetOrigin() - origin):GetLength()
            if nearestTechPoint == nil or distance < nearestTechPointDistance then
            
                nearestTechPoint = techPoint
                nearestTechPointDistance = distance
                
            end
            
        end
        
    end
    
    return nearestTechPoint
    
end

function GetNearest(origin, className, teamNumber, filterFunc)

    assert(type(className) == "string")
    
    local nearest = nil
    local nearestDistance = 0
    
    for index, ent in ientitylist(Shared.GetEntitiesWithClassname(className)) do
    
        // Filter is optional, pass through if there is no filter function defined.
        if not filterFunc or filterFunc(ent) then
        
            if teamNumber == nil or (teamNumber == ent:GetTeamNumber()) then
            
                local distance = (ent:GetOrigin() - origin):GetLength()
                if nearest == nil or distance < nearestDistance then
                
                    nearest = ent
                    nearestDistance = distance
                    
                end
                
            end
            
        end
        
    end
    
    return nearest
    
end

// Computes line of sight to entity
local toEntity = Vector()
function GetCanSeeEntity(seeingEntity, targetEntity)

    PROFILE("NS2Utility:GetCanSeeEntity")
    
    local seen = false
    
    // See if line is in our view cone
    if targetEntity:GetIsVisible() then
    
        local targetOrigin = HasMixin(targetEntity, "Target") and targetEntity:GetEngagementPoint() or targetEntity:GetOrigin()
        local eyePos = GetEntityEyePos(seeingEntity)
        
        // Not all seeing entity types have a FOV.
        // So default to within FOV.
        local withinFOV = true
        
        // Anything that has the GetFov method supports FOV checking.
        if seeingEntity.GetFov ~= nil then
        
            // Reuse vector
            toEntity.x = targetOrigin.x - eyePos.x
            toEntity.y = targetOrigin.y - eyePos.y
            toEntity.z = targetOrigin.z - eyePos.z
            
            // Normalize vector        
            local toEntityLength = math.sqrt(toEntity.x * toEntity.x + toEntity.y * toEntity.y + toEntity.z * toEntity.z)
            if toEntityLength > kEpsilon then
            
                toEntity.x = toEntity.x / toEntityLength
                toEntity.y = toEntity.y / toEntityLength
                toEntity.z = toEntity.z / toEntityLength
                
            end
            
            local seeingEntityAngles = GetEntityViewAngles(seeingEntity)
            local normViewVec = seeingEntityAngles:GetCoords().zAxis        
            local dotProduct = Math.DotProduct(toEntity, normViewVec)
            local fov = seeingEntity:GetFov()
            
            // players have separate fov for marking enemies as sighted
            if seeingEntity.GetMinimapFov then
                fov = seeingEntity:GetMinimapFov(targetEntity)
            end
            
            local halfFov = math.rad(fov / 2)
            local s = math.acos(dotProduct)
            withinFOV = s < halfFov
            
        end
        
        if withinFOV then
        
            // See if there's something blocking our view of the entity.
            local trace = Shared.TraceRay(eyePos, targetOrigin + toEntity, CollisionRep.LOS, PhysicsMask.All, EntityFilterOnly(targetEntity))
            
            if trace.entity == targetEntity then
                seen = true
            end
            
        end
        
    end
    
    return seen
    
end

function GetLocations()
    return EntityListToTable(Shared.GetEntitiesWithClassname("Location"))
end

function GetLocationForPoint(point)

    local ents = GetLocations()
    
    for index, location in ipairs(ents) do
    
        if location:GetIsPointInside(point) then
        
            return location
            
        end    
        
    end
    
    return nil

end

function GetLocationEntitiesNamed(name)

    local locationEntities = {}
    
    if name ~= nil and name ~= "" then
    
        local ents = GetLocations()
        
        for index, location in ipairs(ents) do
        
            if location:GetName() == name then
            
                table.insert(locationEntities, location)
                
            end
            
        end
        
    end

    return locationEntities
    
end

// for performance, cache the lights for each locationName
local lightLocationCache = {}

function GetLightsForLocation(locationName)

    if locationName == nil or locationName == "" then
        return {}
    end
 
    if lightLocationCache[locationName] then
        return lightLocationCache[locationName]   
    end

    local lightList = {}
   
    local locations = GetLocationEntitiesNamed(locationName)
   
    if table.count(locations) > 0 then
   
        for index, location in ipairs(locations) do
           
            for index, renderLight in ipairs(Client.lightList) do

                if renderLight then
               
                    local lightOrigin = renderLight:GetCoords().origin
                   
                    if location:GetIsPointInside(lightOrigin) then
                   
                        table.insert(lightList, renderLight)
           
                    end
                   
                end
               
            end
           
        end
       
    end

    // Log("Total lights %s, lights in %s = %s", #Client.lightList, locationName, #lightList)
    lightLocationCache[locationName] = lightList
  
    return lightList
   
end

if Client then

    function ResetLights()
    
        for index, renderLight in ipairs(Client.lightList) do
        
            renderLight:SetColor(renderLight.originalColor)
            renderLight:SetIntensity(renderLight.originalIntensity)
            
        end                    
        
    end
    
end

function SetPlayerPoseParameters(player, viewModel)

    if not player or not player:isa("Player") then
        Log("SetPlayerPoseParameters: player %s is not a player", player)
    end
    ASSERT(player and player:isa("Player"))
    
    if viewmodel and not viewmodel:isa("Viewmodel") then
        Log("SetPlayerPoseParameters: player %s s viewmodel is a %s", player, viewmodel)
    end
    ASSERT(not viewmodel or viewmodel:isa("Viewmodel"))
    
    local viewAngles = player:GetViewAngles()
    
    local pitch = -Math.Wrap(Math.Degrees(viewAngles.pitch), -180, 180)
	
    local landIntensity = player.landIntensity or 0
    
    local bodyYaw = 0
    if player.bodyYaw then
        bodyYaw = Math.Wrap(Math.Degrees(player.bodyYaw), -180, 180)
    end
    
    local bodyYawRun = 0
    if player.bodyYawRun then
        bodyYawRun = Math.Wrap(Math.Degrees(player.bodyYawRun), -180, 180)
    end
    
    local viewAngles = player:GetViewAngles()
    local viewCoords = viewAngles:GetCoords()
    
    local horizontalVelocity = player:GetVelocityFromPolar()
    // Not all players will contrain their movement to the X/Z plane only.
    if player.GetMoveSpeedIs2D and player:GetMoveSpeedIs2D() then
        horizontalVelocity.y = 0
    end
    
    local x = Math.DotProduct(viewCoords.xAxis, horizontalVelocity)
    local z = Math.DotProduct(viewCoords.zAxis, horizontalVelocity)
    
    local moveYaw = Math.Wrap(Math.Degrees( math.atan2(z,x) ), -180, 180)
    local speedScalar = player:GetVelocityLength() / player:GetMaxSpeed(true)
    
    player:SetPoseParam("move_yaw", moveYaw)
    player:SetPoseParam("move_speed", speedScalar)
    player:SetPoseParam("body_pitch", pitch)
    player:SetPoseParam("body_yaw", bodyYaw)
    player:SetPoseParam("body_yaw_run", bodyYawRun)
    
    player:SetPoseParam("crouch", player:GetCrouchAmount())
    player:SetPoseParam("land_intensity", landIntensity)
    
    if viewModel then
    
        viewModel:SetPoseParam("body_pitch", pitch)
        viewModel:SetPoseParam("move_yaw", moveYaw)
        viewModel:SetPoseParam("move_speed", speedScalar)
        viewModel:SetPoseParam("crouch", player:GetCrouchAmount())
        viewModel:SetPoseParam("body_yaw", bodyYaw)
        viewModel:SetPoseParam("body_yaw_run", bodyYawRun)
        viewModel:SetPoseParam("land_intensity", landIntensity)
        
    end
    
end

// Pass in position on ground
function GetHasRoomForCapsule(extents, position, collisionRep, physicsMask, ignoreEntity)

    if extents ~= nil then
    
        local filter = ConditionalValue(ignoreEntity, EntityFilterOne(ignoreEntity), nil)
        return not Shared.CollideBox(extents, position, collisionRep, physicsMask, filter)
        
    else
        Print("GetHasRoomForCapsule(): Extents not valid.")
    end
    
    return false

end

function GetEngagementDistance(entIdOrTechId, trueTechId)

    local distance = 2
    local success = true
    
    local techId = entIdOrTechId
    if not trueTechId then
    
        local ent = Shared.GetEntity(entIdOrTechId)    
        if ent and ent.GetTechId then
            techId = ent:GetTechId()
        else
            success = false
        end
        
    end
    
    local desc = nil
    if success then
    
        distance = LookupTechData(techId, kTechDataEngagementDistance, nil)
        
        if distance then
            desc = EnumToString(kTechId, techId)    
        else
            distance = 1
            success = false
        end
        
    end    
        
    //Print("GetEngagementDistance(%s, %s) => %s => %s, %s", ToString(entIdOrTechId), ToString(trueTechId), ToString(desc), ToString(distance), ToString(success))
    
    return distance, success
    
end

// If we hit something, create an effect (sparks, blood, etc)
function TriggerHitEffects(doer, target, origin, surface, melee, extraEffectParams)

    local tableParams = {}
    
    if target and target.GetClassName and target.GetTeamType then
        tableParams[kEffectFilterClassName] = target:GetClassName()
        tableParams[kEffectFilterIsMarine] = target:GetTeamType() == kMarineTeamType
        tableParams[kEffectFilterIsAlien] = target:GetTeamType() == kRedTeamType
    end

    if GetIsPointOnInfestation(origin) then
        surface = "organic"
    end
       
    if not surface or surface == "" then
        surface = "metal"
    end
    
    tableParams[kEffectSurface] = surface
    
    if origin then
        tableParams[kEffectHostCoords] = Coords.GetTranslation(origin)
    else
        tableParams[kEffectHostCoords] = Coords.GetIdentity()
    end
    
    if doer then
        tableParams[kEffectFilterDoerName] = doer:GetClassName()
    end
    
    tableParams[kEffectFilterInAltMode] = (melee == true)

    // Add in extraEffectParams if specified    
    if extraEffectParams then
        for key, element in pairs(extraEffectParams) do
            tableParams[key] = element
        end
    end
    
    GetEffectManager():TriggerEffects("damage", tableParams, doer)
    
end

function TriggerMomentumChangeEffects(entity, surface, direction, normal, extraEffectParams)

    assert(math.abs(direction:GetLengthSquared() - 1) < 0.001)
    local tableParams = {}
    
    tableParams[kEffectFilterDoerName] = entity:GetClassName()
    tableParams[kEffectSurface] = ConditionalValue(type(surface) == "string" and surface ~= "", surface, "metal") 

    local coords = Coords.GetIdentity()
    coords.origin = entity:GetOrigin()
    coords.zAxis = direction
    coords.yAxis = normal    
    coords.xAxis = coords.yAxis:CrossProduct(coords.zAxis)
    
    tableParams[kEffectHostCoords] = coords

    // Add in extraEffectParams if specified    
    if extraEffectParams then
        for key, element in pairs(extraEffectParams) do
            tableParams[key] = element
        end
    end
    
    GetEffectManager():TriggerEffects("momentum_change", tableParams)

end

local kInfestationSearchRange = 25
function GetIsPointOnInfestation(point)

    local onInfestation = false
    
    // See if entity is on infestation
    local infestationEntities = GetEntitiesWithinRange("Infestation", point, kInfestationSearchRange)
    for infestationIndex = 1, #infestationEntities do
        
        local infestation = infestationEntities[infestationIndex]
        
        if infestation:GetIsPointOnInfestation(point, GetInfestationVerticalSize(nil)) then
        
            onInfestation = true
            break
            
        end
        
    end
    
    return onInfestation

end

function GetSelectionText(entity, teamNumber)

    local text = ""
    
    local cloakedText = ""    
    if entity.GetIsCamouflaged and entity:GetIsCamouflaged() then
        cloakedText = " (" .. Locale.ResolveString("CAMOUFLAGED") .. ")"
    elseif HasMixin(entity, "Cloakable") and entity:GetIsCloaked() then
        cloakedText = " (" .. Locale.ResolveString("CLOAKED") .. ")"
    end
    local maturity = ""
    
    if HasMixin(entity, "Maturity") then
    
        if entity:GetMaturityLevel() == kMaturityLevel.Grow then
            maturity = Locale.ResolveString("GROWN") .. " "
        end
        
    end
    
    if entity:isa("Player") and entity:GetIsAlive() then
    
        local playerName = Scoreboard_GetPlayerData(entity:GetClientIndex(), "Name")
                    
        if playerName ~= nil then
            
            text = string.format("%s%s", playerName, cloakedText)
        end
                    
    else
    
        // Don't show built % for enemies, show health instead
        local enemyTeam = HasMixin(entity, "Team") and GetEnemyTeamNumber(entity:GetTeamNumber()) == teamNumber
        local techId = entity:GetTechId()
        
        local secondaryText = ""
        if HasMixin(entity, "Construct") and not entity:GetIsBuilt() then        
            secondaryText = "Unbuilt "
            
        elseif HasMixin(entity, "PowerConsumer") and entity:GetRequiresPower() and not entity:GetIsPowered() then
            secondaryText = "Unpowered "
            
        elseif entity:isa("Whip") then
        
            if not entity:GetIsRooted() then
                secondaryText = "Unrooted "
            end
            
        end
        
        local primaryText = GetDisplayNameForTechId(techId)
        if entity.GetDescription then
            primaryText = entity:GetDescription()
        end

        text = string.format("%s%s%s%s", maturity, secondaryText, primaryText, cloakedText)

    end
    
    return text
    
end

function GetCostForTech(techId)
    return LookupTechData(techId, kTechDataCostKey, 0)
end

/**
 * Adds additional points to the path to ensure that no two points are more than
 * maxDistance apart.
 */
function SubdividePathPoints(points, maxDistance)
    PROFILE("NS2Utility:SubdividePathPoints") 
    local numPoints   = #points    
    
    local i = 1
    while i < numPoints do
        
        local point1 = points[i]
        local point2 = points[i + 1]

        // If the distance between two points is large, add intermediate points
        
        local delta    = point2 - point1
        local distance = delta:GetLength()
        local numNewPoints = math.floor(distance / maxDistance)
        local p = 0
        for j=1,numNewPoints do

            local f = j / numNewPoints
            local newPoint = point1 + delta * f
            if (table.find(points, newPoint) == nil) then
                i = i + 1
                table.insert( points, i, newPoint )
                p = p + 1
            end                     
        end 
        i = i + 1    
        numPoints = numPoints + p        
    end           
end

local function GetTraceEndPoint(src, dst, trace, skinWidth)

    local delta    = dst - src
    local distance = delta:GetLength()
    local fraction = trace.fraction
    fraction = Math.Clamp( fraction + (fraction - 1.0) * skinWidth / distance, 0.0, 1.0 )
    
    return src + delta * fraction

end

function GetFriendlyFire()
    return false
end

// All damage is routed through here.
function CanEntityDoDamageTo(attacker, target, cheats, devMode, friendlyFire, damageType)
 
    if not HasMixin(target, "Live") then
        return false
    end
    
    if (not target:GetCanTakeDamage()) then
        return false
    end
    
    if (target == nil or target == {} or (target.GetDarwinMode and target:GetDarwinMode())) then
        return false
    elseif(cheats or devMode) then
        return true
    elseif attacker == nil then
        return true
    end

    // You can always do damage to yourself
    if (attacker == target) then
        return true
    end
    
    // Your own grenades can hurt you
    if attacker:isa("Grenade") then
        local owner = attacker:GetOwner()        
        if owner and owner:GetId() == target:GetId() then
            return true
        end
    end
    
    // Same teams not allowed to hurt each other unless friendly fire enabled
    local teamsOK = true
    if attacker ~= nil then

        teamsOK = GetAreEnemies(attacker, target) or friendlyFire
        
    end
    
    // Allow damage of own stuff when testing
    return teamsOK

end

function TraceMeleeBox(weapon, eyePoint, axis, extents, range, mask, filter)

    // We make sure that the given range is actually the start/end of the melee volume by moving forward the
    // starting point with the extents (and some extra to make sure we don't hit anything behind us),
    // as well as moving the endPoint back with the extents as well (making sure we dont trace backwards)
    
    // Make sure we don't hit anything behind us.
    local startPoint = eyePoint + axis * weapon:GetMeleeOffset()
    local endPoint = eyePoint + axis * math.max(0, range) 
    local trace = Shared.TraceBox(extents, startPoint, endPoint, CollisionRep.Damage, mask, filter)
    return trace, startPoint, endPoint
    
end

local function IsPossibleMeleeTarget(player, target)

    if target and HasMixin(target, "Live") and target:GetCanTakeDamage() and target:GetIsAlive() then
    
        if HasMixin(target, "Team") and GetEnemyTeamNumber(player:GetTeamNumber()) == target:GetTeamNumber() then
            return true
        end
        
    end
    
    return false
    
end

/**
 * Priority function for melee target.
 *
 * Returns newTarget it it is a better target, otherwise target.
 *
 * Default priority: closest enemy player, otherwise closest enemy melee target
 */
local function IsBetterMeleeTarget(player, newTarget, target)

    if IsPossibleMeleeTarget(player, newTarget) then
    
        if not target or (not target:isa("Player") and newTarget:isa("Player")) then
            return true
        end
        
    end
    
    return false
    
end

// melee targets must be in front of the player
local minAngle = 20 / 90
local function IsNotBehind(fromPoint, hitPoint, forwardDirection)

    local toHitPoint = hitPoint - fromPoint
    toHitPoint:Normalize()
    
    return forwardDirection:DotProduct(toHitPoint) > minAngle

end

// The order in which we do the traces - middle first, the corners last.
local kTraceOrder = { 4, 1, 3, 5, 7, 0, 2, 6, 8 }
/**
 * Checks if a melee capsule would hit anything. Does not actually carry
 * out any attack or inflict any damage.
 *
 * Target prio algorithm: 
 * First, a small box (the size of a rifle but or a skulks head) is moved along the view-axis, colliding
 * with everything. The endpoint of this trace is the attackEndPoind
 *
 * Second, a new trace to the attackEndPoint using the full size of the melee box is done. This trace
 * is done WITHOUT REGARD FOR GEOMETRY, and uses an entity-filter that tracks targets as they come,
 * and prioritizes them.
 *
 * Basically, inside the range to the attackEndPoint, the attacker chooses the "best" target freely.
 */
 /**
  * Bullets are small and will hit exactly where you looked. 
  * Melee, however, is different. We select targets from a volume, and we expect the melee'er to be able
  * to basically select the "best" target from that volume. 
  * Right now, the Trace methods available is limited (spheres or world-axis aligned boxes), so we have to
  * compensate by doing multiple traces.
  * We specify the size of the width and base height and its range.
  * Then we split the space into 9 parts and trace/select all of them, choose the "best" target. If no good target is found,
  * we use the middle trace for effects.
  */
function CheckMeleeCapsule(weapon, player, damage, range, optionalCoords, traceRealAttack)

    local eyePoint = player:GetEyePos()
    
    local coords = optionalCoords or player:GetViewAngles():GetCoords()
    local axis = coords.zAxis
    local forwardDirection = Vector(coords.zAxis)
    forwardDirection.y = 0

    if forwardDirection:GetLength() ~= 0 then
        forwardDirection:Normalize()
    end
    
    local width, height = weapon:GetMeleeBase()
    // extents defines a world-axis aligned box, so x and z must be the same. 
    local extents = Vector(width / 6, height / 6, width / 6)
    local filter = EntityFilterOne(player)
    local middleTrace,middleStart
    local target,endPoint,surface,startPoint
    
    for _, pointIndex in ipairs(kTraceOrder) do
    
        local dx = pointIndex % 3 - 1
        local dy = math.floor(pointIndex / 3) - 1
        local point = eyePoint + coords.xAxis * (dx * width / 3) + coords.yAxis * (dy * height / 3)
        local trace, sp, ep = TraceMeleeBox(weapon, point, axis, extents, range, PhysicsMask.Melee, filter)
        
        if dx == 0 and dy == 0 then
            middleTrace, middleStart = trace, sp
        end
        
        if IsBetterMeleeTarget(player, trace.entity, target) and IsNotBehind(eyePoint, trace.endPoint, forwardDirection) then
        
            // Log("Selected %s over %s", target, trace.entity)
            target = trace.entity
            startPoint = sp
            endPoint = trace.endPoint
            surface = trace.surface
            
        end
        
        // Performance boost, doubt it makes much difference, but its an easy one...
        if target and target:isa("Player") then
            break
        end
        
    end
    
    // if we have not found a target, we use the middleTrace to possibly bite a wall (or when cheats are on, teammates)
    target = target or middleTrace.entity
    endPoint = endPoint or middleTrace.endPoint
    surface = surface or middleTrace.surface
    startPoint = startPoint or middleStart
    
    local direction = target and (endPoint - startPoint):GetUnit() or nil
    return target ~= nil or middleTrace.fraction < 1, target, endPoint, direction, surface
    
end

/**
 * Does an attack with a melee capsule.
 */
function AttackMeleeCapsule(weapon, player, damage, range, optionalCoords, altMode)

    // Enable tracing on this capsule check, last argument.
    local didHit, target, endPoint, direction, surface = CheckMeleeCapsule(weapon, player, damage, range, optionalCoords, true)
    
    if didHit then
        weapon:DoDamage(damage, target, endPoint, direction, surface, altMode)
    end
    
    return didHit, target, endPoint, surface
    
end


/**
 * Returns true if the passed in entity is under the control of a client (i.e. either the
 * entity for which SetControllingPlayer has been called on the server, or one
 * of its children).
 */
function GetIsClientControlled(entity)

    PROFILE("NS2Utility:GetIsClientControlled")
    
    local parent = entity:GetParent()
    
    if parent ~= nil and GetIsClientControlled(parent) then
        return true
    end
    
    if Server then
        return Server.GetOwner(entity) ~= nil
    else
        return Client.GetLocalPlayer() == entity
    end

end

gEventTiming = {}
function LogEventTiming()
    if Shared then
        table.insert(gEventTiming, Shared.GetTime())
    end
end

function GetEventTimingString(seconds)

    local logTime = Shared.GetTime() - seconds
    
    local count = 0
    for index, time in ipairs(gEventTiming) do
    
        if time >= logTime then
            count = count + 1
        end
        
    end
    
    return string.format("%d events in past %d seconds (%.3f avg delay).", count, seconds, seconds/count)
    
end

function GetIsVortexed(entity)
    return entity and HasMixin(entity, "VortexAble") and entity:GetIsVortexed()
end

if Client then

    function AdjustInputForInversion(input)
    
        // Invert mouse if specified in options.
        local invertMouse = Client.GetOptionBoolean(kInvertedMouseOptionsKey, false)
        if invertMouse then
            input.pitch = -input.pitch
        end
        
    end
    
    local kMaxPitch = Math.Radians(89.9)
    function ClampInputPitch(input)
        input.pitch = Math.Clamp(input.pitch, -kMaxPitch, kMaxPitch)
    end
    
    // &ol& = order location
    // &ot& = order target entity name
    function TranslateHintText(text)
    
        local translatedText = text
        local player = Client.GetLocalPlayer()
        
        if player and HasMixin(player, "Orders") then
        
            local order = player:GetCurrentOrder()
            if order then
            
                local orderDestination = order:GetLocation()
                local location = GetLocationForPoint(orderDestination)
                local orderLocationName = location and location:GetName() or ""
                translatedText = string.gsub(translatedText, "&ol&", orderLocationName)
                
                local orderTargetEntityName = LookupTechData(order:GetParam(), kTechDataDisplayName, "<entity name>")
                translatedText = string.gsub(translatedText, "&ot&", orderTargetEntityName)
                
            end
            
        end
        
        return translatedText
        
    end
    
end

gSpeedDebug = nil

function SetSpeedDebugText(text, ...)

    if gSpeedDebug then
    
        local result = string.format(text, ...)
    
        gSpeedDebug:SetDebugText(result)
    end
    
end

// returns pairs of impact point, entity
function TraceBullet(player, weapon, startPoint, direction, throughHallucinations, throughUnits)

    local hitInfo = {}
    local lastHitEntity = player
    local endPoint = startPoint + direction * 1000
    
    local maxTraces = 3
    
    for i = 1, maxTraces do
    
        local trace = Shared.TraceRay(startPoint, endPoint, CollisionRep.Damage, PhysicsMask.Bullets, EntityFilterTwo(lastHitEntity, weapon))
        
        if trace.fraction ~= 1 then
        
            table.insertunique(hitInfo, { EndPoint = trace.endPoint, Entity = trace.entity } )

            if trace.entity and (trace.entity:isa("Hallucination") and throughHallucinations == true) or throughUnits == true then
                startPoint = Vector(trace.endPoint)
                lastHitEntity = trace.entity
            else
                break
            end    
        
        else
            break
        end    
        
    end

    return hitInfo

end

-- add comma to separate thousands
function CommaValue(amount)
    local formatted = ""
    if amount ~= nil then
        formatted = amount
        while true do  
            formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
            if (k==0) then
                break
            end
        end
    end
    return formatted
end

// Look for "BIND_" in the string and substitute with key to press
// ie, "Press the BIND_Buy key to evolve to a new lifeform or to gain new upgrades." => "Press the B key to evolve to a new lifeform or to gain new upgrades."
function SubstituteBindStrings(tipString)

    local substitutions = {}
    for word in string.gmatch(tipString, "BIND_(%a+)") do
    
        local bind = GetPrettyInputName(word)
        //local bind = BindingsUI_GetInputValue(word)
        assert(type(bind) == "string", tipString)
        tipString = string.gsub(tipString, "BIND_" .. word, bind)
    end
    
    return tipString
    
end

// Look up texture coordinates in kInventoryIconsTexture
// Used for death messages, inventory icons, and abilities drawn in the alien "energy ball"
gTechIdPosition = nil
function GetTexCoordsForTechId(techId)

    local x1 = 0
    local y1 = 0
    local x2 = kInventoryIconTextureWidth
    local y2 = kInventoryIconTextureHeight
    
    if not gTechIdPosition then
    
        gTechIdPosition = {}
        
        // marine weapons
        gTechIdPosition[kTechId.Rifle] = kDeathMessageIcon.Rifle
        gTechIdPosition[kTechId.Pistol] = kDeathMessageIcon.Pistol
        gTechIdPosition[kTechId.Axe] = kDeathMessageIcon.Axe
        gTechIdPosition[kTechId.Shotgun] = kDeathMessageIcon.Shotgun
        gTechIdPosition[kTechId.Flamethrower] = kDeathMessageIcon.Flamethrower
        gTechIdPosition[kTechId.GrenadeLauncher] = kDeathMessageIcon.Grenade
    end
    
    local position = gTechIdPosition[techId]
    
    if position then
    
        y1 = (position - 1) * kInventoryIconTextureHeight
        y2 = y1 + kInventoryIconTextureHeight
    
    end
    
    return x1, y1, x2, y2

end