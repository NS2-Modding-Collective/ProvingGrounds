// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\FrozenModel.lua
//
//    Created by:   Mats Olsson (mats.olsson@matsotech.se)
//
// Shows a server trace of a single bullet and the coords of the likely target
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/Mixins/ModelMixin.lua")

class 'FrozenModel' (Entity)

FrozenModel.kMapName = "frozenmodel"

local networkVars =
{
    shooterId           = "entityid", // id of the shooter
    targetId            = "entityid", // the id of the target
    freezeTime          = "time", // used to figure out what event this freeze concerns
    lifetime            = "integer (0 to 255)", // how long to live
    // we store away 10 non-zero pose params, and hope we don't have more
    poseParamIndex0     = "integer (0 to 31)", // integer for pose param
    poseParamValue0     = "float", // value of pose param
    poseParamIndex1     = "integer (0 to 31)",
    poseParamValue1     = "float",
    poseParamIndex2     = "integer (0 to 31)", 
    poseParamValue2     = "float",
    poseParamIndex3     = "integer (0 to 31)", 
    poseParamValue3     = "float",
    poseParamIndex4     = "integer (0 to 31)", 
    poseParamValue4     = "float",
    poseParamIndex5     = "integer (0 to 31)", 
    poseParamValue5     = "float",
    poseParamIndex6     = "integer (0 to 31)", 
    poseParamValue6     = "float",
    poseParamIndex7     = "integer (0 to 31)", 
    poseParamValue7     = "float",
    poseParamIndex8     = "integer (0 to 31)", 
    poseParamValue8     = "float",
    poseParamIndex9     = "integer (0 to 31)", 
    poseParamValue9     = "float",    
}

AddMixinNetworkVars(BaseModelMixin, networkVars)
AddMixinNetworkVars(ModelMixin, networkVars)

if Server then

    FrozenModel.frozenModelTable = {} 

    // clean up the frozen models. Updates must be false for the frozen model, or we risk updating
    // the frozen animation state. So we clean up all models from a central place
    local function OnUpdateServer(deltaTime)
    
        local now = Shared.GetTime()
        for frozenId,_ in pairs(FrozenModel.frozenModelTable) do
        
            local frozen = Shared.GetEntity(frozenId)
            if frozen.freezeTime + frozen.lifetime < now then
            
                DestroyEntity(frozen)
                frozen = nil
                
            end
            
            if not frozen then
                FrozenModel.frozenModelTable[frozenId] = nil
            end
            
        end
        
    end

    Event.Hook("UpdateServer",                  OnUpdateServer)

end

local function GetCoords(target)

    if target.physicsModel then
        return target.physicsModel:GetCoords()
    end
    return target:GetCoords()
    
end

function FrozenModel:OnCreate()

    Entity.OnCreate(self)

    InitMixin(self, BaseModelMixin)
    InitMixin(self, ModelMixin)
    
    // need to keep updates going on the server for the timed callback to work
    self:SetUpdates(false)
    if Server then
    
        self.events = {}
        self:SetPropagate(Entity.Propagate_Callback)
        self.physicsType = PhysicsType.None // visual only
        self:SetIsVisible(true)
        self.shooterId = Entity.invalidId
        self.targetId = Entity.invalidId
        FrozenModel.frozenModelTable[self:GetId()] = true
        
    end
    
end

function FrozenModel:AddEvent(hitRegEvent)
    self.events[hitRegEvent:GetId()] = true
end

function FrozenModel:OnDestroy()

    if Server then
    
        for id,_ in pairs(self.events) do
        
            local event = Shared.GetEntity(id)
            if event then
                DestroyEntity(event)
            end
            
        end
        
    end
    
end


function FrozenModel:OnInitialized()

    if Client then
    
        self:OnUpdatePhysics()    
        
        local data = self:GetClientData()
        if data then
        
            self:WritePoseParams()
            self:UpdateAnimState()
            self:CompareWithModelData(data)
            
        end
        
    end
    
end

function FrozenModel:SetPoseParam(target, index, poseIndex, value)

    if index < 10 then
    
        self["poseParamIndex" .. index] = poseIndex
        self["poseParamValue" .. index] = value
        
    else
        Log("%s: Unable to store poseParam %s (%s)", target, poseIndex, value)
    end
    
