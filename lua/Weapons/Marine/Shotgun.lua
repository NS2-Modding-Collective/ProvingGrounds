// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\Weapons\Shotgun.lua
//
//    Created by:   Charlie Cleveland (charlie@unknownworlds.com) and
//                  Max McGuire (max@unknownworlds.com)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/Balance.lua")
Script.Load("lua/Weapons/Marine/ClipWeapon.lua")

class 'Shotgun' (ClipWeapon)

Shotgun.kMapName = "shotgun"

local networkVars =
{
    emptyPoseParam = "private float (0 to 1 by 0.01)"
}

// higher numbers reduces the spread
local kSpreadDistance = 45
local kStartOffset = 0
local kSpreadVectors =
{
    GetNormalizedVector(Vector(-2.8, 4, kSpreadDistance)), GetNormalizedVector(Vector(-1, 3.5, kSpreadDistance)), GetNormalizedVector(Vector(3, 3.5, kSpreadDistance)),
    GetNormalizedVector(Vector(-3.5, 0, kSpreadDistance)), GetNormalizedVector(Vector(-0, 1.5, kSpreadDistance)), GetNormalizedVector(Vector(0.4, 0.5, kSpreadDistance)),
    GetNormalizedVector(Vector(-2, -2, kSpreadDistance)), GetNormalizedVector(Vector(1, -0.5, kSpreadDistance)), GetNormalizedVector(Vector(2, -2.5, kSpreadDistance)),
    GetNormalizedVector(Vector(-1, 0, kSpreadDistance)), 
}

Shotgun.kModelName = PrecacheAsset("models/marine/shotgun/shotgun.model")
local kViewModelName = PrecacheAsset("models/marine/shotgun/shotgun_view.model")
local kAnimationGraph = PrecacheAsset("models/marine/shotgun/shotgun_view.animation_graph")

local kMuzzleEffect = PrecacheAsset("cinematics/marine/shotgun/muzzle_flash.cinematic")
local kMuzzleAttachPoint = "fxnode_shotgunmuzzle"


function Shotgun:OnCreate()

    ClipWeapon.OnCreate(self)
    
    self.emptyPoseParam = 0

end

if Client then

    function Shotgun:OnInitialized()
    
        ClipWeapon.OnInitialized(self)
    
    end

end

function Shotgun:GetAnimationGraphName()
    return kAnimationGraph
end

function Shotgun:GetViewModelName()
    return kViewModelName
end

function Shotgun:GetDeathIconIndex()
    return kDeathMessageIcon.Shotgun
end

function Shotgun:GetHUDSlot()
    return kPrimaryWeaponSlot
end

function Shotgun:GetClipSize()
    return kShotgunClipSize
end

function Shotgun:GetBulletsPerShot()
    return kShotgunBulletsPerShot
end

function Shotgun:GetSpread(bulletNum)

    // NS1 was 20 degrees for half the shots and 20 degrees plus 7 degrees for half the shots
    if bulletNum < (kShotgunBulletsPerShot - 2) then
        return Math.Radians(10)
    else
        return Math.Radians(15)
    end
    
end

function Shotgun:GetRange()
    return kShotgunRange
end

// Only play weapon effects every other bullet to avoid sonic overload
function Shotgun:GetTracerEffectFrequency()
    return 0.5
end

function Shotgun:GetBulletDamage(target, endPoint)
    return kShotgunDamage    
end



function Shotgun:GetHasSecondary(player)
    return true
end

function Shotgun:GetPrimaryCanInterruptReload()
    return true
end

function Shotgun:UpdateViewModelPoseParameters(viewModel)

    viewModel:SetPoseParam("empty", self.emptyPoseParam)
    
end

local function LoadBullet(self)

    if self.clip < self:GetClipSize() then
    
        self.clip = self.clip + 1
        
    end
    
end

function Shotgun:OnTag(tagName)

    PROFILE("Shotgun:OnTag")

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
    elseif tagName == "reload_shotgun_start" then
        self:TriggerEffects("shotgun_reload_start")
    elseif tagName == "reload_shotgun_shell" then
        self:TriggerEffects("shotgun_reload_shell")
    elseif tagName == "reload_shotgun_end" then
        self:TriggerEffects("shotgun_reload_end")
    end
    
    if continueReloading then
    
        local player = self:GetParent()
        if player then
            player:Reload()
        end
        
    end
    
