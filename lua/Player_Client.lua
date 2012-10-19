// ======= Copyright (c) 2003-2012, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\Player_Client.lua
//
//    Created by:   Charlie Cleveland (charlie@unknownworlds.com) and
//                  Max McGuire (max@unknownworlds.com)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/Chat.lua")
Script.Load("lua/HudTooltips.lua")
Script.Load("lua/tweener/Tweener.lua")
Script.Load("lua/Player_Rumble.lua")
Script.Load("lua/TechTreeConstants.lua")
Script.Load("lua/GUICommunicationStatusIcons.lua")

// These screen effects are only used on the local player so create them statically.
Player.screenEffects = { }
Player.screenEffects.lowHealth = Client.CreateScreenEffect("shaders/LowHealth.screenfx")
Player.screenEffects.lowHealth:SetActive(false)
Player.screenEffects.blur = Client.CreateScreenEffect("shaders/Blur.screenfx")
Player.screenEffects.blur:SetActive(false)

local kDefaultPingSound = PrecacheAsset("sound/NS2.fev/common/ping")
local kMarinePingSound = PrecacheAsset("sound/NS2.fev/marine/commander/ping")
local kAlienPingSound = PrecacheAsset("sound/NS2.fev/alien/commander/ping")

local kDefaultFirstPersonEffectName = PrecacheAsset("cinematics/marine/hit_1p.cinematic")

Client.PrecacheLocalSound(kDefaultPingSound)
Client.PrecacheLocalSound(kMarinePingSound)
Client.PrecacheLocalSound(kAlienPingSound)

Player.kRangeFinderDistance = 20

// The amount of health left before the low health warning
// screen effect is active
local kLowHealthWarning = 0.35
local kLowHealthPulseSpeed = 10

Player.kShowGiveDamageTime = 1

gHUDMapEnabled = true

Player.kFirstPersonHealthCircle = PrecacheAsset("models/misc/marine-build/marine-build.model")
Player.kFirstPersonMarineHealthCircle = PrecacheAsset("models/misc/marine-build/marine-build.model")
Player.kFirstPersonAlienHealthCircle = PrecacheAsset("models/misc/marine-build/marine-build.model")

Player.kFirstPersonDeathEffect = PrecacheAsset("cinematics/death_1p.cinematic")

local kHealthCircleFadeOutTime = 1

local function GetHealthCircleName(self)

    if self:GetTeamNumber() == kMarineTeamType then
        return Player.kFirstPersonMarineHealthCircle
    elseif self:GetTeamNumber() == kRedTeamType then
        return Player.kFirstPersonAlienHealthCircle
    end
    
    return Player.kFirstPersonHealthCircle

end

function Player:GetShowUnitStatusForOverride(forEntity)
    return not GetAreEnemies(self, forEntity) or (forEntity:GetOrigin() - self:GetOrigin()):GetLength() < 8
end

function PlayerUI_GetWorldMessages()

    local messageTable = {}
    local player = Client.GetLocalPlayer()
    
    if player then
            
        for _, worldMessage in ipairs(Client.GetWorldMessages()) do
            
            local tableEntry = {}
            
            tableEntry.position = worldMessage.position
            tableEntry.messageType = worldMessage.messageType
            tableEntry.previousNumber = worldMessage.previousNumber
            tableEntry.text = worldMessage.message
            worldMessage.animationFraction = (Client.GetTime() - worldMessage.creationTime) / kWorldMessageLifeTime
            tableEntry.animationFraction = worldMessage.animationFraction
            tableEntry.distance = (worldMessage.position - player:GetOrigin()):GetLength()
            tableEntry.minimumAnimationFraction = worldMessage.minimumAnimationFraction
            tableEntry.entityId = worldMessage.entityId
            
            local direction = GetNormalizedVector(worldMessage.position - player:GetViewCoords().origin)
            tableEntry.inFront = player:GetViewCoords().zAxis:DotProduct(direction) > 0
            
            table.insert(messageTable, tableEntry)
            
        end
    
    end
    
    return messageTable

end

function PlayerUI_GetIsFeinting()

    local player = Client.GetLocalPlayer()
    local isFeinting = false
    
    if player then
    
        if HasMixin(player, "Feint") then
            isFeinting = player:GetIsFeinting()
        end
        
    end
    
    return isFeinting
end

function PlayerUI_GetIsDead()

    local player = Client.GetLocalPlayer()
    local isDead = false
    
    if player then
    
        if HasMixin(player, "Live") then
            isDead = not player:GetIsAlive()
        end
        
    end
    
    return isDead
    
end

function PlayerUI_GetIsSpecating()

    local player = Client.GetLocalPlayer()
    return player ~= nil and (player:isa("Spectator") or player:isa("FilmSpectator"))
    
end

function Player:GetBuyMenuIsDisplaying()
    return self.buyMenu ~= nil
end

function PlayerUI_GetBuyMenuDisplaying()

    local isDisplaying = false
    
    local player = Client.GetLocalPlayer()
    
    if player then
        isDisplaying = player:GetBuyMenuIsDisplaying()
    end
    
    return isDisplaying
    
end

local kUnitStatusDisplayRange = 13
local kDefaultHealthOffset = Vector(0, 1.2, 0)

function PlayerUI_GetUnitStatusInfo()

    local unitStates = { }
    
    local player = Client.GetLocalPlayer()
    
    if player and not player:GetBuyMenuIsDisplaying() and (not player.GetDisplayUnitStates or player:GetDisplayUnitStates()) then
    
        local eyePos = player:GetEyePos()
        local crossHairTarget = player:GetCrossHairTarget()
        
        local range = kUnitStatusDisplayRange
    
        for index, unit in ipairs(GetEntitiesWithMixinWithinRange("UnitStatus", eyePos, range)) do
        
            // checks here if the model was rendered previous frame as well
            local status = unit:GetUnitStatus(player)
            if unit:GetShowUnitStatusFor(player) and (unit:isa("Player") or status ~= kUnitStatus.None or unit == crossHairTarget) then       

                // Get direction to blip. If off-screen, don't render. Bad values are generated if 
                // Client.WorldToScreen is called on a point behind the camera.
                local origin = nil
                local getEngagementPoint = unit.GetEngagementPoint
                if getEngagementPoint then
                    origin = getEngagementPoint(unit)
                else
                    origin = unit:GetOrigin()
                end
                
                local normToEntityVec = GetNormalizedVector(origin - eyePos)
                local normViewVec = player:GetViewAngles():GetCoords().zAxis
               
                local dotProduct = normToEntityVec:DotProduct(normViewVec)
                
                if dotProduct > 0 then

                    local statusFraction = unit:GetUnitStatusFraction(player)
                    local description = unit:GetUnitName(player)
                    local hint = unit:GetUnitHint(player)
                    
                    local healthBarOrigin = origin + kDefaultHealthOffset
                    local getHealthbarOffset = unit.GetHealthbarOffset
                    if getHealthbarOffset then
                        healthBarOrigin = origin + getHealthbarOffset(unit)
                    end
                    
                    local worldOrigin = Vector(origin)
                    origin = Client.WorldToScreen(origin)
                    healthBarOrigin = Client.WorldToScreen(healthBarOrigin)

                    local health = 0
                    local armor = 0
                    
                    local badge = ""
                    
                    if HasMixin(unit, "Badge") then
                        badge = unit:GetBadgeIcon() or ""
                    end
                    
                    local unitState = {
                        
                        Position = origin,
                        WorldOrigin = worldOrigin,
                        HealthBarPosition = healthBarOrigin,
                        Status = status,
                        Name = description,
                        Hint = hint,
                        StatusFraction = statusFraction,
                        HealthFraction = health,
                        ArmorFraction = armor,
                        IsCrossHairTarget = (unit == crossHairTarget),
                        TeamType = kNeutralTeamType,
                        ForceName = unit:isa("Player") and not GetAreEnemies(player, unit),
                        OnScreen = onScreen,
                        BadgeTexture = badge
                    
                    }
                    
                    if unit.GetTeamNumber then
                        unitState.IsFriend = (unit:GetTeamNumber() == player:GetTeamNumber())
                    end
                    
                    if unit.GetTeamType then
                        unitState.TeamType = unit:GetTeamType()
                    end
                    
                    table.insert(unitStates, unitState)
                
                end
                
            end
         
         end
        
    end
    
    return unitStates

