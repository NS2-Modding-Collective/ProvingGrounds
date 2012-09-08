// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\InfestationSpike.lua
//
// Created by: Andreas Urwalek (a_urwa@sbox.tugraz.at)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/CommAbilities/CommanderAbility.lua")
Script.Load("lua/Mixins/ModelMixin.lua")

class 'InfestationSpike' (CommanderAbility)

InfestationSpike.kMapName = "infestationspike"

InfestationSpike.kModelName = PrecacheAsset("models/alien/infestationspike/infestationspike.model")

InfestationSpike.kType = CommanderAbility.kType.OverTime
InfestationSpike.kLifeSpan = 5
InfestationSpike.kDelay = 0

InfestationSpike.kMoveOffset = 4
InfestationSpike.kMoveDuration = 0.4

local networkVars =
{
    spawnPoint = "vector"
}

AddMixinNetworkVars(BaseModelMixin, networkVars)
AddMixinNetworkVars(ModelMixin, networkVars)

function AlignInfestationSpikes(coords)

    local nearbyMarines = GetEntitiesWithinRange("Marine", coords.origin, 20)
    Shared.SortEntitiesByDistance(coords.origin, nearbyMarines)

    for _, marine in ipairs(nearbyMarines) do
    
        if marine:GetIsAlive() and marine:GetIsVisible() then

            local newZAxis = GetNormalizedVectorXZ(marine:GetOrigin() - coords.origin)
            local newXAxis = coords.yAxis:CrossProduct(newZAxis)
            coords.zAxis = newZAxis
            coords.xAxis = newXAxis
            break
        
        end
    
    end
    
    return coords

end

function InfestationSpike:OnCreate()

    CommanderAbility.OnCreate(self)
    
    InitMixin(self, BaseModelMixin)
    InitMixin(self, ModelMixin)

end

function InfestationSpike:OnInitialized()

    CommanderAbility.OnInitialized(self)
    
    self.spawnPoint = self:GetOrigin() - Vector(0,InfestationSpike.kMoveOffset, 0)
    self:SetOrigin(self.spawnPoint)
    self:SetModel(InfestationSpike.kModelName)
    
    if Server then
        self:TriggerEffects("infestation_spike_burst")
    end
    
    // Make the structure kinematic so that the player will collide with it.
    self:SetPhysicsType(PhysicsType.Kinematic)

end

function InfestationSpike:GetType()
    return InfestationSpike.kType
end

function InfestationSpike:GetLifeSpan()
    return InfestationSpike.kLifeSpan + InfestationSpike.kDelay
end

function InfestationSpike:OnUpdate(deltaTime)

    CommanderAbility.OnUpdate(self, deltaTime)
    
    local lifeTime = math.max(0, Shared.GetTime() - self:GetTimeCreated() - InfestationSpike.kDelay)
    local remainingTime = InfestationSpike.kLifeSpan - lifeTime
    
    if remainingTime < InfestationSpike.kLifeSpan then
        
        local moveFraction = 0

        if remainingTime <= 1 then
            moveFraction = Clamp(remainingTime / InfestationSpike.kMoveDuration, 0, 1)
        else
            moveFraction = Clamp(lifeTime / InfestationSpike.kMoveDuration, 0, 1)
        end    
        
        local piFraction = moveFraction * (math.pi / 2)

        self:SetOrigin(self.spawnPoint + Vector(0, math.sin(piFraction) * InfestationSpike.kMoveOffset, 0))
    
    end

end

function InfestationSpike:GetCanBeUsed(player, useSuccessTable)
    useSuccessTable.useSuccess = false    
end

Shared.LinkClassToMap("InfestationSpike", InfestationSpike.kMapName, networkVars)