// ======= Copyright (c) 2003-2012, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\Alien_Server.lua
//
//    Created by:   Charlie Cleveland (charlie@unknownworlds.com) and
//                  Max McGuire (max@unknownworlds.com)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

function Alien:RequestHeal()

    if not self.timeLastHealRequest or self.timeLastHealRequest + 4 < Shared.GetTime() then
    
        self:GetTeam():TriggerAlert(kTechId.AlienAlertNeedHealing, self)
        self:PlaySound("sound/NS2.fev/alien/voiceovers/need_healing")
        self.timeLastHealRequest = Shared.GetTime()
            
    end

end

function Alien:SetPrimalScream(duration)
    self.timeWhenPrimalScreamExpires = Shared.GetTime() + duration
end

function Alien:TriggerEnzyme(duration)
    self.timeWhenEnzymeExpires = duration + Shared.GetTime()
end

function Alien:SetEMPBlasted()    
    self.empBlasted = true    
end

function Alien:Reset()

    Player.Reset(self)
    
    self.twoHives = false
    self.threeHives = false
    
end

function Alien:OnProcessMove(input)

    if self.empBlasted then
    
        self:DeductAbilityEnergy(kEMPBlastEnergyDamage)  
        self.empBlasted = false  
        
    end
    
    Player.OnProcessMove(self, input)
    
    // Calculate two and three hives so abilities for abilities        
    self:UpdateNumHives()
    
    self.enzymed = self.timeWhenEnzymeExpires > Shared.GetTime()
    self.primalScreamBoost = self.timeWhenPrimalScreamExpires > Shared.GetTime()
    
    self:UpdateAutoHeal()
    
end

function Alien:UpdateAutoHeal()

    PROFILE("Alien:UpdateAutoHeal")

    if self:GetIsHealable() and not self.timeLastAlienAutoHeal or self.timeLastAlienAutoHeal + kAlienRegenerationTime <= Shared.GetTime() then

        local healRate = ConditionalValue(GetHasRegenerationUpgrade(self), kAlienInnateRegenerationPercentage * 3, kAlienInnateRegenerationPercentage)
        self:AddHealth(math.max(1, self:GetMaxHealth() * healRate), false)  
        self.timeLastAlienAutoHeal = Shared.GetTime()
    
    end 

end

function Alien:OnTakeDamage(damage, attacker, doer, point)
    self.timeCelerityInterrupted = Shared.GetTime()
end

function Alien:GetDamagedAlertId()
    return kTechId.AlienAlertLifeformUnderAttack
end

/**
 * Morph into new class or buy upgrade.
 */
