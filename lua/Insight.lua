// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\Insight.lua
//
// Created by: Jon 'Huze' Hughes (jon@jhuze.com)
//
// Handles Tech Point network packets and team names
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

kGUILayerInsight = 10
kGreenColor = Color(0, 0.6117, 1, 1)
kPurpleColor = Color(1, 0.4941, 0, 1)
kPenToolColor = Color(1, 1, 1, 1)

local team1Name
local team2Name
local team1Score = 0
local team2Score = 0

function Insight_Clear()
    
end

local function SetTeamNames(newTeam1Name, newTeam2Name)

    team1Name = newTeam1Name
    team2Name = newTeam2Name
    local topBar = GetGUIManager():GetGUIScriptSingle("GUIInsight_TopBar")
    if topBar then
        topBar:SetTeams(team1Name, team2Name)
    end
    
end

local function SetTeamScores(newTeam1Score, newTeam2Score)

    if newTeam1Score == "+" then
        team1Score = team1Score + 1
    elseif newTeam1Score == "-" then
        team1Score = team1Score - 1
    elseif newTeam1Score == nil then
        team1Score = 0
    else
        team1Score = tonumber(newTeam1Score)
    end
    
    if newTeam2Score == "+" then
        team2Score = team2Score + 1
    elseif newTeam2Score == "-" then
        team2Score = team2Score - 1
    elseif newTeam2Score == nil then
        team2Score = 0
    else
        team2Score = tonumber(newTeam2Score)
    end
    
    local topBar = GetGUIManager():GetGUIScriptSingle("GUIInsight_TopBar")
    if topBar then
        topBar:SetScore(team1Score, team2Score)
    end  
    
end

function InsightUI_GetTeam1Name()
    return team1Name
end

function InsightUI_GetTeam2Name()
    return team2Name
end

function InsightUI_GetTeam1Score()
    return team1Score
end

function InsightUI_GetTeam2Score()
    return team2Score
end

local function HandleTeamsMessage(params)

    if params[1] == "teams" then
    
            if params[2] ~= nil and params[3] ~= nil then
                SetTeamScores(team1Score, team2Score)
                SetTeamNames(params[2], params[3])
            elseif params[2] == "swap" or params[2] == "switch" then
                SetTeamScores(team2Score, team1Score)
                SetTeamNames(team2Name, team1Name)
            elseif params[2] == "reset" or params[2] == "clear" then
                SetTeamScores(0, 0)
                SetTeamNames(nil, nil)
            end
            
    elseif params[1] == "team1" then
        SetTeamScores(team1Score, team2Score)
        SetTeamNames(params[2], nil)
    elseif params[1] == "team2" then
        SetTeamScores(team1Score, team2Score)    
        SetTeamNames(nil, params[2])
    end

end

local function OnConsoleTeams(param1, param2)
    HandleTeamsMessage({"teams", param1, param2})
end

local function OnConsoleTeam1(param1)
    HandleTeamsMessage({"team1", param1, nil})
end

local function OnConsoleTeam2(param1)
    HandleTeamsMessage({"team2", param1, nil})
end

local function OnConsoleScores(param1, param2)
    SetTeamScores(param1, param2)
end

local function OnConsoleScore1(param1)
    SetTeamScores(param1, team2Score)
end

local function OnConsoleScore2(param1)
    SetTeamScores(team1Score, param1)
end

/*function OnMessageChat(chat)

    if chat.message:sub(0,1) == "/" then
        params = {}
        for param in chat.message:gmatch("%w+") do 
            table.insert(params, string.lower(param))
        end

        HandleTeamsMessage(params)

    end
    
end*/

local function IntFromString(str)

    local num = tonumber(str)
    if num and num >1 then
        num = num/255
    end
    return num

end

local function OnConsolePenColor(r_or_ColorInt, g, b, a)
    
    if r_or_ColorInt ~= nil and g == nil then
    
        local ColorInt = tonumber(r_or_ColorInt)
        local color = ColorIntToColor(ColorInt)
        if color then
            kPenToolColor = color
        end
        
    else
    
        local rInt = IntFromString(r_or_ColorInt) or 1
        local gInt = IntFromString(g) or 1
        local bInt = IntFromString(b) or 1
        local aInt = IntFromString(a) or 1
        kPenToolColor = Color(rInt, gInt, bInt, aInt)
        
    end

end

Event.Hook("Console_teams", OnConsoleTeams )
Event.Hook("Console_team1", OnConsoleTeam1 )
Event.Hook("Console_team2", OnConsoleTeam2 )
Event.Hook("Console_scores", OnConsoleScores )
Event.Hook("Console_score1", OnConsoleScore1 )
Event.Hook("Console_score2", OnConsoleScore2 )
Event.Hook("Console_johnmadden", OnConsolePenColor )
Event.Hook("Console_jm", OnConsolePenColor )
Event.Hook("Console_pen", OnConsolePenColor )

local maxRTs = 1
local maxRes = 1
local maxKills = 1
local teams = { }

function Insight_GetTeamData(teamIndex)
    return teams[teamIndex]
end

function Insight_GetMaxKills()
    return maxKills
end

local function InitializeTeam(teamIndex)

    local startTime = PlayerUI_GetGameStartTime()
    local teamInfo = GetEntitiesForTeam("TeamInfo", teamIndex)
    local currentKills = teamInfo[1]:GetKills()
    teams[teamIndex] = {
    Kills = currentKills, KillPoints = {Vector(startTime, currentKills, 0)}}
    
end

local function UpdateTeamGraphs(time, teamIndex)

    local teamInfo = GetEntitiesForTeam("TeamInfo", teamIndex)
    local team = teams[teamIndex]
       
    local currentKills = teamInfo[1]:GetKills()
    local previousKills = team.Kills
    if currentKills ~= previousKills then
    
        maxKills = math.max(maxKills, currentKills)
        table.insert(team.KillPoints, Vector(time, currentKills, 0))
        team.Kills = currentKills
    
    end
    
end

local prevGameStartTime = -1
local function OnUpdateClient()

    // Gather Graph information
    if PlayerUI_GetHasGameStarted() and PlayerUI_IsASpectator() and PlayerUI_GetTeamNumber() == kSpectatorIndex then
    
        // Reset graphs if the game just started
        local startTime = PlayerUI_GetGameStartTime()
        if prevGameStartTime < PlayerUI_GetGameStartTime() then

            maxKills = 0
            InitializeTeam(kTeam1Index)
            InitializeTeam(kTeam2Index)
            prevGameStartTime = PlayerUI_GetGameStartTime()
            
        end
        
        local time = Shared.GetTime()
        UpdateTeamGraphs(time, kTeam1Index)
        UpdateTeamGraphs(time, kTeam2Index)
        
    end
    
end
Event.Hook("UpdateClient", OnUpdateClient)