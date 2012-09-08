// ======= Copyright (c) 2003-2012, Unknown Worlds Entertainment, Inc. All rights reserved. =====
//
// lua\AlienTeam.lua
//
//    Created by:   Charlie Cleveland (charlie@unknownworlds.com) and
//                  Max McGuire (max@unknownworlds.com)
//
// This class is used for teams that are actually playing the game, e.g. Marines or Aliens.
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/TechData.lua")
Script.Load("lua/Skulk.lua")
Script.Load("lua/PlayingTeam.lua")
Script.Load("lua/UpgradeStructureManager.lua")

class 'AlienTeam' (PlayingTeam)

// Innate alien regeneration
AlienTeam.kAutoHealInterval = 2
AlienTeam.kStructureAutoHealInterval = 0.5
AlienTeam.kAutoHealUpdateNum = 20 // number of structures to update per autoheal update

AlienTeam.kOrganicStructureHealRate = kHealingBedStructureRegen     // Health per second
AlienTeam.kInfestationUpdateRate = 2

// only update every second to not stress the server too much
AlienTeam.kAlienSpectatorUpdateIntervall = 1

AlienTeam.kSupportingStructureClassNames = {[kTechId.Hive] = {"Hive"} }
AlienTeam.kUpgradeStructureClassNames = {[kTechId.Crag] = {"Crag", "MatureCrag"}, [kTechId.Shift] = {"Shift", "MatureShift"}, [kTechId.Shade] = {"Shade", "MatureShift"} }
AlienTeam.kUpgradedStructureTechTable = {[kTechId.Crag] = {kTechId.MatureCrag}, [kTechId.Shift] = {kTechId.MatureShift}, [kTechId.Shade] = {kTechId.MatureShade}}

AlienTeam.kTechTreeIdsToUpdate = {} // {kTechId.Crag, kTechId.MatureCrag, kTechId.Shift, kTechId.MatureShift, kTechId.Shade, kTechId.MatureShade}

function AlienTeam:GetTeamType()
    return kAlienTeamType
end

function AlienTeam:GetIsAlienTeam()
    return true
end

function AlienTeam:Initialize(teamName, teamNumber)

    PlayingTeam.Initialize(self, teamName, teamNumber)
    
    self.respawnEntity = Skulk.kMapName

    // List stores all the structures owned by builder player types such as the Gorge.
    // This list stores them based on the player platform ID in order to maintain structure
    // counts even if a player leaves and rejoins a server.
    self.clientOwnedStructures = { }
    self.lastAutoHealIndex = 1
    
    self.updateAlienArmorInTicks = nil
    
    self.timeLastWave = nil
    
    self.cloakables = {}
    self.cloakableCloakCount = {}
    
end

function AlienTeam:OnInitialized()

    PlayingTeam.OnInitialized(self)    

    self.timeLastAlienSpectatorCheck = 0
    self.lastAutoHealIndex = 1
    self.timeLastWave = nil
    
    self.clientOwnedStructures = { }
    
    self.cloakables = {}
    self.cloakableCloakCount = {}

end

function AlienTeam:GetTeamInfoMapName()
    return AlienTeamInfo.kMapName
end

local function RemoveGorgeStructureFromClient(self, techId, clientId)

    local structureTypeTable = self.clientOwnedStructures[clientId]
    
    if structureTypeTable then
    
        if not structureTypeTable[techId] then
        
            structureTypeTable[techId] = { }
            return
            
        end    
        
        local removeIndex = 0
        local structure = nil
        for index, id in ipairs(structureTypeTable[techId])  do
        
            if id then
            
                removeIndex = index
                structure = Shared.GetEntity(id)
                break
                
            end
            
        end
        
        if structure then
        
            table.remove(structureTypeTable[techId], removeIndex)
            structure.consumed = true
            structure:Kill()
            
        end
        
    end
    
end

function AlienTeam:AddGorgeStructure(player, structure)

    if player ~= nil and structure ~= nil then
    
        local clientId = Server.GetOwner(player):GetUserId()
        local structureId = structure:GetId()
        local techId = structure:GetTechId()
        
        if not self.clientOwnedStructures[clientId] then
            self.clientOwnedStructures[clientId] = { }
        end
        
        local structureTypeTable = self.clientOwnedStructures[clientId]
        
        if not structureTypeTable[techId] then
            structureTypeTable[techId] = { }
        end
        
        table.insertunique(structureTypeTable[techId], structureId)
        
        local numAllowedStructure = LookupTechData(techId, kTechDataMaxAmount, -1) //* self:GetNumHives()
        
        if numAllowedStructure >= 0 and table.count(structureTypeTable[techId]) > numAllowedStructure then
            RemoveGorgeStructureFromClient(self, techId, clientId)
        end
        
    end
    
