// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\TechTree_Server.lua
//
//    Created by:   Charlie Cleveland (charlie@unknownworlds.com) and
//                  Max McGuire (max@unknownworlds.com)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

// Send the entirety of every the tech node on team change or join. Returns true if it sent anything
function TechTree:SendTechTreeBase(player)

    local sent = false
    
    if self.complete then
    
        // Tell client to empty tech tree before adding new nodes. Send reliably
        // so players are always able to buy weapons, use commander mode, etc.
        Server.SendNetworkMessage(player, "ClearTechTree", {}, true)
    
        for index, techNode in pairs(self.nodeList) do
        
            Server.SendNetworkMessage(player, "TechNodeBase", BuildTechNodeBaseMessage(techNode), true)
            
            sent = true
        
        end
        
    end
    
    return sent
    
end

function TechTree:AddBuyNode(techId, prereq1, prereq2, addOnTechId)

    local techNode = TechNode()
    
    techNode:Initialize(techId, kTechType.Buy, prereq1, prereq2)
    
    if addOnTechId ~= nil then
        techNode.addOnTechId = addOnTechId
    end
    
    self:AddNode(techNode)    
    
end

function TechTree:AddTargetedBuyNode(techId, prereq1, prereq2, addOnTechId)

    local techNode = TechNode()
    
    techNode:Initialize(techId, kTechType.Buy, prereq1, prereq2)
    
    if addOnTechId ~= nil then
        techNode.addOnTechId = addOnTechId
    end
    
    techNode.requiresTarget = true        
    
    self:AddNode(techNode)    

end



function TechTree:AddAction(techId, prereq1, prereq2)

    local techNode = TechNode()

    techNode:Initialize(techId, kTechType.Action, prereq1, prereq2)
    
    self:AddNode(techNode)  

end

function TechTree:AddTargetedAction(techId, prereq1, prereq2)

    local techNode = TechNode()

    techNode:Initialize(techId, kTechType.Action, prereq1, prereq2)
    techNode.requiresTarget = true        
    
    self:AddNode(techNode)
    
end


function TechTree:AddSpecial(techId, requiresTarget)

    local techNode = TechNode()
    
    techNode:Initialize(techId, kTechType.Special, kTechId.None, kTechId.None)
    techNode.requiresTarget = ConditionalValue(requiresTarget, true, false)
    
    self:AddNode(techNode)  

end

function TechTree:AddPassive(techId)

    local techNode = TechNode()
    
    techNode:Initialize(techId, kTechType.Passive, kTechId.None, kTechId.None)
    techNode.requiresTarget = false
    
    self:AddNode(techNode)  

end

// Pre-compute stuff
function TechTree:SetComplete(complete)

    if not self.complete then
        
        self:ComputeUpgradedTechIdsSupporting()
        
        self.complete = true
        
    end
    
end

function TechTree:SetTeamNumber(teamNumber)
    self.teamNumber = teamNumber
end

function TechTree:GiveUpgrade(techId)

    local node = self:GetTechNode(techId)
    if(node ~= nil) then
    
        if(node:GetIsResearch()) then
        
            local newResearchState = not node.researched
            node:SetResearched(newResearchState)
            
            self:SetTechNodeChanged(node, string.format("researched: %s", ToString(newResearchState)))

            if(newResearchState) then
            
                self:QueueOnResearchComplete(techId)
                
            end
            
            return true

        end
        
    else
        Print("TechTree:GiveUpgrade(%d): Couldn't lookup tech node.", techId)
    end
    
    return false
    
end

function TechTree:AddSupportingTechId(techId, idList)

    if self.upgradedTechIdsSupporting == nil then
        self.upgradedTechIdsSupporting = {}
    end
    
    if table.maxn(idList) > 0 then    
        table.insert(self.upgradedTechIdsSupporting, {techId, idList})        
    end
    
end

function TechTree:ComputeUpgradedTechIdsSupporting()

    self.upgradedTechIdsSupporting = {}
    
    for index, techId in pairs(kTechId) do
    
        local idList = self:ComputeUpgradedTechIdsSupportingId(techId)
        self:AddSupportingTechId(techId, idList)
        
    end
    
end


function TechTree:GetTechSpecial(techId)
    return false
end



// Utility functions
function GetHasTech(callingEntity, techId, silenceError)

    if callingEntity ~= nil and HasMixin(callingEntity, "Team") then
    
        local team = GetGamerules():GetTeam(callingEntity:GetTeamNumber())
        
        if team ~= nil and team:isa("PlayingTeam") then
        
            local techTree = team:GetTechTree()
            
            if techTree ~= nil then
                return techTree:GetHasTech(techId, silenceError)
            end
            
        end
        
    end
    
    return false
    
end