end

local kObjectiveOffset = Vector(0, 0.0, 0)
local kObjectiveDistance = 40
local function AddObjectives(objectives, className)

    local player = Client.GetLocalPlayer()
    
    if player then

        for index, objective in ientitylist(Shared.GetEntitiesWithClassname(className)) do
        
            if objective.showObjective and objective.occupiedTeam ~= player:GetTeamNumber() then
            
                local origin = objective:GetOrigin() + kObjectiveOffset
                            
                local cameraCoords = GetRenderCameraCoords()
                local screenPosition = Vector(0,0,0)

                local toPosition = GetNormalizedVector(cameraCoords.origin - objective:GetOrigin())
                local distanceFraction = 1 - Clamp((cameraCoords.origin - objective:GetOrigin()):GetLength() / kObjectiveDistance, 0, 1)
                local dotProduct = cameraCoords.zAxis:DotProduct(toPosition)
                
                if dotProduct < 0 then
                
                    // Display higher then the origin (world units above the origin)
                    local yOffset = ConditionalValue(player:GetTeamType() == kRedTeamType, .75, 3)
        
                    VectorCopy(Client.WorldToScreen(objective:GetOrigin() + Vector(0, yOffset, 0)), screenPosition) 
                    table.insert(objectives, { Position = screenPosition, TechId = objective:GetTechId(), DistanceFraction = distanceFraction })                    
                end
                
            end    

        end
    
    end

end

function PlayerUI_GetObjectives()

    local objectives = { }
    //AddObjectives(objectives, "ResourcePoint")    
    AddObjectives(objectives, "TechPoint") 

    return objectives
    
end

function PlayerUI_GetWaypointType()

    local player = Client.GetLocalPlayer()
    
    local type = kTechId.Move
    
    if player then
    
        local currentOrder = player:GetCurrentOrder()
        if currentOrder then
            type = currentOrder:GetType()
        end
    
    end
    
    return type

end

/**
 * Get the X position of the crosshair image in the atlas. 
 */
function PlayerUI_GetCrosshairX()
    return 0
end

/**
 * Get the Y position of the crosshair image in the atlas.
 * Listed in this order:
 *   Rifle, Pistol, Axe, Shotgun, Minigun, Rifle with GL, Flamethrower
 */
function PlayerUI_GetCrosshairY()

    local player = Client.GetLocalPlayer()

    if(player and not player:GetIsThirdPerson()) then  
      
        local weapon = player:GetActiveWeapon()
        if(weapon ~= nil) then
        
            // Get class name and use to return index
            local index 
            local mapname = weapon:GetMapName()
            
            if mapname == Rifle.kMapName or mapname == GrenadeLauncher.kMapName or mapname == RocketLauncher.kMapName then 
                index = 0
            elseif mapname == Pistol.kMapName then
                index = 1
            elseif mapname == Shotgun.kMapName then
                index = 3
            elseif mapname == Flamethrower.kMapName then
                index = 5
            // Blanks (with default damage indicator)
            else
                index = 8
            end
        
            return index * 64
            
        end
        
    end

end

function PlayerUI_GetCrosshairDamageIndicatorY()

    return 8 * 64
    
end

/**
 * Returns the player name under the crosshair for display (return "" to not display anything).
 */
function PlayerUI_GetCrosshairText()
    
    local player = Client.GetLocalPlayer()
    if player then
        if player.GetCrossHairText then
            return player:GetCrossHairText()
        else
            return player.crossHairText
        end
    end
    return nil
    
end

function Player:GetDisplayUnitStates()
    return self:GetIsAlive()
end

function PlayerUI_GetProgressText()

    local player = Client.GetLocalPlayer()
    if player then
        return player.progressText
    end
    return nil

end

function PlayerUI_GetProgressFraction()

    local player = Client.GetLocalPlayer()
    if player then
        return player.progressFraction
    end
    return nil

end

local kEnemyObjectiveRange = 30
function PlayerUI_GetObjectiveInfo()

    local player = Client.GetLocalPlayer()
    
    if player then
    
        if player.crossHairHealth and player.crossHairText then  
        
            player.showingObjective = true
            return player.crossHairHealth / 100, player.crossHairText .. " " .. ToString(player.crossHairHealth) .. "%", player.crossHairTeamType
            
        end
        
        // check command structures in range (enemy or friend) and return health % and name
        local objectiveInfoEnts = EntityListToTable( Shared.GetEntitiesWithClassname("ObjectiveInfo") )
        local playersTeam = player:GetTeamNumber()
        
        local function SortByHealthAndTeam(ent1, ent2)
            return ent1:GetHealthScalar() < ent2:GetHealthScalar() and ent1.teamNumber == playersTeam
        end
        
        table.sort(objectiveInfoEnts, SortByHealthAndTeam)
        
        for _, objectiveInfoEnt in ipairs(objectiveInfoEnts) do
        
            if objectiveInfoEnt:GetIsInCombat() and ( playersTeam == objectiveInfoEnt:GetTeamNumber() or (player:GetOrigin() - objectiveInfoEnt:GetOrigin()):GetLength() < kEnemyObjectiveRange ) then

                local healthFraction = math.max(0.01, objectiveInfoEnt:GetHealthScalar())

                player.showingObjective = true
                
                local text = StringReformat(Locale.ResolveString("OBJECTIVE_PROGRESS"),
                                            { location = objectiveInfoEnt:GetLocationName(),
                                              name = GetDisplayNameForTechId(objectiveInfoEnt:GetTechId()),
                                              health = math.ceil(healthFraction * 100) })
                
                return healthFraction, text, objectiveInfoEnt:GetTeamType()
                
            end
            
        end
        
        player.showingObjective = false
        
    end
    
end

function PlayerUI_GetShowsObjective()

    local player = Client.GetLocalPlayer()
    if player then
        return player.showingObjective == true
    end
    
    return false

end

function PlayerUI_GetCrosshairHealth()

    local player = Client.GetLocalPlayer()
    if player then
        if player.GetCrossHairHealth then
            return player:GetCrossHairHealth()
        else
            return player.crossHairHealth
        end
    end
    return nil

end

function PlayerUI_GetCrosshairMaturity()

    local player = Client.GetLocalPlayer()
    if player then
        if player.GetCrossHairMaturity then
            return player:GetCrossHairMaturity()
        else
            return player.crossHairMaturity
        end
    end
    return nil

end

function PlayerUI_GetCrosshairBuildStatus()

    local player = Client.GetLocalPlayer()
    if player then
        if player.GetCrossHairBuildStatus then
            return player:GetCrossHairBuildStatus()
        else
            return player.crossHairBuildStatus
        end
    end
    return nil

end

// Returns the int color to draw the results of PlayerUI_GetCrosshairText() in. 
function PlayerUI_GetCrosshairTextColor()
    local player = Client.GetLocalPlayer()
    if player then
        return player.crossHairTextColor
    end
    return kFriendlyColor
end

/**
 * Get the width of the crosshair image in the atlas, return 0 to hide
 */
function PlayerUI_GetCrosshairWidth()

    local player = Client.GetLocalPlayer()
    if player then

        local weapon = player:GetActiveWeapon()
    
        //if (weapon ~= nil and player:isa("Marine") and not player:GetIsThirdPerson()) then
    if (weapon ~= nil and not player:GetIsThirdPerson()) then
            return 64
        end
    end
    
    return 0
    
end


/**
 * Get the height of the crosshair image in the atlas, return 0 to hide
 */
function PlayerUI_GetCrosshairHeight()

    local player = Client.GetLocalPlayer()
    if(player ~= nil) then

        local weapon = player:GetActiveWeapon()    
        //if(weapon ~= nil and player:isa("Marine") and not player:GetIsThirdPerson()) then
    if (weapon ~= nil and not player:GetIsThirdPerson()) then
            return 64
        end
    
    end
    
    return 0

end

/**
 * Returns nil or the commander name.
 */