end

function AlienTeam:GetDroppedGorgeStructures(player, techId)

    local owner = Server.GetOwner(player)

    if owner then
    
        local clientId = owner:GetUserId()
        local structureTypeTable = self.clientOwnedStructures[clientId]
        
        if structureTypeTable then
            return structureTypeTable[techId]
        end
    
    end
    
end

function AlienTeam:GetNumDroppedGorgeStructures(player, techId)

    local structureTypeTable = self:GetDroppedGorgeStructures(player, techId)
    return (not structureTypeTable and 0) or #structureTypeTable
    
end

function AlienTeam:UpdateClientOwnedStructures(oldEntityId)

    if oldEntityId then
    
        for clientId, structureTypeTable in pairs(self.clientOwnedStructures) do
        
            for techId, structureList in pairs(structureTypeTable) do
            
                for i, structureId in ipairs(structureList) do
                
                    if structureId == oldEntityId then
                    
                        if newEntityId then
                            structureList[i] = newEntityId
                        else
                        
                            table.remove(structureList, i)
                            break
                            
                        end
                        
                    end
                    
                end
                
            end
            
        end
        
    end

end

function AlienTeam:OnEntityChange(oldEntityId, newEntityId)

    // Check if the oldEntityId matches any client's built structure and
    // handle the change.
    
    LifeFormEggOnEntityChanged(oldEntityId, newEntityId)
    self:UpdateClientOwnedStructures(oldEntityId)
    self:UpdateCloakablesChanged(oldEntityId, newEntityId)
    
end

local function CreateCysts(hive, harvester, teamNumber)

    // Get hi-detail path on the floor.
    local hiveOrigin = hive:GetOrigin()
    local harvesterOrigin = harvester:GetOrigin()
    local pathDirection = harvesterOrigin - hiveOrigin
    pathDirection:Normalize()
    
    // DL: Offset the start point a little towards the harvester so that we start with a polygon on a nav mesh
    // that is closest to the harvester. This is a workaround for edge case where a start polygon is picked on
    // a tiny island blocked off by the hive.
    local points = GeneratePath(hiveOrigin + pathDirection*0.1, harvesterOrigin)
    
    if GetPointDistance(points) < (kInfestationRadius * 0.8) or GetIsPointOnInfestation(harvester:GetOrigin()) then
        return
    end    
    
    for index, point in ipairs(points) do
    
        local droppedPoint = DropToFloor(point)
        VectorCopy(droppedPoint, point)
        
    end
    
    // Now split up path so we don't have more cysts then we need. We intend to place them
    // at about 1.5 * infestation radius, but we may need to use the one 
    local splitDistance = kInfestationRadius * 0.65
    local splitPoints = SplitPathPoints(hive:GetOrigin(), points, splitDistance)
    
    // place no point any close than this to the RT
    local kMinDistance = 4
    local lastPoint = hive:GetOrigin()
    
    for index, point in ipairs(splitPoints) do
    
        // we use only half the points, backing up to a halfway point if the last point is
        // too close to the harvester
        if index % 2 == 0 then
        
            local withinVerticalZone = math.abs(point.y - harvester:GetOrigin().y) <= GetInfestationVerticalSize()
            
            // Back up to the intermediate point, if any.
            if (point - harvester:GetOrigin()):GetLength() < kMinDistance and withinVerticalZone then
                point = splitPoints[index-1] or point
            end
            
            // check again, if this point is also too close, skip it - we may end up placing none at all
            if (point - harvester:GetOrigin()):GetLength() >= kMinDistance or not withinVerticalZone then
            
                local cyst = CreateEntityForTeam(kTechId.Cyst, point, teamNumber, nil)
                cyst:SetConstructionComplete()
                cyst:SetInfestationFullyGrown()
                
                VectorCopy(point, lastPoint)
                
            end
            
        end
        
    end
    
    // Get hi-detail path on the floor
    local toHarvester = GeneratePath(lastPoint, harvester:GetOrigin())
    
    for index, point in ipairs(toHarvester) do
    
        local droppedPoint = DropToFloor(point)
        VectorCopy(droppedPoint, point)
        
    end
    
    local precisePoints = SplitPathPoints(lastPoint, toHarvester, 0.2)
    local pathLength = GetPointDistance(precisePoints)
    local currentLength = 0
    
    for index, point in ipairs(precisePoints) do
    
        if index > 1 then
            currentLength = currentLength + (point - precisePoints[index-1]):GetLength()
        end
        
        if currentLength > pathLength * 0.7 then
        
            local cyst = CreateEntityForTeam(kTechId.Cyst, point, teamNumber, nil)
            cyst:SetConstructionComplete()
            cyst:SetInfestationFullyGrown()
            break
            
        end
        
    end
    
