// ======= Copyright (c) 2003-2012, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\Alien.lua
//
//    Created by:   Charlie Cleveland (charlie@unknownworlds.com) and
//                  Max McGuire (max@unknownworlds.com)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/Player.lua")
Script.Load("lua/CloakableMixin.lua")
Script.Load("lua/InfestationTrackerMixin.lua")
Script.Load("lua/FireMixin.lua")
Script.Load("lua/UmbraMixin.lua")
Script.Load("lua/RegenerationMixin.lua")
Script.Load("lua/CatalystMixin.lua")
Script.Load("lua/ScoringMixin.lua")
Script.Load("lua/Alien_Upgrade.lua")
Script.Load("lua/UnitStatusMixin.lua")
Script.Load("lua/EnergizeMixin.lua")
Script.Load("lua/MapBlipMixin.lua")
Script.Load("lua/HiveVisionMixin.lua")
Script.Load("lua/FeintMixin.lua")
Script.Load("lua/CombatMixin.lua")
Script.Load("lua/LOSMixin.lua")
Script.Load("lua/SelectableMixin.lua")
Script.Load("lua/AlienActionFinderMixin.lua")

if Client then
    Script.Load("lua/TeamMessageMixin.lua")
end

class 'Alien' (Player)

Alien.kMapName = "alien"

if Server then
    Script.Load("lua/Alien_Server.lua")
else
    Script.Load("lua/Alien_Client.lua")
end

Shared.PrecacheSurfaceShader("models/alien/alien.surface_shader")

Alien.kNotEnoughResourcesSound = PrecacheAsset("sound/NS2.fev/alien/voiceovers/more")

Alien.kChatSound = PrecacheAsset("sound/NS2.fev/alien/common/chat")
Alien.kSpendResourcesSoundName = PrecacheAsset("sound/NS2.fev/alien/commander/spend_nanites")

local kCelerityLoopingSound = PrecacheAsset("sound/NS2.fev/alien/common/celerity_loop")

// Representative portrait of selected units in the middle of the build button cluster
Alien.kPortraitIconsTexture = "ui/alien_portraiticons.dds"

// Multiple selection icons at bottom middle of screen
Alien.kFocusIconsTexture = "ui/alien_focusicons.dds"

// Small mono-color icons representing 1-4 upgrades that the creature or structure has
Alien.kUpgradeIconsTexture = "ui/alien_upgradeicons.dds"

Alien.kAnimOverlayAttack = "attack"

Alien.kWalkBackwardSpeedScalar = 0.75

Alien.kEnergyRecuperationRate = 10.0

// How long our "need healing" text gets displayed under our blip
Alien.kCustomBlipDuration = 10
Alien.kEnergyAdrenalineRecuperationRate = 20.0

local kDefaultAttackSpeed = 1

local networkVars = 
{
    // The alien energy used for all alien weapons and abilities (instead of ammo) are calculated
    // from when it last changed with a constant regen added
    timeAbilityEnergyChanged = "time",
    abilityEnergyOnChange = "float (0 to " .. math.ceil(kAbilityMaxEnergy) .. " by 0.05 [] )",
    
    movementModiferState = "boolean",
    
    twoHives = "private boolean",
    threeHives = "private boolean",
    
    enzymed = "boolean",
    primalScreamBoost = "compensated boolean",
    
    infestationSpeedScalar = "private float",
    infestationSpeedUpgrade = "private boolean",
    
    celeritySpeedScalar = "private float",
    storedHyperMutationTime = "private float",
    storedHyperMutationCost = "private float",
    
    darkVisionOn = "private boolean",
    darkVisionLastFrame = "private boolean"
}

AddMixinNetworkVars(CloakableMixin, networkVars)
AddMixinNetworkVars(UmbraMixin, networkVars)
AddMixinNetworkVars(CatalystMixin, networkVars)
AddMixinNetworkVars(FireMixin, networkVars)
AddMixinNetworkVars(EnergizeMixin, networkVars)
AddMixinNetworkVars(FeintMixin, networkVars)
AddMixinNetworkVars(CombatMixin, networkVars)
AddMixinNetworkVars(LOSMixin, networkVars)
AddMixinNetworkVars(SelectableMixin, networkVars)

