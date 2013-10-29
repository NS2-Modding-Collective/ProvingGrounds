// =========================================================================
//
// lua/PurpleTeamInfo.lua
//
// Team Specific Info
//
// Created by Andy 'SoulRider' Wilson for Proving Grounds
//
// ========================================================================

Script.Load("lua/TeamInfo.lua")

class 'PurpleTeamInfo' (TeamInfo)

PurpleTeamInfo.kMapName = "PurpleTeamInfo"

local networkVars =
{

}

Shared.LinkClassToMap("PurpleTeamInfo", PurpleTeamInfo.kMapName, networkVars)
