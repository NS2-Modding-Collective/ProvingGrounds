// ======= Copyright (c) 2012, Unknown Worlds Entertainment, Inc. All rights reserved. ============
//    
// lua\DamageEffects.lua    
//    
//    Created by:   Andreas Urwalek (andi@unknownworlds.com)
//
//    Effect defination for all damage sources and targets. Including target entities and world geometry surface.
//    
// ========= For more information, visit us at http://www.unknownworlds.com =====================

kDamageEffects =
{

    // Play ricochet sound for player locally for feedback (triggered if target > 5 meters away)
    hit_effect_local =
    {
        hitEffectLocalEffects =
        {

            // marine effects:

            {private_sound = "sound/NS2.fev/materials/metal/ricochet", doer = "ClipWeapon", done = true},

        },
    },
    
    damage_sound_target_local =
    {
        damageSounds =
        {
        }
    
    },
    
    damage_sound =
    {
        damageSounds =
        {
            {sound = "", surface = "nanoshield", world_space = true, done = true},
            {sound = "", surface = "flame", world_space = true, done = true},
            
            // marine effects:           
            {sound = "sound/NS2.fev/materials/metal/bash", surface = "metal", doer = "Rifle", alt_mode = true, world_space = true, done = true},
            {sound = "sound/NS2.fev/materials/organic/bash", surface = "organic", doer = "Rifle", alt_mode = true, world_space = true, done = true},
            {sound = "sound/NS2.fev/materials/organic/bash", surface = "infestation", doer = "Rifle", alt_mode = true, world_space = true, done = true},
            {sound = "sound/NS2.fev/materials/rock/bash", surface = "rock", doer = "Rifle", alt_mode = true, world_space = true, done = true},
            {sound = "sound/NS2.fev/materials/thin_metal/bash", surface = "thin_metal", doer = "Rifle", alt_mode = true, world_space = true, done = true},
            {sound = "sound/NS2.fev/materials/electronic/bash", surface = "electronic", doer = "Rifle", alt_mode = true, world_space = true, done = true},
            {sound = "sound/NS2.fev/materials/armor/bash", surface = "armor", doer = "Rifle", alt_mode = true, world_space = true, done = true},
            {sound = "sound/NS2.fev/materials/organic/bash", doer = "Rifle", alt_mode = true, world_space = true, done = true},
            
            {sound = "", doer = "Flamethrower", world_space = true, done = true},

            {sound = "sound/NS2.fev/materials/metal/ricochet", surface = "metal", doer = "ClipWeapon", world_space = true, done = true},
            {sound = "sound/NS2.fev/materials/rock/ricochet", surface = "rock", doer = "ClipWeapon", world_space = true, done = true},
            {sound = "sound/NS2.fev/materials/thin_metal/ricochet", surface = "thin_metal", doer = "ClipWeapon", world_space = true, done = true},
            {sound = "sound/NS2.fev/materials/electronic/ricochet", surface = "electronic", doer = "ClipWeapon", world_space = true, done = true},
            {sound = "sound/NS2.fev/materials/organic/ricochet", doer = "ClipWeapon", world_space = true, done = true},
            
            {sound = "sound/NS2.fev/materials/metal/axe", surface = "metal", doer = "Axe", world_space = true, done = true},
            {sound = "sound/NS2.fev/materials/rock/axe", surface = "rock", doer = "Axe", world_space = true, done = true},
            {sound = "sound/NS2.fev/materials/thin_metal/axe", surface = "thin_metal", doer = "Axe", world_space = true, done = true},
            {sound = "sound/NS2.fev/materials/electronic/axe", surface = "electronic", doer = "Axe", world_space = true, done = true},
            {sound = "sound/NS2.fev/materials/armor/axe", surface = "armor", doer = "Axe", world_space = true, done = true},
            {sound = "sound/NS2.fev/materials/organic/axe", doer = "Axe", world_space = true, done = true},
            
        }
    },
    
    
    damage_decal =
    {
        damageDecals = 
        {
                  
            // marine blood 
            {decal = {{.25, "cinematics/vfx_materials/decals/marine_blood_01.material"}, 
                      {.25, "cinematics/vfx_materials/decals/marine_blood_02.material"}, 
                      {.25, "cinematics/vfx_materials/decals/marine_blood_03.material"}, 
                      {.25, "cinematics/vfx_materials/decals/marine_blood_04.material"}}, scale = 2, surface = "flesh", done = true}, 

                                  
            // surface marine weapons
            {decal = "cinematics/vfx_materials/decals/clawmark_01.material", scale = 0.35, doer = "Axe", done = true},
            {decal = "cinematics/vfx_materials/decals/clawmark_01.material", scale = 0.35, doer = "Rifle", alt_mode = true, done = true},            
            {decal = "cinematics/vfx_materials/decals/bullet_hole_01.material", scale = 0.125, doer = "Rifle", alt_mode = false, done = true},        
            {decal = "cinematics/vfx_materials/decals/bullet_hole_01.material", scale = 0.125, doer = "Shotgun", done = true},        
            {decal = "cinematics/vfx_materials/decals/bullet_hole_01.material", scale = 0.125, doer = "Pistol", done = true}, 
        },    
    },

    // triggered client side for the shooter, all other players receive a message from the server
    damage =
    {
    
        damageEffects =
        {
            {player_cinematic = "cinematics/materials/flame/flame.cinematic", surface = "flame", done = true},            
        
            // marine effects:
            {player_cinematic = "cinematics/materials/%s/bash.cinematic", doer = "Rifle", alt_mode = true, done = true},
            {player_cinematic = "cinematics/materials/%s/ricochetHeavy.cinematic", doer = "Shotgun", done = true},
            {player_cinematic = "cinematics/materials/%s/ricochet.cinematic", doer = "ClipWeapon", done = true},
            {player_cinematic = "cinematics/materials/%s/axe.cinematic", doer = "Axe", done = true},
                        
        },        
    },

    // effects are played every 3 seconds, client side only
    damaged =
    {
        damagedEffects =
        {
            // marine damaged effects
            {cinematic = "", classname = "Player", done = true},
        }
    },
}

GetEffectManager():AddEffectData("DamageEffects", kDamageEffects)