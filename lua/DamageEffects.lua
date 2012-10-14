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
            {private_sound = "sound/NS2.fev/marine/rifle/alt_hit_hard", doer = "ClipWeapon", isalien = true, surface = "ethereal", done = true},
            {private_sound = "sound/NS2.fev/marine/rifle/alt_hit_hard", doer = "ClipWeapon", isalien = true, surface = "umbra", done = true},
            {private_sound = "sound/NS2.fev/materials/organic/scrape", doer = "Shotgun", isalien = true, done = true},
            {private_sound = "sound/NS2.fev/marine/common/hit", doer = "ClipWeapon", isalien = true, done = true},
            {private_sound = "sound/NS2.fev/materials/metal/ricochet", doer = "ClipWeapon", done = true},
        
        },
    },
    
    damage_sound =
    {
        damageSounds =
        {
            {sound = "", surface = "flame", world_space = true, done = true},
            
            // marine effects:
            {sound = "sound/NS2.fev/marine/rifle/alt_hit_hard", surface = "ethereal", world_space = true, done = true},
            {sound = "sound/NS2.fev/marine/rifle/alt_hit_hard", surface = "hallucination", world_space = true, done = true},
            {sound = "sound/NS2.fev/marine/rifle/alt_hit_hard", surface = "umbra", doer = "ClipWeapon", world_space = true, done = true},
            {sound = "sound/NS2.fev/marine/rifle/alt_hit_hard", surface = "umbra", doer = "Minigun", world_space = true, done = true},
            
            {sound = "sound/NS2.fev/materials/metal/bash", surface = "metal", doer = "Rifle", alt_mode = true, world_space = true, done = true},
            {sound = "sound/NS2.fev/materials/organic/bash", surface = "organic", doer = "Rifle", alt_mode = true, world_space = true, done = true},
            {sound = "sound/NS2.fev/materials/organic/bash", surface = "infestation", doer = "Rifle", alt_mode = true, world_space = true, done = true},
            {sound = "sound/NS2.fev/materials/rock/bash", surface = "rock", doer = "Rifle", alt_mode = true, world_space = true, done = true},
            {sound = "sound/NS2.fev/materials/thin_metal/bash", surface = "thin_metal", doer = "Rifle", alt_mode = true, world_space = true, done = true},
            {sound = "sound/NS2.fev/materials/electronic/bash", surface = "electronic", doer = "Rifle", alt_mode = true, world_space = true, done = true},
            {sound = "sound/NS2.fev/materials/armor/bash", surface = "armor", doer = "Rifle", alt_mode = true, world_space = true, done = true},
            {sound = "sound/NS2.fev/materials/flesh/bash", surface = "flesh", doer = "Rifle", alt_mode = true, world_space = true, done = true},
            {sound = "sound/NS2.fev/materials/membrane/bash", surface = "membrane", doer = "Rifle", alt_mode = true, world_space = true, done = true},
            {sound = "sound/NS2.fev/materials/organic/bash", doer = "Rifle", alt_mode = true, world_space = true, done = true},
            
            {sound = "", doer = "Flamethrower", world_space = true, done = true},

            {sound = "sound/NS2.fev/materials/metal/ricochet", surface = "metal", doer = "ClipWeapon", world_space = true, done = true},
            {sound = "sound/NS2.fev/materials/organic/ricochet", surface = "organic", doer = "ClipWeapon", world_space = true, done = true},
            {sound = "sound/NS2.fev/materials/organic/ricochet", surface = "infestation", doer = "ClipWeapon", world_space = true, done = true},
            {sound = "sound/NS2.fev/materials/rock/ricochet", surface = "rock", doer = "ClipWeapon", world_space = true, done = true},
            {sound = "sound/NS2.fev/materials/thin_metal/ricochet", surface = "thin_metal", doer = "ClipWeapon", world_space = true, done = true},
            {sound = "sound/NS2.fev/materials/door/ricochet", surface = "door", doer = "ClipWeapon", world_space = true, done = true},
            {sound = "sound/NS2.fev/materials/electronic/ricochet", surface = "electronic", doer = "ClipWeapon", world_space = true, done = true},
            {sound = "sound/NS2.fev/materials/armor/ricochet", surface = "armor", doer = "ClipWeapon", world_space = true, done = true},
            {sound = "sound/NS2.fev/materials/flesh/ricochet", surface = "flesh", doer = "ClipWeapon", world_space = true, done = true},
            {sound = "sound/NS2.fev/materials/membrane/ricochet", surface = "membrane", doer = "ClipWeapon", world_space = true, done = true},
            {sound = "sound/NS2.fev/materials/organic/ricochet", doer = "ClipWeapon", world_space = true, done = true},
            
            {sound = "sound/NS2.fev/materials/metal/ricochet", surface = "metal", doer = "Minigun", world_space = true, done = true},
            {sound = "sound/NS2.fev/materials/organic/ricochet", surface = "organic", doer = "Minigun", world_space = true, done = true},
            {sound = "sound/NS2.fev/materials/organic/ricochet", surface = "infestation", doer = "Minigun", world_space = true, done = true},
            {sound = "sound/NS2.fev/materials/rock/ricochet", surface = "rock", doer = "Minigun", world_space = true, done = true},
            {sound = "sound/NS2.fev/materials/thin_metal/ricochet", surface = "thin_metal", doer = "Minigun", world_space = true, done = true},
            {sound = "sound/NS2.fev/materials/door/ricochet", surface = "door", doer = "Minigun", world_space = true, done = true},
            {sound = "sound/NS2.fev/materials/electronic/ricochet", surface = "electronic", doer = "Minigun", world_space = true, done = true},
            {sound = "sound/NS2.fev/materials/armor/ricochet", surface = "armor", doer = "Minigun", world_space = true, done = true},
            {sound = "sound/NS2.fev/materials/flesh/ricochet", surface = "flesh", doer = "Minigun", world_space = true, done = true},
            {sound = "sound/NS2.fev/materials/membrane/ricochet", surface = "membrane", doer = "Minigun", world_space = true, done = true},
            {sound = "sound/NS2.fev/materials/organic/ricochet", doer = "Minigun", world_space = true, done = true},
          
            {sound = "sound/NS2.fev/materials/metal/axe", surface = "metal", doer = "Axe", world_space = true, done = true},
            {sound = "sound/NS2.fev/materials/organic/axe", surface = "organic", doer = "Axe", world_space = true, done = true},
            {sound = "sound/NS2.fev/materials/organic/axe", surface = "infestation", doer = "Axe", world_space = true, done = true},
            {sound = "sound/NS2.fev/materials/rock/axe", surface = "rock", doer = "Axe", world_space = true, done = true},
            {sound = "sound/NS2.fev/materials/thin_metal/axe", surface = "thin_metal", doer = "Axe", world_space = true, done = true},
            {sound = "sound/NS2.fev/materials/electronic/axe", surface = "electronic", doer = "Axe", world_space = true, done = true},
            {sound = "sound/NS2.fev/materials/armor/axe", surface = "armor", doer = "Axe", world_space = true, done = true},
            {sound = "sound/NS2.fev/materials/flesh/axe", surface = "flesh", doer = "Axe", world_space = true, done = true},
            {sound = "sound/NS2.fev/materials/membrane/axe", surface = "membrane", doer = "Axe", world_space = true, done = true},
            {sound = "sound/NS2.fev/materials/organic/axe", doer = "Axe", world_space = true, done = true},
            
            {sound = "sound/NS2.fev/marine/heavy/punch_hit_alien", surface = "membrane", doer = "Claw", world_space = true, done = true},
            {sound = "sound/NS2.fev/marine/heavy/punch_hit_alien", surface = "organic", doer = "Claw", world_space = true, done = true},
            {sound = "sound/NS2.fev/marine/heavy/punch_hit_alien", surface = "infestation", doer = "Claw", world_space = true, done = true},
            {sound = "sound/NS2.fev/marine/heavy/punch_hit_geometry", doer = "Claw", world_space = true, done = true},
            
        }
    },

    // triggered client side for the shooter, all other players receive a message from the server
    damage =
    {
        damageEffects =
        {
            {player_cinematic = "cinematics/materials/flame/flame.cinematic", surface = "flame", done = true},
        
            // marine effects:
            {player_cinematic = "cinematics/materials/ethereal/ethereal.cinematic", surface = "ethereal", done = true},
            
            {player_cinematic = "cinematics/materials/%s/bash.cinematic", doer = "Rifle", alt_mode = true, done = true},
            {player_cinematic = "cinematics/materials/flame/flame.cinematic", doer = "Flamethrower", done = true},
            {player_cinematic = "cinematics/materials/%s/ricochetHeavy.cinematic", doer = "Shotgun", done = true},
            {player_cinematic = "cinematics/materials/%s/ricochetMinigun.cinematic", doer = "Minigun", done = true},
            {player_cinematic = "cinematics/materials/%s/ricochet.cinematic", doer = "ClipWeapon", done = true},
            {player_cinematic = "cinematics/materials/%s/axe.cinematic", doer = "Axe", done = true},

        },        
    },

    // triggered server side only since the required data on client is missing
    flinch =
    {
        flinchEffects =
        {
            // marine flinch effects
            {sound = "sound/NS2.fev/marine/common/wound_serious", classname = "Marine", flinch_severe = true, world_space = true, done = true},
            {sound = "sound/NS2.fev/marine/common/wound", classname = "Marine", world_space = true, done = true},
           
        },
    },

}

GetEffectManager():AddEffectData("DamageEffects", kDamageEffects)