function Alien:OnCreate()

    Player.OnCreate(self)
    
    InitMixin(self, FireMixin)
    InitMixin(self, UmbraMixin)
    InitMixin(self, RegenerationMixin)
    InitMixin(self, CatalystMixin)
    InitMixin(self, EnergizeMixin)
    InitMixin(self, FeintMixin)
    InitMixin(self, CombatMixin)
    InitMixin(self, EntityChangeMixin)
    InitMixin(self, LOSMixin)
    InitMixin(self, SelectableMixin)
    InitMixin(self, AlienActionFinderMixin)
        
    InitMixin(self, ScoringMixin, { kMaxScore = kMaxScore })
    
    self.timeLastMomentumEffect = 0
 
    self.timeAbilityEnergyChange = Shared.GetTime()
    self.abilityEnergyOnChange = kAbilityMaxEnergy
    self.lastEnergyRate = self:GetRecuperationRate()
    
    // Only used on the local client.
    self.darkVisionOn = false
    self.darkVisionLastFrame = false
    self.darkVisionTime = 0
    self.darkVisionEndTime = 0
    
    self.timeCelerityInterrupted = 0
    
    self.twoHives = false
    self.threeHives = false
    self.enzymed = false
    self.primalScreamBoost = false
    
    self.infestationSpeedScalar = 0
    self.celeritySpeedScalar = 0
    self.infestationSpeedUpgrade = false
    
    if Server then
    
        self.timeWhenEnzymeExpires = 0
        self.timeLastCombatAction = 0
        self.timeWhenPrimalScreamExpires = 0
        
        self.loopingCeleritySound = Server.CreateEntity(SoundEffect.kMapName)
        self.loopingCeleritySound:SetAsset(kCelerityLoopingSound)
        self.loopingCeleritySound:SetParent(self)
        
    else
        InitMixin(self, TeamMessageMixin, { kGUIScriptName = "GUIAlienTeamMessage" })
    end
    
end

function Alien:DestroyGUI()

    if Client then
    
        if self.alienHUD then
        
            GetGUIManager():DestroyGUIScript(self.alienHUD)
            self.alienHUD = nil
            
        end
        
        if self.waypoints then
        
            GetGUIManager():DestroyGUIScript(self.waypoints)
            self.waypoints = nil
            
        end
        
        if self.hints then
        
            GetGUIManager():DestroyGUIScript(self.hints)
            self.hints = nil
            
        end
        
        if self.buyMenu then
        
            GetGUIManager():DestroyGUIScript(self.buyMenu)
            MouseTracker_SetIsVisible(false)
            self.buyMenu = nil
            
        end
        
        if self.regenFeedback then
        
            GetGUIManager():DestroyGUIScript(self.regenFeedback)
            self.regenFeedback = nil
            
        end
        
        if self.eggInfo then
        
            GetGUIManager():DestroyGUIScript(self.eggInfo)
            self.eggInfo = nil
            
        end
        
        if self.celerityViewCinematic then
        
            Client.DestroyCinematic(self.celerityViewCinematic)
            self.celerityViewCinematic = nil
            
        end

        if self.objectiveDisplay then
        
            GetGUIManager():DestroyGUIScript(self.objectiveDisplay)
            self.objectiveDisplay = nil
            
        end
        
        if self.progressDisplay then
        
            GetGUIManager():DestroyGUIScript(self.progressDisplay)
            self.progressDisplay = nil
            
        end        
    end
end

function Alien:OnDestroy()

    Player.OnDestroy(self)
    
    self.loopingCeleritySound = nil
    
    self:DestroyGUI()
    
end

function Alien:OnInitialized()

    Player.OnInitialized(self)
    
    InitMixin(self, CloakableMixin)

    self.armor = self:GetArmorAmount()
    self.maxArmor = self.armor
    
    if Server then
    
        InitMixin(self, InfestationTrackerMixin)
        self:UpdateNumHives()
        
        // This Mixin must be inited inside this OnInitialized() function.
        if not HasMixin(self, "MapBlip") then
            InitMixin(self, MapBlipMixin)
        end
        
    elseif Client then
        InitMixin(self, HiveVisionMixin)
    end
    
    if Client and Client.GetLocalPlayer() == self then
    
        Client.SetPitch(0.0)
        self:AddHelpWidget("GUIAlienVisionHelp", 2)
        
    end

end

function Alien:GetCanRepairOverride(target)
    return false
end

function Alien:GetArmorAmount()

    local carapaceAmount = 0
    
    if GetHasCarapaceUpgrade(self) then
        return self:GetArmorFullyUpgradedAmount()
    end

    return self:GetBaseArmor()
   
end

function Alien:GetCanCatalystOverride()
    return false
end

function Alien:GetCarapaceSpeedReduction()
    return kCarapaceSpeedReduction
