// ======= Copyright (c) 2012, Unknown Worlds Entertainment, Inc. All rights reserved. ============
//
// lua\Exo.lua
//
//    Created by:   Brian Cronin (brianc@unknownworlds.com)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

EXO_ENABLED = true

Script.Load("lua/Player.lua")
Script.Load("lua/Mixins/BaseMoveMixin.lua")
Script.Load("lua/Mixins/GroundMoveMixin.lua")
Script.Load("lua/Mixins/CameraHolderMixin.lua")
Script.Load("lua/Weapons/Marine/ExoWeaponHolder.lua")
Script.Load("lua/MapBlipMixin.lua")
Script.Load("lua/VortexAbleMixin.lua")
Script.Load("lua/ScoringMixin.lua")
Script.Load("lua/LOSMixin.lua")
Script.Load("lua/WeldableMixin.lua")
Script.Load("lua/CombatMixin.lua")
Script.Load("lua/SelectableMixin.lua")

local kExoFirstPersonHitEffectName = PrecacheAsset("cinematics/marine/hit_1p_exo.cinematic")

class 'Exo' (Player)

local networkVars =
{
    flashlightOn = "boolean",
    flashlightLastFrame = "private boolean",
    idleSound2DId = "private entityid"
}

Exo.kMapName = "exo"

local kModelName = PrecacheAsset("models/marine/exosuit/exosuit_cm.model")
local kAnimationGraph = PrecacheAsset("models/marine/exosuit/exosuit_cm.animation_graph")

local kDualModelName = PrecacheAsset("models/marine/exosuit/exosuit_mm.model")
local kDualAnimationGraph = PrecacheAsset("models/marine/exosuit/exosuit_mm.animation_graph")

Shared.PrecacheSurfaceShader("shaders/ExoScreen.surface_shader")

local kIdle2D = PrecacheAsset("sound/NS2.fev/marine/heavy/idle_2D")

local kHealthWarning = PrecacheAsset("sound/NS2.fev/marine/heavy/warning")
local kHealthWarningTrigger = 0.4

local kHealthCritical = PrecacheAsset("sound/NS2.fev/marine/heavy/critical")
local kHealthCriticalTrigger = 0.2

local kWalkMaxSpeed = 3.7
local kViewOffsetHeight = 2.3
local kAcceleration = 40

local kSmashEggRange = 1.5

local kCrouchShrinkAmount = 0
local kExtentsCrouchShrinkAmount = 0

local kDeploy2DSound = PrecacheAsset("sound/NS2.fev/marine/heavy/deploy_2D")

// How fast does the Exo armor get repaired by welders.
local kArmorWeldRate = 25

Exo.kXZExtents = 0.55
Exo.kYExtents = 1.2

AddMixinNetworkVars(BaseMoveMixin, networkVars)
AddMixinNetworkVars(GroundMoveMixin, networkVars)
AddMixinNetworkVars(CameraHolderMixin, networkVars)
AddMixinNetworkVars(VortexAbleMixin, networkVars)
AddMixinNetworkVars(LOSMixin, networkVars)
AddMixinNetworkVars(CombatMixin, networkVars)
AddMixinNetworkVars(SelectableMixin, networkVars)

local function SmashNearbyEggs(self)

    local nearbyEggs = GetEntitiesWithinRange("Egg", self:GetOrigin(), kSmashEggRange)
    for _, egg in ipairs(nearbyEggs) do
        egg:Kill(self, self, self:GetOrigin(), Vector(0, -1, 0))
    end
    
    // Keep on killing those nasty eggs forever.
    return true
    
end

