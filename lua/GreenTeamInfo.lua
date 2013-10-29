// =========================================================================
//
// lua/GreenTeamInfo.lua
//
// Team Specific Info
//
// Created by Andy 'SoulRider' Wilson for Proving Grounds
//
// ========================================================================

Script.Load("lua/TeamInfo.lua")

class 'GreenTeamInfo' (TeamInfo)

GreenTeamInfo.kMapName = "GreenTeamInfo"

local networkVars =
{

}

Shared.LinkClassToMap("GreenTeamInfo", GreenTeamInfo.kMapName, networkVars)
