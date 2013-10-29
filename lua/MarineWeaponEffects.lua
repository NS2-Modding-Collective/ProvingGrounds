// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\MarineWeaponEffects.lua
//
//    Created by:   Charlie Cleveland (charlie@unknownworlds.com)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

kMarineWeaponEffects =
{    
    holster =
    {
        holsterStopEffects =
        {
            {stop_cinematic = "cinematics/marine/flamethrower/flame.cinematic", classname = "Flamethrower"},
        },
    },
    
    draw =
    {
        marineWeaponDrawSounds =
        {
            
            {player_sound = "sound/NS2.fev/marine/rifle/deploy_grenade", classname = "GrenadeLauncher", done = true},
            {player_sound = "sound/NS2.fev/marine/rifle/draw", classname = "Rifle", done = true},
            {player_sound = "sound/NS2.fev/marine/pistol/draw", classname = "Pistol", done = true},
            {player_sound = "sound/NS2.fev/marine/axe/draw", classname = "Axe", done = true},
            {player_sound = "sound/NS2.fev/marine/flamethrower/draw", classname = "Flamethrower", done = true},
            {player_sound = "sound/NS2.fev/marine/shotgun/deploy", classname = "Shotgun", done = true},            
        },

    },
    
    reload = 
    {
        gunReloadEffects =
        {
            {player_sound = "sound/NS2.fev/marine/rifle/reload", classname = "Rifle"},
            {player_sound = "sound/NS2.fev/marine/pistol/reload", classname = "Pistol"},
            {player_sound = "sound/NS2.fev/marine/flamethrower/reload", classname = "Flamethrower"},
        },
    },
    
    reload_cancel =
    {
        gunReloadCancelEffects =
        {
            {stop_sound = "sound/NS2.fev/marine/rifle/reload", classname = "Rifle"},
            {stop_sound = "sound/NS2.fev/marine/pistol/reload", classname = "Pistol"},
            {stop_sound = "sound/NS2.fev/marine/flamethrower/reload", classname = "Flamethrower"}
        },
    },
    
    clipweapon_empty =
    {
        emptySounds =
        {
            {player_sound = "sound/NS2.fev/marine/shotgun/fire_empty", classname = "Shotgun", done = true},
            {player_sound = "sound/NS2.fev/marine/common/empty", classname = "Rifle", done = true},
            {player_sound = "sound/NS2.fev/marine/common/empty", classname = "Flamethrower", done = true},
            {player_sound = "sound/NS2.fev/marine/common/empty", classname = "GrenadeLauncher", done = true},
            {player_sound = "sound/NS2.fev/marine/common/empty", classname = "Pistol", done = true},  
        },
        
    },
    
    rifle_alt_attack = 
    {
        rifleAltAttackEffects = 
        {
            { player_sound = "sound/NS2.fev/marine/rifle/alt_swing_female", sex = "female", done = true },
            { player_sound = "sound/NS2.fev/marine/rifle/alt_swing" },
        },
    },
    
    pistol_attack = 
    {
        pistolAttackEffects = 
        {
            {viewmodel_cinematic = "cinematics/marine/pistol/muzzle_flash.cinematic", attach_point = "fxnode_pistolmuzzle"},
            // First-person and weapon shell casings
            {viewmodel_cinematic = "cinematics/marine/pistol/shell.cinematic", attach_point = "fxnode_pistolcasing"},
            
            {weapon_cinematic = "cinematics/marine/pistol/muzzle_flash.cinematic", attach_point = "fxnode_pistolmuzzle"},
            {weapon_cinematic = "cinematics/marine/pistol/shell.cinematic", attach_point = "fxnode_pistolcasing"} ,
            
            // Sound effect
            {player_sound = "sound/NS2.fev/marine/pistol/fire"},
        },
    },
    
    axe_attack = 
    {
        axeAttackEffects = 
        {
            { player_sound = "sound/NS2.fev/marine/axe/attack_female", sex = "female", done = true },
            { player_sound = "sound/NS2.fev/marine/axe/attack" },
        },
    },
    
    shotgun_attack_sound_last =
    {
        effects =
        {
            {player_sound = "sound/NS2.fev/marine/shotgun/fire_last"},
        }
    },
    
    shotgun_attack_sound = 
    {
        effects =
        {
            {player_sound = "sound/NS2.fev/marine/shotgun/fire"},
        }
    },
    
    shotgun_attack_sound_medium = 
    {
        effects =
        {
            {player_sound = "sound/NS2.fev/marine/shotgun/fire_upgrade_1"},
        }
    },
    
    shotgun_attack_sound_max = 
    {
        effects =
        {
            {player_sound = "sound/NS2.fev/marine/shotgun/fire_upgrade_3"},
        }
    },

    shotgun_attack = 
    {
        shotgunAttackEffects = 
        {
            {viewmodel_cinematic = "cinematics/marine/shotgun/muzzle_flash.cinematic", attach_point = "fxnode_shotgunmuzzle"},
            {weapon_cinematic = "cinematics/marine/shotgun/muzzle_flash.cinematic", attach_point = "fxnode_shotgunmuzzle"},
            {weapon_cinematic = "cinematics/marine/shotgun/shell.cinematic", attach_point = "fxnode_shotguncasing"} ,
        },
    },
    
    // Special shotgun reload effects
    shotgun_reload_start =
    {
        shotgunReloadStartEffects =
        {
            {player_sound = "sound/NS2.fev/marine/shotgun/start_reload"},
        },
    },

    shotgun_reload_shell =
    {
        shotgunReloadShellEffects =
        {
            {player_sound = "sound/NS2.fev/marine/shotgun/load_shell"},
        },
    },

    shotgun_reload_end =
    {
        shotgunReloadEndEffects =
        {
            {player_sound = "sound/NS2.fev/marine/shotgun/end_reload"},
        },
    },
    
    // Special shotgun reload effects
    grenadelauncher_reload_start =
    {
        grenadelauncherReloadStartEffects =
        {
            {player_sound = "sound/NS2.fev/marine/grenade_launcher/reload_start"},
        },
    },

    grenadelauncher_reload_shell =
    {
        grenadelauncherReloadShellEffects =
        {
            {sound = "sound/NS2.fev/marine/grenade_launcher/reload"},
        },
    },
    
    grenadelauncher_reload_shell_last =
    {
        grenadelauncherReloadShellEffects =
        {
            {player_sound = "sound/NS2.fev/marine/grenade_launcher/reload_last"},
        },
    },

    grenadelauncher_reload_end =
    {
        grenadelauncherReloadEndEffects =
        {
            {player_sound = "sound/NS2.fev/marine/grenade_launcher/reload_end"},
        },
    },
    
    grenadelauncher_attack =
    {
        glAttackEffects =
        {
            {viewmodel_cinematic = "cinematics/marine/gl/muzzle_flash.cinematic", attach_point = "fxnode_shotgunmuzzle", empty = false},
            {weapon_cinematic = "cinematics/marine/gl/muzzle_flash.cinematic", attach_point = "fxnode_shotgunmuzzle", empty = false},
            
            {player_sound = "sound/NS2.fev/marine/rifle/fire_grenade", done = true},
            {player_sound = "sound/NS2.fev/marine/common/empty", empty = true, done = true},
        },
    },
    
    grenadelauncher_alt_attack =
    {
        glAttackEffects =
        {
            {viewmodel_cinematic = "cinematics/marine/gl/muzzle_flash.cinematic", attach_point = "fxnode_glmuzzle", empty = false},
            
            {player_sound = "sound/NS2.fev/marine/rifle/fire_grenade", done = true},
            {player_sound = "sound/NS2.fev/marine/common/empty", empty = true, done = true},
        },
    },

    rocketlauncher_reload_start =
    {
        rocketlauncherReloadStartEffects =
        {
            {player_sound = "sound/NS2.fev/marine/grenade_launcher/reload_start"},
        },
    },

    rocketlauncher_reload_shell =
    {
        rocketlauncherReloadShellEffects =
        {
            {sound = "sound/NS2.fev/marine/grenade_launcher/reload"},
        },
    },
    
    rocketlauncher_reload_shell_last =
    {
        rocketlauncherReloadShellEffects =
        {
            {player_sound = "sound/NS2.fev/marine/grenade_launcher/reload_last"},
        },
    },

    rocketlauncher_reload_end =
    {
        rocketlauncherReloadEndEffects =
        {
            {player_sound = "sound/NS2.fev/marine/grenade_launcher/reload_end"},
        },
    },
    
    rocketlauncher_attack =
    {
        glAttackEffects =
        {
            {viewmodel_cinematic = "cinematics/marine/gl/muzzle_flash.cinematic", attach_point = "fxnode_glmuzzle", empty = false},
            {weapon_cinematic = "cinematics/marine/gl/muzzle_flash.cinematic", attach_point = "fxnode_glmuzzle", empty = false},
            
            {player_sound = "sound/NS2.fev/marine/rifle/fire_grenade", done = true},
            {player_sound = "sound/NS2.fev/marine/common/empty", empty = true, done = true},
        },
    },
    
    rocketlauncher_alt_attack =
    {
        glAttackEffects =
        {
            {viewmodel_cinematic = "cinematics/marine/gl/muzzle_flash.cinematic", attach_point = "fxnode_glmuzzle", empty = false},
            
            {player_sound = "sound/NS2.fev/marine/rifle/fire_grenade", done = true},
            {player_sound = "sound/NS2.fev/marine/common/empty", empty = true, done = true},
        },
    },
  
    flamethrower_attack_start =
    {
        soundEffects =
        {
            {player_sound = "sound/NS2.fev/marine/flamethrower/attack_start"},
        }    
    },
    
    flamethrower_attack = 
    {
        flamethrowerAttackCinematics = 
        {
            // If we're out of ammo, play 'flame out' effect
            {viewmodel_cinematic = "cinematics/marine/flamethrower/flameout.cinematic", attach_point = "fxnode_flamethrowermuzzle", empty = true},
            {weapon_cinematic = "cinematics/marine/flamethrower/flameout.cinematic", attach_point = "fxnode_flamethrowermuzzle", empty = true, done = true},
        
            // Otherwise play either first-person or third-person flames
            {viewmodel_cinematic = "cinematics/marine/flamethrower/flame_1p.cinematic", attach_point = "fxnode_flamethrowermuzzle"},
            {weapon_cinematic = "cinematics/marine/flamethrower/flame.cinematic", attach_point = "fxnode_flamethrowermuzzle"},
        },
    },
    
    flamethrower_attack_end = 
    {
        flamethrowerAttackEndCinematics = 
        {
            //{stop_sound = "sound/NS2.fev/marine/flamethrower/attack_start"},
            {player_sound = "sound/NS2.fev/marine/flamethrower/attack_end"},
        },
    },

    grenadelauncher_reload =
    {
        glReloadEffects = 
        {
            {player_sound = "sound/NS2.fev/marine/rifle/reload_grenade"},
        },    
    },
    
    grenade_bounce =
    {
        grenadeBounceEffects =
        {
            {sound = "sound/NS2.fev/marine/rifle/grenade_bounce"},
        },
    },
    
    explosion_decal =
    {
        explosionDecal =
        {
            {decal = "cinematics/vfx_materials/decals/blast_01.material", scale = 2, done = true}
        }    
    },
    
    grenade_explode =
    {
        grenadeExplodeEffects =
        {
            // Any asset name with a %s will use the "surface" parameter as the name        
            {cinematic = "cinematics/materials/ethereal/grenade_explosion.cinematic", surface = "ethereal", done = true},   
            {cinematic = "cinematics/materials/%s/grenade_explosion.cinematic"},
        },
        
        grenadeExplodeSounds =
        {
            {sound = "sound/NS2.fev/marine/common/explode", surface = "ethereal", done = true},
            {sound = "sound/NS2.fev/marine/common/explode", done = true},
        },
    }, 

    shadow_step =
    {
        shadowStepEffects =
        {
            {player_sound = "sound/NS2.fev/alien/fade/shadow_step"},
            {player_cinematic = "cinematics/alien/fade/shadowstep_silent.cinematic", done = true},
        }
    
    },   
}

GetEffectManager():AddEffectData("MarineWeaponEffects", kMarineWeaponEffects)