end

function AlienTeam:SpawnInitialStructures(techPoint)

    local tower, hive = PlayingTeam.SpawnInitialStructures(self, techPoint)
    
    hive:SetFirstLogin()
    hive:SetInfestationFullyGrown()
    
    // It is possible there was not an available tower if the map is not designed properly.
    if tower then
        CreateCysts(hive, tower, self:GetTeamNumber())
    end
    
    return tower, hive
    
end

function AlienTeam:GetHasAbilityToRespawn()
    
    local hives = GetEntitiesForTeam("Hive", self:GetTeamNumber())
    return table.count(hives) > 0
    
end

function AlienTeam:Update(timePassed)

    PROFILE("AlienTeam:Update")
    
    if self.updateAlienArmorInTicks then
    
        if self.updateAlienArmorInTicks == 0 then
        
            for index, alien in ipairs(GetEntitiesForTeam("Alien", self:GetTeamNumber())) do
                alien:UpdateArmorAmount()
            end
            
            self.updateAlienArmorInTicks = nil
        
        else
            self.updateAlienArmorInTicks = self.updateAlienArmorInTicks - 1
        end
        
    end

    PlayingTeam.Update(self, timePassed)
    self:UpdateTeamAutoHeal(timePassed)
    self:UpdateCloakables()
    
end

function AlienTeam:OnTechTreeUpdated()

    if self.updateAlienArmor then
        
        self.updateAlienArmor = false
        self.updateAlienArmorInTicks = 100
        
    end

end

// update every tick but only a small amount of structures
function AlienTeam:UpdateTeamAutoHeal(timePassed)

    PROFILE("AlienTeam:UpdateTeamAutoHeal")

    local time = Shared.GetTime()
    
    if self.timeOfLastAutoHeal == nil then
        self.timeOfLastAutoHeal = Shared.GetTime()
    end
    
    if time > (self.timeOfLastAutoHeal + AlienTeam.kStructureAutoHealInterval) then
        
        local intervalLength = time - self.timeOfLastAutoHeal
        local gameEnts = GetEntitiesWithMixinForTeam("InfestationTracker", self:GetTeamNumber())
        local numEnts = table.count(gameEnts)
        local toIndex = self.lastAutoHealIndex + AlienTeam.kAutoHealUpdateNum - 1
        toIndex = ConditionalValue(toIndex <= numEnts , toIndex, numEnts)
        local hasHealingBedUpgrade = GetHasHealingBedUpgrade(self:GetTeamNumber())
        
        for index = self.lastAutoHealIndex, toIndex do

            local entity = gameEnts[index]
            
            // players update the auto heal on their own
            if not entity:isa("Player") then
            
                // we add whips as an exception here. construction should still be restricted to onInfestation, we only don't want whips to take damage off infestation
                local requiresInfestation   = ConditionalValue(entity:isa("Whip"), false, LookupTechData(entity:GetTechId(), kTechDataRequiresInfestation))
                local isOnInfestation       = entity:GetGameEffectMask(kGameEffect.OnInfestation)
                local isHealable            = entity:GetIsHealable()
                local deltaTime             = 0
                
                if not entity.timeLastAutoHeal then
                    entity.timeLastAutoHeal = Shared.GetTime()
                else
                    deltaTime = Shared.GetTime() - entity.timeLastAutoHeal
                    entity.timeLastAutoHeal = Shared.GetTime()
                end

                if requiresInfestation and not isOnInfestation then
                    // Take damage!
                    local damage = entity:GetMaxHealth() * kBalanceInfestationHurtPercentPerSecond/100 * deltaTime
                    entity:DeductHealth(damage)
                    
                elseif isOnInfestation and isHealable and hasHealingBedUpgrade then
                    entity:AddHealth(math.min(AlienTeam.kOrganicStructureHealRate * deltaTime, 0.02*entity:GetMaxHealth()), true)                
                end
            
            end
        
        end
        
        if self.lastAutoHealIndex + AlienTeam.kAutoHealUpdateNum >= numEnts then
            self.lastAutoHealIndex = 1
        else
            self.lastAutoHealIndex = self.lastAutoHealIndex + AlienTeam.kAutoHealUpdateNum
        end 

        self.timeOfLastAutoHeal = Shared.GetTime()

   end
    
