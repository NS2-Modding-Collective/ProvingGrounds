//=============================================================================
//
// lua\Weapons\Marine\Rocket.lua
//
// Created by Charlie Cleveland (charlie@unknownworlds.com)
// Copyright (c) 2011, Unknown Worlds Entertainment, Inc.
//
//=============================================================================

Script.Load("lua/Weapons/Projectile.lua")
Script.Load("lua/Mixins/ModelMixin.lua")
Script.Load("lua/TeamMixin.lua")
Script.Load("lua/DamageMixin.lua")

class 'Rocket' (Projectile)

Rocket.kMapName = "rocket"
Rocket.kModelName = PrecacheAsset("models/marine/rifle/rifle_grenade.model")

local kMinLifeTime = .7

// prevents collision with friendly players in range to spawnpoint
Rocket.kDisableCollisionRange = 10

local networkVars = { }

AddMixinNetworkVars(BaseModelMixin, networkVars)
AddMixinNetworkVars(ModelMixin, networkVars)
AddMixinNetworkVars(TeamMixin, networkVars)

function Rocket:OnCreate()

    Projectile.OnCreate(self)
    
    InitMixin(self, BaseModelMixin)
    InitMixin(self, ModelMixin)
    InitMixin(self, TeamMixin)
    InitMixin(self, DamageMixin)
        
end

function Rocket:GetProjectileModel()
    return Rocket.kModelName
end 
function Rocket:GetDeathIconIndex()
    return kDeathMessageIcon.Grenade
end

function Rocket:GetDamageType()
    return kRocketLauncherRocketDamageType
end

if Server then

    function Rocket:ProcessHit(targetHit, surface)
        if targetHit then
            self:Detonate(targetHit)            
        end
        
    end
   
    function Rocket:Detonate(targetHit)
    
        // Do damage to nearby targets.
        local hitEntities = GetEntitiesWithMixinForTeamWithinRange("Live", GetEnemyTeamNumber(self:GetTeamNumber()), self:GetOrigin(), kRocketLauncherRocketDamageRadius)
        
        // Remove grenade and add firing player.
        table.removevalue(hitEntities, self)
        local owner = self:GetOwner()
        // It is possible this grenade does not have an owner.
        if owner then
            table.insertunique(hitEntities, owner)
        end
        
        RadiusDamage(hitEntities, self:GetOrigin(), kRocketLauncherRocketDamageRadius, kRocketLauncherRocketDamage, self)
        
        // TODO: use what is defined in the material file
        local surface = GetSurfaceFromEntity(targetHit)
        
        local params = {surface = surface}
        if not targetHit then
            params[kEffectHostCoords] = Coords.GetLookIn( self:GetOrigin(), self:GetCoords().zAxis )
        end
        
        self:TriggerEffects("grenade_explode", params)
        
        DestroyEntity(self)
        
    end
    
    function Rocket:GetCanDetonate()
        return true
    end
    
    function Rocket:SetVelocity(velocity)
    
        Projectile.SetVelocity(self, velocity)
        
        if Rocket.kDisableCollisionRange > 0 then
        
            if self.physicsBody and not self.collisionDisabled then
            
                // exclude all nearby friendly players from collision
                for index, player in ipairs(GetEntitiesForTeamWithinRange("Player", self:GetTeamNumber(), self:GetOrigin(), Rocket.kDisableCollisionRange)) do
                    
                    if player:GetController() then
                        Shared.SetPhysicsObjectCollisionsEnabled(self.physicsBody, player:GetController(), false)
                    end
                
                end

                self.collisionDisabled = true

            end
        
        end
        
    end  

end

Shared.LinkClassToMap("Rocket", Rocket.kMapName, networkVars)