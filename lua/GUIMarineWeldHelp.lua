// ======= Copyright (c) 2012, Unknown Worlds Entertainment, Inc. All rights reserved. ==========
//
// lua\GUIMarineWeldHelp.lua
//
// Created by: Brian Cronin (brianc@unknownworlds.com)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

local kWelderTextureName = "ui/marine_welder.dds"

local kIconHeight = 128
local kIconWidth = 128
local kBackgroundYOffset = -120

class 'GUIMarineWeldHelp' (GUIScript)

function GUIMarineWeldHelp:Initialize()

    self.keyBackground = GUICreateButtonIcon("Weapon" .. kWelderHUDSlot)
    self.keyBackground:SetAnchor(GUIItem.Middle, GUIItem.Bottom)
    local size = self.keyBackground:GetSize()
    self.keyBackground:SetPosition(Vector(-size.x / 2, -size.y + kBackgroundYOffset, 0))
    self.keyBackground:SetIsVisible(false)
    
    self.welderImage = GUIManager:CreateGraphicItem()
    self.welderImage:SetAnchor(GUIItem.Middle, GUIItem.Top)
    self.welderImage:SetSize(Vector(kIconWidth, kIconHeight, 0))
    self.welderImage:SetPosition(Vector(-kIconWidth / 2, -kIconHeight, 0))
    self.welderImage:SetTexture(kWelderTextureName)
    self.keyBackground:AddChild(self.welderImage)
    
end

function GUIMarineWeldHelp:Update(dt)

    if not self.welderUsed then
    
        local currentOrderType = PlayerUI_GetCurrentOrderType()
        if currentOrderType == kTechId.Weld or currentOrderType == kTechId.AutoWeld then
        
            self.keyBackground:SetIsVisible(true)
            local player = Client.GetLocalPlayer()
            if player then
            
                if player:GetActiveWeapon():isa("Welder") then
                
                    self.keyBackground:SetIsVisible(false)
                    self.welderUsed = true
                    Client.SetOptionInteger("help/guimarineweldhelp", Client.GetOptionInteger("help/guimarineweldhelp", 0) + 1)
                    
                end
                
            end
            
        end
        
    end
    
end

function GUIMarineWeldHelp:Uninitialize()

    GUI.DestroyItem(self.keyBackground)
    self.keyBackground = nil
    
end