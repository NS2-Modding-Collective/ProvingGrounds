// ======= Copyright (c) 2003-2012, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\Globals.lua
//
//    Created by:   Charlie Cleveland (charlie@unknownworlds.com)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================
Script.Load("lua/Utility.lua")

// All the layouts are based around this screen height.
kBaseScreenHeight = 1080

// Team types - corresponds with teamNumber in editor_setup.xml
kNeutralTeamType = 0
kMarineTeamType = 1
kRedTeamType = 2
kRandomTeamType = 3

// Team colors
kMarineFontName = "fonts/AgencyFB_large.fnt"
kMarineFontColor = Color(0.756, 0.952, 0.988, 1)

kAlienFontName = "fonts/AgencyFB_large.fnt"
kAlienFontColor = Color(0.901, 0.623, 0.215, 1)

kNeutralFontName = "fonts/AgencyFB_large.fnt"
kNeutralFontColor = Color(0.7, 0.7, 0.7, 1)

// Move hit effect slightly off surface we hit so particles don't penetrate. In meters.
kHitEffectOffset = 0.13

kMarineTeamColor = 0x4DB1FF
kMarineTeamColorFloat = Color(0.302, 0.859, 1)
kAlienTeamColor = 0xFFCA3A
kRedColor = Color(1, .61, 0, 1)
kAlienTeamColorFloat = Color(1, 0.792, 0.227)
kNeutralTeamColor = 0xEEEEEE
kChatPrefixTextColor = 0xFFFFFF
kChatTextColor = { [kNeutralTeamType] = kNeutralFontColor,
                   [kMarineTeamType] = kMarineFontColor,
                   [kRedTeamType] = kAlienFontColor }
kChatTypeTextColor = 0xDD4444
kFriendlyColor = 0xFFFFFF
kNeutralColor = 0xAAAAFF
kEnemyColor = 0xFF0000
kParasitedTextColor = 0xFFEB7F

kParasiteColor = Color(1, 1, 0, 1)
kPoisonedColor = Color(0, 1, 0, 1)

kCountDownLength = 6

// Team numbers and indices
kTeamInvalid = -1
kTeamReadyRoom = 0
kTeam1Index = 1
kTeam2Index = 2
kSpectatorIndex = 3

// Marines vs. Aliens
kTeam1Type = kMarineTeamType
kTeam2Type = kRedTeamType //Changed From: kAlienTeamType

// Used for playing team and scoreboard
kTeam1Name = "Blue Team"
kTeam2Name = "Red Team"
kSpectatorTeamName = "Ready room"
kDefaultPlayerName = "Avatar"

kMaxResources = 999

// Max number of entities allowed in radius. Don't allow creating any more entities if this number is rearched.
// Don't include players in count.
kMaxEntitiesInRadius = 25
kMaxEntityRadius = 15

kWorldMessageLifeTime = 1.0
kWorldMessageResourceOffset = Vector(0, 2.5, 0)
kResourceMessageRange = 35
kWorldDamageNumberAnimationSpeed = 150
// Updating messages with new numbers shouldn't reset animation - keep it big and faded-in intead of growing
kWorldDamageRepeatAnimationScalar = .1

// Max player name
kMaxNameLength = 20
kMaxScore = 9999
kMaxKills = 254
kMaxStreak = 254
kMaxDeaths = 254
kMaxPing = 999

kMaxChatLength = 80

kMaxHotkeyGroups = 5

// Surface list. Add more materials here to precache ricochets, bashes, footsteps, etc
// Used with PrecacheMultipleAssets
kSurfaceList = { "door", "electronic", "metal", "organic", "rock", "thin_metal", "membrane", "armor", "flesh", "flame", "infestation", "glass" }

// a longer surface list, for hiteffects only (used by hiteffects network message, don't remove any values)
kHitEffectSurface = enum( { "metal", "electronic", "organic", "rock", "thin_metal", "membrane", "armor", "flesh", "flame", "infestation", "glass", "ethereal", "flame", "hallucination", "umbra", "nanoshield" } )
kHitEffectRelevancyDistance = 40
kHitEffectMaxPosition = 1638 // used for precision in hiteffect message
kTracerSpeed = 75
kMaxHitEffectsPerSecond = 200

kMainMenuFlash = "ui/main_menu.swf"

kPlayerStatus = enum( { "Hidden", "Dead", "GrenadeLauncher", "RocketLauncher", "Rifle", "Shotgun", "Flamethrower", "Void", "Spectator", "AntiMatterSword" } )
kPlayerCommunicationStatus = enum( {'None', 'Voice', 'Typing', 'Menu'} )

