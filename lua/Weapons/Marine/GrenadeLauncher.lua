// ======= Copyright © 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\Weapons\GrenadeLauncher.lua
//
//    Created by:   Charlie Cleveland (charlie@unknownworlds.com) and
//                  Max McGuire (max@unknownworlds.com)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/Weapons/Marine/Shotgun.lua")
Script.Load("lua/Weapons/Marine/Grenade.lua")

class 'GrenadeLauncher' (Shotgun)

GrenadeLauncher.kMapName = "grenadelauncher"

GrenadeLauncher.kModelName = PrecacheAsset("models/marine/shotgun/shotgun.model")
local kViewModelName = PrecacheAsset("models/marine/shotgun/shotgun_view.model")

local kLauncherFireDelay = kGrenadeLauncherFireDelay
local kReloadTimer = kGrenadeLifetime
local kTimeReloaded = 0

GrenadeLauncher.networkVars =
{
    auxClipFull = "boolean",
    reloadingGrenade = "boolean"
}

function GrenadeLauncher:OnCreate()

    Shotgun.OnCreate(self)
  
    self.auxClipFull = true
    
    self.reloadingGrenade = false
    
end

// Use rifle attack effect block for primary fire
function GrenadeLauncher:GetPrimaryAttackPrefix()
    return "shotgun"
end

function GrenadeLauncher:GetViewModelName()
    return kViewModelName
end

function GrenadeLauncher:GetNeedsAmmo(includeClip)
    return Shotgun.GetNeedsAmmo(self, includeClip) or (includeClip and not self.auxClipFull)
end

function GrenadeLauncher:GetHUDSlot()
    return kPrimaryWeaponSlot
end

function GrenadeLauncher:GetAuxClip()

    // Return how many grenades we have left. Naming seems strange but the 
    // "clip" for the GL is how many grenades we have total.
    return ConditionalValue(self.auxClipFull, 1, 0)
    
end

function GrenadeLauncher:GetSecondaryAttackDelay()
    return kLauncherFireDelay
end

function GrenadeLauncher:CanReload()

    return ClipWeapon.CanReload(self) or not self.auxClipFull
end

local function CheckReloadGrenade(self)

    if not self.auxClipFull then
        
        self.auxClipFull = true
        self.reloadingGrenade = true
        kTimeReloaded = Shared.GetTime()
        
    
    end
    
end


function GrenadeLauncher:UpdateViewModelPoseParameters(viewModel, input)
    
    // Needs to be called before we set the grenade parameters.
    Shotgun.UpdateViewModelPoseParameters(self, viewModel, input)
    
/*    viewModel:SetPoseParam("hide_gl", 0)
    local glEmpty = ConditionalValue(self.auxClipFull, 0, 1)
    viewModel:SetPoseParam("gl_empty", glEmpty)*/
    
end

function GrenadeLauncher:GetEffectParams(tableParams)

    Shotgun.GetEffectParams(self, tableParams)
    
    tableParams[kEffectFilterEmpty] = not self.auxClipFull
    
end

function GrenadeLauncher:OnProcessMove(input)
    Shotgun.OnProcessMove(self, input)
    
    if kTimeReloaded + kReloadTimer <= Shared.GetTime() then
        self.reloadingGrenade = false
        CheckReloadGrenade(self)
    end
    
end

function GrenadeLauncher:OnHolster(player)

    ClipWeapon.OnHolster(self, player)
    
    self.secondaryAttacking = false
    self.blockingSecondary = false

end

local function ShootGrenade(self)

    local player = self:GetParent()
    if Server and player then
        
        local viewAngles = player:GetViewAngles()
        local viewCoords = viewAngles:GetCoords()
        
        // Make sure start point isn't on the other side of a wall or object
        local startPoint = player:GetEyePos() - (viewCoords.zAxis * 0.2)
        local trace = Shared.TraceRay(startPoint, startPoint + viewCoords.zAxis * 25, CollisionRep.Default, PhysicsMask.Bullets, EntityFilterOne(player))

        // make sure the grenades flies to the crosshairs target
        local grenadeStartPoint = player:GetEyePos() + viewCoords.zAxis * .5 - viewCoords.xAxis * .1 - viewCoords.yAxis * .25
        
        // if we would hit something use the trace endpoint, otherwise use the players view direction (for long range shots)
        local grenadeDirection = ConditionalValue(trace.fraction ~= 1, trace.endPoint - grenadeStartPoint, viewCoords.zAxis)
        grenadeDirection:Normalize()
        
        local grenade = CreateEntity(Grenade.kMapName, grenadeStartPoint, player:GetTeamNumber())
        
        SetAnglesFromVector(grenade, grenadeDirection)
        
        // Inherit player velocity?
        local startVelocity = grenadeDirection * 20
        startVelocity.y = startVelocity.y + 3
        grenade:Setup(player, startVelocity, true)
        
        // Set grenade owner to player so we don't collide with ourselves and so we
        // can attribute a kill to us
        grenade:SetOwner(player)
        
    end

    self.auxClipFull = false

end

function GrenadeLauncher:OnSecondaryAttack(player)

    if self.auxClipFull and not self:GetIsReloading() and not self:GetPrimaryAttacking() then
        ShootGrenade(self)
    end

end

function GrenadeLauncher:GetIsReloading()
    return Shotgun.GetIsReloading(self) or self.reloadingGrenade
end

function GrenadeLauncher:OnTag(tagName)

    Shotgun.OnTag(self, tagName)
    
    if not self.reloadingGrenade and self.auxClipFull and self:GetSecondaryAttacking() and tagName == "grenade_shoot" then
        ShootGrenade(self)
    end
    
    if tagName == "grenade_reload_end" then
        self.reloadingGrenade = false
    end

end

function GrenadeLauncher:OnUpdateAnimationInput(modelMixin)

    PROFILE("GrenadeLauncher:OnUpdateAnimationInput")

    Shotgun.OnUpdateAnimationInput(self, modelMixin)
    
    modelMixin:SetAnimationInput("gl", true)
    
    // disabled this line of code since it caused a looping opening animation
    //modelMixin:SetAnimationInput("gl_empty", not self.auxClipFull)
    
    if self.reloadingGrenade then
        modelMixin:SetAnimationInput("activity", "reload_shotgun_shell")
    end
    
end

Shared.LinkClassToMap("GrenadeLauncher", GrenadeLauncher.kMapName, GrenadeLauncher.networkVars)