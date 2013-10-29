// ======= Copyright (c) 2003-2010, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\NetworkMessages.lua
//
//    Created by:   Charlie Cleveland (charlie@unknownworlds.com) and
//                  Max McGuire (max@unknownworlds.com)
//
// See the Messages section of the Networking docs in Spark Engine scripting docs for details.
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================
Script.Load("lua/Globals.lua")
Script.Load("lua/TechTreeConstants.lua")
Script.Load("lua/InsightNetworkMessages.lua")
Script.Load("lua/SharedDecal.lua")

local kCameraShakeMessage =
{
    intensity = "float (0 to 1 by 0.01)"
}

Shared.RegisterNetworkMessage("CameraShake", kCameraShakeMessage)

function BuildCameraShakeMessage(intensity)
    
    local t = {}
    t.intensity = intensity
    return t

end

function ParseCameraShakeMessage(message)
    return message.intensity
end

local kCreateDecalMessage =
{
    normal = string.format("integer(1 to %d)", kNumIndexedVectors),
    posx = string.format("float (%d to %d by 0.05)", -kHitEffectMaxPosition, kHitEffectMaxPosition),
    posy = string.format("float (%d to %d by 0.05)", -kHitEffectMaxPosition, kHitEffectMaxPosition),
    posz = string.format("float (%d to %d by 0.05)", -kHitEffectMaxPosition, kHitEffectMaxPosition), 
    decalIndex = string.format("integer (1 to %d)", kNumSharedDecals),
    scale = "float (0 to 5 by 0.05)"
}

Shared.RegisterNetworkMessage("CreateDecal", kCreateDecalMessage)

function BuildCreateDecalMessage(normal, position, decalIndex, scale)   
 
    local t = { }
    t.normal = normal
    t.posx = position.x
    t.posy = position.y
    t.posz = position.z
    t.decalIndex = decalIndex
    t.scale = scale
    return t
    
end

function ParseCreateDecalMessage(message)
    return GetVectorFromIndex(message.normal), Vector(message.posx, message.posy, message.posz), GetDecalMaterialNameFromIndex(message.decalIndex), message.scale
end

function BuildSelectUnitMessage(teamNumber, unit, selected, keepSelection)

    assert(teamNumber)

    local t =  {}
    t.teamNumber = teamNumber
    t.unitId = unit and unit:GetId() or Entity.invalidId
    t.selected = selected == true
    t.keepSelection = keepSelection == true    
    return t

end

function ParseSelectUnitMessage(message)
    return message.teamNumber, Shared.GetEntity(message.unitId), message.selected, message.keepSelection
end

function BuildConnectMessage(isMale, avatarVariant)

    local t = { }
    t.isMale = isMale
    t.avatarVariant = avatarVariant
    return t
    
end

local kConnectMessage =
{
    isMale = "boolean",
    avatarVariant = "enum kAvatarVariant",
}
Shared.RegisterNetworkMessage("ConnectMessage", kConnectMessage)

local kSetPlayerVariantMessage = kConnectMessage
Shared.RegisterNetworkMessage("SetPlayerVariant", kSetPlayerVariantMessage)

local kHitEffectMessage =
{
    // TODO: figure out a reasonable precision for the position
    posx = string.format("float (%d to %d by 0.05)", -kHitEffectMaxPosition, kHitEffectMaxPosition),
    posy = string.format("float (%d to %d by 0.05)", -kHitEffectMaxPosition, kHitEffectMaxPosition),
    posz = string.format("float (%d to %d by 0.05)", -kHitEffectMaxPosition, kHitEffectMaxPosition),
    doerId = "entityid",
    surface = "enum kHitEffectSurface",
    targetId = "entityid",
    showtracer = "boolean",
    altMode = "boolean",
    damage = "integer (0 to 5000)",
    direction = string.format("integer(1 to %d)", kNumIndexedVectors),
}

function BuildHitEffectMessage(position, doer, surface, target, showtracer, altMode, damage, direction)

    local t = { }
    t.posx = position.x
    t.posy = position.y
    t.posz = position.z
    t.doerId = (doer and doer:GetId()) or Entity.invalidId
    t.surface = (surface and StringToEnum(kHitEffectSurface, surface)) or kHitEffectSurface.metal
    t.targetId = (target and target:GetId()) or Entity.invalidId
    t.showtracer = showtracer == true
    t.altMode = altMode == true
    t.damage = damage
    t.direction = direction or 1
    return t
    
