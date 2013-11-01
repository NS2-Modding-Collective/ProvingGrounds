// ==========================================================================================
//
// lua\Weapons\Shotgun.lua.lua
//
//    Created by:   Andy 'Soul Rider' Wilson for Proving Grounds Mod
//
// ===========================================================================================

Script.Load("lua/Balance.lua")
Script.Load("lua/LiveMixin.lua")
Script.Load("lua/Weapons/Marine/ClipWeapon.lua")
Script.Load("lua/PointGiverMixin.lua")
Script.Load("lua/Weapons/Marine/Grenade.lua")

class 'Shotgun' (ClipWeapon)

Shotgun.kMapName = "shotgun"

local kBulletSize = 0.016

local networkVars =
{
    emptyPoseParam = "private float (0 to 1 by 0.01)"
}

AddMixinNetworkVars(LiveMixin, networkVars)

// higher numbers reduces the spread
local kSpreadDistance = 15
local kStartOffset = 0
local kSpreadVectors =
{
    GetNormalizedVector(Vector(-0.01, 0.01, kSpreadDistance)),
    
    GetNormalizedVector(Vector(-0.45, 0.45, kSpreadDistance)),
    GetNormalizedVector(Vector(0.45, 0.45, kSpreadDistance)),
    GetNormalizedVector(Vector(0.45, -0.45, kSpreadDistance)),
    GetNormalizedVector(Vector(-0.45, -0.45, kSpreadDistance)),
    
    GetNormalizedVector(Vector(-1, 0, kSpreadDistance)),
    GetNormalizedVector(Vector(1, 0, kSpreadDistance)),
    GetNormalizedVector(Vector(0, -1, kSpreadDistance)),
    GetNormalizedVector(Vector(0, 1, kSpreadDistance)),
    
    GetNormalizedVector(Vector(-0.35, 0, kSpreadDistance)),
    GetNormalizedVector(Vector(0.35, 0, kSpreadDistance)),
    GetNormalizedVector(Vector(0, -0.35, kSpreadDistance)),
    GetNormalizedVector(Vector(0, 0.35, kSpreadDistance)),
    
    GetNormalizedVector(Vector(-0.8, -0.8, kSpreadDistance)),
    GetNormalizedVector(Vector(-0.8, 0.8, kSpreadDistance)),
    GetNormalizedVector(Vector(0.8, 0.8, kSpreadDistance)),
    GetNormalizedVector(Vector(0.8, -0.8, kSpreadDistance)),
    
}

Shotgun.kModelName = PrecacheAsset("models/marine/shotgun/shotgun.model")
local kViewModels = GenerateAvatarViewModelPaths("shotgun")
local kAnimationGraph = PrecacheAsset("models/marine/shotgun/shotgun_view.animation_graph")

local kMuzzleEffect = PrecacheAsset("cinematics/marine/shotgun/muzzle_flash.cinematic")
local kMuzzleAttachPoint = "fxnode_shotgunmuzzle"

local kGrenadeSpeed = 20

function Shotgun:OnCreate()

    ClipWeapon.OnCreate(self)
    
    InitMixin(self, LiveMixin)
    InitMixin(self, PointGiverMixin)
       
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

function Shotgun:GetViewModelName(sex, variant)
    return kViewModels[sex][variant]
end

function Shotgun:GetDeathIconIndex()
    return kDeathMessageIcon.Shotgun
end

function Shotgun:GetHUDSlot()
    return kFourthWeaponSlot
end

function Shotgun:GetClipSize()
    return kShotgunClipSize
end

function Shotgun:GetBulletsPerShot()
    return kShotgunBulletsPerShot
end

function Shotgun:GetRange()
    return 50
end

// Only play weapon effects every other bullet to avoid sonic overload
function Shotgun:GetTracerEffectFrequency()
    return 0.5
end

function Shotgun:GetBulletDamage()
    return kShotgunDamage    
end

function Shotgun:GetHasSecondary(player)
    return true
end

function Shotgun:GetPrimaryCanInterruptReload()
    return true
end

function Shotgun:GetSecondaryCanInterruptReload()
    return false
end

local function ShootGrenade(self, player)

    PROFILE("ShootGrenade")
    
    self:TriggerEffects("grenadelauncher_attack")

    if Server or (Client and Client.GetIsControllingPlayer()) then

        local viewCoords = player:GetViewCoords()
        local eyePos = player:GetEyePos()

        local startPointTrace = Shared.TraceCapsule(eyePos, eyePos + viewCoords.zAxis, 0.2, 0, CollisionRep.Move, PhysicsMask.PredictedProjectileGroup, EntityFilterTwo(self, player))
        local startPoint = startPointTrace.endPoint

        local direction = viewCoords.zAxis
        
        if startPointTrace.fraction ~= 1 then
            direction = GetNormalizedVector(direction:GetProjection(startPointTrace.normal))
        end

        local grenade = player:CreatePredictedProjectile("Grenade", startPoint, direction * kGrenadeSpeed, 0.7, 0.45)
    
    end
    
    TEST_EVENT("Grenade Launcher primary attack")
    
