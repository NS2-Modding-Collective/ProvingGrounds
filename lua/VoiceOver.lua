// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\VoiceOver.lua
//
// Created by: Andreas Urwalek (andi@unknownworlds.com)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

LEFT_MENU = 1
RIGHT_MENU = 2
kMaxRequestsPerSide = 5

kVoiceId = enum ({

    'None', 'VoteConcede', 

})

local function VoteConcedeRound(player)

    if player then
        GetGamerules():CastVoteByPlayer(kTechId.VoteConcedeRound, player)
    end  
    
end


local kSoundData = 
{

    [kVoiceId.VoteConcede] = { Function = VoteConcedeRound },
}
-- Initialize the female variants of the voice overs and precache.
for _, soundData in pairs(kSoundData) do

    if soundData.Sound ~= nil and string.len(soundData.Sound) > 0 then
    
        PrecacheAsset(soundData.Sound)
        
        soundData.SoundFemale = soundData.Sound .. "_female"
        PrecacheAsset(soundData.SoundFemale)
        
    end
    
end

function GetVoiceSoundData(voiceId)
    return kSoundData[voiceId]
end

local kRequestMenus = 
{
    ["Spectator"] = { },
    ["AlienSpectator"] = { },
    ["MarineSpectator"] = { },
    
}

function GetRequestMenu(side, className)

    local menu = kRequestMenus[className]
    if menu and menu[side] then
        return menu[side]
    end
    
    return { }
    
end

if Client then

    function GetVoiceDescriptionText(voiceId)
    
        local descriptionText = ""
        
        local soundData = kSoundData[voiceId]
        if soundData then
            descriptionText = Locale.ResolveString(soundData.Description)
        end
        
        return descriptionText
        
    end
    
    function GetVoiceKeyBind(voiceId)
    
        local soundData = kSoundData[voiceId]
        if soundData then
            return soundData.KeyBind
        end    
        
    end
    
end
