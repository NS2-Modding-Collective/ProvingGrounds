//
// lua\Weapons\RocketLauncher.lua
//
//    Created by:   Andy "SoulRider' Wilson for Proving Grounds
//
// ========= For more information, visit us at http://www.modbeans.com =====================

Script.Load("lua/Balance.lua")
Script.Load("lua/Weapons/Marine/ClipWeapon.lua")
Script.Load("lua/Weapons/Marine/Rocket.lua")
Script.Load("lua/EntityChangeMixin.lua")

class 'RocketLauncher' (ClipWeapon)

RocketLauncher.kMapName = "rocketlauncher"

local networkVars =
{
    // Only used on the view model, so it can be private.
    emptyPoseParam = "private float (0 to 1 by 0.01)"
}

RocketLauncher.kModelName = PrecacheAsset("models/marine/grenadelauncher/grenadelauncher.model")
local kViewModelName = PrecacheAsset("models/marine/grenadelauncher/grenadelauncher_view.model")
local kAnimationGraph = PrecacheAsset("models/marine/grenadelauncher/grenadelauncher_view.animation_graph")

function RocketLauncher:OnCreate()

    ClipWeapon.OnCreate(self)
    
    self.emptyPoseParam = 0
    
    if Server then
    
        self.lastFiredRocketId = Entity.invalidId
        InitMixin(self, EntityChangeMixin)
        
    end
    
end

function RocketLauncher:GetAnimationGraphName()
    return kAnimationGraph
end

function RocketLauncher:GetViewModelName()
    return kViewModelName
end

function RocketLauncher:GetDeathIconIndex()
    return kDeathMessageIcon.Shotgun
end

function RocketLauncher:GetHUDSlot()
    return kTertiaryWeaponSlot
end

function RocketLauncher:GetClipSize()
    return kRocketLauncherClipSize
end

function RocketLauncher:GetHasSecondary(player)
    return false
end

function RocketLauncher:GetPrimaryCanInterruptReload()
    return true
end

function RocketLauncher:GetSecondaryAttackRequiresPress()
    return true
end    

function RocketLauncher:UpdateViewModelPoseParameters(viewModel)

    viewModel:SetPoseParam("empty", self.emptyPoseParam)
    
end

local function LoadBullet(self)

    if self.clip < self:GetClipSize() then
    
        self.clip = self.clip + 1
        
    end
    
end

function RocketLauncher:GetAmmoPackMapName()
    return RocketLauncherAmmo.kMapName
end 

function RocketLauncher:OnTag(tagName)

    PROFILE("RocketLauncher:OnTag")
    
    continueReloading = false
    if self:GetIsReloading() and tagName == "reload_end" then
        continueReloading = true
    end
    
    if tagName == "end" then
        self.primaryAttacking = false
    end
    
    ClipWeapon.OnTag(self, tagName)
    
    if tagName == "load_shell" then
        LoadBullet(self)
    // We have a special case when loading the last shell in the clip.
    elseif tagName == "load_shell_sound" and self.clip < (self:GetClipSize() - 1) then
        self:TriggerEffects("grenadelauncher_reload_shell")
    elseif tagName == "load_shell_sound" then
        self:TriggerEffects("grenadelauncher_reload_shell_last")
    elseif tagName == "reload_start" then
        self:TriggerEffects("grenadelauncher_reload_start")
    elseif tagName == "shut_canister" then
        self:TriggerEffects("grenadelauncher_reload_end")
    end
    
    if continueReloading then
    
        local player = self:GetParent()
        if player then
            player:Reload()
        end
        
    end
    
end

function RocketLauncher:OnUpdateAnimationInput(modelMixin)

    ClipWeapon.OnUpdateAnimationInput(self, modelMixin)
    
    modelMixin:SetAnimationInput("loaded_shells", self:GetClip())
    
end

local function ShootRocket(self, player)

    PROFILE("ShootRocket")
    
    self:TriggerEffects("grenadelauncher_attack")
    
    if Server and player then
    
        local viewAngles = player:GetViewAngles()
        local viewCoords = viewAngles:GetCoords()
        
        // Make sure start point isn't on the other side of a wall or object
        local startPoint = player:GetEyePos() - (viewCoords.zAxis * 0.2)
        local trace = Shared.TraceRay(startPoint, startPoint + viewCoords.zAxis * 25, CollisionRep.Default, PhysicsMask.Bullets, EntityFilterOne(player))
        
        // make sure the rocket flies to the crosshairs target
        local rocketStartPoint = player:GetEyePos() + viewCoords.zAxis * 0.65 - viewCoords.xAxis * 0.35 - viewCoords.yAxis * 0.25
        
        // if we would hit something use the trace endpoint, otherwise use the players view direction (for long range shots)
        local rocketDirection = ConditionalValue(trace.fraction ~= 1, trace.endPoint - rocketStartPoint, viewCoords.zAxis)
        rocketDirection:Normalize()
        
        local rocket = CreateEntity(Rocket.kMapName, rocketStartPoint, player:GetTeamNumber())
        
        // Inherit player velocity?
        local startVelocity = rocketDirection
        startVelocity = startVelocity * 25
        
        local angles = Angles(0,0,0)
        angles.yaw = GetYawFromVector(rocketDirection)
        angles.pitch = GetPitchFromVector(rocketDirection)
        rocket:SetAngles(angles)
        
        rocket:Setup(player, startVelocity, false)
        
        self.lastFiredRocketId = rocket:GetId()
        
    end
    
end

function RocketLauncher:FirePrimary(player)
    ShootRocket(self, player)    
end

function RocketLauncher:OnProcessMove(input)

    ClipWeapon.OnProcessMove(self, input)
    self.emptyPoseParam = Clamp(Slerp(self.emptyPoseParam, ConditionalValue(self.clip == 0, 1, 0), input.time * 1), 0, 1)
    
end

if Server then

    local function DetonateRockets(self, player)
    
        local rocket = Shared.GetEntity(self.lastFiredRocketId)  
        
        if rocket and rocket:GetCanDetonate() then
            rocket:Detonate()
            self.lastFiredRocketId = Entity.invalidId
        end
    
    end
    
    function RocketLauncher:OnEntityChange(oldId, newId)
    
        if oldId == self.lastFiredRocketId then
            self.lastFiredRocketId = Entity.invalidId
        end
    
    end

    function RocketLauncher:OnSecondaryAttack(player)

        local sprintedRecently = (Shared.GetTime() - self.lastTimeSprinted) < kMaxTimeToSprintAfterAttack
        local attackAllowed = not sprintedRecently and not self:GetSecondaryAttackRequiresPress() or not player:GetSecondaryAttackLastFrame()
    
        if not player:GetIsSprinting() and self:GetIsDeployed() and attackAllowed and not self.primaryAttacking then        
            DetonateGrenades(self, player) 
        end    

    end

end

Shared.LinkClassToMap("RocketLauncher", RocketLauncher.kMapName, networkVars)