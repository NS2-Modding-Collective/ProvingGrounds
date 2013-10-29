// =========================================================================================
//
// lua\Avatar_Server.lua
//
//    Created by:   Andy 'Soul Rider' Wilson for Proving Grounds Mod
//
// ================================================================================================

function Avatar:OnTakeDamage(damage, attacker, doer, point)

    if doer then
    
        if doer:isa("Grenade") and doer:GetOwner() == self then
        
            self.onGround = false
            local velocity = self:GetVelocity()
            local fromGrenade = self:GetOrigin() - doer:GetOrigin()
            local length = fromGrenade:Normalize()
            local force = Clamp(1 - (length / 4), 0, 1)
            
            if force > 0 then
                velocity:Add(force * fromGrenade)
                self:SetVelocity(velocity)
            end
            
        end
   
    end

end

function Avatar:ApplyCatPack()

    self.catpackboost = true
    self.timeCatpackboost = Shared.GetTime()
    
end

function Avatar:InitWeapons()

    Player.InitWeapons(self)
    
    self:GiveItem(Axe.kMapName)
    self:GiveItem(Pistol.kMapName)
    self:GiveItem(Rifle.kMapName)
    self:GiveItem(Shotgun.kMapName)
    self:GiveItem(RocketLauncher.kMapName)
    
    
    self:SetQuickSwitchTarget(Pistol.kMapName)
    self:SetActiveWeapon(Axe.kMapName)

end

function Avatar:GiveItem(itemMapName)

    local newItem = nil

    if itemMapName then

        local setActive = true
        return Player.GiveItem(self, itemMapName, setActive)
        
    end
    
    return newItem
    
end

function Avatar:OnKill(attacker, doer, point, direction)
    
    // Destroy remaining weapons
    self:DestroyWeapons()
    
    Player.OnKill(self, attacker, doer, point, direction)
        
    self.originOnDeath = self:GetOrigin()
    
end

function Avatar:GetOriginOnDeath()
    return self.originOnDeath
end