end

function ParseHitEffectMessage(message)

    local position = Vector(message.posx, message.posy, message.posz)
    local doer = Shared.GetEntity(message.doerId)
    local surface = EnumToString(kHitEffectSurface, message.surface)
    local target = Shared.GetEntity(message.targetId)
    local showtracer = message.showtracer
    local altMode = message.altMode
    local damage = message.damage
    local direction = GetVectorFromIndex(message.direction)
    
    return position, doer, surface, target, showtracer, altMode, damage, direction
    
end

Shared.RegisterNetworkMessage( "HitEffect", kHitEffectMessage )

/*
For damage numbers
*/
local kDamageMessage =
{
    posx = string.format("float (%d to %d by 0.05)", -kHitEffectMaxPosition, kHitEffectMaxPosition),
    posy = string.format("float (%d to %d by 0.05)", -kHitEffectMaxPosition, kHitEffectMaxPosition),
    posz = string.format("float (%d to %d by 0.05)", -kHitEffectMaxPosition, kHitEffectMaxPosition),
    targetId = "entityid",
    amount = "float",
}

function BuildDamageMessage(target, amount, hitpos)
    
    local t = {}
    t.posx = hitpos.x
    t.posy = hitpos.y
    t.posz = hitpos.z
    t.amount = amount
    t.targetId = (target and target:GetId()) or Entity.invalidId
    return t
    
end

function ParseDamageMessage(message)
    local position = Vector(message.posx, message.posy, message.posz)
    return Shared.GetEntity(message.targetId), message.amount, position
end

Shared.RegisterNetworkMessage( "Damage", kDamageMessage )

// Tell players WHY they can't join a team
local kJoinErrorMessage =
{
    // Don't really need anything here
}
function BuildJoinErrorMessage()
    return {}
end
Shared.RegisterNetworkMessage( "JoinError", kJoinErrorMessage )

local kMaxPing = 999

local kPingMessage = 
{
    clientIndex = "integer",
    ping = "integer (0 to " .. kMaxPing .. ")"
}

function BuildPingMessage(clientIndex, ping)

    local t = {}
    
    t.clientIndex       = clientIndex
    t.ping              = math.min(ping, kMaxPing)
    
    return t
    
end

function ParsePingMessage(message)
    return message.clientIndex, message.ping
end

Shared.RegisterNetworkMessage( "Ping", kPingMessage )

kWorldTextMessageType = enum({ 'Damage' })
local kWorldTextMessage =
{
    messageType = "enum kWorldTextMessageType",
    data = "float",
    position = "vector"
}

function BuildWorldTextMessage(messageType, data, position)

    local t = { }
    
    t.messageType = messageType
    t.data = data
    t.position = position
    
    return t
    
end

Shared.RegisterNetworkMessage("WorldText", kWorldTextMessage)

// Scores 
local kScoresMessage = 
{
    clientId = "integer",
    entityId = "entityid",
    playerName = string.format("string (%d)", kMaxNameLength),
    teamNumber = string.format("integer (-1 to %d)", kRandomTeamType),
    score = string.format("integer (0 to %d)", kMaxScore),
    kills = string.format("integer (0 to %d)", kMaxKills),
    assists = string.format("integer (0 to %d)", kMaxKills),
    deaths = string.format("integer (0 to %d)", kMaxDeaths),
    isRookie = "boolean",
    status = "enum kPlayerStatus",
    isSpectator = "boolean",
}