function PlayerUI_GetCommanderName()

    local player = Client.GetLocalPlayer()
    local commanderName = nil
    
    if player then
    
        // we simply use the scoreboard ui here, since it holds all informations required client side
        local commTable = ScoreboardUI_GetOrderedCommanderNames(player:GetTeamNumber())
        
        if table.count(commTable) > 0 then
            commanderName = commTable[1]
        end    
        
    end
    
    return commanderName
    
end

function PlayerUI_GetWeapon()
-- TODO : Return actual weapon name
    local player = Client.GetLocalPlayer()
    if player then
        return player:GetActiveWeapon()
    end
    return nil

end

/**
 * Returns a list of techIds (weapons) the player is carrying.
 */
function PlayerUI_GetInventoryTechIds()

    PROFILE("PlayerUI_GetInventoryTechIds")
    
    local player = Client.GetLocalPlayer()
    if player and HasMixin(player, "WeaponOwner") then
    
        local inventoryTechIds = table.array(5)
        local weaponList = player:GetHUDOrderedWeaponList()
        
        for w = 1, #weaponList do
        
            local weapon = weaponList[w]
            table.insert(inventoryTechIds, { TechId = weapon:GetTechId(), HUDSlot = weapon:GetHUDSlot() })
            
        end
        
        return inventoryTechIds
        
    end
    return { }
    
end

function PlayerUI_IsCameraAnimated()

    local player = Client.GetLocalPlayer()
    if player ~= nil then
        return player:IsAnimated()
    end
    
    return false
    
end

/**
 * Returns the techId of the active weapon.
 */
function PlayerUI_GetActiveWeaponTechId()

    PROFILE("PlayerUI_GetActiveWeaponTechId")
    
    local player = Client.GetLocalPlayer()
    if player then
        local activeWeapon = player:GetActiveWeapon()
        if activeWeapon then
            return activeWeapon:GetTechId()
        end    
    end

end

function PlayerUI_GetPlayerClass()
    
    /*
    local player = Client.GetLocalPlayer()
    if player then
        return player:GetClassName()
    end
    */
    return "Player"

end

function PlayerUI_GetMinimapPlayerDirection()

    local player = Client.GetLocalPlayer()
    if player then
        local coords = player:GetViewAngles():GetCoords().zAxis
        return math.atan2(coords.x, coords.z)
    end
    return 0

end

function PlayerUI_GetWeaponClip()
    local player = Client.GetLocalPlayer()
    if player then
        return player:GetWeaponClip()
    end
    return 0
end

function PlayerUI_GetAuxWeaponClip()
    local player = Client.GetLocalPlayer()
    if player then
        return player:GetAuxWeaponClip()
    end
    return 0
end

function PlayerUI_GetWeldPercentage()
    local player = Client.GetLocalPlayer()
    if player and player.GetCurrentWeldPercentage then
        return player:GetCurrentWeldPercentage()
    end    

    return 0
end

function PlayerUI_GetUnitStatusPercentage()

    local player = Client.GetLocalPlayer()
    
    if player and player.UnitStatusPercentage then
        return player:UnitStatusPercentage()
    end
    
    return 0
end

/**
 * Called by Flash to get the value to display for the team resources on
 * the HUD.
 */
function PlayerUI_GetTeamResources()

    PROFILE("PlayerUI_GetTeamResources")
    
    local player = Client.GetLocalPlayer()
    if player then
        return player:GetDisplayTeamResources()
    end
    return 0
end

// TODO: 
function PlayerUI_MarineAbilityIconsImage()
end

function PlayerUI_GetGameStartTime()

    local entityList = Shared.GetEntitiesWithClassname("GameInfo")
    if entityList:GetSize() > 0 then
    
        local gameInfo = entityList:GetEntityAtIndex(0)
        local state = gameInfo:GetState()
        
        if state ~= kGameState.NotStarted and
           state ~= kGameState.PreGame and
           state ~= kGameState.Countdown then
            return gameInfo:GetStartTime()
        end
        
    end
    
    return 0
    
end

function PlayerUI_GetPlayerHealth()

    local player = Client.GetLocalPlayer()
    if player then
    
        local health = math.ceil(player:GetHealth())
        // When alive, enforce at least 1 health for display.
        if player:GetIsAlive() then
            health = math.max(1, health)
        end
        return health
        
    end
    
    return 0
    
end

function PlayerUI_GetPlayerMaxHealth()

    local player = Client.GetLocalPlayer()
    if player then
        return player:GetMaxHealth()
    end
    
    return 0
    
end

function PlayerUI_GetPlayerArmor()

    local player = Client.GetLocalPlayer()
    if player then
        return player:GetArmor()
    end
    
    return 0
    
end

function PlayerUI_GetPlayerMaxArmor()

    local player = Client.GetLocalPlayer()
    if player then
        return player:GetMaxArmor()
    end
    
    return 0
    
end

// For drawing health circles
function GameUI_GetHealthStatus(entityId)

    local entity = Shared.GetEntity(entityId)
    if entity ~= nil then
    
        if HasMixin(entity, "Live") then
            return entity:GetHealth() / entity:GetMaxHealth()
        else
            Print("GameUI_GetHealthStatus(%d) - Entity type %s is not alive.", entityId, entity:GetMapName())
        end
        
    end
    
    return 0
    
end

function Player:GetName(forEntity)

    // There are cases where the player name will be nil such as right before
    // this Player is destroyed on the Client (due to the scoreboard removal message
    // being received on the Client before the entity removed message). Play it safe.
    return Scoreboard_GetPlayerData(self:GetClientIndex(), "Name") or "No Name"
    
end

function PlayerUI_GetPlayerName()

    local player = Client.GetLocalPlayer()
    if player then
        return player:GetName()
    end

    return ""    

end

function Player:GetIsLocalPlayer()
    return self == Client.GetLocalPlayer()
end

function Player:GetDrawResourceDisplay()
    return false
end

function Player:GetShowHealthFor(player)
    return player:isa("Spectator") or ( not GetAreEnemies(self, player) and self:GetIsAlive() )
end

function Player:GetCrossHairTarget()

    local viewAngles = self:GetViewAngles()    
    local viewCoords = viewAngles:GetCoords()    
    local startPoint = self:GetEyePos()
    local endPoint = startPoint + viewCoords.zAxis * Player.kRangeFinderDistance
    
    local trace = Shared.TraceRay(startPoint, endPoint, CollisionRep.Damage, PhysicsMask.AllButPCsAndRagdolls, EntityFilterOne(self))
    return trace.entity
    
end

function Player:GetShowCrossHairText()
    return self:GetTeamNumber() == kMarineTeamType or self:GetTeamNumber() == kRedTeamType
end

function Player:UpdateCrossHairText(entity)

    if self.buyMenu ~= nil then
        self.crossHairText = nil
        self.crossHairHealth = 0
        self.crossHairMaturity = 0
        self.crossHairBuildStatus = 0
        return
    end

    if not entity or not entity:isa("Player") then
        self.crossHairText = nil
        return
    end    
       
    if entity:isa("Player") and GetAreEnemies(self, entity) then
        self.crossHairText = nil
        return
    elseif entity:isa("Player") and GetAreFriends(self, entity) then
        self.crossHairText = entity:GetName()
        return
    end    
    
    if GetAreEnemies(self, entity) then
        self.crossHairTextColor = kEnemyColor
    elseif GetAreFriends(self, entity) then
        self.crossHairTextColor = kFriendlyColor
    else
        self.crossHairTextColor = kNeutralColor
    end

end

// Updates visibilty, status and position of health circle when aiming at an entity with live mixin
function Player:UpdateCrossHairTarget()
 
    //local entity = self:GetCrossHairTarget()
    
    if GetShowHealthRings() == false then
        entity = nil
    end    
    
    self:UpdateCrossHairText(entity)
    
end

// use only client side (for bringing up menus for example). Key events, and their consequences, are not send to the server
function Player:SendKeyEvent(key, down)

    // When exit hit, bring up menu
    if down and key == InputKey.Escape and (Shared.GetTime() > (self.timeLastMenu + 0.3) and not ChatUI_EnteringChatMessage()) then
    
        ExitPressed()
        self.timeLastMenu = Shared.GetTime()
        return true
        
    end
    
    return false

