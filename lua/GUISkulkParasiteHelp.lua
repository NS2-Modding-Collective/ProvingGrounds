// ======= Copyright (c) 2012, Unknown Worlds Entertainment, Inc. All rights reserved. ==========
//
// lua\GUISkulkParasiteHelp.lua
//
// Created by: Brian Cronin (brianc@unknownworlds.com)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

local kParasiteTextureName = "ui/parasite.dds"

local kIconHeight = 128
local kIconWidth = 128
local kBackgroundYOffset = -120

class 'GUISkulkParasiteHelp' (GUIScript)

function GUISkulkParasiteHelp:Initialize()

    self.keyBackground = GUICreateButtonIcon("Weapon" .. kParasiteHUDSlot)
    self.keyBackground:SetAnchor(GUIItem.Middle, GUIItem.Bottom)
    local size = self.keyBackground:GetSize()
    self.keyBackground:SetPosition(Vector(-size.x / 2, -size.y + kBackgroundYOffset, 0))
    
    self.attackKeyBackground = GUICreateButtonIcon("PrimaryAttack")
    self.attackKeyBackground:SetAnchor(GUIItem.Middle, GUIItem.Bottom)
    size = self.attackKeyBackground:GetSize()
    self.attackKeyBackground:SetPosition(Vector(-size.x / 2, -size.y + kBackgroundYOffset, 0))
    self.attackKeyBackground:SetIsVisible(false)
    
    self.parasiteImage = GUIManager:CreateGraphicItem()
    self.parasiteImage:SetAnchor(GUIItem.Middle, GUIItem.Bottom)
    self.parasiteImage:SetSize(Vector(kIconWidth, kIconHeight, 0))
    self.parasiteImage:SetPosition(Vector(-kIconWidth / 2, -kIconHeight + kBackgroundYOffset - size.y, 0))
    self.parasiteImage:SetTexture(kParasiteTextureName)
    
end

function GUISkulkParasiteHelp:Update(dt)

    self.keyBackground:SetIsVisible(false)
    self.attackKeyBackground:SetIsVisible(false)
    self.parasiteImage:SetIsVisible(false)
    
    if not self.parasiteUsed then
    
        local player = Client.GetLocalPlayer()
        if player then
        
            // Show the switch weapon key until they change to the parasite.
            local parasiteEquipped = player:GetActiveWeapon() and player:GetActiveWeapon():isa("Parasite")
            self.parasiteImage:SetIsVisible(true)
            self.keyBackground:SetIsVisible(parasiteEquipped ~= true)
            self.attackKeyBackground:SetIsVisible(parasiteEquipped == true)
            if parasiteEquipped and player:GetPrimaryAttackLastFrame() then
            
                self.keyBackground:SetIsVisible(false)
                self.attackKeyBackground:SetIsVisible(false)
                self.parasiteImage:SetIsVisible(false)
                self.parasiteUsed = true
                Client.SetOptionInteger("help/guiskulkparasitehelp", Client.GetOptionInteger("help/guiskulkparasitehelp", 0) + 1)
                
            end
            
        end
        
    end
    
end

function GUISkulkParasiteHelp:Uninitialize()

    GUI.DestroyItem(self.keyBackground)
    self.keyBackground = nil
    
    GUI.DestroyItem(self.attackKeyBackground)
    self.attackKeyBackground = nil
    
    GUI.DestroyItem(self.parasiteImage)
    self.parasiteImage = nil
    
end