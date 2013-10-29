// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\GeneralEffects.lua
//
//    Created by:   Charlie Cleveland (charlie@unknownworlds.com)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

kGeneralEffectData = 
{  
    spawn_weapon =
    {
        spawnWeaponEffects =
        {
            {cinematic = "cinematics/marine/spawn_item.cinematic", done = true},    
        }
    },
    
    spawn =
    {
        spawnEffects =
        {
            // marine
            {cinematic = "", classname = "WeaponAmmoPack", done = true},            
            {cinematic = "cinematics/marine/spawn_item.cinematic", classname = "AmmoPack", done = true},
            {cinematic = "cinematics/marine/spawn_item.cinematic", classname = "MedPack", done = true},
            {cinematic = "cinematics/marine/spawn_item.cinematic", classname = "CatPack", done = true},
            
        },
        
        spawnSoundEffects =
        {
            // marine
            {sound = "", classname = "WeaponAmmoPack", done = true},
            {sound = "sound/NS2.fev/marine/structures/generic_spawn", classname = "AmmoPack", done = true},
            {sound = "sound/NS2.fev/marine/structures/generic_spawn", classname = "MedPack", done = true},
            {sound = "sound/NS2.fev/marine/structures/generic_spawn", classname = "CatPack", done = true},
            
            
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
    
    catalyst =
    {
        catalystEffects =
        {
            // TODO: adjust sound effects (those are triggered multiple times during catalyst effect)
            {sound = "sound/NS2.fev/marine/common/catalyst", isalien = false},
            
        },
    },
    
    // Called whenever the object is destroyed (this will happen after death, but also when an entity is deleted
    // due to a round reset. Called only on the server.
    on_destroy =
    {
        destroySoundEffects = 
        {
            // Delete all parented or looping sounds and effects associated with this object
            {stop_effects = "", classname = "Entity"},
        },
    },
    
    death =
    {
        // Structure effects in other lua files
        // If death animation isn't played, and ragdoll isn't triggered, entity will be destroyed and removed immediately.
        // Otherwise, effects are responsible for setting ragdoll/death time.
        generalDeathCinematicEffects =
        {
            // TODO: Substitute material properties?
            {cinematic = "cinematics/materials/%s/grenade_explosion.cinematic", classname = "Grenade", done = true},
        },
      
        // Play world sound instead of parented sound as entity is going away?
        deathSoundEffects = 
        {
            {sound = "sound/NS2.fev/marine/common/death_female", classname = "Avatar", sex = "female", done = true},
            {sound = "sound/NS2.fev/marine/common/death", classname = "Avatar", done = true},
        },
        
    },
            
}

GetEffectManager():AddEffectData("GeneralEffectData", kGeneralEffectData)