end

function Shotgun:GetSecondaryAttackRequiresPress()
    return true
end

function Shotgun:OnSecondaryAttack(player)

    if not self:GetPrimaryAttacking() and not player:GetSecondaryAttackLastFrame() and not self:GetIsReloading() then
        if self.clip > 0 then 
            ShootGrenade(self, player)
            self.clip = self.clip - 1
        elseif self.clip == 0 then
            self:OnSecondaryAttackEnd(player)
            // Automatically reload if we're out of ammo.
            player:Reload()
        end
    end
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
    
    local continueReloading = false
    if self:GetIsReloading() and tagName == "reload_end" then
    
        continueReloading = true
        self.reloading = false
        
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

// used for last effect
function Shotgun:GetEffectParams(tableParams)
    tableParams[kEffectFilterEmpty] = self.clip == 1
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
    
    self:TriggerEffects("shotgun_attack_sound")
    self:TriggerEffects("shotgun_attack")
    
    for bullet = 1, math.min(numberBullets, #kSpreadVectors) do
    
        if not kSpreadVectors[bullet] then
            break
        end    
    
        local spreadDirection = shootCoords:TransformVector(kSpreadVectors[bullet])

        local endPoint = startPoint + spreadDirection * range
        startPoint = player:GetEyePos() + shootCoords.xAxis * kSpreadVectors[bullet].x * kStartOffset + shootCoords.yAxis * kSpreadVectors[bullet].y * kStartOffset
        
        local trace = Shared.TraceRay(startPoint, endPoint, CollisionRep.Damage, PhysicsMask.Bullets, filter)
        if not trace.entity then
        
            -- Limit the box trace to the point where the ray hit as an optimization.
            local boxTraceEndPoint = trace.fraction ~= 1 and trace.endPoint or endPoint
            local extents = GetDirectedExtentsForDiameter(spreadDirection, kBulletSize)
            trace = Shared.TraceBox(extents, startPoint, boxTraceEndPoint, CollisionRep.Damage, PhysicsMask.Bullets, filter)
            
        end
        
        local damage = 0

        /*
        // Check prediction
        local values = GetPredictionValues(startPoint, endPoint, trace)
        if not CheckPredictionData( string.format("attack%d", bullet), true, values ) then
            Server.PlayPrivateSound(player, "sound/NS2.fev/marine/voiceovers/game_start", player, 1.0, Vector(0, 0, 0))
        end
        */
            
        // don't damage 'air'..
        if trace.fraction < 1 then
        
            local direction = (trace.endPoint - startPoint):GetUnit()
            local impactPoint = trace.endPoint - direction * kHitEffectOffset
            local surfaceName = trace.surface

            local effectFrequency = self:GetTracerEffectFrequency()
            local showTracer = bullet % effectFrequency == 0
            
            self:ApplyBulletGameplayEffects(player, trace.entity, impactPoint, direction, kShotgunDamage, trace.surface, showTracer)
            
            if Client and showTracer then
                TriggerFirstPersonTracer(self, trace.endPoint)
            end
            
        end
        
        local client = Server and player:GetClient() or Client
        if not Shared.GetIsRunningPrediction() and client.hitRegEnabled then
            RegisterHitEvent(player, bullet, startPoint, trace, damage)
        end
        
    end
    
    TEST_EVENT("Shotgun primary attack")
    
end

function Shotgun:OnProcessMove(input)
    ClipWeapon.OnProcessMove(self, input)
    self.emptyPoseParam = Clamp(Slerp(self.emptyPoseParam, ConditionalValue(self.clip == 0, 1, 0), input.time * 1), 0, 1)
end

function Shotgun:GetAmmoPackMapName()
    return ShotgunAmmo.kMapName
end    


if Client then

    function Shotgun:GetBarrelPoint()
    
        local player = self:GetParent()
        if player then
        
            local origin = player:GetEyePos()
            local viewCoords= player:GetViewCoords()
            
            return origin + viewCoords.zAxis * 0.4 + viewCoords.xAxis * -0.18 + viewCoords.yAxis * -0.2
            
        end
        
        return self:GetOrigin()
        
    end
    
    function Shotgun:GetUIDisplaySettings()
        return { xSize = 256, ySize = 128, script = "lua/GUIShotgunDisplay.lua" }
    end

end

function Shotgun:ModifyDamageTaken(damageTable, attacker, doer, damageType)
    if damageType ~= kDamageType.Corrode then
        damageTable.damage = 0
    end
end

function Shotgun:GetCanTakeDamageOverride()
    return self:GetParent() == nil
end

if Server then

    function Shotgun:OnKill()
        DestroyEntity(self)
    end
    
    function Shotgun:GetSendDeathMessageOverride()
        return false
    end   
    
end

Shared.LinkClassToMap("Shotgun", Shotgun.kMapName, networkVars)