end

// For debugging. Cheats only.
function Player:ToggleTraceReticle()
    self.traceReticle = not self.traceReticle
end

function Player:UpdateMisc(input)

    PROFILE("Player:UpdateMisc")

    if not Shared.GetIsRunningPrediction() then
    
        self:UpdateCrossHairTarget()
        self:UpdateDamageIndicators()
        self:UpdateChat(input)
        
    end
    
end

function Player:SetBlurEnabled(blurEnabled)

    if Player.screenEffects.blur then
        Player.screenEffects.blur:SetActive(blurEnabled)
    end
    
end


function Player:UpdateScreenEffects(deltaTime)

    // Show low health warning if below the threshold and not a spectator and not a commander.
    local isSpectator = self:isa("Spectator") or self:isa("FilmSpectator")

    if self:GetHealthScalar() <= kLowHealthWarning and not isSpectator then
    
        Player.screenEffects.lowHealth:SetActive(true)
        local healthWeight = 1 - (self:GetHealthScalar() / kLowHealthWarning)
        local pulseSpeed = kLowHealthPulseSpeed / 2 + (kLowHealthPulseSpeed / 2 * healthWeight)
        local pulseScalar = (math.sin(Shared.GetTime() * pulseSpeed) + 1) / 2
        healthWeight = 0.5 + (0.5 * (healthWeight * pulseScalar))
        Player.screenEffects.lowHealth:SetParameter("healthWeight", healthWeight)
        
    else
        Player.screenEffects.lowHealth:SetActive(false)
    end
    
end

function Player:UpdateIdleSound()

    // Set idle sound parameter if playing
    if self.idleSoundInstance then
    
        // 1 means inactive, 0 means active   
        local value = ConditionalValue(Shared.GetTime() < self.timeOfIdleActive, 1, 0)
        self.idleSoundInstance:SetParameter("idle", value, 5)
        
        // Set speed parameter also
        local speedScalar = Clamp(self:GetSpeedScalar(), 0, 1)
        self.idleSoundInstance:SetParameter("speed", speedScalar, 5)
        
    end
    
end

function Player:GetDrawWorld(isLocal)
    return not self:GetIsLocalPlayer() or self:GetIsThirdPerson() or ((self.countingDown and not Shared.GetCheatsEnabled()) and self:GetTeamNumber() ~= kNeutralTeamType)
end

// Only called when not running prediction
function Player:UpdateClientEffects(deltaTime, isLocal)

    if isLocal then
    
        self:UpdateIdleSound()
        
    end
    
end

function PlayerUI_GetCrossHairVerticalOffset()

    local vOffset = 0
    local player = Client.GetLocalPlayer()
    
    if player and player.pitchDiff then
    
        vOffset = math.sin(player.pitchDiff) * Client.GetScreenWidth() / 2
    
    end
    
    return vOffset

end

function Player:SetDesiredName()

    // Set default player name to one set in Steam, or one we've used and saved previously
    local playerName = Client.GetOptionString( kNicknameOptionsKey, Client.GetUserName() )
   
    Shared.ConsoleCommand(string.format("name \"%s\"", playerName))

end

function Player:AddAlert(techId, worldX, worldZ, entityId, entityTechId)
    
    assert(worldX)
    assert(worldZ)
    
    // Create alert blip
    local alertType = LookupTechData(techId, kTechDataAlertType, kAlertType.Info)

    table.insert(self.alertBlips, worldX)
    table.insert(self.alertBlips, worldZ)
    table.insert(self.alertBlips, alertType - 1)
    
    // Create alert message => {text, icon x offset, icon y offset, -1, entity id}
    local alertText = GetDisplayNameForAlert(techId, "")
    
    local xOffset, yOffset = GetMaterialXYOffset(entityTechId, GetIsMarineUnit(self))
    if not xOffset or not yOffset then
        Print("Warning: Missing texture offsets for alert: %s techId %s", alertText, EnumToString(kTechId, entityTechId))
        xOffset = 0
        yOffset = 0
    end
    
    table.insert(self.alertMessages, alertText)
    table.insert(self.alertMessages, xOffset)
    table.insert(self.alertMessages, yOffset)
    table.insert(self.alertMessages, entityId)
    table.insert(self.alertMessages, worldX)
    table.insert(self.alertMessages, worldZ)
    
end

function Player:GetAndClearAlertBlips()

    local alertBlips = {}
    table.copy(self.alertBlips, alertBlips)
    table.clear(self.alertBlips)
    return alertBlips
    
end

local function DisableDanger(self)

    // Stop looping music.
    if self:GetIsLocalPlayer() then
        Client.StopMusic("danger")
    end
    
end

// Called on the Client only, after OnInitialized(), for a ScriptActor that is controlled by the local player.
// Ie, the local player is controlling this Marine and wants to intialize local UI, flash, etc.
function Player:OnInitLocalClient()

    self.minimapVisible = false
    
    self.alertBlips = { }
    self.alertMessages = { }

    // Only create base HUDs the first time a player is created.
    // We only ever want one of these.
    GetGUIManager():CreateGUIScriptSingle("GUICrosshair")
    GetGUIManager():CreateGUIScriptSingle("GUIScoreboard")
    GetGUIManager():CreateGUIScriptSingle("GUINotifications")
    GetGUIManager():CreateGUIScriptSingle("GUIRequests")
    GetGUIManager():CreateGUIScriptSingle("GUIDamageIndicators")
    GetGUIManager():CreateGUIScriptSingle("GUIDeathMessages")
    GetGUIManager():CreateGUIScriptSingle("GUIChat")
    GetGUIManager():CreateGUIScriptSingle("GUIVoiceChat")
    GetGUIManager():CreateGUIScriptSingle("GUIMapAnnotations")
    //GetGUIManager():CreateGUIScriptSingle("GUIPlayerNameTags")
    GetGUIManager():CreateGUIScriptSingle("GUIGameEnd")
    GetGUIManager():CreateGUIScriptSingle("GUIWorldText")
    
    if self.unitStatusDisplay == nil then
    
        self.unitStatusDisplay = GetGUIManager():CreateGUIScript("GUIUnitStatus")
        self.unitStatusDisplay:EnableAlienStyle()
        
    end

    // Re-enable skybox rendering after commanding
    SetSkyboxDrawState(true)
    
    // Turn on sound occlusion for non-commanders
    Client.SetSoundGeometryEnabled(true)
    
    // Setup materials, etc. for death messages
    InitDeathMessages(self)
    
    // Fix after Main/Client issue resolved
    self:SetDesiredName()
    
    self.traceReticle = false
    
    self.damageIndicators = { }
    
    Client.SetEnableFog(true)
    
    local loopingIdleSound = self:GetIdleSoundName()
    if loopingIdleSound then
        
        local soundIndex = Shared.GetSoundIndex(loopingIdleSound)
        self.idleSoundInstance = Client.CreateSoundEffect(soundIndex)
        self.idleSoundInstance:SetParent(self:GetId())
        self.idleSoundInstance:Start()
        
        self.timeOfIdleActive = Shared.GetTime()
        
    end
    
    self.crossHairText = nil
    self.crossHairTextColor = kFriendlyColor
    
    // reset mouse sens in case it hase been forgotten somewhere else
    Client.SetMouseSensitivityScalar(1)
    
end

function Player:SetEthereal(ethereal)

    if self.screenEffects and self.screenEffects.fadeBlink and (not ethereal or not self:GetIsThirdPerson()) then
        self.screenEffects.fadeBlink:SetActive(ethereal)
    end
    
end

/**
 * Called when the player entity is destroyed.
 */
function Player:OnDestroy()
    
    self:CloseMenu()
    
    if self.idleSoundInstance then
        Client.DestroySoundEffect(self.idleSoundInstance)
    end
    
    if self.guiCountDownDisplay then
    
        GetGUIManager():DestroyGUIScript(self.guiCountDownDisplay)
        self.guiCountDownDisplay = nil
        
    end
    
    if self.unitStatusDisplay then
    
        GetGUIManager():DestroyGUIScript(self.unitStatusDisplay)
        self.unitStatusDisplay = nil
        
    end
    
    if self.viewModel ~= nil then
        Client.DestroyRenderViewModel(self.viewModel)
        self.viewModel = nil
    end
    
    ScriptActor.OnDestroy(self)
    
