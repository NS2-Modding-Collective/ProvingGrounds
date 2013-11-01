// ======= Copyright (c) 2003-2012, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\Globals.lua
//
//    Created by:   Charlie Cleveland (charlie@unknownworlds.com)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================
Script.Load("lua/Utility.lua")

kMaxPlayerSkill = 1000
kMaxPlayerLevel = 100

kSuicideDelay = 6

kDecalMaxLifetime = 60

// All the layouts are based around this screen height.
kBaseScreenHeight = 1080

// Team types - corresponds with teamNumber in editor_setup.xml
kNeutralTeamType = 0
kGreenTeamType = 1
kPurpleTeamType = 2
kRandomTeamType = 3

// Spawn Item types - corresponds with itemName in editor_setup.xml
kSpawnItem1 = 1

// after 5 minutes players are allowed to give up a round
kMinTimeBeforeConcede = 10 * 60
kPercentNeededForVoteConcede = 0.75

// Team colors
kGreenFontName = "fonts/AgencyFB_large.fnt"
kGreenFontColor = Color(0.078, 0.978, 0.384, 1)

kPurpleFontName = "fonts/AgencyFB_large.fnt"
kPurpleFontColor = Color(0.848, 0.143, 0.531, 1)

kNeutralFontName = "fonts/AgencyFB_large.fnt"
kNeutralFontColor = Color(0.7, 0.7, 0.7, 1)

// Move hit effect slightly off surface we hit so particles don't penetrate. In meters.
kHitEffectOffset = 0.13
// max distance of blood from impact point to nearby geometry
kBloodDistance = 3.5

kGreenTeamColor = 0x4DB1FF
kGreenTeamColorFloat = Color(0.1, 0.98, 0.4)
kPurpleTeamColor = 0xFFCA3A
kPurpleTeamColorFloat = Color(0.85, 0.15, 0.5)
kNeutralTeamColor = 0xEEEEEE
kChatPrefixTextColor = 0xFFFFFF
kChatTextColor = { [kNeutralTeamType] = kNeutralFontColor,
                   [kGreenTeamType] = kGreenFontColor,
                   [kPurpleTeamType] = kPurpleFontColor }
kNewPlayerColor = 0x00DC00
kNewPlayerColorFloat = Color(0, 0.862, 0, 1)
kChatTypeTextColor = 0xDD4444
kFriendlyColor = 0xFFFFFF
kNeutralColor = 0xAAAAFF
kEnemyColor = 0xFF0000

kCountDownLength = 6

// Team numbers and indices
kTeamInvalid = -1
kTeamReadyRoom = 0
kTeam1Index = 1
kTeam2Index = 2
kSpectatorIndex = 3

// Green vs. Purple
kTeam1Type = kGreenTeamType
kTeam2Type = kPurpleTeamType

// Used for playing team and scoreboard
kTeam1Name = "Engineers"
kTeam2Name = "Scientists"
kSpectatorTeamName = "Ready room"
kDefaultPlayerName = "Avatar"

// Used for cross team win scenarios
kTeamWin = enum( { 'None', 'Team1Win', 'Team2Win', 'TheyDraw' }) 

kPickupHealth = 25
// Max number of entities allowed in radius. Don't allow creating any more entities if this number is rearched.
// Don't include players in count.
kMaxEntitiesInRadius = 25
kMaxEntityRadius = 15

kWorldMessageLifeTime = 1.0
kWorldMessageResourceOffset = Vector(0, 2.5, 0)
kResourceMessageRange = 35
kWorldDamageNumberAnimationSpeed = 220
// Updating messages with new numbers shouldn't reset animation - keep it big and faded-in intead of growing
kWorldDamageRepeatAnimationScalar = .1

// Max player name
kMaxNameLength = 20
kMaxScore = 9999
kMaxKills = 254
kMaxDeaths = 254
kMaxPing = 999

kMaxChatLength = 80

kMaxHotkeyGroups = 9

// Surface list. Add more materials here to precache ricochets, bashes, footsteps, etc
// Used with PrecacheMultipleAssets
kSurfaceList = { "electronic", "metal", "rock", "thin_metal", "armor", "flame", "glass" }

// a longer surface list, for hiteffects only (used by hiteffects network message, don't remove any values)
kHitEffectSurface = enum( { "metal", "electronic", "rock", "thin_metal", "armor", "glass", "flame"} )
kHitEffectRelevancyDistance = 40
kHitEffectMaxPosition = 1638 // used for precision in hiteffect message
kTracerSpeed = 115
kMaxHitEffectsPerSecond = 200

kMainMenuFlash = "ui/main_menu.swf"