function Alien:ProcessBuyAction(techIds)

    ASSERT(type(techIds) == "table")
    ASSERT(table.count(techIds) > 0)

    local success = false
    local healthScalar = 1
    local armorScalar = 1
    local totalCosts = 0
    
    // Check for room
    local eggExtents = LookupTechData(kTechId.Embryo, kTechDataMaxExtents)
    local newAlienExtents = nil
    // Aliens will have a kTechDataMaxExtents defined, find it.
    for i, techId in ipairs(techIds) do
        newAlienExtents = LookupTechData(techId, kTechDataMaxExtents)
        if newAlienExtents then break end
    end
    
    // In case we aren't evolving to a new alien, using the current's extents.
    if not newAlienExtents then
    
        newAlienExtents = LookupTechData(self:GetTechId(), kTechDataMaxExtents)
        // Preserve existing health/armor when we're not changing lifeform
        healthScalar = self:GetHealth() / self:GetMaxHealth()
        armorScalar = self:GetArmor() / self:GetMaxArmor()
        
    end
    
    local physicsMask = PhysicsMask.AllButPCsAndRagdolls
    local position = self:GetOrigin()
    local newLifeFormTechId = kTechId.None
    
    if self:GetIsOnGround() and
           GetHasRoomForCapsule(eggExtents, position + Vector(0, eggExtents.y + Embryo.kEvolveSpawnOffset, 0), CollisionRep.Default, physicsMask, self) and
           GetHasRoomForCapsule(newAlienExtents, position + Vector(0, newAlienExtents.y + Embryo.kEvolveSpawnOffset, 0), CollisionRep.Default, physicsMask, self) then
        
        // Deduct cost here as player is immediately replaced and copied.
        for i, techId in ipairs(techIds) do
        
            local bought = true
            
            // Try to buy upgrades (upgrades don't have a gestate name, only aliens do).
            if not LookupTechData(techId, kTechDataGestateName) then
            
                // If we don't already have this upgrade, buy it.
                if not self:GetHasUpgrade(techId) then
                    bought = true
                else
                    bought = false
                end
                
            else
                newLifeFormTechId = techId          
            end
            
            if bought then
                totalCosts = totalCosts + LookupTechData(techId, kTechDataCostKey)
            end
            
        end
        
        local hasHyperMutation = false        
        if table.contains(techIds, kTechId.HyperMutation) or GetHasHyperMutationUpgrade(self) then
        
            hasHyperMutation = true

            if newLifeFormTechId ~= kTechId.None then   
                totalCosts = totalCosts - self.storedHyperMutationCost
            end

        end

        if newLifeFormTechId ~= kTechId.None then
            self.twoHives = false
            self.threeHives = false
        end

        if totalCosts > self:GetResources() then
            success = false
        else    

            self:AddResources(math.min(0, -totalCosts))
            
            if newLifeFormTechId ~= kTechId.None then
                self.storedHyperMutationCost = LookupTechData(newLifeFormTechId, kTechDataCostKey, 0)
            end
            
            local newPlayer = self:Replace(Embryo.kMapName)
            position.y = position.y + Embryo.kEvolveSpawnOffset
            newPlayer:SetOrigin(position)

            if not newPlayer:IsAnimated() then
                newPlayer:SetDesiredCamera(1.1, { follow = true, tweening = kTweeningFunctions.easeout7 })
            end
            newPlayer:SetCameraDistance(kGestateCameraDistance)
            newPlayer:SetViewOffsetHeight(.5)
            
            if totalCosts < 0 then
                newPlayer.resOnGestationComplete = -totalCosts
            end
            
            // Clear angles, in case we were wall-walking or doing some crazy alien thing
            local angles = Angles(self:GetViewAngles())
            angles.roll = 0.0
            angles.pitch = 0.0
            newPlayer:SetOriginalAngles(angles)
            
            // Eliminate velocity so that we don't slide or jump as an egg
            newPlayer:SetVelocity(Vector(0, 0, 0))
            
            newPlayer:DropToFloor()
            
            newPlayer:SetGestationData(techIds, self:GetTechId(), healthScalar, armorScalar)
            
            success = true
        
        end
        
    else
        self:TriggerInvalidSound()
    end
    
    return success
    
end

// Increase armor absorption the depending on our defensive upgrade level
function Alien:GetHealthPerArmorOverride(damageType, healthPerArmor)
    
    local newHealthPerArmor = healthPerArmor

    local team = self:GetTeam()
    local numHives = team:GetNumHives()
    
    // make sure not to ignore damage types
    if numHives >= 3 then
        newHealthPerArmor = healthPerArmor * kHealthPointsPerArmorScalarHive3
    elseif numHives == 2 then
        newHealthPerArmor = healthPerArmor * kHealthPointsPerArmorScalarHive2
    elseif numHives == 1 then
        newHealthPerArmor = healthPerArmor * kHealthPointsPerArmorScalarHive1
    end

    return newHealthPerArmor
    
end

function Alien:MakeSpecialEdition()
    // Currently there's no alien special edition visual difference
end

function Alien:GetTierTwoTechId()
    return kTechId.None
end

function Alien:GetTierThreeTechId()
    return kTechId.None
end

function Alien:GetTierThreeWeaponMapName()
    return LookupTechData(self:GetTierThreeTechId(), kTechDataMapName)
end

function Alien:GetTierTwoWeaponMapName()
    return LookupTechData(self:GetTierTwoTechId(), kTechDataMapName)
end

function Alien:UnlockTierTwo()

    local tierTwoMapName = self:GetTierTwoWeaponMapName()
    
    if tierTwoMapName and self:GetIsAlive() then
    
        local activeWeapon = self:GetActiveWeapon()
        
        if tierTwoMapName then
        
            local tierTwoWeapon = self:GetWeapon(tierTwoMapName)
            if not tierTwoWeapon then
                self:GiveItem(tierTwoMapName)
            end
        
        end
        
        if activeWeapon then
            self:SetActiveWeapon(activeWeapon:GetMapName())
        end
    
    end
    