end

function Player:DrawGameStatusMessage()

    local time = Shared.GetTime()
    local fraction = 1 - (time - math.floor(time))
    Client.DrawSetColor(255, 0, 0, fraction*200)

    if(self.countingDown) then
    
        Client.DrawSetTextPos(.42*Client.GetScreenWidth(), .95*Client.GetScreenHeight())
        Client.DrawString("Game is starting")
        
    else
    
        Client.DrawSetTextPos(.25*Client.GetScreenWidth(), .95*Client.GetScreenHeight())
        Client.DrawString("Game will start when both sides have players")
        
    end

end

function entityIdInList(entityId, entityList, useParentId)

    for index, entity in ipairs(entityList) do
    
        local id = entity:GetId()
        if(useParentId) then id = entity:GetParentId() end
        
        if(id == entityId) then
        
            return true
            
        end
        
    end
    
    return false
    
end

function Player:DebugVisibility()

    // For each visible entity on other team
    local entities = GetEntitiesMatchAnyTypesForTeam({"Player", "ScriptActor"}, GetEnemyTeamNumber(self:GetTeamNumber()))
    
    for entIndex, entity in ipairs(entities) do
    
        // If so, remember that it's seen and break
        local seen = GetCanSeeEntity(self, entity)            
        
        // Draw red or green depending
        DebugLine(self:GetEyePos(), entity:GetOrigin(), 1, ConditionalValue(seen, 0, 1), ConditionalValue(seen, 1, 0), 0, 1)
        
    end

end

function Player:CloseMenu()
    return false    
end

function Player:GetWeaponClip()

    // We could do some checks to make sure we have a non-nil ClipWeapon,
    // but this should never be called unless we do.
    local weapon = self:GetActiveWeapon()
    
    if weapon ~= nil then
        if weapon:isa("ClipWeapon") then
            return weapon:GetClip()
        end
    end
    
    return 0
    
end

function Player:GetAuxWeaponClip()

    // We could do some checks to make sure we have a non-nil ClipWeapon,
    // but this should never be called unless we do.
    local weapon = self:GetActiveWeapon()
    
    if(weapon ~= nil and weapon:isa("ClipWeapon")) then
        return weapon:GetAuxClip()
    end
    
    return 0
    
end   

function Player:GetHeadAttachpointName()
    return "Head"
end

function Player:GetCameraViewCoordsOverride(cameraCoords)

    local initialAngles = Angles()
    initialAngles:BuildFromCoords(cameraCoords)

    local continue = true

    if not self:GetIsAlive() and self:GetAnimateDeathCamera() then

        local attachCoords = self:GetAttachPointCoords(self:GetHeadAttachpointName())

        local animationIntensity = 0.2
        local movementIntensity = 0.5
        
        cameraCoords.yAxis = GetNormalizedVector(cameraCoords.yAxis + attachCoords.yAxis * animationIntensity)
        cameraCoords.xAxis = cameraCoords.yAxis:CrossProduct(cameraCoords.zAxis)
        cameraCoords.zAxis = cameraCoords.xAxis:CrossProduct(cameraCoords.yAxis)        
        
        cameraCoords.origin.x = cameraCoords.origin.x + (attachCoords.origin.x - cameraCoords.origin.x) * movementIntensity
        cameraCoords.origin.y = attachCoords.origin.y
        cameraCoords.origin.z = cameraCoords.origin.z + (attachCoords.origin.z - cameraCoords.origin.z) * movementIntensity
        
        return cameraCoords
    
    end

    if self.countingDown and not Shared.GetCheatsEnabled() then
    
        if HasMixin(self, "Team") and (self:GetTeamNumber() == kMarineTeamType or self:GetTeamNumber() == kRedTeamType) then
            cameraCoords = self:GetCameraViewCoordsCountdown(cameraCoords)
            Client.SetYaw(self.viewYaw)
            Client.SetPitch(self.viewPitch)
            continue = false
        end
        
        if not self.clientCountingDown then

            self.clientCountingDown = true    
            if self.OnCountDown then
                self:OnCountDown()
            end  
  
        end
        
    end
        
    if continue then
    
         if self.clientCountingDown then
            self.clientCountingDown = false
            
            if self.OnCountDownEnd then
                self:OnCountDownEnd()
            end 
        end
        
        local activeWeapon = self:GetActiveWeapon()
        local animateCamera = activeWeapon and (not activeWeapon.GetPreventCameraAnimation or not activeWeapon:GetPreventCameraAnimation())
    
        // clamp the yaw value to prevent sudden camera flip    
        local cameraAngles = Angles()
        cameraAngles:BuildFromCoords(cameraCoords)
        cameraAngles.pitch = Clamp(cameraAngles.pitch, -kMaxPitch, kMaxPitch)

        cameraCoords = cameraAngles:GetCoords(cameraCoords.origin)

        // Add in camera movement from view model animation
        if self:GetCameraDistance() == 0 then    
        
            local viewModel = self:GetViewModelEntity()
            if viewModel and animateCamera then
            
                local success, viewModelCameraCoords = viewModel:GetCameraCoords()
                if success then
                
                    // If the view model coords has scaling in it that can affect
                    // our later calculations, so remove it.
                    viewModelCameraCoords.xAxis:Normalize()
                    viewModelCameraCoords.yAxis:Normalize()
                    viewModelCameraCoords.zAxis:Normalize()

                    cameraCoords = cameraCoords * viewModelCameraCoords
                    
                end
                
            end
        
        end

        // Allow weapon or ability to override camera (needed for Blink)
        if activeWeapon then
        
            local override, newCoords = activeWeapon:GetCameraCoords()
            
            if override then
                cameraCoords = newCoords
            end
            
        end

        // Add in camera shake effect if any
        if(Shared.GetTime() < self.cameraShakeTime) then
        
            // Camera shake knocks view up and down a bit
            local shakeAmount = math.sin( Shared.GetTime() * self.cameraShakeSpeed * 2 * math.pi ) * self.cameraShakeAmount
            local origin = Vector(cameraCoords.origin)
            
            //cameraCoords.origin = cameraCoords.origin + self.shakeVec*shakeAmount
            local yaw = GetYawFromVector(cameraCoords.zAxis)
            local pitch = GetPitchFromVector(cameraCoords.zAxis) + shakeAmount
            
            local angles = Angles(Clamp(pitch, -kMaxPitch, kMaxPitch), yaw, 0)
            cameraCoords = angles:GetCoords(origin)
            
        end
        
        cameraCoords = self:PlayerCameraCoordsAdjustment(cameraCoords)
    
    end

    local resultingAngles = Angles()
    resultingAngles:BuildFromCoords(cameraCoords)
    /*
    local fovScale = 1
    
    if self:GetNumModelCameras() > 0 then
        local camera = self:GetModelCamera(0)
        fovScale = camera:GetFov() / math.rad(self:GetFov())
    else
        fovScale = 65 / self:GetFov()
    end

    self.pitchDiff = GetAnglesDifference(resultingAngles.pitch, initialAngles.pitch) * fovScale*/
  
    return cameraCoords
    
end

function Player:GetCountDownFraction()

    if not self.clientTimeCountDownStarted then
        self.clientTimeCountDownStarted = Shared.GetTime()
    end
    
    return Clamp((Shared.GetTime() - self.clientTimeCountDownStarted) / Player.kCountDownLength, 0, 1)

end

function Player:GetCountDownTime()

    if self.clientTimeCountDownStarted then
        return Player.kCountDownLength - (Shared.GetTime() - self.clientTimeCountDownStarted)
    end
    
    return Player.kCountDownLength

end

