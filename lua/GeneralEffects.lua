// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\GeneralEffects.lua
//
//    Created by:   Charlie Cleveland (charlie@unknownworlds.com)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

kGeneralEffectData = 
{  
    spawn =
    {
        spawnEffects =
        {
            // marine
            {cinematic = "", classname = "WeaponAmmoPack", done = true},            
            {cinematic = "cinematics/marine/spawn_item.cinematic", classname = "AmmoPack", done = true},
            {cinematic = "cinematics/marine/spawn_item.cinematic", classname = "MedPack", done = true},
            {cinematic = "cinematics/marine/spawn_item.cinematic", classname = "Mine", done = true},
            
        },
        
        spawnSoundEffects =
        {
            // marine
            {sound = "", classname = "WeaponAmmoPack", done = true},
            {sound = "sound/NS2.fev/marine/structures/generic_spawn", classname = "AmmoPack", done = true},
            {sound = "sound/NS2.fev/marine/structures/generic_spawn", classname = "MedPack", done = true},
                       
            // common
            {sound = "sound/NS2.fev/common/connect", classname = "ReadyRoomPlayer", done = true},
        }
        
    },

    join_team =
    {
        joinTeamEffects =
        {
            {sound = "sound/NS2.fev/alien/common/join_team", isalien = true, done = true},
            {sound = "sound/NS2.fev/marine/common/join_team", isalien = false, done = true},
        },
    },
    
    idle =
    {
        idleSounds =
        {            
            {sound = "sound/NS2.fev/marine/flamethrower/idle", classname = "Flamethrower", done = true},
        },
    },
    
    idle_stop =
    {
        idleStopSounds =
        {            
        }        
    },    
    
    // Called whenever the object is destroyed (this will happen after death, but also when an entity is deleted
    // due to a round reset. Called only on the server.
    on_destroy =
    {
        destroySoundEffects = 
        {
            // Delete all parented or looping sounds and effects associated with this object
            {stop_effects = "", classname = "Actor"},
        },
    },
    
    death =
    {
        // Structure effects in other lua files
        // If death animation isn't played, and ragdoll isn't triggered, entity will be destroyed and removed immediately.
        // Otherwise, effects are responsible for setting ragdoll/death time.
        generalDeathCinematicEffects =
        {
            {cinematic = "cinematics/marine/exo/explosion.cinematic", classname = "Exo", done = true},
            // TODO: Substitute material properties?
            {cinematic = "cinematics/materials/%s/grenade_explosion.cinematic", classname = "Grenade", done = true},
        },
      
        // Play world sound instead of parented sound as entity is going away?
        deathSoundEffects = 
        {
            {sound = "sound/NS2.fev/marine/structures/generic_death", classname = "Exo", done = true},
            
            {sound = "sound/NS2.fev/marine/common/death", classname = "Marine", done = true},
            {sound = "sound/NS2.fev/marine/structures/extractor_death", classname = "Extractor", done = true},
            {sound = "sound/NS2.fev/marine/structures/arc/death", classname = "ARC", done = true},
        },
        
    },
    
    // Unit catches on fire. Called on server only.
    fire_start =
    {
        fireStartEffects =
        {
            {parented_sound = "sound/NS2.fev/common/fire_small"},
        },
    },
    
    fire_stop =
    {
        fireStopEffects =
        {
            {stop_sound = "sound/NS2.fev/common/fire_small"},
        },
    },
       
    complete_order =
    {
        completeOrderSound =
        {
            {sound = "sound/NS2.fev/marine/voiceovers/complete"},
        }
    },
            
}

GetEffectManager():AddEffectData("GeneralEffectData", kGeneralEffectData)
