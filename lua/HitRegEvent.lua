// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\HitRegEvent.lua
//
//    Created by:   Mats Olsson (mats.olsson@matsotech.se)
//
// Shows a server trace of a single bullet towards a frozen target.
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/FrozenModel.lua")


class 'HitRegEvent' (Entity)

HitRegEvent.kMapName = "HitRegEvent"

local networkVars =
{
    frozenModelId       = "entityid", // id of the frozen model we aim at
    endPoint            = "vector", // where the bullet ended up (started in origin)
    hit                 = "boolean", // if it was a hit or not
    time                = "time", // when created
    sequenceNum         = "integer (0 to 15)", // events created on the same attack (shotguns)
    damage              = "float", // server calculated damage
    targetOrigin        = "vector", // target origin when shot at
    targetPhysicsOrigin = "vector", // target's reported physics model origin when shot at
    yaw                 = "float", // target yaw
    pitch               = "float", // target pitch
    roll                = "float", // target roll
}

local frozenModelCache = { }
local frozenModelCacheTime = 0

function HitRegEvent:OnCreate()

    Entity.OnCreate(self)
    
    self:SetPropagate(Entity.Propagate_Callback)
    
    // disable updating - we get destroyed by our frozen model
    self:SetUpdates(false)
    
end

local gLastRollAngle = 0
local gLastRollTime = 0

function RegisterHitEvent(shooter, sequenceNum, startPoint, trace, damage)
    
    //Log("RHE %s %s %s %s -> %s", shooter, sequenceNum, startPoint, damage, trace.entity)

    local target = trace.entity
    local now = Shared.GetTime()
    local hit = target and true
    if not target then
        target = DbgTracer.FindAimedAtTarget(shooter, startPoint, trace.endPoint)
    end
    if target then
        local angles = target:GetAngles()
        if gLastRollTime ~= now then
            gLastRollTime = now
            gLastRollAngle = angles.roll
        end
        
        if gLastRollAngle ~= angles.roll then
            Log("%s-%s: roll changed from %s to %s on same tick!", now, sequenceNum, gLastRollAngle, angles.roll)
        end

        if Server then
            //Log("hitreg for %s on %s", shooter, target)
            local hitRegEvent = CreateEntity(HitRegEvent.kMapName)
            hitRegEvent:Setup(shooter, sequenceNum, target, startPoint, trace.endPoint, hit, damage, shooter:GetClient().hitRegDuration)  
        else
            // save up data to compare with incoming server events
            //Log("hitreg for %s on %s", shooter, target)
            local key = string.format("%s-%s", now, sequenceNum)
            clientEventTable[key] = {
                 shooterId = shooter:GetId(),
                 targetId = target:GetId(),
                 time = now, 
                 sequenceNum = sequenceNum, 
                 startPoint = startPoint,
                 endPoint = trace.endPoint,
                 targetOrigin = target:GetOrigin(),
                 targetPhysicsOrigin = target.physicsModel and target.physicsModel:GetCoords().origin or Vector(0,0,0),
                 yaw = angles.yaw,
                 pitch = angles.pitch,
                 roll = angles.roll,
                 damage = damage
            }
            
            FrozenModel.AddClientEvent(shooter, target)
        end
    else
        Log("No plausible target found for %s %s-%s", shooter, now, sequenceNum) 
    end
end


function HitRegEvent:OnInitialized()
    if Client then 
    
        // we need to wait until we are synchronized before we can do anything
        serverEventTable[self:GetId()] = true
            
    end
    
end

if Server then
/**
 * Get a frozen model for a shot from shooter to target at the given time. 
 * Use caching to allow shotgun-like weapons to send multiple hit regs on one model.
 */
function HitRegEvent:GetFrozenModel(shooter, target, time, lifetime)
    if frozenModelCacheTime ~= time then
        frozenModelCache = {}
        frozenModelCacheTime = time
    end
    local key = shooter:GetId() .. "," .. target:GetId()
    local result = frozenModelCache[key]
    result = result and Shared.GetEntity(result)
    if not result then
        result = CreateEntity(FrozenModel.kMapName)
        result:Copy(shooter, target, lifetime)
        frozenModelCache[key] = result:GetId()
    end
    return result
end

/**
 * Setup the hit-reg event. 
 */
function HitRegEvent:Setup(shooter, sequenceNum, target, startPoint, endPoint, hit, damage, lifetime)
    local now = Shared.GetTime()
    local frozenModel = self:GetFrozenModel(shooter, target, now, lifetime)
    if frozenModel then
        self.frozenModelId = frozenModel:GetId()
        frozenModel:AddEvent(self)
    else
        DestroyEntity(self)
        return nil
    end
    self:SetOrigin(startPoint)
    self.targetOrigin = target:GetOrigin()
    self.endPoint = endPoint
    self.hit = hit
    self.damage = damage
    self.sequenceNum = sequenceNum
    self.time = Shared.GetTime()
    local angles = target:GetAngles()
    self.yaw = angles.yaw
    self.pitch = angles.pitch
    self.roll = angles.roll
    self.targetPhysicsOrigin = target.physicsModel and target.physicsModel:GetCoords().origin or Vector(0,0,0)

    return self
end

// we are relevent if our frozen model is
function HitRegEvent:OnGetIsRelevant(player)

    local frozenModel = Shared.GetEntity(self.frozenModelId)
    return frozenModel and frozenModel:OnGetIsRelevant(player)