function Exo:OnCreate()

    Player.OnCreate(self)
    
    InitMixin(self, BaseMoveMixin, { kGravity = Player.kGravity })
    InitMixin(self, GroundMoveMixin)
    InitMixin(self, VortexAbleMixin)
    InitMixin(self, EntityChangeMixin)
    InitMixin(self, LOSMixin)
    InitMixin(self, CameraHolderMixin, { kFov = kExoFov })
    InitMixin(self, ScoringMixin, { kMaxScore = kMaxScore })
    InitMixin(self, WeldableMixin)
    InitMixin(self, CombatMixin)
    InitMixin(self, SelectableMixin)
    
    self:SetIgnoreHealth(true)
    
    self:AddTimedCallback(SmashNearbyEggs, 0.1)
    
    self.deployed = false
    
    self.flashlightOn = false
    self.flashlightLastFrame = false
    self.idleSound2DId = Entity.invalidId
    
    if Server then
    
        self.idleSound2D = Server.CreateEntity(SoundEffect.kMapName)
        self.idleSound2D:SetAsset(kIdle2D)
        self.idleSound2D:SetParent(self)
        self.idleSound2D:Start()
        
        // Only sync 2D sound with this Exo player.
        self.idleSound2D:SetPropagate(Entity.Propagate_Callback)
        function self.idleSound2D.OnGetIsRelevant(_, player)
            return player == self
        end
        
        self.idleSound2DId = self.idleSound2D:GetId()
        
    else
    
        self.flashlight = Client.CreateRenderLight()
        
        self.flashlight:SetType(RenderLight.Type_Spot)
        self.flashlight:SetColor(Color(.8, .8, 1))
        self.flashlight:SetInnerCone(math.rad(30))
        self.flashlight:SetOuterCone(math.rad(45))
        self.flashlight:SetIntensity(10)
        self.flashlight:SetRadius(25)
        //self.flashlight:SetGoboTexture("models/marine/male/flashlight.dds")
        
        self.flashlight:SetIsVisible(false)
        
    end
    
end

function Exo:OnInitialized()

    // SetModel must be called before Player.OnInitialized is called so the attach points in
    // the Exo are valid to attach weapons to. This is far too subtle...
    self:SetModel(kModelName, kAnimationGraph)
    
    Player.OnInitialized(self)
    
    if Server then
    
        // This Mixin must be inited inside this OnInitialized() function.
        if not HasMixin(self, "MapBlip") then
            InitMixin(self, MapBlipMixin)
        end
        
        self.armor = self:GetArmorAmount()
        self.maxArmor = self.armor
        
    elseif Client then
        InitMixin(self, HiveVisionMixin)        
    end
    
end

function Exo:GetCrouchShrinkAmount()
    return kCrouchShrinkAmount
end

function Exo:GetExtentsCrouchShrinkAmount()
    return kExtentsCrouchShrinkAmount
end

// exo has no crouch animations
function Exo:GetCanCrouch()
    return false
end

function Exo:InitWeapons()

    Player.InitWeapons(self)
    
    local weaponHolder = self:GiveItem(ExoWeaponHolder.kMapName, false)
    weaponHolder:SetWeapons(Claw.kMapName, Minigun.kMapName)
    weaponHolder:TriggerEffects("exo_login")
    self:SetActiveWeapon(ExoWeaponHolder.kMapName)
    StartSoundEffectForPlayer(kDeploy2DSound, self)
    
end

function Exo:InitDualMinigun()

    self:SetModel(kDualModelName, kDualAnimationGraph)
    
    local weaponHolder = self:GetWeapon(ExoWeaponHolder.kMapName, false)
    weaponHolder:SetWeapons(Minigun.kMapName, Minigun.kMapName)
    weaponHolder:TriggerEffects("exo_login")
    self:SetActiveWeapon(ExoWeaponHolder.kMapName)
    StartSoundEffectForPlayer(kDeploy2DSound, self)
    
end

function Exo:OnDestroy()

    if self.marineHUD then
    
        GetGUIManager():DestroyGUIScript(self.marineHUD)
        self.marineHUD = nil
        
    end
    
    if self.exoHUD then
    
        GetGUIManager():DestroyGUIScript(self.exoHUD)
        self.exoHUD = nil
        
    end
    
    if self.progressDisplay then
    
        GetGUIManager():DestroyGUIScript(self.progressDisplay)
        self.progressDisplay = nil
        
    end
    
    if self.flashlight ~= nil then
        Client.DestroyRenderLight(self.flashlight)
    end
    
end

function Exo:GetMaxViewOffsetHeight()
    return kViewOffsetHeight
end

function Exo:GetAcceleration()
    return kAcceleration
end

function Exo:GetMaxSpeed(possible)
    return kWalkMaxSpeed