kPlayerStatus = enum( { "Hidden", "Dead", "Void", "Spectator"} )
kPlayerCommunicationStatus = enum( {'None', 'Voice', 'Typing', 'Menu'} )
kSpectatorMode = enum( { 'FreeLook', 'None' /*'Following', 'FirstPerson'*/ } )

kNoWeaponSlot = 0
// Weapon slots.
kPrimaryWeaponSlot = 1
kSecondaryWeaponSlot = 2
kTertiaryWeaponSlot = 3
kFourthWeaponSlot = 4
kFifthWeaponSlot = 5
kSixthWeaponSlot = 6
//Weapon Reload Time Multipler for faster than NS2 reloads
kReloadTime = 4

// How long to display weapon picker after selecting weapons
kDisplayWeaponTime = 0.5

// Death message indices 
kDeathMessageIcon = enum( { 'None', 
                            'Rifle', 'RifleButt', 'Pistol', 'Axe', 'Shotgun',
                            'Flamethrower', 'Grenade', 'GL', 
                            } )

// Bit mask table for non-stackable game effects. OnInfestation is set if we're on ANY infestation (regardless of team).
// Always keep "Max" as last element.
kGameEffect = CreateBitMask( { "NearDeath", "OnFire" } )
kGameEffectMax = bit.lshift( 1, GetBitMaskNumBits(kGameEffect) )

kMaxEntityStringLength = 32
kMaxAnimationStringLength = 32

// Player modes. When outside the default player mode, input isn't processed from the player
kPlayerMode = enum( {'Default', 'Taunt'} )

// Team alert types
kAlertType = enum( {'Attack', 'Info', 'Request'} )

// Game state
kGameState = enum( {'NotStarted', 'PreGame', 'Countdown', 'Started', 'Team1Won', 'Team2Won', 'Draw'} )

// Marquee while active, to ensure we get mouse release event even if on top of other component
kHighestPriorityZ = 3

// How often to send kills, deaths, nick name changes, etc. for scoreboard
kScoreboardUpdateInterval = 1

// How often to send ping updates to individual players
kUpdatePingsIndividual = 3

// How often to send ping updates to all players.
kUpdatePingsAll = 12

// Bit masks for relevancy checking
kRelevantToTeam1Unit        = 1
kRelevantToTeam2Unit        = 2
kRelevantToTeam1            = 4
kRelevantToTeam2            = 8
kRelevantToReadyRoom        = 16

kFeedbackURL = "http://getsatisfaction.com/unknownworlds/feedback/topics/new?product=unknownworlds_natural_selection_2&display=layer&style=idea&custom_css=http://www.unknownworlds.com/game_scripts/ns2/styles.css"

// Used for menu on top of class (marine or alien buy menus or out of game menu) 
kMenuFlashIndex = 2

// Fade to black time (then to spectator mode)
kFadeToBlackTime = 3

// Constant to prevent z-fighting 
kZFightingConstant = 0.1

// invisible and blocks all movement
kMovementCollisionGroupName = "MovementCollisionGeometry"
// same as 'MovementCollisionGeometry'
kCollisionGeometryGroupName = "CollisionGeometry"
// invisible, blocks anything default geometry would block
kInvisibleCollisionGroupName = "InvisibleGeometry"
// visible and won't block anything
kNonCollisionGeometryGroupName = "NonCollisionGeometry"

// Max players allowed in game
kMaxPlayers = 32

kMaxIdleWorkers = 127
kMaxPlayerAlerts = 127

// Max distance to propagate entities with
kMaxRelevancyDistance = 40

kEpsilon = 0.0001

kInventoryIconsTexture = "ui/inventory_icons.dds"
kInventoryIconTextureWidth = 128
kInventoryIconTextureHeight = 64

// Options keys
kNicknameOptionsKey = "nickname"
kVisualDetailOptionsKey = "visualDetail"
kSoundInputDeviceOptionsKey = "sound/input-device"
kSoundOutputDeviceOptionsKey = "sound/output-device"
kSoundVolumeOptionsKey = "soundVolume"
kMusicVolumeOptionsKey = "musicVolume"
kVoiceVolumeOptionsKey = "voiceVolume"
kDisplayOptionsKey = "graphics/display/display"
kWindowModeOptionsKey = "graphics/display/window-mode"
kDisplayQualityOptionsKey = "graphics/display/quality"
kInvertedMouseOptionsKey = "input/mouse/invert"
kLastServerConnected = "lastConnectedServer"
kLastServerPassword  = "lastServerPassword"
kLastServerMapName  = "lastServerMapName"

