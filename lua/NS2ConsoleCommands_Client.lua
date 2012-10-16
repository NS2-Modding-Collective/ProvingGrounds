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

local kTestHudCinematic = PrecacheAsset("cinematics/hudTest.cinematic")
local kTestHudModel = PrecacheAsset("models/marine/observatory/observatory.model")
local hudCinematic = nil
local function OnCommandHUDCinematic()

    if hudCinematic then
        Client.DestroyHUDCinematic(hudCinematic)
    end
    
    hudCinematic = Client.CreateHUDCinematic()
    hudCinematic:SetCinematic(kTestHudCinematic)
    //hudCinematic:SetModel(kTestHudModel)
    hudCinematic:SetRepeatStyle(Cinematic.Repeat_Loop)
    hudCinematic:SetBackgroundMaterial("ui/hudTest.material")
    
    local vector1 = Vector(0, 0, 0)
    local vector2 = Vector(400, 300, 0)
    
    hudCinematic:SetPosition(vector1)
    hudCinematic:SetSize(vector2)

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
        Client.PlayMusic(name)
    end
    
end

local function OnCommandDebugCommander(vm)

    if Shared.GetCheatsEnabled() then    
        BuildUtility_SetDebug(vm)        
    end
    
end

Event.Hook("Console_tracereticle", OnCommandTraceReticle)
Event.Hook("Console_random_debug", OnCommandRandomDebug)
Event.Hook("Console_location", OnCommandLocation)
Event.Hook("Console_changegcsettingclient", OnCommandChangeGCSettingClient)
Event.Hook("Console_cents", OnCommandClientEntities)
Event.Hook("Console_hudcinematic", OnCommandHUDCinematic)
Event.Hook("Console_r_healthrings", OnCommandHealthRings)
Event.Hook("Console_reset_help", OnCommandResetHelp)
Event.Hook("Console_music", OnConsoleMusic)

Event.Hook("Console_debugcommander", OnCommandDebugCommander)