end
end


if Client then

// register the same data on the client. Match up later.
clientEventTable = clientEventTable or {}

// incoming hitregevents from server is stored here (key is id)
serverEventTable = serverEventTable or {}

// log the actual and predicted amount of damage in the client log table, which we flush now and then
clientLogTable = clientLogTable or {}

// avoid doing too much work
local lastWorkTime = 0

function HitRegEvent:Match(clientEvent)

    local frozenModel = Shared.GetEntity(self.frozenModelId)
    local lifetime = frozenModel and frozenModel.lifetime or 10
    
    // show it in blue if the damage for this event differs, red if a hit or yellow if a miss
    local epDiff = (self.endPoint - clientEvent.endPoint):GetLength()

    if not Client.hitRegLogOnly then 
        local diffs = epDiff > 0.001
        local red, yellow, blue = { 1, 0, 0, 1 }, { 1, 1, 0, 1 }, { 0, 0, 1, 1 }
        local color = diffs and blue or ( self.hit and red or yellow)
        
        DebugLine(self:GetOrigin(), self.endPoint, lifetime, unpack(color)) 

        if self.hit then
            if diffs then
                DebugBox(clientEvent.endPoint, clientEvent.endPoint, Vector(0.05,0.05,0.05), lifetime, unpack(blue))
            end
            DebugBox(self.endPoint, self.endPoint, Vector(0.05,0.05,0.05), lifetime, unpack(red))
        end
    end
    
    // log if startpoint mismatch
    local origDelta = (self:GetOrigin() - clientEvent.startPoint):GetLength()
    if origDelta > 0.001 then
        Log("%s-%s :origin mismatch by %s", self.time, self.sequenceNum, origDelta)
    end
    if epDiff > 0.001 then
        Log("%s-%s :endpoint mismatch by %s", self.time, self.sequenceNum, epDiff)
    end
    self:CompPos("targetOrigin", clientEvent)
    if self:CompPos("targetPhysicsOrigin", clientEvent) then
        local serverD = (self.targetOrigin - self.targetPhysicsOrigin):GetLength()
        local clientD = (clientEvent.targetOrigin - clientEvent.targetPhysicsOrigin):GetLength()
        Log("serverD %s, clientD %s", serverD, clientD) 
    end
    
    self:CompAngle("yaw", clientEvent)
    self:CompAngle("pitch", clientEvent)
    self:CompAngle("roll", clientEvent)
 
    // we sum up hit events in the clientLogTable
    local targetId = clientEvent.targetId
    if targetId then
        entry = clientLogTable[targetId] or { damage = 0, pDamage = 0 }
        entry.damage = entry.damage + self.damage
        entry.pDamage = entry.pDamage + clientEvent.damage
        entry.time = Shared.GetTime()
        local target = Shared.GetEntity(targetId)
        if target then
            entry.targetName = string.format("%s-%s", target:GetClassName(), targetId)
        end
        clientLogTable[targetId] = entry 
    end
    
end

function HitRegEvent:CompAngle(name, clientEvent)
    local serverA = DegreesTo360(math.deg(self[name]))
    local clientA = DegreesTo360(math.deg(clientEvent[name]))
    local diff = math.abs(serverA - clientA)
    if diff > 0.001 then
        Log("%s-%s: %s diff (deg) %s (server %s, client %s)", self.time, self.sequenceNum, name, diff, serverA, clientA)
    end
end

function HitRegEvent:CompPos(name, clientEvent)
    local serverV = self[name]
    local clientV = clientEvent[name]
    local diff = (serverV - clientV):GetLength()
    if diff > 0.001 then
        Log("%s-%s: %s diff %s (server %s, client %s)", self.time, self.sequenceNum, name, diff, serverV, clientV)
        return true
    end
    return false
end



local function OnUpdateClient(deltaTime)
    local now = Shared.GetTime()
    // empty any serverEvents
    for id,_ in pairs(serverEventTable) do
        local event = Shared.GetEntity(id)
        if event then
            local key = string.format("%s-%s", event.time, event.sequenceNum)
            local clientEvent = clientEventTable[key]
            if clientEvent then
                event:Match(clientEvent)
                clientEventTable[key] = nil
            end
        end
    end
    
    if now + 0.5 > lastWorkTime then
    
        lastWorkTime = now
    
        local deleteTable = {}
        // log hits on entities that we haven't hurt for 0.8 seconds
        for id,log in pairs(clientLogTable) do
            if now - log.time > 0.8 then
                Log("Hit %s for %s actual damage, %s predicted", log.targetName, log.damage, log.pDamage)                                
                deleteTable[id] = true
            end
        end
        
        for key,_ in pairs(deleteTable) do
            clientLogTable[key] = nil
        end
        
        deleteTable = {}
        // run through the clientEventTable and log/remove any old events
        for key,clientEvent in pairs(clientEventTable) do
            if now - clientEvent.time > 2 then
                Log("Unmatched client event found, %s, %s->%s", key, clientEvent.shooterId, clientEvent.targetId )
                deleteTable[key] = true
            end
        end
        
        for key,_ in pairs(deleteTable) do
            clientEventTable[key] = nil
        end
    end
        
    serverEventTable = {}
end

Event.Hook("UpdateClient",              OnUpdateClient)

end

Shared.LinkClassToMap("HitRegEvent", HitRegEvent.kMapName, networkVars)