kPhysicsGpuAccelerationKey = "physics/gpu-acceleration"
kGraphicsXResolutionOptionsKey = "graphics/display/x-resolution"
kGraphicsYResolutionOptionsKey = "graphics/display/y-resolution"
kAntiAliasingOptionsKey = "graphics/display/anti-aliasing"
kAtmosphericsOptionsKey = "graphics/display/atmospherics"
kShadowsOptionsKey = "graphics/display/shadows"
kShadowFadingOptionsKey = "graphics/display/shadow-fading"
kBloomOptionsKey = "graphics/display/bloom"
kAnisotropicFilteringOptionsKey = "graphics/display/anisotropic-filtering"

kMouseSensitivityScalar         = 50

// Player use range
kPlayerUseRange = 2
kMaxPitch = (math.pi / 2) - math.rad(3)

// Statistics
kStatisticsURL = "http://sponitor2.herokuapp.com/api/send"

kCatalyzURL = "https://catalyz.herokuapp.com/v1"

kResourceType = enum( {'Energy', 'Ammo'} )

kNameTagFontColors = { [kGreenTeamType] = kGreenFontColor,
                       [kPurpleTeamType] = kPurpleFontColor,
                       [kNeutralTeamType] = kNeutralFontColor }

kNameTagFontNames = { [kGreenTeamType] = kGreenFontName,
                      [kPurpleTeamType] = kPurpleFontName,
                      [kNeutralTeamType] = kNeutralFontName }

kHealthBarColors = { [kGreenTeamType] = Color(0.078, 0.978, 0.384, 1),
                     [kPurpleTeamType] = Color(0.848, 0.143, 0.531, 1),
                     [kNeutralTeamType] = Color(1, 1, 1, 1) }
                     
// used for specific effects
kUseInterval = 0.1

kPlayerLOSDistance = 20
kStructureLOSDistance = 3.5

// Rookie mode
kRookieSaveInterval = 30 // seconds
kRookieTimeThreshold = 4 * 60 * 60 // 4 hours
kRookieNetworkCheckInterval = 2
kRookieOptionsKey = "rookieMode"

kMinFOVAdjustmentDegrees = 0
kMaxFOVAdjustmentDegrees = 20

kDamageEffectType = enum({ 'Blood', 'Sparks' })

kIconColors = 
{
    [kGreenTeamType] = Color(0.8, 0.96, 1, 1),
    [kPurpleTeamType] = Color(1, 0.9, 0.4, 1),
    [kNeutralTeamType] = Color(1, 1, 1, 1),
}

//----------------------------------------
//  DLC stuff
//----------------------------------------

function GetHasDLC(productId, client)

    if productId == nil then
        return true
    end

    if Client then    
        assert( client == nil )
        return Client.GetIsDlcAuthorized(productId)    
    elseif Server and client then
        assert( client ~= nil )
        return Server.GetIsDlcAuthorized(client, productId)
    else
        return false
    end

end

kSpecialEditionProductId = 4930
kDeluxeEditionProductId = 4932
kShoulderPadProductId = 250891
kAssaultMarineProductId = 250892
kShadowProductId = 250893

// DLC player variants
// "code" is the key

// TODO we can really just get rid of the enum. use array-of-structures pattern, and use #kMarineVariants to network vars

kAvatarVariant = enum({"green"/*, "special", "deluxe", "assault", "eliteassault"*/})
kAvatarVariantData =
{
    [kAvatarVariant.green]        =  { productId = nil                      , displayName = "Green"         , modelFilePart = ""              , viewModelFilePart = ""              }  , 
/*    [kAvatarVariant.special]      =  { productId = kSpecialEditionProductId , displayName = "Black"         , modelFilePart = "_special"      , viewModelFilePart = "_special"      }  , 
    [kAvatarVariant.deluxe]       =  { productId = kDeluxeEditionProductId  , displayName = "Deluxe"        , modelFilePart = "_special_v1"   , viewModelFilePart = "_deluxe"       }  , 
    [kAvatarVariant.assault]      =  { productId = kAssaultMarineProductId  , displayName = "Assault"       , modelFilePart = "_assault"      , viewModelFilePart = "_assault"      }  , 
    [kAvatarVariant.eliteassault] =  { productId = kShadowProductId         , displayName = "Elite Assault" , modelFilePart = "_eliteassault" , viewModelFilePart = "_eliteassault" }  , 
*/}

kDefaultAvatarVariant = kAvatarVariant.green

function FindVariant( data, displayName )

        for var, data in pairs(data) do
        if data.displayName == displayName then
            return var
        end
    end
    return nil

end

function GetVariantName( data, var )
    return data[var].displayName
end

function GetHasVariant(data, var, client)
    return true
end

kShoulderPad2ProductId =
{
    kShoulderPadProductId,
    kShadowProductId,
}
function GetHasShoulderPad(index, client)
    return GetHasDLC( kShoulderPad2ProductId[index], client )
end

