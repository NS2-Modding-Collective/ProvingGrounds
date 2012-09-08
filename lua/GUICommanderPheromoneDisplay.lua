// ======= Copyright (c) 2012, Unknown Worlds Entertainment, Inc. All rights reserved. ==========
//
// lua\GUICommanderPheromoneDisplay.lua
//
// Created by: Brian Cronin (brianc@unknownworlds.com)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

local kTextureName = "ui/alien_order.dds"
local kOrderPixelWidth = 128
local kOrderPixelHeight = 128
local kBaseScale = 0.2

local kPheromoneTextureCoords = { }
kPheromoneTextureCoords[kTechId.ThreatMarker] = { 0, 0, kOrderPixelWidth, kOrderPixelHeight }
kPheromoneTextureCoords[kTechId.LargeThreatMarker] = { 0, 0, kOrderPixelWidth, kOrderPixelHeight }
kPheromoneTextureCoords[kTechId.NeedHealingMarker] = { kOrderPixelWidth * 4, 0, kOrderPixelWidth * 5, kOrderPixelHeight }
kPheromoneTextureCoords[kTechId.WeakMarker] = { kOrderPixelWidth * 4, 0, kOrderPixelWidth * 5, kOrderPixelHeight }
kPheromoneTextureCoords[kTechId.ExpandingMarker] = { kOrderPixelWidth, 0, kOrderPixelWidth * 2, kOrderPixelHeight }

class 'GUICommanderPheromoneDisplay' (GUIScript)

function GUICommanderPheromoneDisplay:Initialize()
    self.pheromoneUIs = table.array(10)
end

function GUICommanderPheromoneDisplay:Uninitialize()

    for p = 1, #self.pheromoneUIs do
        GUI.DestroyItem(self.pheromoneUIs[p])
    end
    self.pheromoneUIs = table.array(10)
    
end

local function FreeAllPheromoneUIs(self)

    for p = 1, #self.pheromoneUIs do
        self.pheromoneUIs[p]:SetIsVisible(false)
    end
    
end

local function GetFreePheromoneUI(self)

    for p = 1, #self.pheromoneUIs do
    
        local currentUI = self.pheromoneUIs[p]
        if not currentUI:GetIsVisible() then
        
            currentUI:SetIsVisible(true)
            return currentUI
            
        end
        
    end
    
    local newUI = GUIManager:CreateGraphicItem()
    newUI:SetAnchor(GUIItem.Left, GUIItem.Top)
    newUI:SetColor(Color(1, 1, 1, 1))
    newUI:SetBlendTechnique(GUIItem.Add)
    newUI:SetTexture(kTextureName)
    table.insert(self.pheromoneUIs, newUI)
    return newUI
    
end

function GUICommanderPheromoneDisplay:Update(deltaTime)

    FreeAllPheromoneUIs(self)
    
    local pheromones = CommanderUI_GetPheromones()
    for p = 1, #pheromones do
    
        local currentPheromone = pheromones[p]
        local ui = GetFreePheromoneUI(self)
        ui:SetTexturePixelCoordinates(unpack(kPheromoneTextureCoords[currentPheromone:GetType()]))
        local size = Vector(kOrderPixelWidth, kOrderPixelHeight, 0) * (kBaseScale + (0.05 * (currentPheromone:GetLevel() - 1)))
        ui:SetSize(size)
        ui:SetPosition(Client.WorldToScreen(currentPheromone:GetOrigin()) - size / 2)
        ui:SetColor(Color(1, 1, 1, 0.5 + (0.1 * (currentPheromone:GetLevel() - 1))))
        
    end
    
end