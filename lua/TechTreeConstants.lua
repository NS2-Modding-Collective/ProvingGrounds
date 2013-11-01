// ======= Copyright (c) 2003-2012, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\TechTreeConstants.lua
//
//    Created by:   Charlie Cleveland (charlie@unknownworlds.com)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

local gTechIdToString = {}

local function createTechIdEnum(table)

    for i = 1, #table do    
        gTechIdToString[table[i]] = i  
    end
    
    return enum(table)

end

kTechId = createTechIdEnum({
    
    'None', 
    
    'VoteConcedeRound',
    

    'ReadyRoomPlayer', 
    
    /////////////
    // Avatars //
    /////////////
    
    // Avatar classes + spectators
    'Avatar', 'GreenAvatar', 'PurpleAvatar', 'Spectator', 'MarineSpectator',
    
    // Weapons 
    'Rifle', 'Pistol', 'Shotgun', 'HeavyRifle', 'GrenadeLauncher', 'RocketLauncher', 'Flamethrower', 'Axe', 
    
    // Mapping Entities
    
    'JumpPadTrigger', 'ItemSpawn',
    
    'ItemPickups', 'AmmoPack', 'MedPack', 'CatPack',
  
    'GameStarted',
    
    'DeathTrigger',

    // Maximum index
    'Max'
    
    })
    
function StringToTechId(string)
    return gTechIdToString[string] or kTechId.None
end    

// Increase techNode network precision if more needed
kTechIdMax  = kTechId.Max