end

function AlienTeam:GetWaveSpawnStartTime()
    return ConditionalValue(self.timeLastWave, self.timeLastWave, 0)
end

function AlienTeam:InitTechTree()

    PlayingTeam.InitTechTree(self)
    
    // Add special alien menus
    self.techTree:AddMenu(kTechId.MarkersMenu)
    self.techTree:AddMenu(kTechId.UpgradesMenu)
    self.techTree:AddMenu(kTechId.ShadePhantomMenu)
    self.techTree:AddMenu(kTechId.ShadePhantomStructuresMenu)
    self.techTree:AddMenu(kTechId.ShiftEcho)
    self.techTree:AddMenu(kTechId.LifeFormMenu)
    
    self.techTree:AddPassive(kTechId.Infestation)
    
    // Add markers (orders)
    self.techTree:AddSpecial(kTechId.ThreatMarker, true)
    self.techTree:AddSpecial(kTechId.LargeThreatMarker, true)
    self.techTree:AddSpecial(kTechId.NeedHealingMarker, true)
    self.techTree:AddSpecial(kTechId.WeakMarker, true)
    self.techTree:AddSpecial(kTechId.ExpandingMarker, true)
    
    // Gorge specific orders
    self.techTree:AddOrder(kTechId.AlienMove)
    self.techTree:AddOrder(kTechId.AlienAttack)
    //self.techTree:AddOrder(kTechId.AlienDefend)
    self.techTree:AddOrder(kTechId.AlienConstruct)
    self.techTree:AddOrder(kTechId.Heal)
    
    // Commander abilities
    self.techTree:AddBuildNode(kTechId.Cyst,                kTechId.None,           kTechId.None)
    self.techTree:AddTargetedActivation(kTechId.NutrientMist,     kTechId.None,           kTechId.None)
    self.techTree:AddBuildNode(kTechId.InfestationSpike,    kTechId.TwoHives,           kTechId.None)
    self.techTree:AddTargetedActivation(kTechId.EnzymeCloud,      kTechId.None,           kTechId.None)
    self.techTree:AddActivation(kTechId.Rupture,                      kTechId.None,           kTechId.None)
           
    // Hive types
    self.techTree:AddBuildNode(kTechId.Hive,                    kTechId.None,           kTechId.None)
    self.techTree:AddPassive(kTechId.HiveHeal)
    self.techTree:AddBuildNode(kTechId.CragHive,                kTechId.Hive,                kTechId.None)
    self.techTree:AddBuildNode(kTechId.ShadeHive,               kTechId.Hive,                kTechId.None)
    self.techTree:AddBuildNode(kTechId.ShiftHive,               kTechId.Hive,                kTechId.None)
    
    self.techTree:AddUpgradeNode(kTechId.UpgradeToCragHive,     kTechId.Hive,                kTechId.None)
    self.techTree:AddUpgradeNode(kTechId.UpgradeToShadeHive,    kTechId.Hive,                kTechId.None)
    self.techTree:AddUpgradeNode(kTechId.UpgradeToShiftHive,    kTechId.Hive,                kTechId.None)
    
    // infestation upgrades
    self.techTree:AddResearchNode(kTechId.HealingBed,            kTechId.CragHive,            kTechId.None)
    self.techTree:AddResearchNode(kTechId.MucousMembrane,        kTechId.ShiftHive,           kTechId.None)
    self.techTree:AddResearchNode(kTechId.BacterialReceptors,    kTechId.ShadeHive,           kTechId.None)
    
    // Tier 1
    self.techTree:AddBuildNode(kTechId.Harvester,                 kTechId.None,                kTechId.None)
    self.techTree:AddManufactureNode(kTechId.Drifter,             kTechId.None,                kTechId.None)
    self.techTree:AddPassive(kTechId.DrifterCamouflage)

    // Whips
    self.techTree:AddBuildNode(kTechId.Whip,                      kTechId.None,                kTechId.None)
    self.techTree:AddUpgradeNode(kTechId.EvolveBombard,             kTechId.None,                kTechId.None)

    self.techTree:AddActivation(kTechId.WhipBombard)
    self.techTree:AddActivation(kTechId.WhipBombardCancel)
    self.techTree:AddActivation(kTechId.WhipUnroot)
    self.techTree:AddActivation(kTechId.WhipRoot)
    
    // Tier 1 lifeforms
    self.techTree:AddAction(kTechId.Skulk,                     kTechId.None,                kTechId.None)
    self.techTree:AddAction(kTechId.Gorge,                     kTechId.None,                kTechId.None)
    self.techTree:AddAction(kTechId.Lerk,                      kTechId.None,                kTechId.None)
    self.techTree:AddAction(kTechId.Fade,                      kTechId.None,                kTechId.None)
    self.techTree:AddAction(kTechId.Onos,                      kTechId.None,                kTechId.None)
    self.techTree:AddBuyNode(kTechId.Egg,                      kTechId.None,                kTechId.None)
    
    self.techTree:AddUpgradeNode(kTechId.GorgeEgg,          kTechId.None,                kTechId.None)
    self.techTree:AddUpgradeNode(kTechId.LerkEgg,          kTechId.None,                kTechId.None)
    self.techTree:AddUpgradeNode(kTechId.FadeEgg,          kTechId.TwoHives,                kTechId.None)
    self.techTree:AddUpgradeNode(kTechId.OnosEgg,          kTechId.TwoHives,                kTechId.None)
    
    // Special alien structures. These tech nodes are modified at run-time, depending when they are built, so don't modify prereqs.
    self.techTree:AddBuildNode(kTechId.Crag,                      kTechId.CragHive,          kTechId.None)
    self.techTree:AddBuildNode(kTechId.Shift,                     kTechId.ShiftHive,          kTechId.None)
    self.techTree:AddBuildNode(kTechId.Shade,                     kTechId.ShadeHive,          kTechId.None)
    
    // Alien upgrade structure
    self.techTree:AddBuildNode(kTechId.Shell, kTechId.CragHive, kTechId.None)
    self.techTree:AddUpgradeNode(kTechId.UpgradeRegenerationShell, kTechId.CragHive, kTechId.None)
    self.techTree:AddBuildNode(kTechId.RegenerationShell, kTechId.None, kTechId.None)
    self.techTree:AddUpgradeNode(kTechId.UpgradeCarapaceShell, kTechId.CragHive, kTechId.None)
    self.techTree:AddBuildNode(kTechId.CarapaceShell, kTechId.None, kTechId.None)
    
    self.techTree:AddBuildNode(kTechId.Spur,                     kTechId.ShiftHive,          kTechId.None)    
    self.techTree:AddUpgradeNode(kTechId.UpgradeCeleritySpur,    kTechId.ShiftHive,          kTechId.None)
    self.techTree:AddBuildNode(kTechId.CeleritySpur,             kTechId.None,          kTechId.None)    
    self.techTree:AddUpgradeNode(kTechId.UpgradeAdrenalineSpur,    kTechId.ShiftHive,          kTechId.None)
    self.techTree:AddBuildNode(kTechId.AdrenalineSpur,             kTechId.None,          kTechId.None)    
    self.techTree:AddUpgradeNode(kTechId.UpgradeHyperMutationSpur, kTechId.ShiftHive,        kTechId.None) 
    self.techTree:AddBuildNode(kTechId.HyperMutationSpur,          kTechId.None,        kTechId.None)     
    
    self.techTree:AddBuildNode(kTechId.Veil,                     kTechId.ShadeHive,        kTechId.None)
    self.techTree:AddUpgradeNode(kTechId.UpgradeSilenceVeil,     kTechId.ShadeHive,        kTechId.None)
    self.techTree:AddBuildNode(kTechId.SilenceVeil,              kTechId.None,        kTechId.None) 
    self.techTree:AddUpgradeNode(kTechId.UpgradeCamouflageVeil,  kTechId.ShadeHive,        kTechId.None) 
    self.techTree:AddBuildNode(kTechId.CamouflageVeil,           kTechId.None,        kTechId.None)    
    self.techTree:AddUpgradeNode(kTechId.UpgradeAuraVeil,  kTechId.ShadeHive,        kTechId.None) 
    self.techTree:AddBuildNode(kTechId.AuraVeil,           kTechId.None,        kTechId.None) 
    self.techTree:AddUpgradeNode(kTechId.UpgradeFeintVeil,  kTechId.ShadeHive,        kTechId.None) 
    self.techTree:AddBuildNode(kTechId.FeintVeil,           kTechId.None,        kTechId.None) 

    // Crag
    self.techTree:AddUpgradeNode(kTechId.EvolveBabblers,          kTechId.None,          kTechId.None)
    self.techTree:AddPassive(kTechId.CragHeal)
    self.techTree:AddActivation(kTechId.HealWave,                kTechId.None,          kTechId.None)
    self.techTree:AddActivation(kTechId.CragBabblers,             kTechId.None,          kTechId.None)

    // Shift    
    self.techTree:AddUpgradeNode(kTechId.EvolveEcho,              kTechId.None,         kTechId.None)
    self.techTree:AddBuildNode(kTechId.ShiftHatch,               kTechId.None,         kTechId.None) 
    self.techTree:AddPassive(kTechId.ShiftEnergize,               kTechId.None,         kTechId.None)
    
    self.techTree:AddTargetedActivation(kTechId.TeleportHydra,       kTechId.None,         kTechId.None)
    self.techTree:AddTargetedActivation(kTechId.TeleportWhip,        kTechId.None,         kTechId.None)
    self.techTree:AddTargetedActivation(kTechId.TeleportCrag,        kTechId.None,         kTechId.None)
    self.techTree:AddTargetedActivation(kTechId.TeleportShade,       kTechId.None,         kTechId.None)
    self.techTree:AddTargetedActivation(kTechId.TeleportShift,       kTechId.None,         kTechId.None)
    self.techTree:AddTargetedActivation(kTechId.TeleportVeil,        kTechId.None,         kTechId.None)
    self.techTree:AddTargetedActivation(kTechId.TeleportSpur,        kTechId.None,         kTechId.None)
    self.techTree:AddTargetedActivation(kTechId.TeleportShell,       kTechId.None,         kTechId.None)
    self.techTree:AddTargetedActivation(kTechId.TeleportHive,       kTechId.None,         kTechId.None)
    self.techTree:AddTargetedActivation(kTechId.TeleportEgg,       kTechId.None,         kTechId.None)

    // Shade
    self.techTree:AddUpgradeNode(kTechId.EvolveHallucinations,    kTechId.None,        kTechId.None)
    self.techTree:AddPassive(kTechId.ShadeDisorient)
    self.techTree:AddPassive(kTechId.ShadeCloak)
    self.techTree:AddActivation(kTechId.ShadeInk,                 kTechId.None,         kTechId.None) 

    // Hallucinations
    self.techTree:AddManufactureNode(kTechId.HallucinateDrifter,  kTechId.None,   kTechId.None)
    self.techTree:AddManufactureNode(kTechId.HallucinateSkulk,    kTechId.None,   kTechId.None)
    self.techTree:AddManufactureNode(kTechId.HallucinateGorge,    kTechId.None,   kTechId.None)
    self.techTree:AddManufactureNode(kTechId.HallucinateLerk,     kTechId.None,   kTechId.None)
    self.techTree:AddManufactureNode(kTechId.HallucinateFade,     kTechId.None,   kTechId.None)
    self.techTree:AddManufactureNode(kTechId.HallucinateOnos,     kTechId.None,   kTechId.None)
    
    self.techTree:AddBuildNode(kTechId.HallucinateHive,           kTechId.None,           kTechId.None)
    self.techTree:AddBuildNode(kTechId.HallucinateWhip,           kTechId.None,           kTechId.None)
    self.techTree:AddBuildNode(kTechId.HallucinateShade,          kTechId.ShadeHive,      kTechId.None)
    self.techTree:AddBuildNode(kTechId.HallucinateCrag,           kTechId.CragHive,       kTechId.None)
    self.techTree:AddBuildNode(kTechId.HallucinateShift,          kTechId.ShiftHive,      kTechId.None)
    self.techTree:AddBuildNode(kTechId.HallucinateHarvester,      kTechId.None,           kTechId.None)
    self.techTree:AddBuildNode(kTechId.HallucinateHydra,          kTechId.None,           kTechId.None)
    
    self.techTree:AddSpecial(kTechId.TwoHives)
    self.techTree:AddSpecial(kTechId.ThreeHives)
    
    // Tier 2
    
    self.techTree:AddResearchNode(kTechId.Leap,            kTechId.TwoHives,              kTechId.None)
    self.techTree:AddResearchNode(kTechId.Spores,            kTechId.TwoHives,              kTechId.None)
    self.techTree:AddResearchNode(kTechId.BileBomb,            kTechId.TwoHives,              kTechId.None)
    self.techTree:AddResearchNode(kTechId.Blink,            kTechId.TwoHives,              kTechId.None)
    

    // Tier 3
     
    self.techTree:AddResearchNode(kTechId.Xenocide,            kTechId.Leap,              kTechId.ThreeHives)
    self.techTree:AddResearchNode(kTechId.Umbra,            kTechId.Spores,              kTechId.ThreeHives)
    --self.techTree:AddResearchNode(kTechId.WebStalk,            kTechId.BileBomb,              kTechId.None)
    self.techTree:AddResearchNode(kTechId.Vortex,            kTechId.Blink,              kTechId.ThreeHives)
    --self.techTree:AddResearchNode(kTechId.PrimalScream,            kTechId.Stomp,        kTechId.None)   
    self.techTree:AddResearchNode(kTechId.Stomp,            kTechId.ThreeHives,              kTechId.None)

    // Global alien upgrades. Make sure the first prerequisite is the main tech required for it, as this is 
    // what is used to display research % in the alien evolve menu.
    // The second prerequisite is needed to determine the buy node unlocked when the upgrade is actually researched.
    self.techTree:AddBuyNode(kTechId.Carapace, kTechId.CarapaceShell, kTechId.None, kTechId.AllAliens)    
    self.techTree:AddBuyNode(kTechId.Regeneration, kTechId.RegenerationShell, kTechId.None, kTechId.AllAliens)
    self.techTree:AddBuyNode(kTechId.Silence, kTechId.SilenceVeil, kTechId.None, kTechId.AllAliens)
    self.techTree:AddBuyNode(kTechId.Camouflage, kTechId.CamouflageVeil, kTechId.None, kTechId.AllAliens)
    self.techTree:AddBuyNode(kTechId.Celerity, kTechId.CeleritySpur, kTechId.None, kTechId.AllAliens)  
    self.techTree:AddBuyNode(kTechId.Adrenaline, kTechId.AdrenalineSpur, kTechId.None, kTechId.AllAliens)  
    self.techTree:AddBuyNode(kTechId.HyperMutation, kTechId.HyperMutationSpur, kTechId.None, kTechId.AllAliens)
    self.techTree:AddBuyNode(kTechId.Feint, kTechId.FeintVeil, kTechId.None, kTechId.AllAliens)
    
    //self.techTree:AddBuyNode(kTechId.Aura, kTechId.AuraVeil, kTechId.None, kTechId.AllAliens)
    
    // Specific alien upgrades
    self.techTree:AddBuildNode(kTechId.Hydra,               kTechId.None,               kTechId.None)
    
    
    //self.techTree:AddBuyNode(kTechId.Sap, kTechId.SapTech, kTechId.TwoHives, kTechId.Fade)
    
    //self.techTree:AddResearchNode(kTechId.BoneShieldTech, kTechId.Crag, kTechId.TwoHives)
    //self.techTree:AddBuyNode(kTechId.BoneShield, kTechId.BoneShieldTech, kTechId.None, kTechId.Onos)
    
    self.techTree:SetComplete()
    