end

function Alien:GetCarapaceFraction()

    local maxCarapaceArmor = self:GetMaxArmor() - self:GetBaseArmor()
    local currentCarpaceArmor = math.max(0, self:GetArmor() - self:GetBaseArmor())
    
    if maxCarapaceArmor == 0 then
        return 0
    end

    return currentCarpaceArmor / maxCarapaceArmor

end

function Alien:GetCarapaceMovementScalar()

    if GetHasCarapaceUpgrade(self) then
        return 1 - self:GetCarapaceFraction() * self:GetCarapaceSpeedReduction()    
    end
    
    return 1

end

function Alien:GetSlowSpeedModifier()
    return Player.GetSlowSpeedModifier(self) * self:GetCarapaceMovementScalar()
end

function Alien:GetHasTwoHives()
    return self.twoHives
end

function Alien:GetHasThreeHives()
    return self.threeHives
end

// For special ability, return an array of totalPower, minimumPower, tex x offset, tex y offset, 
// visibility (boolean), command name
function Alien:GetAbilityInterfaceData()
    return { }
end

local function CalcEnergy(self, rate)
    local dt = Shared.GetTime() - self.timeAbilityEnergyChanged
    local result = Clamp(self.abilityEnergyOnChange + dt * rate, 0, kAbilityMaxEnergy)
    return result
end

function Alien:GetEnergy()
    local rate = self:GetRecuperationRate()
    if self.lastEnergyRate ~= rate then
        // we assume we ask for energy enough times that the change in energy rate
        // will hit on the same tick they occure (or close enough)
        self.abilityEnergyOnChange = CalcEnergy(self, self.lastEnergyRate)
        self.timeAbilityEnergyChange = Shared.GetTime()
    end
    self.lastEnergyRate = rate
    return CalcEnergy(self, rate)
end

function Alien:AddEnergy(energy)
    assert(energy >= 0)
    self.abilityEnergyOnChange = Clamp(self:GetEnergy() + energy, 0, kAbilityMaxEnergy)
    self.timeAbilityEnergyChanged = Shared.GetTime()
end

function Alien:SetEnergy(energy)
    self.abilityEnergyOnChange = Clamp(energy, 0, kAbilityMaxEnergy)
    self.timeAbilityEnergyChanged = Shared.GetTime()
end

function Alien:DeductAbilityEnergy(energyCost)

    if not self:GetDarwinMode() then
        self.abilityEnergyOnChange = Clamp(self:GetEnergy() - energyCost, 0, kAbilityMaxEnergy)
        self.timeAbilityEnergyChanged = Shared.GetTime()
    end
    
end

function Alien:GetRecuperationRate()

    if self:GetIsFeinting() then
        return 0
    end    

    local scalar = ConditionalValue(self:GetGameEffectMask(kGameEffect.OnFire), kOnFireEnergyRecuperationScalar, 1)
    scalar = scalar * ConditionalValue(self.darkVisionOn, kAlienVisionEnergyRegenMod, 1)
    
    if GetHasAdrenalineUpgrade(self) then
        return scalar * Alien.kEnergyAdrenalineRecuperationRate
    else    
        return scalar * Alien.kEnergyRecuperationRate
    end
    
end

function Alien:GetMaxEnergy()
    return kAbilityMaxEnergy
end

function Alien:GetMaxBackwardSpeedScalar()
    return Alien.kWalkBackwardSpeedScalar
end

