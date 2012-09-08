// ======= Copyright (c) 2012, Unknown Worlds Entertainment, Inc. All rights reserved. ==========
//
// lua\GUIMapHelp.lua
//
// Created by: Brian Cronin (brianc@unknownworlds.com)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

local kMapTextureNames = { "ui/marine_map.dds", "ui/alien_map.dds" }

local kIconHeight = 128
local kIconWidth = 128
local kBackgroundYOffset = -120

class 'GUIMapHelp' (GUIScript)

function GUIMapHelp:Initialize()

    self.keyBackground = GUICreateButtonIcon("ShowMap")
    self.keyBackground:SetAnchor(GUIItem.Middle, GUIItem.Bottom)
    local size = self.keyBackground:GetSize()
    self.keyBackground:SetPosition(Vector(-size.x / 2, -size.y + kBackgroundYOffset, 0))
    
    self.mapImage = GUIManager:CreateGraphicItem()
    self.mapImage:SetAnchor(GUIItem.Middle, GUIItem.Top)
    self.mapImage:SetSize(Vector(kIconWidth, kIconHeight, 0))
    self.mapImage:SetPosition(Vector(-kIconWidth / 2, -kIconHeight, 0))
    self.mapImage:SetTexture(kMapTextureNames[1])
    self.keyBackground:AddChild(self.mapImage)
    
end

function GUIMapHelp:Update(dt)

    local player = Client.GetLocalPlayer()
    if player then
    
        if player:GetTeamType() == kAlienTeamType then
            self.mapImage:SetTexture(kMapTextureNames[2])
        else
            self.mapImage:SetTexture(kMapTextureNames[1])
        end
        
        if not self.mapSeen and player:GetIsMinimapVisible() then
        
            self.keyBackground:SetIsVisible(false)
            self.mapSeen = true
            Client.SetOptionInteger("help/guimaphelp", Client.GetOptionInteger("help/guimaphelp", 0) + 1)
            
        end
        
    end
    
end

function GUIMapHelp:Uninitialize()

    GUI.DestroyItem(self.keyBackground)
    self.keyBackground = nil
    
end