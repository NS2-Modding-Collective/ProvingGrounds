// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\ConsoleCommands_Client.lua
//
//    Created by:   Charlie Cleveland (charlie@unknownworlds.com) and
//                  Max McGuire (max@unknownworlds.com)
//
// Only loaded when game rules are set and propagated to client.
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

local function OnCommandTraceReticle()
    if Shared.GetCheatsEnabled() then
        Print("Toggling tracereticle cheat.")        
        Client.GetLocalPlayer():ToggleTraceReticle()
    end
end

local function OnCommandRandomDebug()

    if Shared.GetCheatsEnabled() then
        local newState = not gRandomDebugEnabled
        gRandomDebugEnabled = newState
    end
    
end

local function OnCommandLocation(client)

    local player = Client.GetLocalPlayer()

    local locationName = player:GetLocationName()
    locationName = locationName == "" and "nowhere" or locationName
    Log("You(%s) are in \"%s\", position %s.", player, locationName, player:GetOrigin())
    
end

local function OnCommandChangeGCSettingClient(settingName, newValue)

    if Shared.GetCheatsEnabled() then
    
        if settingName == "setpause" or settingName == "setstepmul" then
            Shared.Message("Changing client GC setting " .. settingName .. " to " .. tostring(newValue))
            collectgarbage(settingName, newValue)
        else
            Shared.Message(settingName .. " is not a valid setting")
        end
        
    end
    
end

local function OnCommandClientEntities(entityType)

    if Shared.GetCheatsEnabled() then
        DumpEntityCounts(entityType)
    end
    
end

local gHealthringsDisabled = false
local function OnCommandHealthRings(state)

    local enabled = state == "true"
    local disabled = state == "false"
    
    if disabled then
        gHealthringsDisabled = true
    elseif enabled then
        gHealthringsDisabled = false
    end    

end

function GetShowHealthRings()
    return not gHealthringsDisabled
end

local function OnCommandResetHelp(helpName)

    if not helpName then
        Client.RemoveOption("help/")
    else
        Client.RemoveOption("help/" .. string.lower(helpName))
    end
    Print("Widget help reset.")
    
end

local function OnConsoleMusic(name)

    if Shared.GetCheatsEnabled() then
        Client.PlayMusic("sound/NS2.fev/" .. name)
    end
    
end

local function OnCommandDrawDecal(material, scale)

    if Shared.GetCheatsEnabled() then

        local player = Client.GetLocalPlayer()
        if player and material then
        
            // trace to a surface and draw the decal
            local startPoint = player:GetEyePos()
            local endPoint = startPoint + player:GetViewCoords().zAxis * 100
            local trace = Shared.TraceRay(startPoint, endPoint,  CollisionRep.Default, PhysicsMask.Bullets, EntityFilterAll())
            
            if trace.fraction ~= 1 then
            
                local coords = Coords.GetTranslation(trace.endPoint)
                coords.yAxis = trace.normal
                coords.zAxis = coords.yAxis:GetPerpendicular()
                coords.xAxis = coords.yAxis:CrossProduct(coords.zAxis)
            
                scale = scale and tonumber(scale) or 1.5
                
                Client.CreateTimeLimitedDecal(material, coords, scale)
                Print("created decal %s", ToString(material))
            
            end
        
        else
            Print("usage: drawdecal <materialname> <scale>")        
        end
    
    end

end

Event.Hook("Console_drawdecal", OnCommandDrawDecal)

Event.Hook("Console_tracereticle", OnCommandTraceReticle)
Event.Hook("Console_random_debug", OnCommandRandomDebug)
Event.Hook("Console_location", OnCommandLocation)
Event.Hook("Console_changegcsettingclient", OnCommandChangeGCSettingClient)
Event.Hook("Console_cents", OnCommandClientEntities)
Event.Hook("Console_r_healthrings", OnCommandHealthRings)
Event.Hook("Console_reset_help", OnCommandResetHelp)
Event.Hook("Console_music", OnConsoleMusic)
