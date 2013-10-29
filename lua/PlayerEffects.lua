// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\PlayerEffects.lua
//
//    Created by:   Charlie Cleveland (charlie@unknownworlds.com)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

kPlayerEffectData = 
{

    strafe_jump =
    {
        effects =
        {
            {player_sound = "sound/NS2.fev/marine/common/sprint_start", done = true},
        }
    },
        
    jump =
    {
        jumpSoundEffects =
        {
            {player_sound = "sound/NS2.fev/marine/common/jump", classname = "Avatar", done = true},
        },
    },
    
    footstep =
    {
        footstepSoundEffects =
        {
            
            // Backpedal
            {sound = "sound/NS2.fev/materials/metal/backpedal_left", left = true, forward = false, surface = "metal", done = true},
            {sound = "sound/NS2.fev/materials/metal/backpedal_right", left = false, forward = false, surface = "metal", done = true},
            {sound = "sound/NS2.fev/materials/thin_metal/backpedal_left", left = true, forward = false, surface = "thin_metal", done = true},
            {sound = "sound/NS2.fev/materials/thin_metal/backpedal_right", left = false, forward = false, surface = "thin_metal", done = true},
            {sound = "sound/NS2.fev/materials/rock/backpedal_left", left = true, forward = false, surface = "rock", done = true},
            {sound = "sound/NS2.fev/materials/rock/backpedal_right", left = false, forward = false, surface = "rock", done = true},
            
            // Normal walk
            {sound = "sound/NS2.fev/materials/metal/footstep_left_for_enemy", left = true, surface = "metal", enemy = true, done = true},
            {sound = "sound/NS2.fev/materials/metal/footstep_left", left = true, surface = "metal", done = true},
            {sound = "sound/NS2.fev/materials/metal/footstep_right_for_enemy", left = true, surface = "metal", enemy = true, done = true},
            {sound = "sound/NS2.fev/materials/metal/footstep_right", left = false, surface = "metal", done = true},
            
            {sound = "sound/NS2.fev/materials/thin_metal/footstep_left_for_enemy", left = true, surface = "thin_metal", enemy = true, done = true},
            {sound = "sound/NS2.fev/materials/thin_metal/footstep_left", left = true, surface = "thin_metal", done = true},
            {sound = "sound/NS2.fev/materials/thin_metal/footstep_right_for_enemy", left = false, surface = "thin_metal", enemy = true, done = true},
            {sound = "sound/NS2.fev/materials/thin_metal/footstep_right", left = false, surface = "thin_metal", done = true},
            
            {sound = "sound/NS2.fev/materials/organic/footstep_left_for_enemy", left = true, surface = "organic", enemy = true, done = true},
            {sound = "sound/NS2.fev/materials/organic/footstep_left", left = true, surface = "organic", done = true},
            {sound = "sound/NS2.fev/materials/organic/footstep_right_for_enemy", left = false, surface = "organic", enemy = true, done = true},
            {sound = "sound/NS2.fev/materials/organic/footstep_right", left = false, surface = "organic", done = true},
            
            {sound = "sound/NS2.fev/materials/rock/footstep_left_for_enemy", left = true, surface = "rock", enemy = true, done = true},
            {sound = "sound/NS2.fev/materials/rock/footstep_left", left = true, surface = "rock", done = true},
            {sound = "sound/NS2.fev/materials/rock/footstep_right_for_enemy", left = false, surface = "rock", enemy = true, done = true},
            {sound = "sound/NS2.fev/materials/rock/footstep_right", left = false, surface = "rock", done = true},
            
        },
    },
    
    land = 
    {
        landSoundEffects = 
        {
            {player_sound = "sound/NS2.fev/materials/thin_metal/fall", surface = "thin_metal", classname = "Avatar", done = true},
            {player_sound = "sound/NS2.fev/materials/rock/fall", surface = "rock", classname = "Avatar", done = true},
            {player_sound = "sound/NS2.fev/materials/metal/fall", classname = "Avatar", done = true},            
            
            {player_sound = "sound/NS2.fev/materials/organic/fall", surface = "organic", classname = "ReadyRoomPlayer", done = true},
            {player_sound = "sound/NS2.fev/materials/thin_metal/fall", surface = "thin_metal", classname = "ReadyRoomPlayer", done = true},
            {player_sound = "sound/NS2.fev/materials/rock/fall", surface = "rock", classname = "ReadyRoomPlayer", done = true},
            {player_sound = "sound/NS2.fev/materials/metal/fall", classname = "ReadyRoomPlayer", done = true},   
            
        },
        
        
    },
    
    taunt = 
    {
        tauntSound =
        {
            
            {sound = "sound/NS2.fev/marine/voiceovers/taunt_female", classname = "Avatar", sex = "female", done = true},
            {sound = "sound/NS2.fev/marine/voiceovers/taunt", classname = "Avatar", done = true},

        }
    },
}

GetEffectManager():AddEffectData("PlayerEffectData", kPlayerEffectData)