end

function FrozenModel:ReadPoseParams(target)

    // as we don't know how many params we have, we just scan for the first 32
    // and save away all non-zero ones
    local paramIndex = 0
    for i = 0, 31 do
    
        local value = target.poseParams:Get(i)
        if value ~= 0 then
        
            self:SetPoseParam(target, paramIndex, i, value)
            paramIndex = paramIndex + 1
            
        end
        
    end
    
end 

function FrozenModel:WritePoseParams()

     // as we don't know how many params we have, we just scan for the first 32
    // and save away all non-zero ones
    local paramIndex = 0
    for i = 0, 9 do
    
        local index = self["poseParamIndex" .. i]
        local value = self["poseParamValue" .. i]
        if value ~= 0 then
            self.poseParams:Set(index, value)
        end
        
    end
    
end 

if Client then

    function FrozenModel:UpdateAnimState()
    
        local model = Shared.GetModel(self.modelIndex)
        local graph = Shared.GetAnimationGraph(self.animationGraphIndex)
        
        if graph then
        
            local passedTags = {}
            local time = self.freezeTime
            
            local state = self.animationState
            state:Update(graph, model, self.poseParams, time-50, time, passedTags)
            self.updated = true
            
        end
        
    end
    
end

function FrozenModel:Copy(shooter, target, lifetime)

    self.shooterId = shooter:GetId()
    self.targetId = target:GetId()
    self.lifetime = lifetime
    self.freezeTime = Shared.GetTime()
    self:ReadPoseParams(target)
    
    if target.lastRenderAnimationState then
        FrozenModel.Dump(target.lastRenderAnimationState)
    end
    
    local preOrigin = GetCoords(target).origin
    Shared.TraceRay(shooter:GetEyePos(), target:GetEngagementPoint(), CollisionRep.Damage, PhysicsMask.Bullets, EntityFilterOne(shooter))
    local postOrigin = GetCoords(target).origin
    
    if (preOrigin- postOrigin):GetLength() > 0.01 then
        Log("%s: origin changed from %s to %s on traceray hit", target, preOrigin, postOrigin)
    end
    self:CopyModelState(target)
    
    //Log("Dump %s/%s", target, self.freezeTime)
    //FrozenModel.Dump(FrozenModel.ExtractModelData(target))
    
    return self
    
end

function FrozenModel:VerifyPhysics(shooter)

    Log("VerifyPhysics")
    local traces1 = self:ScanRight(shooter)
    local traces2 = self:ScanRight(shooter)
    local startPoint = shooter:GetEyePos()
    
    for i, t1 in ipairs(traces1) do
    
        local t2 = traces2[i]
        if t1.entity ~= t2.entity then
        
            DebugLine(startPoint, t1.endPoint, self.lifetime, 1, 0, 0, 1)
            DebugLine(startPoint, t2.endPoint, self.lifetime, 0, 1, 0, 1)
            
        else
            DebugLine(startPoint, t1.endPoint, self.lifetime, 0, t1.entity and 1 or 0, 1, 1)          
        end
        
    end
    
end

// 
// We scan to our right, shooting many times until we hit the target entity, then
// repeating it to see that we get all the hits correctly (if the hit/miss picture changes between the
// rounds, we have a problem
//
function FrozenModel:ScanRight(shooter)

    local startPoint = shooter:GetEyePos()
    local viewAngles = shooter:GetViewAngles()
    local filter = EntityFilterOne(shooter)
    local range = 20
    local traces = {}
    
    for i = 1, 15 do
    
        local shootCoords = viewAngles:GetCoords()
        viewAngles.yaw = viewAngles.yaw + math.pi / 180
        local endPoint = startPoint + shootCoords.zAxis * range
        traces[i] = Shared.TraceRay(startPoint, endPoint, CollisionRep.Damage, PhysicsMask.Bullets, filter)
        
    end
    
    return traces
    
end

function FrozenModel:OnGetIsRelevant(player)
    return player:GetId() == self.shooterId
end

function FrozenModel:GetPhysicsModelAllowedOverride()

    // we are visual only
    return false
    
end


local function copyTable(table)

    local result = { }
    for k,v in pairs(table) do
        result[k] = v
    end
    
    return result
    