end

function AlienTeam:GetNumHives()

    local teamInfoEntity = Shared.GetEntity(self.teamInfoEntityId)
    return teamInfoEntity:GetNumCapturedTechPoints()
    
end

function AlienTeam:GetActiveHiveCount()

    local activeHiveCount = 0
    
    for index, hive in ipairs(GetEntitiesForTeam("Hive", self:GetTeamNumber())) do
    
        if hive:GetIsAlive() and hive:GetIsBuilt() then
            activeHiveCount = activeHiveCount + 1
        end
    
    end

    return activeHiveCount

end

/**
 * Inform all alien players about the hive construction (add new abilities).
 */
function AlienTeam:OnHiveConstructed(newHive)

    local activeHiveCount = self:GetActiveHiveCount()
    
    for index, alien in ipairs(GetEntitiesForTeam("Alien", self:GetTeamNumber())) do
    
        if alien:GetIsAlive() and alien.OnHiveConstructed then
            alien:OnHiveConstructed(newHive, activeHiveCount)
        end
        
    end
    
    SendTeamMessage(self, kTeamMessageTypes.HiveConstructed, newHive:GetLocationId())
    
end

/**
 * Inform all alien players about the hive destruction (remove abilities).
 */
function AlienTeam:OnHiveDestroyed(destroyedHive)

    local activeHiveCount = self:GetActiveHiveCount()
    
    for index, alien in ipairs(GetEntitiesForTeam("Alien", self:GetTeamNumber())) do
    
        if alien:GetIsAlive() and alien.OnHiveDestroyed then
            alien:OnHiveDestroyed(destroyedHive, activeHiveCount)
        end
        
    end
    
