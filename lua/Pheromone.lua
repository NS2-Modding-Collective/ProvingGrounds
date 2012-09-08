// ======= Copyright (c) 2003-2012, Unknown Worlds Entertainment, Inc. All rights reserved. =====
//
// lua\Pheromone.lua
//
// A way for the alien commander to communicate with his minions.
// 
// Goals
//   Create easy way for alien commander to communicate with his team without needing to click aliens and give orders. That wouldn’t fit.
//   Keep it feeling “bottom-up” so players can make their own choices
//   Have “orders” feel environmental
//
// First implementation
//   Create pheromones that act as a hive sight blip. Aliens can see pheromones like blips on their HUD. Examples: “Need healing”, “Need protection”, “Building here”, 
//   “Need infestation”, “Threat detected”, “Reinforce”. These are not orders, but informational. It’s up to aliens to decide what to do, if anything. 
//
//   Each time you create pheromones, it will create a new “signpost” at that location if there isn’t one nearby. Otherwise, if it is a new type, it will remove the 
//   old one and create the new one. If there is one of the same type nearby, it will intensify the current one to make it more important. In this way, each pheromone 
//   has an analog intensity which indicates the range at which it can be seen, as well as the alpha, font weight, etc. (how much it stands out to players).
//
//   Each time you click, a circle animates showing the new intensity (larger intensity shows a bigger circle). When creating pheromones, VAFX play slight gas sound and 
//   foggy bits pop out of the environment and coalesce, spinning, around the new sign post text.
//
//   When mousing over them, a “dismiss” button appears so the commander and manually delete them if no longer relevant. They also dissipate over time. Each level gives 
//   it x seconds of life.
// 
//   Pheromones are public property and have no owner. Any commander can dismiss, modify or grow any other pheromone cloud.
//
//   Show very faint/basic pheromone indicator to marines also. They have an idea that they are nearby, but don’t know what (perhaps just play faint sound when created, no visual).
//
//   Created by:   Charlie Cleveland (charlie@unknownworlds.com) 
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

class 'Pheromone' (Entity)

Pheromone.kMapName = "pheromone"
local kMaxLevel = 3
local kDistPerLevel = 15
local kLifetimePerLevel = 10
local kMaxPheromones = 5

local networkVars =
{
    // "Threat detected", "Reinforce", etc.
    type = "enum kTechId",
    
    // timestamp when to kill the pheromone
    untilTime = "time",
    
    // Level 1 - 5, indicating how widely to broadcast to nearby aliens and the "strength" to display it
    level = string.format("integer (1 to %d", kMaxLevel)
}

function Pheromone:OnCreate()

    Entity.OnCreate(self)
    
    self:SetPropagate(Entity.Propagate_Mask)
    self:UpdateRelevancy()
    
    self.type = kTechId.None
    self.lifetime = 0
    self.level = 1
    
    if Server then
        self:SetUpdates(true)
    end
    
end

function Pheromone:Initialize(techId)

    self.type = techId
    self.level = 1
    self.untilTime = Shared.GetTime() + kLifetimePerLevel
    
end

function Pheromone:GetType()
    return self.type
end

function Pheromone:GetBlipType()
    return kBlipType.Pheromone
end

function Pheromone:GetLevel()
    return self.level
end

function Pheromone:GetDisplayName()
    return GetDisplayNameForTechId(self.type, "<no pheromone name>")
end

function Pheromone:GetAppearDistance()
    return self.level * kDistPerLevel
end

function Pheromone:UpdateRelevancy()

    self:SetRelevancyDistance(self:GetAppearDistance())
    
    if self.teamNumber == 1 then
        self:SetIncludeRelevancyMask(kRelevantToTeam1)
    else
        self:SetIncludeRelevancyMask(kRelevantToTeam2)
    end
    
end

if Server then

    local function GetExistingPheromoneInRange(techId, position, teamNumber)
    
        local foundExistingPheromone = nil
        local nearestDist = math.huge
        
        local pheromones = GetEntitiesWithinRange("Pheromone", position, 5)
        for p = 1, #pheromones do
        
            local pheromone = pheromones[p]
            if pheromone:GetType() == techId then
            
                local dist = (position - pheromone:GetOrigin()):GetLength()
                if dist < nearestDist then
                
                    nearestDist = dist
                    foundExistingPheromone = pheromone
                    
                end
                
            end
            
        end
        
        return foundExistingPheromone
        
    end
    
    function CreatePheromone(techId, position, teamNumber)
    
        // Look for existing nearby pheromone with same type and increase the size of it
        local pheromone = GetExistingPheromoneInRange(techId, position, teamNumber)
        
        if pheromone then
            pheromone:Increase()
        else
        
            // Check if there are too many Pheromones in play already.
            local existingPheromones = Shared.GetEntitiesWithClassname("Pheromone")
            if existingPheromones:GetSize() >= kMaxPheromones then
            
                // Find the closest to self destruction.
                local closest = nil
                for p = 1, existingPheromones:GetSize() do
                
                    local current = existingPheromones:GetEntityAtIndex(p - 1)
                    if not closest or current.untilTime < closest.untilTime then
                        closest = current
                    end
                    
                end
                
                Server.DestroyEntity(closest)
                
            end
            
            // Otherwise create new one (hover off ground a little).
            pheromone = CreateEntity(Pheromone.kMapName, position + Vector(0, 0.5, 0), teamNumber)
            pheromone:Initialize(techId)
            
        end
        
        return pheromone
        
    end
    
    function Pheromone:Increase()
    
        // Don't increase if we're already the biggest we can be
        if self.level < kMaxLevel then
        
            self.level = self.level + 1
            self.untilTime = self.untilTime + kLifetimePerLevel
            
        end
        
    end
    
    function Pheromone:OnUpdate(timePassed)
    
        // Expire pheromones after a time
        if self.untilTime <= Shared.GetTime() then
            DestroyEntity(self)
        end
        
    end
    
end

Shared.LinkClassToMap("Pheromone", Pheromone.kMapName, networkVars)