function BuildScoresMessage(scorePlayer, sendToPlayer)

    local isEnemy = scorePlayer:GetTeamNumber() == GetEnemyTeamNumber(sendToPlayer:GetTeamNumber())
    
    local t = {}

    t.clientId = scorePlayer:GetClientIndex()
    t.entityId = scorePlayer:GetId()
    t.playerName = string.sub(scorePlayer:GetName(), 0, kMaxNameLength)
    t.teamNumber = scorePlayer:GetTeamNumber()
    t.score = 0
    t.kills = 0
    t.assists = 0
    t.deaths = 0
    
    if HasMixin(scorePlayer, "Scoring") then
    
        t.score = scorePlayer:GetScore()
        t.kills = scorePlayer:GetKills()
        t.assists = scorePlayer:GetAssistKills()
        t.deaths = scorePlayer:GetDeaths()
        
    end

    t.isRookie = ConditionalValue(isEnemy, false, scorePlayer:GetIsRookie())
    t.status = ConditionalValue(isEnemy, kPlayerStatus.Hidden, scorePlayer:GetPlayerStatusDesc())
    t.isSpectator = ConditionalValue(isEnemy, false, scorePlayer:isa("Spectator"))

    t.reinforcedTierNum = scorePlayer.reinforcedTierNum
    
    return t
    
end

Shared.RegisterNetworkMessage("Scores", kScoresMessage)

// For taking damage
local kTakeDamageIndicator =
{
    worldX = "float",
    worldZ = "float",
    damage = "float"
}

function BuildTakeDamageIndicatorMessage(sourceVec, damage)
    local t = {}
    t.worldX = sourceVec.x
    t.worldZ = sourceVec.z
    t.damage = damage
    return t
end

function ParseTakeDamageIndicatorMessage(message)
    return message.worldX, message.worldZ, message.damage
end

Shared.RegisterNetworkMessage("TakeDamageIndicator", kTakeDamageIndicator)

// Player id changed 
local kEntityChangedMessage = 
{
    oldEntityId = "entityid",
    newEntityId = "entityid",
}

function BuildEntityChangedMessage(oldId, newId)

    local t = {}
    
    t.oldEntityId = oldId
    t.newEntityId = newId
    
    return t
    
end

local kMutePlayerMessage = 
{
    muteClientIndex = "integer",
    setMute = "boolean"
}

function BuildMutePlayerMessage(muteClientIndex, setMute)

    local t = {}

    t.muteClientIndex = muteClientIndex
    t.setMute = setMute
    
    return t
    
end

function ParseMutePlayerMessage(t)
    return t.muteClientIndex, t.setMute
end

local kDebugLineMessage =
{
    startPoint = "vector",
    endPoint = "vector",
    lifetime = "float",
    r = "float",
    g = "float",
    b = "float",
    a = "float"
}

function BuildDebugLineMessage(startPoint, endPoint, lifetime, r, g, b, a)

    local t = { }
    
    t.startPoint = startPoint
    t.endPoint = endPoint
    t.lifetime = lifetime
    t.r = r
    t.g = g
    t.b = b
    t.a = a
    
    return t
    
end

function ParseDebugLineMessage(t)
    return t.startPoint, t.endPoint, t.lifetime, t.r, t.g, t.b, t.a
end

local kDebugCapsuleMessage =
{
    sweepStart = "vector",
    sweepEnd = "vector",
    capsuleRadius = "float",
    capsuleHeight = "float",
    lifetime = "float"
}

function BuildDebugCapsuleMessage(sweepStart, sweepEnd, capsuleRadius, capsuleHeight, lifetime)

    local t = { }
    
    t.sweepStart = sweepStart
    t.sweepEnd = sweepEnd
    t.capsuleRadius = capsuleRadius
    t.capsuleHeight = capsuleHeight
    t.lifetime = lifetime
    
    return t
    
end

function ParseDebugCapsuleMessage(t)
    return t.sweepStart, t.sweepEnd, t.capsuleRadius, t.capsuleHeight, t.lifetime
end

local kSetNameMessage =
{
    name = "string (" .. kMaxNameLength .. ")"
}
Shared.RegisterNetworkMessage("SetName", kSetNameMessage)

local kChatClientMessage =
{
    teamOnly = "boolean",
    message = string.format("string (%d)", kMaxChatLength + 1)
}

function BuildChatClientMessage(teamOnly, chatMessage)
    return { teamOnly = teamOnly, message = chatMessage }
end

local kChatMessage =
{
    teamOnly = "boolean",
    playerName = "string (" .. kMaxNameLength .. ")",
    locationId = "integer (-1 to 1000)",
    teamNumber = "integer (" .. kTeamInvalid .. " to " .. kSpectatorIndex .. ")",
    teamType = "integer (" .. kNeutralTeamType .. " to " .. kPurpleTeamType .. ")",
    message = string.format("string (%d)", kMaxChatLength + 1)
}