function Alien:UpdateSpeedModifiers(input)

    if Server then
        self.infestationSpeedUpgrade = GetHasMucousMembraneUpgrade(self:GetTeamNumber())        
    end

    local rate = -0.5
    if self:GetGameEffectMask(kGameEffect.OnInfestation) and self.infestationSpeedUpgrade then
        rate = 0.5
    end

    self.infestationSpeedScalar = Clamp( self.infestationSpeedScalar + input.time * rate, 0, 1)
    
    local prevCeleritySpeedScalar = self.celeritySpeedScalar
    
    if GetHasCelerityUpgrade(self) then
    
        local isMoving = input.move:GetLength() > 0 or self:GetSpeedScalar() > 0.5

        if self.timeCelerityInterrupted + kCelerityStart < Shared.GetTime() and isMoving then
    
            self.celeritySpeedScalar = Clamp( self.celeritySpeedScalar + input.time / kCelerityBuildUpDuration, 0, 1)
            
            if prevCeleritySpeedScalar ~= self.celeritySpeedScalar and prevCeleritySpeedScalar == 0 then
            
                self:TriggerEffects("celerity_start")
                self.timeLastCelerityStartEffect = Shared.GetTime()

                if Server and not self.loopingCeleritySound:GetIsPlaying() then
                    self.loopingCeleritySound:Start()
                end    
                
            end
      
        else
        
            self.celeritySpeedScalar = Clamp( self.celeritySpeedScalar - input.time / kCelerityRampDownDuration, 0, 1)
            
            if not isMoving then
                self.timeCelerityInterrupted = Shared.GetTime()
            end
            
            if prevCeleritySpeedScalar ~= self.celeritySpeedScalar and (not self.timeLastCelerityEndEffect or self.timeLastCelerityEndEffect + 2 < Shared.GetTime()) then
            
                self:TriggerEffects("celerity_end")
                self.timeLastCelerityEndEffect = Shared.GetTime()
                
                if Server and self.loopingCeleritySound:GetIsPlaying() then
                    self.loopingCeleritySound:Stop()
                end
                
            end
            
        end
        
    else
        self.celeritySpeedScalar = 0
    end

    
end

function Alien:SetDarkVision(state)

    if state ~= self.darkVisionOn then
    
        self.darkVisionOn = state
    
        if Client and self == Client.GetLocalPlayer() then
        
            if self.darkVisionOn then
            
                self.darkVisionTime = Shared.GetTime()
                self:TriggerEffects("alien_vision_on") 
                
            else
            
                self.darkVisionEndTime = Shared.GetTime()
                self:TriggerEffects("alien_vision_off")
                
            end
            
        end
    
    end

end

function Alien:UpdateSharedMisc(input)

    self:UpdateSpeedModifiers(input)
    
    if self:GetEnergy() <= 0 then
    
        self:SetDarkVision(false)
        
    end    
    
    Player.UpdateSharedMisc(self, input)
    
end

function Alien:HandleButtons(input)

    PROFILE("Alien:HandleButtons")   

    if self:GetIsFeinting() then
    
        // The following inputs are disabled when feinting.
        input.commands = bit.band(input.commands, bit.bnot(bit.bor(Move.Use, Move.Buy, Move.Jump,
                                                                   Move.PrimaryAttack, Move.SecondaryAttack,
                                                                   Move.NextWeapon, Move.PrevWeapon, Move.Reload,
                                                                   Move.Taunt, Move.Weapon1, Move.Weapon2,
                                                                   Move.Weapon3, Move.Weapon4, Move.Weapon5, Move.Crouch)))
    end
    
    Player.HandleButtons(self, input)
    
    // Update alien movement ability
    local newMovementState = bit.band(input.commands, Move.MovementModifier) ~= 0
    if newMovementState ~= self.movementModiferState and self.movementModiferState ~= nil then
        self:MovementModifierChanged(newMovementState, input)
    end
    
    self.movementModiferState = newMovementState
    
    local darkVisionPressed = bit.band(input.commands, Move.ToggleFlashlight) ~= 0
    if not self.darkVisionLastFrame and darkVisionPressed then
        self:SetDarkVision(not self.darkVisionOn)
    end
    self.darkVisionLastFrame = darkVisionPressed
    
end

function Alien:GetIsCamouflaged()
    return GetHasCamouflageUpgrade(self) and not self:GetIsInCombat()
end

function Alien:GetCustomAnimationName(animName)
    return animName
end

function Alien:GetNotEnoughResourcesSound()
    return Alien.kNotEnoughResourcesSound
end

// Returns true when players are selecting new abilities. When true, draw small icons
// next to your current weapon and force all abilities to draw.
function Alien:GetInactiveVisible()
    return Shared.GetTime() < self:GetTimeOfLastWeaponSwitch() + kDisplayWeaponTime
end

/**
 * Must override.
 */
function Alien:GetBaseArmor()
    assert(false)
end

/**
 * Must override.
 */
function Alien:GetArmorFullyUpgradedAmount()
    assert(false)
end

function Alien:GetCanBeHealedOverride()
    return self:GetIsAlive() and not self:GetIsFeinting()
end    


function Alien:MovementModifierChanged(newMovementModifierState, input)
end

// aliens don't clamp their speed
function Alien:OnClampSpeed(input, velocity)
end

/**
 * Aliens cannot climb ladders.
 */
function Alien:GetCanClimb()
    return false
end

function Alien:GetHasSayings()
    return true
end

