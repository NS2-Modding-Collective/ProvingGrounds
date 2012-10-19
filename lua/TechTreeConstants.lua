// ======= Copyright (c) 2003-2012, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\TechTreeConstants.lua
//
//    Created by:   Charlie Cleveland (charlie@unknownworlds.com)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

kTechId = enum({
    
    'None', 
    
   
    'ReadyRoomPlayer', 'Player', 
    'Avatar', 'Spectator', 'MarineSpectator', 'RedSpectator',
 
    // Weapons 
    'Rifle', 'Pistol', 'Shotgun', 'Claw', 'Minigun', 'GrenadeLauncher', 'RocketLauncher', 'Flamethrower', 'Axe', 'AntiMatterSword',
	'Blink',
    'GameStarted',
    
    'DeathTrigger',

    // Maximum index
    'Max'
    
    })

// Increase techNode network precision if more needed
kTechIdMax  = kTechId.Max

// Tech types
kTechType = enum({ 'Invalid', 'Action', 'Activation', 'Special', 'Passive' })
