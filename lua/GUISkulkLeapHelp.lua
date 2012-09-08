// ======= Copyright (c) 2012, Unknown Worlds Entertainment, Inc. All rights reserved. ==========
//
// lua\GUISkulkLeapHelp.lua
//
// Created by: Brian Cronin (brianc@unknownworlds.com)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

local kLeapTextureName = "ui/skulk_jump.dds"

local kIconWidth = 128
local kIconHeight = 128
local kBackgroundYOffset = -120

class 'GUISkulkLeapHelp' (GUIScript)

function GUISkulkLeapHelp:Initialize()

    self.keyBackground = GUICreateButtonIcon("SecondaryAttack")
    self.keyBackground:SetAnchor(GUIItem.Middle, GUIItem.Bottom)
    local size = self.keyBackground:GetSize()
    self.keyBackground:SetPosition(Vector(-size.x / 2, -size.y + kBackgroundYOffset, 0))
    
    self.leapImage = GUIManager:CreateGraphicItem()
    self.leapImage:SetAnchor(GUIItem.Middle, GUIItem.Top)
    self.leapImage:SetSize(Vector(kIconWidth, kIconHeight, 0))
    self.leapImage:SetPosition(Vector(-kIconWidth / 2, -kIconHeight, 0))
    self.leapImage:SetTexture(kLeapTextureName)
    self.keyBackground:AddChild(self.leapImage)
    
end

function GUISkulkLeapHelp:Update(dt)

    self.keyBackground:SetIsVisible(false)
    
    local player = Client.GetLocalPlayer()
    if player then
    
        if not self.leaped and player:GetIsLeaping() then
        
            self.leaped = true
            Client.SetOptionInteger("help/guiskulkleaphelp", Client.GetOptionInteger("help/guiskulkleaphelp", 0) + 1)
            
        end
        
        local activeWeapon = player:GetActiveWeapon()
        if not self.leaped and activeWeapon and activeWeapon:GetHasSecondary(player) then
            self.keyBackground:SetIsVisible(true)
        end
        
    end
    
end

function GUISkulkLeapHelp:Uninitialize()

    GUI.DestroyItem(self.keyBackground)
    self.keyBackground = nil
    
end