end

function AlienTeam:OnUpgradeChamberConstructed(upgradeChamber)

    if upgradeChamber:GetTechId() == kTechId.CarapaceShell then
        self.updateAlienArmor = true
    end
    
end

function AlienTeam:OnUpgradeChamberDestroyed(upgradeChamber)

    if upgradeChamber:GetTechId() == kTechId.CarapaceShell then
        self.updateAlienArmor = true
    end
    
    // These is a list of all tech to check when a upgrade chamber is destroyed.
    local checkForLostResearch = { [kTechId.RegenerationShell] = { "Shell", kTechId.Regeneration },
                                   [kTechId.CarapaceShell] = { "Shell", kTechId.Carapace },
                                   [kTechId.CeleritySpur] = { "Spur", kTechId.Celerity },
                                   [kTechId.HyperMutationSpur] = { "Spur", kTechId.HyperMutation },
                                   [kTechId.SilenceVeil] = { "Veil", kTechId.Silence },
                                   [kTechId.AuraVeil] = { "Veil", kTechId.Aura } }
    
    local checkTech = checkForLostResearch[upgradeChamber:GetTechId()]
    if checkTech then
    
        local anyRemain = false
        for _, ent in ientitylist(Shared.GetEntitiesWithClassname(checkTech[1])) do
        
            // Don't count the upgradeChamber as it is being destroyed now.
            if ent ~= upgradeChamber and ent:GetTechId() == upgradeChamber:GetTechId() then
            
                anyRemain = true
                break
                
            end
            
        end
        
        if not anyRemain then
            SendTeamMessage(self, kTeamMessageTypes.ResearchLost, checkTech[2])
        end
        
    end
    