end

function Alien:LockTierTwo()

    local tierTwoMapName = self:GetTierTwoWeaponMapName()
    
    if tierTwoMapName and self:GetIsAlive() then
    
        local tierTwoWeapon = self:GetWeapon(tierTwoMapName)
        local activeWeapon = self:GetActiveWeapon()
        local activeWeaponMapName = nil
        
        if activeWeapon ~= nil then
            activeWeaponMapName = activeWeapon:GetMapName()
        end
        
        if tierTwoWeapon then
            self:RemoveWeapon(tierTwoWeapon)
        end
        
        if activeWeaponMapName == tierTwoMapName then
            self:SwitchWeapon(1)
        end
        
    end    
    
end

function Alien:UnlockTierThree()

    local tierThreeMapName = self:GetTierThreeWeaponMapName()
    
    if tierThreeMapName and self:GetIsAlive() then
    
        local activeWeapon = self:GetActiveWeapon()
    
        local tierThreeWeapon = self:GetWeapon(tierThreeMapName)
        if not tierThreeWeapon then
            self:GiveItem(tierThreeMapName)
        end
        
        if activeWeapon then
            self:SetActiveWeapon(activeWeapon:GetMapName())
        end
    
    end
    
end

function Alien:LockTierThree()

    local tierThreeMapName = self:GetTierThreeWeaponMapName()
    
    if tierThreeMapName and self:GetIsAlive() then
    
        local tierThreeWeapon = self:GetWeapon(tierThreeMapName)
        local activeWeapon = self:GetActiveWeapon()
        local activeWeaponMapName = nil
        
        if activeWeapon ~= nil then
            activeWeaponMapName = activeWeapon:GetMapName()
        end
        
        if tierThreeWeapon then
            self:RemoveWeapon(tierThreeWeapon)
        end
        
        if activeWeaponMapName == tierThreeMapName then
            self:SwitchWeapon(1)
        end
        
    end
    
end

function Alien:OnKill(attacker, doer, point, direction)

    Player.OnKill(self, attacker, doer, point, direction)
    
    self.storedHyperMutationCost = 0
    self.twoHives = false
    self.threeHives = false
    
end

function Alien:UpdateNumHives()

    local time = Shared.GetTime()
    if self.timeOfLastNumHivesUpdate == nil or (time > self.timeOfLastNumHivesUpdate + 0.5) then
    
        local team = self:GetTeam()
        if team and team.GetTechTree then
        
            local hasTwoHivesNow = GetGamerules():GetAllTech() or (self:GetTierTwoTechId() ~= kTechId.None and GetHasTech(self, self:GetTierTwoTechId(), true))
            
            local hadTwoHives = self.twoHives
            // Don't lose abilities unless you die.
            self.twoHives = self.twoHives or hasTwoHivesNow
            
            // Prevent the callbacks from being called too often.
            if hadTwoHives ~= self.twoHives then
            
                if self.twoHives then
                    self:UnlockTierTwo()
                else
                    self:LockTierTwo()
                end
                
            end
            
            local hasThreeHivesNow = GetGamerules():GetAllTech() or (self:GetTierTwoTechId() ~= kTechId.None and GetHasTech(self, self:GetTierThreeTechId(), true))
            local hadThreeHives = self.threeHives
            // Don't lose abilities unless you die.
            self.threeHives = self.threeHives or hasThreeHivesNow
            
            // Prevent the callbacks from being called too often.
            if hadThreeHives ~= self.threeHives then
            
                if self.threeHives then
                    self:UnlockTierThree()
                else
                    self:LockTierThree()
                end
                
            end
            
        end
        
        self.timeOfLastNumHivesUpdate = time
        
    end
    
end

function Alien:CopyPlayerDataFrom(player)

    Player.CopyPlayerDataFrom(self, player)
    
    self.twoHives = player.twoHives
    self.threeHives = player.threeHives
    
    if self:GetTeamType() == kAlienTeamType then
    
        self.storedHyperMutationTime = player.storedHyperMutationTime
        self.storedHyperMutationCost = player.storedHyperMutationCost
        
    end
    
end