function BuildChatMessage(teamOnly, playerName, playerLocationId, playerTeamNumber, playerTeamType, chatMessage)

    local message = { }
    
    message.teamOnly = teamOnly
    message.playerName = playerName
    message.locationId = playerLocationId
    message.teamNumber = playerTeamNumber
    message.teamType = playerTeamType
    message.message = chatMessage
    
    return message
    
end

local kVoteConcedeCastMessage =
{
    voterName = "string (" .. kMaxNameLength .. ")",
    votesMoreNeeded = "integer (0 to 64)"
}

local kTeamConcededMessage =
{
    teamNumber = string.format("integer (-1 to %d)", kRandomTeamType)
}


function BuildRookieMessage(isRookie)

    local t = {}

    t.isRookie = isRookie
    
    return t
    
end

function ParseRookieMessage(t)
    return t.isRookie
end


local kGameEndMessage =
{
    win = "boolean"
}
Shared.RegisterNetworkMessage("GameEnd", kGameEndMessage)

Shared.RegisterNetworkMessage("EntityChanged", kEntityChangedMessage)
Shared.RegisterNetworkMessage("ResetGame", {} )

// Notifications
Shared.RegisterNetworkMessage("VoteConcedeCast", kVoteConcedeCastMessage)
Shared.RegisterNetworkMessage("TeamConceded", kTeamConcededMessage)

// Player actions
Shared.RegisterNetworkMessage("MutePlayer", kMutePlayerMessage)

// Chat
Shared.RegisterNetworkMessage("ChatClient", kChatClientMessage)
Shared.RegisterNetworkMessage("Chat", kChatMessage)

// Debug messages
Shared.RegisterNetworkMessage("DebugLine", kDebugLineMessage)
Shared.RegisterNetworkMessage("DebugCapsule", kDebugCapsuleMessage)

local kRookieMessage =
{
    isRookie = "boolean"
}
Shared.RegisterNetworkMessage( "SetRookieMode", kRookieMessage )


local kCommunicationStatusMessage = 
{
    communicationStatus = "enum kPlayerCommunicationStatus"
}

function BuildCommunicationStatus(communicationStatus)

    local t = {}

    t.communicationStatus = communicationStatus
    
    return t
    
end

function ParseCommunicationStatus(t)
    return t.communicationStatus
end

Shared.RegisterNetworkMessage( "SetCommunicationStatus", kCommunicationStatusMessage )

local kAutoConcedeWarning =
{
    time = "time",
    team1Conceding = "boolean"
}
Shared.RegisterNetworkMessage("AutoConcedeWarning", kAutoConcedeWarning)

Shared.RegisterNetworkMessage("SpectatePlayer", { entityId = "entityid"})
Shared.RegisterNetworkMessage("SwitchFromFirstPersonSpectate", { mode = "enum kSpectatorMode" })
Shared.RegisterNetworkMessage("SwitchFirstPersonSpectatePlayer", { forward = "boolean" })
Shared.RegisterNetworkMessage("SetClientIndex", { clientIndex = "integer" })
Shared.RegisterNetworkMessage("ServerHidden", { hidden = "boolean" })
Shared.RegisterNetworkMessage("SetClientTeamNumber", { teamNumber = string.format("integer (-1 to %d)", kRandomTeamType) })
Shared.RegisterNetworkMessage("WaitingForAutoTeamBalance", { waiting = "boolean" })
Shared.RegisterNetworkMessage("SetTimeWaveSpawnEnds", { time = "time" })
Shared.RegisterNetworkMessage("SetIsRespawning", { isRespawning = "boolean" })
Shared.RegisterNetworkMessage("SetDesiredSpawnPoint", { desiredSpawnPoint = "position" })

local kTeamNumDef = "integer (" .. kTeamInvalid .. " to " .. kSpectatorIndex .. ")"
Shared.RegisterNetworkMessage("DeathMessage", { killerIsPlayer = "boolean", killerId = "integer", killerTeamNumber = kTeamNumDef, iconIndex = "enum kDeathMessageIcon", targetIsPlayer = "boolean", targetId = "integer", targetTeamNumber = kTeamNumDef })
