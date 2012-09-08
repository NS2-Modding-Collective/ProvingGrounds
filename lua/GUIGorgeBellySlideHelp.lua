// ======= Copyright (c) 2012, Unknown Worlds Entertainment, Inc. All rights reserved. ==========
//
// lua\GUIGorgeBellySlideHelp.lua
//
// Created by: Brian Cronin (brianc@unknownworlds.com)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

local kBellyTextureName = "ui/gorge_slide.dds"

local kIconHeight = 128
local kIconWidth = 128
local kBackgroundYOffset = -120

class 'GUIGorgeBellySlideHelp' (GUIScript)

function GUIGorgeBellySlideHelp:Initialize()

    self.keyBackground = GUICreateButtonIcon("MovementModifier")
    self.keyBackground:SetAnchor(GUIItem.Middle, GUIItem.Bottom)
    local size = self.keyBackground:GetSize()
    self.keyBackground:SetPosition(Vector(-size.x / 2, -size.y + kBackgroundYOffset, 0))
    self.keyBackground:SetIsVisible(false)
    
    self.bellySlideImage = GUIManager:CreateGraphicItem()
    self.bellySlideImage:SetAnchor(GUIItem.Middle, GUIItem.Top)
    self.bellySlideImage:SetSize(Vector(kIconWidth, kIconHeight, 0))
    self.bellySlideImage:SetPosition(Vector(-kIconWidth / 2, -kIconHeight, 0))
    self.bellySlideImage:SetTexture(kBellyTextureName)
    self.keyBackground:AddChild(self.bellySlideImage)
    
end

function GUIGorgeBellySlideHelp:Update(dt)

    self.keyBackground:SetIsVisible(false)
    
    local player = Client.GetLocalPlayer()
    if not self.bellySlideUsed and player then
    
        if player:GetVelocity():GetLength() > 1 then
        
            self.keyBackground:SetIsVisible(true)
            if player:GetIsBellySliding() then
            
                self.bellySlideUsed = true
                Client.SetOptionInteger("help/guigorgebellyslidehelp", Client.GetOptionInteger("help/guigorgebellyslidehelp", 0) + 1)
                
            end
            
        end
        
    end
    
end

function GUIGorgeBellySlideHelp:Uninitialize()

    GUI.DestroyItem(self.keyBackground)
    self.keyBackground = nil
    
end