end

function Exo:MakeSpecialEdition()
    // Currently there's no Exo special edition visual difference
end

function Exo:GetHeadAttachpointName()
    return "Exosuit_HoodHinge"
end

function Exo:GetArmorAmount()

    local armorLevels = 0
    
    if GetHasTech(self, kTechId.Armor3, true) then
        armorLevels = 3
    elseif GetHasTech(self, kTechId.Armor2, true) then
        armorLevels = 2
    elseif GetHasTech(self, kTechId.Armor1, true) then
        armorLevels = 1
    end
    
    return kExosuitArmor + armorLevels * kExosuitArmorPerUpgradeLevel
    
end

function Exo:GetFirstPersonHitEffectName()
    return kExoFirstPersonHitEffectName
end 

function Exo:GetCanRepairOverride(target)
    return false
end

function Exo:GetReceivesBiologicalDamage()
    return false
end

function Exo:GetReceivesVaporousDamage()
    return false
end

function Exo:GetCanBeWeldedOverride()
    return not self:GetIsVortexed() and self:GetArmor() < self:GetMaxArmor(), false
end

function Exo:GetWeldPercentageOverride()
    return self:GetArmor() / self:GetMaxArmor()
end

local function UpdateHealthWarningTriggered(self)

    local healthPercent = self:GetArmorScalar()
    if healthPercent > kHealthWarningTrigger then
        self.healthWarningTriggered = false
    end
    
    if healthPercent > kHealthCriticalTrigger then
        self.healthCriticalTriggered = false
    end
    
end

local kEngageOffset = Vector(0, 1.5, 0)
function Exo:GetEngagementPointOverride()
    return self:GetOrigin() + kEngageOffset
end

local kExoHealthbarOffset = Vector(0, 1.8, 0)
function Exo:GetHealthbarOffset()
    return kExoHealthbarOffset
end

function Exo:OnWeldOverride(doer, elapsedTime)

    if self:GetArmor() < self:GetMaxArmor() then
    
        local addArmor = kArmorWeldRate * elapsedTime
        self:SetArmor(self:GetArmor() + addArmor)
        
        if Server then
            UpdateHealthWarningTriggered(self)
        end
        
    end
    
end

function Exo:GetPlayerStatusDesc()
    return self:GetIsAlive() and kPlayerStatus.Exo or kPlayerStatus.Dead
end

/**
 * The Exo does not use anything. It smashes.
 */
function Exo:GetIsAbleToUse()
    return false
end

local function UpdateIdle2DSound(self, yaw, pitch, dt)

    if self.idleSound2DId ~= Entity.invalidId then
    
        local idleSound2D = Shared.GetEntity(self.idleSound2DId)
        
        self.lastExoYaw = self.lastExoYaw or yaw
        self.lastExoPitch = self.lastExoPitch or pitch
        
        local yawDiff = math.abs(GetAnglesDifference(yaw, self.lastExoYaw))
        local pitchDiff = math.abs(GetAnglesDifference(pitch, self.lastExoPitch))
        
        self.lastExoYaw = yaw
        self.lastExoPitch = pitch
        
        local rotateSpeed = math.min(1, ((yawDiff ^ 2) + (pitchDiff ^ 2)) / 0.05)
        //idleSound2D:SetParameter("rotate", rotateSpeed, 1)
        
    end
    
end

function Exo:OnProcessMove(input)

    Player.OnProcessMove(self, input)
    
    if Client and not Shared.GetIsRunningPrediction() then
        UpdateIdle2DSound(self, input.yaw, input.pitch, input.time)
    end
    
    local flashlightPressed = bit.band(input.commands, Move.ToggleFlashlight) ~= 0
    if not self.flashlightLastFrame and flashlightPressed then
    
        self:SetFlashlightOn(not self:GetFlashlightOn())
        Shared.PlaySound(self, Marine.kFlashlightSoundName)
        
    end
    self.flashlightLastFrame = flashlightPressed
    
end

function Exo:SetFlashlightOn(state)
    self.flashlightOn = state
end

function Exo:GetFlashlightOn()
    return self.flashlightOn
end