end

function Shotgun:FirePrimary(player)

    local viewAngles = player:GetViewAngles()
    viewAngles.roll = NetworkRandom() * math.pi * 2
    
    local shootCoords = viewAngles:GetCoords()
    
    
    // Filter ourself out of the trace so that we don't hit ourselves.
    local filter = EntityFilterTwo(player, self)
    local range = self:GetRange()
    
    local numberBullets = self:GetBulletsPerShot()
    local startPoint = player:GetEyePos()
    
    self:TriggerEffects("shotgun_attack")

    for bullet = 1, numberBullets do
    
        if not kSpreadVectors[bullet] then
            break
        end    
    
        local spreadDirection = shootCoords:TransformVector(kSpreadVectors[bullet])

        local endPoint = startPoint + spreadDirection * range
        startPoint = player:GetEyePos() + shootCoords.xAxis * kSpreadVectors[bullet].x * kStartOffset + shootCoords.yAxis * kSpreadVectors[bullet].y * kStartOffset
        
        local trace = Shared.TraceRay(startPoint, endPoint, CollisionRep.Damage, PhysicsMask.Bullets, filter)
        
        local damage = 0

        /*
        // Check prediction
        local values = GetPredictionValues(startPoint, endPoint, trace)
        if not CheckPredictionData( string.format("attack%d", bullet), true, values ) then
            Server.PlayPrivateSound(player, "sound/NS2.fev/marine/voiceovers/game_start", player, 1.0, Vector(0, 0, 0))
        end
        */
            
        // don't damage 'air'..
        if trace.fraction < 1 or GetIsVortexed(player) then
        
            local direction = (trace.endPoint - startPoint):GetUnit()
            local impactPoint = trace.endPoint - direction * kHitEffectOffset
            local surfaceName = trace.surface

            local effectFrequency = self:GetTracerEffectFrequency()
            local playLocal = bullet % effectFrequency == 0
            
            self:ApplyBulletGameplayEffects(player, trace.entity, impactPoint, direction, kShotgunDamage, trace.surface, playLocal)

        end
        
        local client = Server and player:GetClient() or Client
        if not Shared.GetIsRunningPrediction() and client.hitRegEnabled then
            RegisterHitEvent(player, bullet, startPoint, trace, damage)
        end
        
    end
    
end

function Shotgun:OnProcessMove(input)
    ClipWeapon.OnProcessMove(self, input)
    self.emptyPoseParam = Clamp(Slerp(self.emptyPoseParam, ConditionalValue(self.clip == 0, 1, 0), input.time * 1), 0, 1)
end

function Shotgun:GetAmmoPackMapName()
    return ShotgunAmmo.kMapName
end    

/*local function ShootGrenade(self)

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
        local startVelocity = grenadeDirection * 15
        startVelocity.y = startVelocity.y + 3
        grenade:SetVelocity(startVelocity)
        
        // Set grenade owner to player so we don't collide with ourselves and so we
        // can attribute a kill to us
        grenade:SetOwner(player)
        
    end

end

function Shotgun:OnSecondaryAttack(player)

    local enoughTimePassed = self.timeAttackStarted + kGrenadeLauncherFireDelay < Shared.GetTime()
    local attackAllowed = (not self:GetIsReloading() or self:GetSecondaryCanInterruptReload()) and (not self:GetSecondaryAttackRequiresPress() or not player:GetSecondaryAttackLastFrame()) and enoughTimePassed
    attackAllowed = attackAllowed and (not self:GetPrimaryIsBlocking() or not self.blockingPrimary) and not self.blockingSecondary
    
    if self:GetIsDeployed() and attackAllowed and not self.primaryAttacking then
    
        self.secondaryAttacking = true
        
        if self:GetIsReloading() then
            CancelReload(self)
        end
        
        Weapon.OnSecondaryAttack(self, player)
        
        self.blockingSecondary = true
        self.timeAttackStarted = Shared.GetTime()
        ShootGrenade(self)
        
        return true
        
    end
    
    return false
    
end*/


Shared.LinkClassToMap("Shotgun", Shotgun.kMapName, networkVars)