kMaxAlienAbilities = 3

kNoWeaponSlot = 0
// Weapon slots (marine only). Alien weapons use just regular numbers.
kPrimaryWeaponSlot = 1
kSecondaryWeaponSlot = 2
kTertiaryWeaponSlot = 3

// How long to display weapon picker after selecting weapons
kDisplayWeaponTime = 1.5

// If player bought Special Edition
kSpecialEditionProductId = 4930

// Death message indices 
kDeathMessageIcon = enum( {'None', 'Rifle', 'RifleButt',
                           'Pistol', 'Axe', 'Shotgun',
                           'Flamethrower', 'Grenade', 'AntiMatterSword' } )
// Bit mask table for non-stackable game effects. OnInfestation is set if we're on ANY infestation (regardless of team).
// Always keep "Max" as last element.
kGameEffect = CreateBitMask( {"NearDeath", "OnFire", "Max"} )
kGameEffectMax = bit.lshift( 1, GetBitMaskNumBits(kGameEffect) )

kMaxEntityStringLength = 32
kMaxAnimationStringLength = 32

// Player modes. When outside the default player mode, input isn't processed from the player
kPlayerMode = enum( {'Default', 'Taunt'} )

// Team alert types
kAlertType = enum( {'Attack', 'Info', 'Request'} )

// Dynamic light modes for power grid
kLightMode = enum( {'Normal', 'NoPower', 'LowPower', 'Damaged'} )

// Game state
kGameState = enum( {'NotStarted', 'PreGame', 'Countdown', 'Started', 'Team1Won', 'Team2Won', 'Draw'} )

// Marquee while active, to ensure we get mouse release event even if on top of other component
kHighestPriorityZ = 3

// How often to send kills, deaths, nick name changes, etc. for scoreboard
kScoreboardUpdateInterval = 1

// How often to send ping updates to individual players
kUpdatePingsIndividual = 3

// How often to send ping updates to all players.
kUpdatePingsAll = 10

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

kCollisionGeometryGroupName     = "CollisionGeometry"
kNonCollisionGeometryGroupName  = "NonCollisionGeometry"

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
kSoundVolumeOptionsKey = "soundVolume"
kMusicVolumeOptionsKey = "musicVolume"
kVoiceVolumeOptionsKey = "voiceVolume"
kWindowModeOptionsKey = "graphics/display/window-mode"
kDisplayQualityOptionsKey = "graphics/display/quality"
kInvertedMouseOptionsKey = "input/mouse/invert"
kLastServerConnected = "lastConnectedServer"
kLastServerPassword  = "lastServerPassword"

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

// Pathing flags
kPathingFlags = enum ({'UnBuildable', 'UnPathable', 'Blockable'})

// How far from the order location must units be to complete it.
kAIMoveOrderCompleteDistance = 0.01
kPlayerMoveOrderCompleteDistance = 1.5

// Statistics
kStatisticsURL = "http://strong-ocean-7422.herokuapp.com"

kCatalyzURL = "https://catalyz.herokuapp.com/v1"

kResourceType = enum( {'Team', 'Personal', 'Energy', 'Ammo'} )

kNameTagFontColors = { [kMarineTeamType] = kMarineFontColor,
                       [kRedTeamType] = kAlienFontColor,
                       [kNeutralTeamType] = kNeutralFontColor }

kNameTagFontNames = { [kMarineTeamType] = kMarineFontName,
                      [kRedTeamType] = kAlienFontName,
                      [kNeutralTeamType] = kNeutralFontName }

kHealthBarColors = { [kMarineTeamType] = Color(0.725, 0.921, 0.949, 1),
                     [kRedTeamType] = Color(0.776, 0.364, 0.031, 1),
                     [kNeutralTeamType] = Color(1, 1, 1, 1) }
                     
kArmorBarColors = { [kMarineTeamType] = Color(0.078, 0.878, 0.984, 1),
                    [kRedTeamType] = Color(0.576, 0.194, 0.011, 1),
                    [kNeutralTeamType] = Color(0.5, 0.5, 0.5, 1) }

// used for specific effects
kUseInterval = 0.1

kPlayerLOSDistance = 20
kStructureLOSDistance = 3.5

kGestateCameraDistance = 1.75
kMinFOVAdjustmentDegrees = 0
kMaxFOVAdjustmentDegrees = 20