if Server then

    function Exo:OnHealed()
        UpdateHealthWarningTriggered(self)
    end
    
    function Exo:OnTakeDamage(damage, attacker, doer, point, direction, damageType)
    
        local healthPercent = self:GetArmorScalar()
        if not self.healthCriticalTriggered and healthPercent <= kHealthCriticalTrigger then
        
            StartSoundEffectForPlayer(kHealthCritical, self)
            self.healthCriticalTriggered = true
            
        elseif not self.healthWarningTriggered and healthPercent <= kHealthWarningTrigger then
        
            StartSoundEffectForPlayer(kHealthWarning, self)
            self.healthWarningTriggered = true
            
        end
        
    end
    
    function Exo:OnKill(attacker, doer, point, direction)
    
        Player.OnKill(self, attacker, doer, point, direction)
        
        local activeWeapon = self:GetActiveWeapon()
        if activeWeapon and activeWeapon.OnParentKilled then
            activeWeapon:OnParentKilled(attacker, doer, point, direction)
        end
        
    end
    
end

if Client then

    local function ShowHUD(self, show)
    
        self.marineHUD:SetIsVisible(show)
        self.exoHUD:SetIsVisible(show)
        
    end
    
    function Exo:OnInitLocalClient()
    
        Player.OnInitLocalClient(self)
        
        if self.marineHUD == nil then
        
            self.marineHUD = GetGUIManager():CreateGUIScript("Hud/Marine/GUIMarineHUD")
            self.marineHUD:SetStatusDisplayVisible(false)
            self.marineHUD:SetFrameVisible(false)
            self.marineHUD:SetInventoryDisplayVisible(false)
            
        end
        
        if self.exoHUD == nil then
            self.exoHUD = GetGUIManager():CreateGUIScript("Hud/Marine/GUIExoHUD")
        end
        
        if self.progressDisplay == nil then
            self.progressDisplay = GetGUIManager():CreateGUIScript("GUIProgressBar")
        end
        
        ShowHUD(self, false)
        
    end
    
    // The Exo overrides the default trigger for footsteps.
    // They are triggered by the view model for the local player but
    // still uses the default behavior for other players viewing the Exo.
    function Exo:TriggerFootstep()
    
        if self ~= Client.GetLocalPlayer() then
            Player.TriggerFootstep(self)
        end
        
    end
    
    function Exo:UpdateClientEffects(deltaTime, isLocal)
    
        Player.UpdateClientEffects(self, deltaTime, isLocal)
        
        if isLocal then
        
            local visible = self.deployed and self:GetIsAlive() and not self:GetIsThirdPerson()
            ShowHUD(self, visible)
            
        end
        
    end
    
    function Exo:OnUpdateRender()
    
        PROFILE("Exo:OnUpdateRender")
        
        Player.OnUpdateRender(self)
        
        local isLocal = self:GetIsLocalPlayer()
        // Synchronize the state of the light representing the flash light.
        self.flashlight:SetIsVisible(self.flashlightOn and (isLocal or self:GetIsVisible()) )
        
        if self.flashlightOn then
        
            local coords = Coords(self:GetViewCoords())
            coords.origin = coords.origin + coords.zAxis * 0.75
            
            self.flashlight:SetCoords(coords)
            
            // Only display atmospherics for third person players.
            local density = 0.2
            if isLocal and not self:GetIsThirdPerson() then
                density = 0
            end
            self.flashlight:SetAtmosphericDensity(density)
            
        end
        
        if self:GetIsLocalPlayer() then
        
            local viewModel = self:GetViewModelEntity()
            if viewModel then
            
                viewModel:InstanceMaterials()
                
                local model = viewModel:GetRenderModel()
                if model then
                    model:SetMaterialParameter("armorAmount", math.ceil(self:GetArmor()))
                end
                
            end
            
        end
        
    end
    
end

function Exo:GetCanClimb()
    return false
end

function Exo:OnTag(tagName)

    PROFILE("Exo:OnTag")

    Player.OnTag(self, tagName)
    
    if tagName == "deploy_end" then
        self.deployed = true
    end
    
end

Shared.LinkClassToMap("Exo", Exo.kMapName, networkVars)