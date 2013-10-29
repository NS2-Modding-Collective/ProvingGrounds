// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\NetworkMessages_Client.lua
//
//    Created by:   Charlie Cleveland (charlie@unknownworlds.com) and
//                  Max McGuire (max@unknownworlds.com)
//
// See the Messages section of the Networking docs in Spark Engine scripting docs for details.
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/InsightNetworkMessages_Client.lua")

function OnCommandPing(pingTable)

    local playerId, ping = ParsePingMessage(pingTable)    
    Scoreboard_SetPing(playerId, ping)
    
end

function OnCommandHitEffect(hitEffectTable)

    local position, doer, surface, target, showtracer, altMode, damage, direction = ParseHitEffectMessage(hitEffectTable)
    HandleHitEffect(position, doer, surface, target, showtracer, altMode, damage, direction)
    
end

// Show damage numbers for players.
function OnCommandDamage(damageTable)

    local target, amount, hitpos = ParseDamageMessage(damageTable)
    if target then
        Client.AddWorldMessage(kWorldTextMessageType.Damage, amount, hitpos, target:GetId())
    end
    
end

function OnCommandScores(scoreTable)

    local status = kPlayerStatus[scoreTable.status]
    if scoreTable.status == kPlayerStatus.Hidden then
        status = "-"
    elseif scoreTable.status == kPlayerStatus.Dead then
        status = Locale.ResolveString("STATUS_DEAD")
    elseif scoreTable.status == kPlayerStatus.Void then
        status = Locale.ResolveString("STATUS_VOID")
    elseif scoreTable.status == kPlayerStatus.Spectator then
        status = Locale.ResolveString("STATUS_SPECTATOR")
    end
    
    Scoreboard_SetPlayerData(scoreTable.clientId, scoreTable.entityId, scoreTable.playerName, scoreTable.teamNumber, scoreTable.score,
                             scoreTable.kills, scoreTable.deaths, scoreTable.isRookie,
                             status, scoreTable.isSpectator, scoreTable.assists)
    
end

function OnCommandOnResetGame()

    Scoreboard_OnResetGame()
    ResetLights()
    
end

function OnCommandDebugLine(debugLineMessage)
    DebugLine(ParseDebugLineMessage(debugLineMessage))
end

function OnCommandDebugCapsule(debugCapsuleMessage)
    DebugCapsule(ParseDebugCapsuleMessage(debugCapsuleMessage))
end

kWorldTextResolveStrings = { }
kWorldTextResolveStrings[kWorldTextMessageType.Damage] = "DAMAGE_TAKEN"
function OnCommandWorldText(message)

    local messageStr = string.format(Locale.ResolveString(kWorldTextResolveStrings[message.messageType]), message.data)
    Client.AddWorldMessage(message.messageType, messageStr, message.position)
    
end

function OnCommandJoinError(message)
    ChatUI_AddSystemMessage( Locale.ResolveString("JOIN_ERROR_TOO_MANY") )
end

function OnVoteConcedeCast(message)

    local text = string.format(Locale.ResolveString("VOTE_CONCEDE_BROADCAST"), message.voterName, message.votesMoreNeeded)
    ChatUI_AddSystemMessage(text)
    
end

function OnTeamConceded(message)

    if message.teamNumber == kMarineTeamType then
        ChatUI_AddSystemMessage(Locale.ResolveString("TEAM_MARINES_CONCEDED"))
    else
        ChatUI_AddSystemMessage(Locale.ResolveString("TEAM_ALIENS_CONCEDED"))
    end
    
end

local function OnCommandCreateDecal(message)
    
    local normal, position, materialName, scale = ParseCreateDecalMessage(message)
    
    local coords = Coords.GetTranslation(position)
    coords.yAxis = normal
    
    local randomAxis = Vector(math.random() * 2 - 0.9, math.random() * 2 - 1.1, math.random() * 2 - 1)
    randomAxis:Normalize()
    
    coords.zAxis = randomAxis
    coords.xAxis = coords.yAxis:CrossProduct(coords.zAxis)
    coords.zAxis = coords.xAxis:CrossProduct(coords.yAxis)
    
    coords.xAxis:Normalize()
    coords.yAxis:Normalize()
    
    Shared.CreateTimeLimitedDecal(materialName, coords, scale)

end
Client.HookNetworkMessage("CreateDecal", OnCommandCreateDecal)

local function OnSetClientIndex(message)
    Client.localClientIndex = message.clientIndex
end
Client.HookNetworkMessage("SetClientIndex", OnSetClientIndex)

local function OnSetServerHidden(message)
    Client.serverHidden = message.hidden
end
Client.HookNetworkMessage("ServerHidden", OnSetServerHidden)

local function OnSetClientTeamNumber(message)
    Client.localClientTeamNumber = message.teamNumber
end
Client.HookNetworkMessage("SetClientTeamNumber", OnSetClientTeamNumber)

local function OnMessageAutoConcedeWarning(message)

    local warningText = StringReformat(Locale.ResolveString("AUTO_CONCEDE_WARNING"), { time = message.time, teamName = message.team1Conceding and "Marines" or "Aliens" })
    ChatUI_AddSystemMessage(warningText)
    
end

local function OnCommandCameraShake(message)

    local intensity = ParseCameraShakeMessage(message)
    
    local player = Client.GetLocalPlayer()
    if player and player.SetCameraShake then
        player:SetCameraShake(intensity * 0.1, 5, 0.25)    
    end

end

Client.HookNetworkMessage("AutoConcedeWarning", OnMessageAutoConcedeWarning)

Client.HookNetworkMessage("Ping", OnCommandPing)
Client.HookNetworkMessage("HitEffect", OnCommandHitEffect)
Client.HookNetworkMessage("Damage", OnCommandDamage)
Client.HookNetworkMessage("JoinError", OnCommandJoinError)
Client.HookNetworkMessage("Scores", OnCommandScores)

Client.HookNetworkMessage("ResetGame", OnCommandOnResetGame)

Client.HookNetworkMessage("DebugLine", OnCommandDebugLine)
Client.HookNetworkMessage("DebugCapsule", OnCommandDebugCapsule)

Client.HookNetworkMessage("WorldText", OnCommandWorldText)

Client.HookNetworkMessage("VoteConcedeCast", OnVoteConcedeCast)
Client.HookNetworkMessage("TeamConceded", OnTeamConceded)
Client.HookNetworkMessage("CameraShake", OnCommandCameraShake)