end

function AlienTeam:OnResearchComplete(structure, researchId)

    PlayingTeam.OnResearchComplete(self, structure, researchId)
    
    local checkForGainedResearch = { [kTechId.UpgradeRegenerationShell] = kTechId.Regeneration,
                                     [kTechId.UpgradeCarapaceShell] = kTechId.Carapace,
                                     [kTechId.UpgradeCeleritySpur] = kTechId.Celerity,
                                     [kTechId.UpgradeHyperMutationSpur] = kTechId.HyperMutation,
                                     [kTechId.UpgradeSilenceVeil] = kTechId.Silence,
                                     [kTechId.UpgradeAuraVeil] = kTechId.Aura }
    
    local gainedResearch = checkForGainedResearch[researchId]
    if gainedResearch then
        SendTeamMessage(self, kTeamMessageTypes.ResearchComplete, gainedResearch)
    end
    
end

function AlienTeam:UpdateCloakables()

    for index, cloakableId in ipairs(self.cloakables) do
        local cloakable = Shared.GetEntity(cloakableId)
        cloakable:SetIsCloaked(true, 1, false)
    end
 
end

function AlienTeam:RegisterCloakable(cloakable)

    //Print("AlienTeam:RegisterCloakable(%s)", ToString(cloakable))

    local entityId = cloakable:GetId()

    if self.cloakableCloakCount[entityId] == nil then
        self.cloakableCloakCount[entityId] = 0
    end
    
    table.insertunique(self.cloakables, entityId)
    self.cloakableCloakCount[entityId] = self.cloakableCloakCount[entityId] + 1
    
    //Print("num shades: %s", ToString(self.cloakableCloakCount[entityId]))

end

function AlienTeam:DeregisterCloakable(cloakable)

    //Print("AlienTeam:DeregisterCloakable(%s)", ToString(cloakable))

    local entityId = cloakable:GetId()

    if self.cloakableCloakCount[entityId] == nil then
        self.cloakableCloakCount[entityId] = 0
    end
    
    self.cloakableCloakCount[entityId] = math.max(self.cloakableCloakCount[entityId] - 1, 0)
    if self.cloakableCloakCount[entityId] == 0 then
        table.removevalue(self.cloakables, entityId)
    end
    
    //Print("num shades: %s", ToString(self.cloakableCloakCount[entityId]))

end

function AlienTeam:UpdateCloakablesChanged(oldEntityId, newEntityId)

    // can happen at server/round startup
    if self.cloakables == nil then
        return
    end

    // simply remove from list, new entity will be added automatically by the trigger
    if oldEntityId then
        table.removevalue(self.cloakables, oldEntityId)    
        self.cloakableCloakCount[oldEntityId] = nil
    end

end

function AlienTeam:GetSpectatorMapName()
    return AlienSpectator.kMapName
end