function Player:GetCountDownCamerStartCoords()

    local coords = nil
    
    // find the closest command structure and a random start position, look at it at start
    local commandStructures = GetEntitiesForTeam("CommandStructure", self:GetTeamNumber())
    
    if #commandStructures > 0 then
    
        local extents = LookupTechData(kTechDataMaxExtents, self:GetTechId(), Vector(Player.kXZExtents, Player.kYExtents, Player.kXZExtents))
        local randomSpawn = GetRandomSpawnForCapsule(extents.y, extents.x, commandStructures[1]:GetOrigin(), 4, 7, EntityFilterAll())
    
        if randomSpawn then
        
            randomSpawn = randomSpawn + Vector(0, 2, 0)
            local directionToPlayer = self:GetEyePos() - randomSpawn  
            directionToPlayer.y = 0
            directionToPlayer:Normalize()  
            coords =  Coords.GetLookIn(randomSpawn, directionToPlayer)
            
        end    

    end
    
    return coords

end  

function Player:OnCountDown()

    if not Shared.GetCheatsEnabled() then
    
        if not self.guiCountDownDisplay and HasMixin(self, "Team") and (self:GetTeamNumber() == kMarineTeamType or self:GetTeamNumber() == kRedTeamType) then
            self.guiCountDownDisplay = GetGUIManager():CreateGUIScript("GUICountDownDisplay")
        end
        
    end

end

function Player:OnCountDownEnd()

    if self.guiCountDownDisplay then
    
        GetGUIManager():DestroyGUIScript(self.guiCountDownDisplay)
        self.guiCountDownDisplay = nil
        
    end
    
    Client.PlayMusic("round_start")
    
end

function Player:GetCameraViewCoordsCountdown(cameraCoords)

    if not Shared.GetCheatsEnabled() then
    
        if not self.countDownStartCameraCoords then
            self.countDownStartCameraCoords = self:GetCountDownCamerStartCoords()
        end
        
        if not self.countDownEndCameraCoords then
            self.countDownEndCameraCoords = self:GetViewCoords()
        end

        if self.countDownStartCameraCoords then
        
            local originDiff = self.countDownEndCameraCoords.origin - self.countDownStartCameraCoords.origin        
            local zAxisDiff = self.countDownEndCameraCoords.zAxis - self.countDownStartCameraCoords.zAxis
            zAxisDiff.y = 0
            local animationFraction = self:GetCountDownFraction()
            
            //local viewDirection = self.countDownStartCameraCoords.zAxis + zAxisDiff * animationFraction
            local viewDirection = self.countDownStartCameraCoords.zAxis + zAxisDiff * ( math.cos((animationFraction * (math.pi / 2)) + math.pi ) + 1)

            viewDirection:Normalize()
            
            cameraCoords = Coords.GetLookIn(self.countDownStartCameraCoords.origin + originDiff * animationFraction, viewDirection)
            
            // correct the yAxis to prevent camera flipping
            if cameraCoords.yAxis:DotProduct(Vector(0, 1, 0)) < 0 then
                cameraCoords.yAxis = cameraCoords.zAxis:CrossProduct(-cameraCoords.xAxis)
                cameraCoords.xAxis = viewDirection:CrossProduct(cameraCoords.yAxis)
            end
            
        end
        
    end

    return cameraCoords

end

function Player:PlayerCameraCoordsAdjustment(cameraCoords)

    // No adjustment by default. This function can be overridden to modify the camera
    // coordinates right before rendering.
    return cameraCoords

end

// Ignore camera shaking when done quickly in a row
function Player:SetCameraShake(amount, speed, time)

    // Overrides existing shake if it has elapsed or if new shake amount is larger
    local success = false
    
    local currentTime = Shared.GetTime()
    
    if self.cameraShakeLastTime ~= nil and (currentTime > (self.cameraShakeLastTime + .5)) then
    
        if currentTime > self.cameraShakeTime or amount > self.cameraShakeAmount then
        
            self.cameraShakeAmount = amount

            // "bumps" per second
            self.cameraShakeSpeed = speed 
            
            self.cameraShakeTime = currentTime + time
            
            self.cameraShakeLastTime = currentTime
            
            success = true
            
        end
        
    end
    
    return success
    
end

function PlayerUI_GetIsRepairing()

    local player = Client.GetLocalPlayer()
    if player then
        return player.timeLastRepaired ~= nil and player.timeLastRepaired + 1 > Shared.GetTime()
    end    
    
    return false
    
end

function PlayerUI_GetIsConstructing()

    local player = Client.GetLocalPlayer()
    if player then
        return player.timeLastConstructed ~= nil and player.timeLastConstructed + 1 > Shared.GetTime()
    end
    
    return false
    
end

function PlayerUI_GetLocationPower()

    local player = Client.GetLocalPlayer()
    local isPowered = false
    local powerSource = nil
    local lightMode = nil
    
    if player then
    
        local powerPoint = GetPowerPointForLocation(player:GetLocationName())
        powerSource = powerPoint
        if powerPoint then
        
            isPowered = powerPoint:GetIsPowering()
            lightMode = powerPoint:GetLightMode()
            
        end
        
    end
    
    return { isPowered, powerSource, lightMode }
    
end

// fetch the oldest notification
function PlayerUI_GetRecentNotification()

    if gDebugNotifications then
        if math.random() < 0.2 then
            return { LocationName = "Test Location" , TechId = math.random(1, 80) }
        end
    end

    local notification = nil
    
    local player = Client.GetLocalPlayer()
    if player and player.GetAndClearNotification then
        notification = player:GetAndClearNotification()
    end

    return notification
end

function PlayerUI_GetHasItem(techId)

    local hasItem = false

    if techId and techId ~= kTechId.None then
    
        local player = Client.GetLocalPlayer()
        if player then
        
            local items = GetChildEntities(player, "ScriptActor")

            for index, item in ipairs(items) do
            
                if item:GetTechId() == techId then
                
                    hasItem = true
                    break
                    
                end

            end
        
        end
    
    end
    
    return hasItem

end

local gPreviousTechId = kTechId.None
function PlayerUI_GetRecentPurchaseable()

    local player = Client.GetLocalPlayer()
    if player ~= nil then
        local teamInfo = GetEntitiesForTeam("TeamInfo", player:GetTeamNumber())
        if table.count(teamInfo) > 0 then
        
            local newTechId = teamInfo[1]:GetLatestResearchedTech()
            local playSound = newTechId ~= gPreviousTechId
            
            gPreviousTechId = newTechId
            return newTechId, playSound
            
        end
    end
    return 0, false

end

// True means display the menu or sub-menu
function PlayerUI_ShowSayings()
    local player = Client.GetLocalPlayer()    
    if player then
        return player:GetShowSayings()
    end
    return nil
end

// returns 0 - 3
function PlayerUI_GetArmorLevel()
    local armorLevel = 0
    return armorLevel
end

function PlayerUI_GetWeaponLevel()
    local weaponLevel = 0   
    return weaponLevel
end

// return array of sayings
function PlayerUI_GetSayings()

    local sayings = nil
    local player = Client.GetLocalPlayer()        
    if(player:GetHasSayings()) then
        sayings = player:GetSayings()
    end
    return sayings
    
end

// Returns 0 unless a saying was just chosen. Returns 1 - number of sayings when one is chosen.
function PlayerUI_SayingChosen()

    local player = Client.GetLocalPlayer()
    if player then
    
        local saying = player:GetAndClearSaying()
        if saying ~= nil then
            return saying
        end
        
    end
    return 0
    
end

// Draw the current location on the HUD ("Marine Start", "Processing", etc.)
function PlayerUI_GetLocationName()

    local locationName = ""
    
    local player = Client.GetLocalPlayer()
    if player ~= nil and player:GetIsPlaying() then
        locationName = player:GetLocationName()
    end
    
    return locationName
    
end

function PlayerUI_GetOrigin()

    local player = Client.GetLocalPlayer()    
    if player ~= nil then
        return player:GetOrigin()
    end
    
    return Vector(0, 0, 0)
    
end

function PlayerUI_GetYaw()

    local player = Client.GetLocalPlayer()    
    if player ~= nil then
        return player:GetAngles().yaw
    end
    
    return 0
    
end

function PlayerUI_GetEyePos()

    local player = Client.GetLocalPlayer()    
    if player ~= nil then
        return player:GetEyePos()
    end
    
    return Vector(0, 0, 0)
    
end

