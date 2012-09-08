// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\DbgTracer
//
//    Created by:   Mats Olsson (mats.olsson@matsotech.se)
//
// Centralized handling of server-side tracing of targeting/shooting/projectiles
//

Script.Load("lua/DbgTracer_Commands.lua")

class 'DbgTracer'

DbgTracer.kZeroExtents = Vector(0,0,0)

DbgTracer.kClientAimColor = { 1, 1, 0, 0.8 } // yellow
DbgTracer.kClientMissColor = { 1, 0, 0, 0.8 } // red
DbgTracer.kClientHitColor = { 0, 1, 0, 0.8 } // green
DbgTracer.clientDuration = 10
DbgTracer.clientTracingEnabled = false

/**
  * Finds a suitable mobile target that the shooter was aiming at but missed.
  */
function DbgTracer.FindAimedAtTarget(shooter, startPoint, endPoint)
    // look for enemy players to mark up 
    local enemyTeamNumber = GetEnemyTeamNumber(shooter:GetTeamNumber())
    local targets = GetEntitiesMatchAnyTypesForTeam({ "Structure", "Player", "MAC", "Drifter" }, enemyTeamNumber)

    // find the closest one to our los
    local selValue, selCos = -10000,0
    local losVector = GetNormalizedVector(startPoint - endPoint)
    local entity = nil

    for i,target in ipairs(targets) do

        local targetVector = GetNormalizedVector(startPoint - target:GetOrigin())

        local cos = Math.DotProduct(losVector, targetVector)
        local range = (startPoint - target:GetOrigin()):GetLength()
        // fudge a bit to make closer targets better
        local value = cos - range * range * (1 - cos)

        if (entity == nil or value > selValue) then
            entity, selValue, selCos = target, value, cos
        end

    end   

     // if our best target isn't really that good, we require it to be close
    if entity and selCos < 0.8 and (entity:GetOrigin() - startPoint):GetLength() > 5 then
        entity = nil
    end
    return entity
end

function DbgTracer.GetBoundingBox(entity) 

    local model = Shared.GetModel(entity.modelIndex)  

    if (model ~= nil) then

        local min, max = model:GetExtents()
        local p = entity:GetOrigin()
        return { p + min, p + max }

    end

    // no model found, return a 2x2m cube
    local v1 = Vector(1,1,1)
    return { entity:GetOrigin() - v1, entity:GetOrigin() + v1 }
end


// this one is used for both client AND server
function OnCommandHitReg(client, logOnly, duration)

    if Shared.GetCheatsEnabled() then

        local player = nil
        
        if Client then
            // shift the argument on the client side...
            logOnly = client
            duration = logOnly

            player = Client.GetLocalPlayer()
            client = Client
        else
            if client then
                player = client:GetControllingPlayer()
            end
        end
        
        if client then  
    
            local enabled = not client.hitRegEnabled
            if duration or logOnly then
                enabled = true
            end
            duration = duration or "10"
            logOnly = logOnly or client.hitRegLogOnly or "false"
            
            if player then
                client.hitRegEnabled = enabled 
                client.hitRegLogOnly = logOnly ~= "false"
                client.hitRegDuration = tonumber(duration)
                Log("hitReg %s, logOnly %s, duration %s", client.hitRegEnabled, client.hitRegLogOnly, client.hitRegDuration)
            end
        
        end
        
    end    
        
end


if Client then

    function DbgTracer.MarkClientFire(shooter, startPoint)

        if not Shared.GetIsRunningPrediction() and DbgTracer.clientTracingEnabled  then
            //Shared.Message("Client; attack by " .. ToString(shooter) .. " from " .. ToString(startPoint) .. " at " .. Shared.GetTime()) 
            local viewVec   = shooter:GetViewAngles():GetCoords().zAxis
            local aimedAtTarget = DbgTracer.FindAimedAtTarget(shooter, startPoint, startPoint + viewVec)

            if aimedAtTarget then
                if DbgTracer.clientTracingEnabled then
                    // check if we hit along the view vector
                    local traceView = Shared.TraceRay(startPoint, startPoint + viewVec * 100, CollisionRep.Damage, PhysicsMask.Bullets, EntityFilterOne(shooter)) 
                    local color = DbgTracer.kClientMissColor 
                    if traceView.entity == aimedAtTarget then
                        color = DbgTracer.kClientHitColor
                    end
                    DebugLine(startPoint, startPoint + viewVec, DbgTracer.clientDuration, unpack(color))

                    local extents = aimedAtTarget:GetExtents()
                    local targetVec = aimedAtTarget:GetOrigin() + Vector(0,extents.y / 2, 0) - startPoint
                    targetVec:Normalize()
                    DebugLine(startPoint, startPoint + targetVec, DbgTracer.clientDuration, unpack(DbgTracer.kClientAimColor))   
                end
            end
        end
    end

    function OnCommandClientTrace()
        local now = Shared.GetTime()
        if now ~= DbgTracer.lastChangeTime then 
            DbgTracer.clientTracingEnabled = not DbgTracer.clientTracingEnabled 
            Shared.Message("Client tracing " .. (DbgTracer.clientTracingEnabled and "on" or "off"))
            DbgTracer.lastChangeTime = now
        end
    end

    function OnCommandClientTraceDur(dur)
        DbgTracer.clientDuration = tonumber(dur)
        Shared.Message("Client tracing duration " .. DbgTracer.clientDuration)
    end

    Event.Hook("Console_ctrace",             OnCommandClientTrace)
    Event.Hook("Console_ctracedur",          OnCommandClientTraceDur)

end

Event.Hook("Console_hitreg",                OnCommandHitReg)