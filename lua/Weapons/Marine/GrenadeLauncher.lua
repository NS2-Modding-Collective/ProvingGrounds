// ==========================================================================================
//
// lua\Weapons\GrenadeLauncher.lua
//
//    Created by:   Andy 'Soul Rider' Wilson for Proving Grounds Mod
//
// ===========================================================================================

Script.Load("lua/Weapons/Marine/Shotgun.lua")
Script.Load("lua/Weapons/Marine/Grenade.lua")

class 'GrenadeLauncher' (Shotgun)

GrenadeLauncher.kMapName = "grenadelauncher"

GrenadeLauncher.networkVars =
{
}
function GrenadeLauncher:OnCreate()

    Shotgun.OnCreate(self)
    
end

// Use Shotgun attack effect block for primary fire
function GrenadeLauncher:GetPrimaryAttackPrefix()
    return "shotgun"
end

function GrenadeLauncher:OnHolster(player)

    ClipWeapon.OnHolster(self, player)
    
    self.secondaryAttacking = false
    self.blockingSecondary = false

end

local function ShootGrenade(self)
    
    PrintToLog("ShootGrenade Activated")
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

end

function GrenadeLauncher:OnSecondaryAttack(player)

    if not self:GetPrimaryAttacking() then
        ShootGrenade(self)
        PrintToLog("ShootGrenadeCalled")
    end

end

function GrenadeLauncher:OnTag(tagName)

    Shotgun.OnTag(self, tagName)
    
    if self:GetSecondaryAttacking() and tagName == "grenade_shoot" then
        ShootGrenade(self)
    end
    
    if tagName == "grenade_reload_end" then
        self.reloadingGrenade = false
    end

end

Shared.LinkClassToMap("GrenadeLauncher", GrenadeLauncher.kMapName, GrenadeLauncher.networkVars)