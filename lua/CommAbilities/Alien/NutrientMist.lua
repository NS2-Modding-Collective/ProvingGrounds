// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\NutrientMist.lua
//
// Created by: Andreas Urwalek (andi@unknownworlds.com)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/CommAbilities/CommanderAbility.lua")

class 'NutrientMist' (CommanderAbility)

NutrientMist.kMapName = "NutrientMist"

NutrientMist.kNutrientMistEffect = PrecacheAsset("cinematics/alien/hive/hive_catalyst.cinematic")

NutrientMist.kType = CommanderAbility.kType.Instant
NutrientMist.kSearchRange = 5
NutrientMist.kDuration = kNutrientMistDuration

local networkVars = { }

function NutrientMist:Perform()

    self.success = false

    local entities = GetEntitiesWithMixinForTeamWithinRange("Catalyst", self:GetTeamNumber(), self:GetOrigin(), NutrientMist.kSearchRange)
    
    local CheckFunc = function(entity)
        return entity:GetCanCatalyst()
    end
    
    local closest = self:GetClosestFromTable(entities, CheckFunc)
    
    if closest then
        closest:TriggerCatalyst(NutrientMist.kDuration)
        self.success = true
    end
    
end

function NutrientMist:GetStartCinematic()
    return NutrientMist.kNutrientMistEffect
end

function NutrientMist:GetType()
    return NutrientMist.kType
end

function NutrientMist:GetThinkTime()
    return 1.5
end 

function NutrientMist:GetLifeSpan()
    return NutrientMist.kDuration
end

function NutrientMist:GetWasSuccess()
    return self.success
end

function GetIsCatalystAble(entity)
    return entity and HasMixin(entity, "Catalyst") and entity:GetCanCatalyst()
end

Shared.LinkClassToMap("NutrientMist", NutrientMist.kMapName, networkVars)