function PlayerUI_GetCountDownFraction()

    local player = Client.GetLocalPlayer()
    
    if player and player.GetCountDownFraction then
        return player:GetCountDownFraction()
    end
    
    return 0
    
end

function PlayerUI_GetRemainingCountdown()

    local player = Client.GetLocalPlayer()
    
    if player and player.GetCountDownFraction then
        return player:GetCountDownTime()
    end
    
    return 0
    
end

function PlayerUI_GetIsThirdperson()

    local player = Client.GetLocalPlayer()
    
    if player then
    
        return player:GetIsThirdPerson()
    
    end
    
    return false

end

function PlayerUI_GetIsPlaying()

    local player = Client.GetLocalPlayer()
    
    if player then
        return player:GetIsPlaying()
    end
    
    return false
    
end

function PlayerUI_GetForwardNormal()

    local player = Client.GetLocalPlayer()
    if player ~= nil then
        return player:GetCameraViewCoords().zAxis
    end
    return Vector(0, 0, 1)
    
end

function PlayerUI_IsACommander()

    local player = Client.GetLocalPlayer()
    if player ~= nil then
        return player:isa("Commander")
    end
    
    return false
    
end

function PlayerUI_IsASpectator()

    local player = Client.GetLocalPlayer()
    if player ~= nil then
        return player:isa("Spectator")
    end
    
    return false
    
end

function PlayerUI_IsOverhead()

    local player = Client.GetLocalPlayer()
    if player ~= nil then
        return player:isa("Commander") or (player:isa("Spectator") and player:GetIsOverhead())
    end
    
    return false
    
end

function PlayerUI_IsOnMarineTeam()

    local player = Client.GetLocalPlayer()
    if player and HasMixin(player, "Team") then
        return player:GetTeamNumber() == kMarineTeamType
    end
    
    return false    
    
end

function PlayerUI_IsOnAlienTeam()

    local player = Client.GetLocalPlayer()
    if player and HasMixin(player, "Team") then
        return player:GetTeamNumber() == kRedTeamType
    end
    
    return false  
    
end

function PlayerUI_IsAReadyRoomPlayer()

    local player = Client.GetLocalPlayer()
    if player ~= nil then
        return player:GetTeamNumber() == kTeamReadyRoom
    end
    
    return false
    
end

function PlayerUI_GetTeamNumber()

    local player = Client.GetLocalPlayer()
    
    if player and HasMixin(player, "Team") then    
        return player:GetTeamNumber()    
    end
    
    return 0

end

function PlayerUI_GetRequests()

    local player = Client.GetLocalPlayer()
    local requests = {}
    
    if player and player.GetRequests then

        for _, techId in ipairs() do
        
            local name = GetDisplayNameForTechId(techId)
            
            table.insert(requests, { Name = name, TechId = techId } )
        
        end
 
    end
    
    return requests

end

function PlayerUI_GetTimeDamageTaken()

    local player = Client.GetLocalPlayer()
    if player then
    
        if HasMixin(player, "Combat") then
            return player:GetTimeLastDamageTaken()
        end
    
    end
    
    return 0

end

function PlayerUI_GetTeamType()

    local player = Client.GetLocalPlayer()
    
    if player and HasMixin(player, "Team") then    
        return player:GetTeamType()    
    end
    
    return kNeutralTeamType

end

function PlayerUI_GetHasGameStarted()

     local player = Client.GetLocalPlayer()
     return player and player:GetGameStarted()
     
end

function PlayerUI_GetTeamColor(teamNumber)

    if teamNumber then
        return ColorIntToColor(GetColorForTeamNumber(teamNumber))
    else
        local player = Client.GetLocalPlayer()
        return ColorIntToColor(GetColorForPlayer(player))
    end
    
end

/**
 * Returns all locations as a name and origin.
 */
function PlayerUI_GetLocationData()

    local returnData = { }
    local locationEnts = GetLocations()
    for i, location in ipairs(locationEnts) do
        if location:GetShowOnMinimap() then
            table.insert(returnData, { Name = location:GetName(), Origin = location:GetOrigin() })
        end
    end
    return returnData

end

/**
 * Converts world coordinates into normalized map coordinates.
 */
function PlayerUI_GetMapXY(worldX, worldZ)

    local player = Client.GetLocalPlayer()
    if player then
        local success, mapX, mapY = player:GetMapXY(worldX, worldZ)
        return mapX, mapY
    end
    return 0, 0

end

/**
 * Damage indicators. Returns a array of damage indicators which are used to draw red arrows pointing towards
 * recent damage. Each damage indicator pair will consist of an alpha and a direction. The alpha is 0-1 and the
 * direction in radians is the angle at which to display it. 0 should face forward (top of the screen), pi 
 * should be behind us (bottom of the screen), pi/2 is to our left, 3*pi/2 is right.
 * 
 * For two damage indicators, perhaps:
 *  {alpha1, directionRadians1, alpha2, directonRadius2}
 *
 * It returns an empty table if the player has taken no damage recently. 
 */
function PlayerUI_GetDamageIndicators()

    local drawIndicators = {}
    
    local player = Client.GetLocalPlayer()
    if player then
    
        for index, indicatorTriple in ipairs(player.damageIndicators) do
            
            local alpha = Clamp(1 - ((Shared.GetTime() - indicatorTriple[3])/Player.kDamageIndicatorDrawTime), 0, 1)
            table.insert(drawIndicators, alpha)

            local worldX = indicatorTriple[1]
            local worldZ = indicatorTriple[2]
            
            local normDirToDamage = GetNormalizedVector(Vector(player:GetOrigin().x, 0, player:GetOrigin().z) - Vector(worldX, 0, worldZ))
            local worldToView = player:GetViewAngles():GetCoords():GetInverse()
            
            local damageDirInView = worldToView:TransformVector(normDirToDamage)
            
            local directionRadians = math.atan2(damageDirInView.x, damageDirInView.z)
            if directionRadians < 0 then
                directionRadians = directionRadians + 2 * math.pi
            end
            
            table.insert(drawIndicators, directionRadians)
            
        end
        
    end
    
    return drawIndicators
    
end

// Displays an image around the crosshair when the local player has given damage to something else.
// Returns true if the indicator should be displayed and the time that has passed as a percentage.
function PlayerUI_GetShowGiveDamageIndicator()

    local player = Client.GetLocalPlayer()
    if player and player.GetDamageIndicatorTime and player:GetIsPlaying() then
    
        local timePassed = Shared.GetTime() - player:GetDamageIndicatorTime()
        return timePassed <= Player.kShowGiveDamageTime, math.min(timePassed / Player.kShowGiveDamageTime, 1)
        
    end
    
    return false, 0
    
end

function Player:AddTakeDamageIndicator(worldX, worldZ)

    // Insert triple indicating when damage was taken and from where it came 
    local triple = {worldX, worldZ, Shared.GetTime()}
    table.insert(self.damageIndicators, triple)
    
    if not self:GetIsAlive() and not self.deathTriggered then
        self:TriggerFirstPersonDeathEffects()
        self.deathTriggered = true
    end
    
end

// child classes can override this
function Player:GetShowDamageIndicator()

    local weapon = self:GetActiveWeapon()
    if weapon then
        return weapon:GetShowDamageIndicator()
    end    
    return true
    
end

// child classes should override this
function Player:OnGiveDamage()
end

function Player:UpdateDamageIndicators()

    local indicesToRemove = {}
    
    // Expire old damage indicators
    for index, indicatorTriple in ipairs(self.damageIndicators) do
    
        if Shared.GetTime() > (indicatorTriple[3] + Player.kDamageIndicatorDrawTime) then
        
            table.insert(indicesToRemove, index)
            
        end
        
    end
    
    for i, index in ipairs(indicesToRemove) do
        table.remove(self.damageIndicators, index)
    end
    
    // update damage given
    if self.giveDamageTimeClientCheck ~= self.giveDamageTime then
    
        self.giveDamageTimeClientCheck = self.giveDamageTime
        // Must factor in ping time as this value is delayed.
        self.giveDamageTimeClient = self.giveDamageTime + Client.GetPing()
        self.showDamage = self:GetShowDamageIndicator()
        if self.showDamage then
            self:OnGiveDamage()
        end
        
    end
    
