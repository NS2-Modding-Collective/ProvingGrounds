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

function Avatar:SetPoisoned(attacker)

    self.poisoned = true
    self.timePoisoned = Shared.GetTime()
    
    if attacker then
        self.lastPoisonAttackerId = attacker:GetId()
    end
    
end

function Avatar:ApplyCatPack()

    self.catpackboost = true
    self.timeCatpackboost = Shared.GetTime()
    
end

function Avatar:OnEntityChange(oldId, newId)

    Player.OnEntityChange(self, oldId, newId)

    if oldId == self.lastPoisonAttackerId then
    
        if newId then
            self.lastPoisonAttackerId = newId
        else
            self.lastPoisonAttackerId = Entity.invalidId
        end
        
    end
 
end

function Avatar:InitWeapons()

    Player.InitWeapons(self)
    //Amended for Proving Grounds
    self:GiveItem(BMFG.kMapName)
    
    local weaponHolder = self:GetWeapon(BMFG.kMapName, false)
    weaponHolder:SetWeapons(Minigun.kMapName, Minigun.kMapName)
    
    self:SetActiveWeapon(BMFG.kMapName)

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

function Avatar:OnOverrideOrder(order)
    
    local orderTarget = nil
    
    if (order:GetParam() ~= nil) then
        orderTarget = Shared.GetEntity(order:GetParam())
    end
    
    // Default orders to unbuilt friendly structures should be construct orders
    if(order:GetType() == kTechId.Default and GetOrderTargetIsConstructTarget(order, self:GetTeamNumber())) then
    
        order:SetType(kTechId.Construct)
        
    elseif(order:GetType() == kTechId.Default and GetOrderTargetIsWeldTarget(order, self:GetTeamNumber())) and self:GetWeapon(Welder.kMapName) then
    
        order:SetType(kTechId.Weld)
        
    elseif order:GetType() == kTechId.Default and GetOrderTargetIsDefendTarget(order, self:GetTeamNumber()) then
    
        order:SetType(kTechId.Defend)

    // If target is enemy, attack it
    elseif (order:GetType() == kTechId.Default) and orderTarget ~= nil and HasMixin(orderTarget, "Live") and GetEnemyTeamNumber(self:GetTeamNumber()) == orderTarget:GetTeamNumber() and orderTarget:GetIsAlive() and (not HasMixin(orderTarget, "LOS") or orderTarget:GetIsSighted()) then
    
        order:SetType(kTechId.Attack)

    elseif order:GetType() == kTechId.Default then
        
        // Convert default order (right-click) to move order
        order:SetType(kTechId.Move)
        
    end
    
end

local function BuyExo(self, techId)

    local maxAttempts = 100
    for index = 1, maxAttempts do
    
        // Find open area nearby to place the big guy.
        local capsuleHeight, capsuleRadius = self:GetTraceCapsule()
        local spawnPoint = GetRandomSpawnForCapsule(capsuleHeight, capsuleRadius, self:GetModelOrigin(), 0.5, 5, EntityFilterOne(self))

        if spawnPoint then
        
            self:AddResources(-GetCostForTech(techId))
            if techId == kTechId.Exosuit then
                self:GiveExo(spawnPoint)
            elseif techId == kTechId.DualMinigunExosuit then
                self:GiveDualExo(spawnPoint)
            end
            
            return
            
        end
        
    end
    
    Print("Error: Could not find a spawn point to place the Exo")
    
end

function Avatar:AttemptToBuy(techIds)

    local techId = techIds[1]
    
    local hostStructure = GetHostStructureFor(self, techId)
    
    if hostStructure then
    
        local mapName = LookupTechData(techId, kTechDataMapName)
        
        if mapName then
                        
            Shared.PlayPrivateSound(self, Marine.kSpendResourcesSoundName, nil, 1.0, self:GetOrigin())
            
            if techId == kTechId.Jetpack then
            
                // need to apply this here since we change the class
                self:AddResources(-GetCostForTech(techId))
                self:GiveJetpack()
                
            elseif techId == kTechId.Exosuit or techId == kTechId.DualMinigunExosuit then
                BuyExo(self, techId)              
            else
            
                // Make sure we're ready to deploy new weapon so we switch to it properly
                if self:GiveItem(mapName) then
                
                    Shared.PlayWorldSound(nil, Marine.kGunPickupSound, nil, self:GetOrigin())
                    return true
                    
                end
                
            end
            
            return false
            
        end
        
    end
    
    return false
    
end

// special threatment for mines and welders
function Avatar:GiveItem(itemMapName)

    local newItem = nil

    if itemMapName then
        
        local continue = true
        local setActive = true
        
        if itemMapName == LayMines.kMapName then
        
            local mineWeapon = self:GetWeapon(LayMines.kMapName)
            
            if mineWeapon then
                mineWeapon:Refill(kNumMines)
                continue = false
                setActive = false
            end
            
        elseif itemMapName == Welder.kMapName then
        
            // since axe cannot be dropped we need to delete it before adding the welder (shared hud slot)
            local switchAxe = self:GetWeapon(Axe.kMapName)
            
            if switchAxe then
                self:RemoveWeapon(switchAxe)
                DestroyEntity(switchAxe)
                continue = true
            else
                continue = false // don't give a second welder
            end
        
        end
        
        if continue == true then
            return Player.GiveItem(self, itemMapName, setActive)
        end
        
    end
    
    return newItem
    
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
        
    // Note: Flashlight is powered by Marine's beating heart. Eco friendly.
    self:SetFlashlightOn(false)
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