function Alien:GetSayings()

    if self.showSayings then
    
        if self.showSayingsMenu == 1 then
            return alienGroupSayingsText    
        end
        
        if self.showSayingsMenu == 2 then
            return GetVoteActionsText(self:GetTeamNumber())
        end
        
        return
        
    end
    
    return nil
    
end

function Alien:ExecuteSaying(index, menu)

    Player.ExecuteSaying(self, index, menu)
    
    if Server then
    
        // Handle voting.
        if menu == 2 then
            GetGamerules():CastVoteByPlayer(voteActionsActions[index], self)
        else
        
            if index > 0 and index <= #alienGroupSayingsSounds then
            
                self:PlaySound(alienGroupSayingsSounds[index])
                
                local techId = alienRequestActions[index]
                if techId ~= kTechId.None then
                    self:GetTeam():TriggerAlert(techId, self)
                end
                
                // Remember this as a custom blip type so we can display 
                // appropriate text ("needs healing")
                self:SetCustomBlip( alienBlipTypes[index] )
                
            end
            
        end
        
    end
    
end

function Alien:SetCustomBlip(blipType)

    self.customBlipType = blipType
    
    if blipType ~= kBlipType.Undefined then
        self.customBlipTime = Shared.GetTime()
    else
        self.customBlipTime = nil
    end

end

function Alien:GetCustomBlip()

    if self.customBlipType ~= nil and self.customBlipType ~= kBlipType.Undefined then
    
        if self.customBlipTime and Shared.GetTime() < (self.customBlipTime + Alien.kCustomBlipDuration) then
        
            return self.customBlipType
            
        end
        
    end
    
    return kBlipType.Undefined
    
end   

function Alien:GetChatSound()
    return Alien.kChatSound
end

function Alien:GetDeathMapName()
    return AlienSpectator.kMapName
end

// Returns the name of the player's lifeform
function Alien:GetPlayerStatusDesc()

    local status = kPlayerStatus.Void
    
    if (self:GetIsAlive() == false) then
        status = kPlayerStatus.Dead
    else
        if (self:isa("Embryo")) then
            status = kPlayerStatus.Embryo
        else
            status = kPlayerStatus[self:GetClassName()]
        end
    end
    
    return status

end

function Alien:OnCatalyst()
end

function Alien:OnCatalystEnd()
end

function Alien:GetCanTakeDamageOverride()
    return Player.GetCanTakeDamageOverride(self) and not self:GetIsFeinting()
end

// childs ca override this. Any incoming damage will be reduced by this number, before any further calculations are done
function Alien:GetHideArmorAmount()
    return 0
end

function Alien:ComputeDamageOverride(attacker, damage, damageType, time)

    if self.primalScreamBoost then
        damage = 0
    else    

        damage = damage - self:GetHideArmorAmount()
        damage = ConditionalValue(damage >= 0, damage, 0)
        
    end    

    return damage

end


function Alien:GetAcceleration()
    return Player.kAcceleration * self:GetMovementSpeedModifier()
end

function Alien:GetCeleritySpeedModifier()
    return kCeleritySpeedModifier
end

function Alien:GetCelerityScalar()

    if GetHasCelerityUpgrade(self) then    
        return 1 + self.celeritySpeedScalar * self:GetCeleritySpeedModifier()        
    end
    
    return 1

end

function Alien:GetInfestationBonus()
    return kAlienDefaultInfestationSpeedBonus
end

function Alien:GetMovementSpeedModifier()
    return self:GetCelerityScalar() * self:GetSlowSpeedModifier() + (self.infestationSpeedScalar * self:GetInfestationBonus())
end
function Alien:GetEffectParams(tableParams)

    Player.GetEffectParams(self,tableParams)
    tableParams[kEffectFilterSilenceUpgrade] = GetHasSilenceUpgrade(self)

end

function Alien:GetIsEnzymed()
    return self.enzymed
end

function Alien:OnPrimaryAttack()
    self.timeCelerityInterrupted = Shared.GetTime()
end

function Alien:OnDamageDone(doer, target)
    if not doer or not doer:isa("Hydra") then
        self.timeCelerityInterrupted = Shared.GetTime()
    end
end

function Alien:OnUpdateAnimationInput(modelMixin)

    Player.OnUpdateAnimationInput(self, modelMixin)
    
    modelMixin:SetAnimationInput("attack_speed", self:GetIsEnzymed() and kEnzymeAttackSpeed or kDefaultAttackSpeed)
    
end

Shared.LinkClassToMap("Alien", Alien.kMapName, networkVars)