end

function Player:GetDamageIndicatorTime()

    if self.showDamage then
        return self.giveDamageTimeClient
    end
    
    return 0
    
end

local function OnJumpLandClient(self)

    if not Shared.GetIsRunningPrediction() then
    
        local landSurface = GetSurfaceAndNormalUnderEntity(self)
        self:TriggerEffects("land", { surface = landSurface, enemy = GetAreEnemies(self, Client.GetLocalPlayer()) })
        
    end
    
end

function Player:OnJumpLandLocalClient()
    OnJumpLandClient(self)
end

function Player:OnJumpLandNonLocalClient()
    OnJumpLandClient(self)
end

// Call OnJumpLandNonLocalClient for other players to avoid network traffic
function Player:CheckClientJumpLandOnSynch()

    if not self:GetIsLocalPlayer() then
    
        if self.clientOnSurface == false and self:GetIsOnSurface() then
            self:OnJumpLandNonLocalClient()
        end
        
        self.clientOnSurface = self:GetIsOnSurface()
        
    end
    
end


function Player:OnPreUpdate()

    PROFILE("Player:OnPreUpdate")

    self:CheckClientJumpLandOnSynch()
    
    if self.locationId ~= self.lastLocationId then
    
        self:OnLocationChange(Shared.GetString(self.locationId))
        
        self.lastLocationId = self.locationId
        
    end
    
end

function Player:OnUpdatePlayer(deltaTime)

    if not Shared.GetIsRunningPrediction() then
           
        self:UpdateClientEffects(deltaTime, self:GetIsLocalPlayer())
        
        self:UpdateCommunicationStatus()
        
    end
    
end


function Player:UpdateCommunicationStatus()

    if self:GetIsLocalPlayer() then

        local time = Client.GetTime()
        
        if self.timeLastCommStatusUpdate == nil or (time > self.timeLastCommStatusUpdate + 0.5) then
        
            local newCommStatus = kPlayerCommunicationStatus.None

            // If voice comm being used
            if Client.IsVoiceRecordingActive() then
                newCommStatus = kPlayerCommunicationStatus.Voice
            // If we're typing
            elseif ChatUI_EnteringChatMessage() then
                newCommStatus = kPlayerCommunicationStatus.Typing
            // In menu
            elseif MainMenu_GetIsOpened() then
                newCommStatus = kPlayerCommunicationStatus.Menu
            end
            
            if newCommStatus ~= self:GetCommunicationStatus() then
            
                Client.SendNetworkMessage("SetCommunicationStatus", BuildCommunicationStatus(newCommStatus), true)
                self:SetCommunicationStatus(newCommStatus)
                
            end
        
            self.timeLastCommStatusUpdate = time
            
        end
        
    end
    
end

function Player:OnGetIsVisible(visibleTable)
    visibleTable.Visible = self:GetDrawWorld()
end

function Player:OnUpdateRender()

    PROFILE("Player:OnUpdateRender")
    
    if self:GetIsLocalPlayer() then
    
        local blurEnabled = self.minimapVisible
        self:SetBlurEnabled(blurEnabled)
        
        self.lastOnUpdateRenderTime = self.lastOnUpdateRenderTime or Shared.GetTime()
        local now = Shared.GetTime()
        self:UpdateScreenEffects(now - self.lastOnUpdateRenderTime)
        self.lastOnUpdateRenderTime = now
        
    end
    
end

function Player:UpdateChat(input)

    if not Shared.GetIsRunningPrediction() then
    
        // Enter chat message
        if (bit.band(input.commands, Move.TextChat) ~= 0) then
            ChatUI_EnterChatMessage(false)
        end

        // Enter chat message
        if (bit.band(input.commands, Move.TeamChat) ~= 0) then
            ChatUI_EnterChatMessage(true)
        end
        
    end
    
end

function Player:GetCustomSelectionText()
    return string.format("%s kills\n%s deaths\n%s score",
            ToString(Scoreboard_GetPlayerData(self:GetClientIndex(), "Kills")),
            ToString(Scoreboard_GetPlayerData(self:GetClientIndex(), "Deaths")),
            ToString(Scoreboard_GetPlayerData(self:GetClientIndex(), "Score")))
end

function Player:GetIdleSoundName()
    return nil
end

function Player:SetIdleSoundInactive()
    self.timeOfIdleActive = Shared.GetTime() + 3
end

// Set light shake amount due to nearby roaming Onos
function Player:SetLightShakeAmount(amount, duration, scalar)

    if scalar == nil then
        scalar = 1
    end
    
    // So lights start moving in time with footsteps
    self:ResetShakingLights()

    self.lightShakeAmount = Clamp(amount, 0, 1)
    
    // Save off original amount so we can have it fall off nicely
    self.savedLightShakeAmount = self.lightShakeAmount
    
    self.lightShakeEndTime = Shared.GetTime() + duration
    
    self.lightShakeScalar = scalar
    
end

function Player:AddBindingHint(bindingString, entId, localizableText, priority)

    assert(type(bindingString) == "string")
    assert(type(entId) == "number")
    assert(type(localizableText) == "string")
    assert(type(priority) == "number")

    if self.hints then
    
        local key = BindingsUI_GetInputValue(bindingString)
        local localizedText = string.format(Locale.ResolveString(localizableText), ToString(key))
        self.hints:AddHint(entId, localizedText, priority)
        
    end
    
end

function Player:AddHint(entId, localizableText, priority)

    assert(type(entId) == "number")
    assert(type(localizableText) == "string")
    assert(type(priority) == "number")
    
    if self.hints then    
        self.hints:AddHint(entId, Locale.ResolveString(localizableText), priority)        
    end    
end

// Put a small information sign in the world
/*
function Player:AddInfoHint(entId, localizableText, priority)

    assert(type(entId) == "number")
    assert(type(localizableText) == "string")
    assert(type(priority) == "number")
    
    if self.hints then    
        self.hints:AddInfoHint(entId, Locale.ResolveString(localizableText), priority)        
    end    

end
*/

function Player:AddGlobalHint(localizableText, priority)

    assert(type(localizableText) == "string")
    assert(type(priority) == "number")

    if self.hints then
    
        local text = TranslateHintText(Locale.ResolveString(localizableText))
        self.hints:AddGlobalHint(text, priority)
        
    end
end

function Player:GetFirstPersonDeathEffect()
    return Player.kFirstPersonDeathEffect
end

function Player:TriggerFirstPersonDeathEffects()

    local cinematic = Client.CreateCinematic(RenderScene.Zone_ViewModel)
    cinematic:SetCinematic(self:GetFirstPersonDeathEffect())
    
end

local function GetFirstPersonHitEffectName(doer)

    local effectName = kDefaultFirstPersonEffectName
    
    local player = Client.GetLocalPlayer()
    
    if player and player.GetFirstPersonHitEffectName then    
        effectName = player:GetFirstPersonHitEffectName(doer)    
    end
    
    return effectName

end

function Player:OnTakeDamageClient(damage, doer, position)

    if self == Client.GetLocalPlayer() then

        if doer and GetAreFriends(self, doer) then
            return
        end

        local cameraCoords = GetRenderCameraCoords()
        if cameraCoords then
        
            local effectCoords = Coords.GetIdentity()
            effectCoords.yAxis = GetNormalizedVectorXY(cameraCoords.origin - position)
            effectCoords.xAxis = effectCoords.zAxis:CrossProduct(effectCoords.yAxis)
            
            local cinematic = Client.CreateCinematic(RenderScene.Zone_ViewModel)
            cinematic:SetCinematic(GetFirstPersonHitEffectName(doer))
            cinematic:SetCoords(effectCoords)
        
        end
    
    end
    
    // TODO: trigger camera tilt, somehow, somewhere (probably 'global' tilt for smoothing transistion to spectator camera / death anim)

end

/**
 * This is called from BaseModelMixin. This will force all player animations to process so we
 * get animation tags on the Client for other player models. These tags are needed to trigger
 * footstep sound effects.
 */
function Player:GetClientSideAnimationEnabled()
    return true
end