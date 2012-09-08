// ======= Copyright (c) 2012, Unknown Worlds Entertainment, Inc. All rights reserved. ==========
//
// lua\GUIMarineJetpackHelp.lua
//
// Created by: Brian Cronin (brianc@unknownworlds.com)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

local kJetpackImage = "ui/marine_jetpack.dds"
local kJetpackFrameWidth = 128
local kJetpackFrameHeight = 128

local kTimeNeededToLearnToFly = 6

local kBackgroundYOffset = -120

class 'GUIMarineJetpackHelp' (GUIScript)

function GUIMarineJetpackHelp:Initialize()

    self.keyBackground = GUICreateButtonIcon("Jump")
    self.keyBackground:SetAnchor(GUIItem.Middle, GUIItem.Bottom)
    local size = self.keyBackground:GetSize()
    self.keyBackground:SetPosition(Vector(-size.x / 2, -size.y + kBackgroundYOffset, 0))
    
    self.jetpackImage = GUIManager:CreateGraphicItem()
    self.jetpackImage:SetAnchor(GUIItem.Middle, GUIItem.Top)
    self.jetpackImage:SetSize(Vector(kJetpackFrameWidth, kJetpackFrameHeight, 0))
    self.jetpackImage:SetPosition(Vector(-kJetpackFrameWidth / 2, -kJetpackFrameHeight, 0))
    self.jetpackImage:SetTexture(kJetpackImage)
    self.keyBackground:AddChild(self.jetpackImage)
    
end

function GUIMarineJetpackHelp:Update(dt)

    local player = Client.GetLocalPlayer()
    if player then
    
        self.totalAirTime = self.totalAirTime or 0
        self.totalAirTime = player:GetIsOnGround() and self.totalAirTime or self.totalAirTime + dt
        self.keyBackground:SetIsVisible(player:GetIsOnGround() and self.totalAirTime < kTimeNeededToLearnToFly)
        
        if not self.learnedToFly and self.totalAirTime >= kTimeNeededToLearnToFly then
        
            self.learnedToFly = true
            Client.SetOptionInteger("help/guimarinejetpackhelp", Client.GetOptionInteger("help/guimarinejetpackhelp", 0) + 1)
            
        end
        
    end
    
end

function GUIMarineJetpackHelp:Uninitialize()

    GUI.DestroyItem(self.keyBackground)
    self.keyBackground = nil
    
end