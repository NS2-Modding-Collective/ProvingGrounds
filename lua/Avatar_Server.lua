// ======= Copyright (c) 2003-2012, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\Avatar_Server.lua
//
//    Created by:   Andy 'Soul Rider' Wilson for Proving Grounds
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

local function GetCanTriggerAlert(self, techId, timeOut)

    if not self.alertTimes then
        self.alertTimes = {}
    end
    
    return not self.alertTimes[techId] or self.alertTimes[techId] + timeOut < Shared.GetTime()

end

function Avatar:OnPrimaryAttack()

    local weapon = self:GetActiveWeapon()
    if weapon and weapon:isa("ClipWeapon") then
    
        if weapon:GetAmmo() < weapon:GetClipSize() and GetCanTriggerAlert(self, kTechId.MarineAlertNeedAmmo, kAmmoAutoRequestTimeout) and #GetEntitiesForTeamWithinRange("Armoy", self:GetTeamNumber(), self:GetOrigin(), kFindArmoryRange) == 0 then
        
            self:GetTeam():TriggerAlert(kTechId.MarineAlertNeedAmmo, self)
            self.alertTimes[kTechId.MarineAlertNeedAmmo] = Shared.GetTime()
            self:PlaySound("sound/NS2.fev/marine/voiceovers/ammo")
            
        end
    
    end

end

function Avatar:RequestHeal()

    if GetCanTriggerAlert(self, kTechId.MarineAlertNeedMedpack, Marine.kMarineAlertTimeout) then
    
        self:GetTeam():TriggerAlert(kTechId.MarineAlertNeedMedpack, self)
        self.alertTimes[kTechId.MarineAlertNeedMedpack] = Shared.GetTime()
        self:PlaySound("sound/NS2.fev/marine/voiceovers/medpack")
            
    end

end

function Avatar:ExecuteSaying(index, menu)

    if not Player.ExecuteSaying(self, index, menu) then

        if Server then
        
            if menu == 3 and voteActionsActions[index] then
                GetGamerules():CastVoteByPlayer(voteActionsActions[index], self)
            else
            
                local sayings = marineRequestSayingsSounds
                local sayingActions = marineRequestActions
                
                if menu == 2 then
                
                    sayings = marineGroupSayingsSounds
                    sayingActions = marineGroupRequestActions
                    
                end
                
                if sayings[index] then
                
                    local techId = sayingActions[index]
                    if techId ~= kTechId.None and GetCanTriggerAlert(self, techId, Avatar.kMarineAlertTimeout) then
                    
                        self:PlaySound(sayings[index])
                        self:GetTeam():TriggerAlert(techId, self)
                        self.alertTimes[techId] = Shared.GetTime()
                        
                    end
                    
                end
                
            end
            
        end
        
    end
    
end

function Avatar:OnTakeDamage(damage, attacker, doer, point)

    if damage > 50 and (not self.timeLastDamageKnockback or self.timeLastDamageKnockback + 1 < Shared.GetTime()) then    
    
        self:AddPushImpulse(GetNormalizedVectorXZ(self:GetOrigin() - point) * damage * 0.2)
        self.timeLastDamageKnockback = Shared.GetTime()
        
    end

end

function Avatar:GetDamagedAlertId()
    return kTechId.MarineAlertSoldierUnderAttack
end

function Avatar:ApplyCatPack()

    self.catpackboost = true
    self.timeCatpackboost = Shared.GetTime()
    
end

function Avatar:InitWeapons()

    Player.InitWeapons(self)
    //Amended for Proving Grounds
    self:GiveItem(Shotgun.kMapName)
    
    self:SetActiveWeapon(Shotgun.kMapName)

end

local function GetHostSupportsTechId(host, techId)

    if Shared.GetCheatsEnabled() then
        return true
    end
    
    local techFound = false
    
    if host.GetItemList then
    
        for index, supportedTechId in ipairs(host:GetItemList()) do
        
            if supportedTechId == techId then
            
                techFound = true
                break
                
            end
            
        end
        
    end
    
    return techFound
    
end

local function PlayerIsFacingHostStructure(player, host)
    return true
end

function GetHostStructureFor(entity, techId)

    local hostStructures = {}
    table.copy(GetEntitiesForTeamWithinRange("Armory", entity:GetTeamNumber(), entity:GetOrigin(), Armory.kResupplyUseRange), hostStructures, true)
    table.copy(GetEntitiesForTeamWithinRange("PrototypeLab", entity:GetTeamNumber(), entity:GetOrigin(), PrototypeLab.kResupplyUseRange), hostStructures, true)
    
    if table.count(hostStructures) > 0 then
    
        for index, host in ipairs(hostStructures) do
        
            // check at first if the structure is hostign the techId:
            if GetHostSupportsTechId(host, techId) and PlayerIsFacingHostStructure(player, host) then
                return host
            end    
        
        end
            
    end
    
    return nil

end

function Avatar:DropAllWeapons()

    local weaponSpawnCoords = self:GetAttachPointCoords(Weapon.kHumanAttachPoint)
    local weaponList = self:GetHUDOrderedWeaponList()
    for w = 1, #weaponList do
    
        local weapon = weaponList[w]
        if weapon:GetIsDroppable() and LookupTechData(weapon:GetTechId(), kTechDataCostKey, 0) > 0 then
            self:Drop(weapon, true, true)
        end
        
    end
    
end

function Avatar:OnKill(attacker, doer, point, direction)

    // drop all weapons which cost resources
    self:DropAllWeapons()

    // destroy remaining weapons
    self:DestroyWeapons()
    
    Player.OnKill(self, attacker, doer, point, direction)
    self:PlaySound(Marine.kDieSoundName)

    self.originOnDeath = self:GetOrigin()
    
end

function Avatar:GetCanPhase()
    return not GetIsVortexed(self) and self:GetIsAlive() and (not self.timeOfLastPhase or (Shared.GetTime() > (self.timeOfLastPhase + Marine.kPlayerPhaseDelay)))
end

function Avatar:SetTimeOfLastPhase(time)
    self.timeOfLastPhase = time
end

function Avatar:GetOriginOnDeath()
    return self.originOnDeath
end

function Avatar:GiveJetpack()

    local activeWeapon = self:GetActiveWeapon()
    local activeWeaponMapName = nil
    local health = self:GetHealth()
    
    if activeWeapon ~= nil then
        activeWeaponMapName = activeWeapon:GetMapName()
    end
    
    local jetpackMarine = self:Replace(JetpackMarine.kMapName, self:GetTeamNumber(), true, Vector(self:GetOrigin()))
    
    jetpackMarine:SetActiveWeapon(activeWeaponMapName)
    jetpackMarine:SetHealth(health)
    
end

function Avatar:GiveExo(spawnPoint)

    self:DropAllWeapons()
    self:Replace(Exo.kMapName, self:GetTeamNumber(), false, spawnPoint)
    
end

function Avatar:GiveDualExo(spawnPoint)

    self:DropAllWeapons()
    local exo = self:Replace(Exo.kMapName, self:GetTeamNumber(), false, spawnPoint)
    exo:InitDualMinigun()
    
end