end

// we are interested in comparing most of the networkVars for the model mixin
local copiedFields = copyTable(ModelMixin.networkVars)

// strip away stuff we are not interested in
copiedFields["physicsType"] = nil
copiedFields["collisionRep"] = nil
copiedFields["physicsGroup"] = nil
copiedFields["physicsGroupFilterMask"] = nil

// the angles and coords are manually added
local comparedFields = copyTable(copiedFields)
comparedFields["angles"] = true
comparedFields["coords"] = true
comparedFields["freezeTime"] = true

/**
 * Copy our animation state to the given copy.
 */
function FrozenModel:CopyModelState(target)

    // Make sure to trace to this entity to update the physics model properly... 
    self:SetCoords(Copy(GetCoords(target)))
    self:SetAngles(Copy(target:GetAngles()))
    self:SetModel(Shared.GetModelName(target.modelIndex), Shared.GetAnimationGraphName(target.animationGraphIndex))
    
    for k,_ in pairs(copiedFields) do
        self[k] = Copy(target[k])
    end
    
end

    
/**
 * Add a client event for later comparison with frozen models from the server
 */
function FrozenModel.ExtractModelData(target)

    local data = { }
    
    // copy interesting fields target
    for k,_ in pairs(copiedFields) do
        data[k] = Copy(target[k])
    end
    
    // angles and coords are not fields, so copy them manually
    data["angles"] = Copy(target:GetAngles())
    data["coords"] = Copy(GetCoords(target))
    data["freezeTime"] = Shared.GetTime()
    
    return data
    
end

function FrozenModel.Dump(data)

    local firstTime = true
    for k,_ in pairs(comparedFields) do
        Log("    %30s: %s", k, data[k])
    end
    
end

function FrozenModel.DumpDiff(data1,data2)

    local firstTime = true
    for k,_ in pairs(comparedFields) do
    
        if data1[k] ~= data2[k] then
            Log("%30s: %s ~= %s", k, data1[k], data2[k])
        end
        
    end
    
end

if Client then

    local clientEventTable = {}
    
    function FrozenModel:OnDestroy()
    
        // remove any old stuff in the clientEventTable
        clientEventTable[self.freezeTime] = nil
        
    end
    
    function FrozenModel.AddClientEvent(shooter, target)
    
        if target.lastRenderAnimationState then
            FrozenModel.Dump(target.lastRenderAnimationState)
        end
        
        local preOrigin = GetCoords(target).origin
        Shared.TraceRay(shooter:GetEyePos(), target:GetEngagementPoint(), CollisionRep.Damage, PhysicsMask.Bullets, EntityFilterOne(shooter))
        
        local postOrigin = GetCoords(target).origin
        if (preOrigin- postOrigin):GetLength() > 0.01 then
            Log("%s: client origin changed from %s to %s on traceray hit", target, preOrigin, postOrigin)
        end
        
        local now = Shared.GetTime()
        local table = clientEventTable[now] or { }
        
        clientEventTable[now] = table
        table[target:GetId()] = FrozenModel.ExtractModelData(target)
        
    end
    
    function FrozenModel:GetClientData()
    
        local table = clientEventTable[self.freezeTime] 
        if not table then
            Log("No client data for %s", self.freezeTime)
            return nil
        end
        
        local data = table[self.targetId]
        if not data then
            Log("No target data for %s", self.targetId)
            return nil
        end
        
        return data
        
    end
    
    function FrozenModel:CompareWithModelData(data)
    
        local diffed = false
        local firstTime = true
        self.angles = self:GetAngles()
        self.coords = GetCoords(self)
        
        for k,_ in pairs(comparedFields) do
        
            local v1 = ToString(data[k])
            local v2 = ToString(self[k])
            
            if v1 ~= v2 then
            
                if firstTime then
                
                    Log("Diffs in event %s/%s", self.targetId, self.freezeTime)
                    firstTime = false
                    
                end
                
                Log("    %30s: %s != %s", k, v1, v2)
                diffed = true
                
            end
            
        end
        
        if not diffed then
            //Log("######## %s/%s: verified", self.targetId, self.freezeTime)
        end
        
    end
    
end

Shared.LinkClassToMap("FrozenModel", FrozenModel.kMapName, networkVars)