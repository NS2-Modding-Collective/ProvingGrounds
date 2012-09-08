// ======= Copyright (c) 2012, Unknown Worlds Entertainment, Inc. All rights reserved. ==========
//
// lua\GUILerkFlapHelp.lua
//
// Created by: Brian Cronin (brianc@unknownworlds.com)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

local kFlapFrames = { "ui/lerk_fly1.dds", "ui/lerk_fly2.dds" }
local kFlapFrameWidth = 128
local kFlapFrameHeight = 128
local kFlapSpeed = 0.5

local kTimeNeededToLearnToFly = 8

local kBackgroundYOffset = -120

class 'GUILerkFlapHelp' (GUIScript)

function GUILerkFlapHelp:Initialize()

    self.keyBackground = GUICreateButtonIcon("Jump")
    self.keyBackground:SetAnchor(GUIItem.Middle, GUIItem.Bottom)
    local size = self.keyBackground:GetSize()
    self.keyBackground:SetPosition(Vector(-size.x / 2, -size.y + kBackgroundYOffset, 0))
    
    self.currentFlapFrame = 1
    self.flapImage = GUIManager:CreateGraphicItem()
    self.flapImage:SetAnchor(GUIItem.Middle, GUIItem.Top)
    self.flapImage:SetSize(Vector(kFlapFrameWidth, kFlapFrameHeight, 0))
    self.flapImage:SetPosition(Vector(-kFlapFrameWidth / 2, -kFlapFrameHeight, 0))
    self.flapImage:SetTexture(kFlapFrames[self.currentFlapFrame])
    self.keyBackground:AddChild(self.flapImage)
    
end

function GUILerkFlapHelp:Update(dt)

    self.timePassed = self.timePassed or 0
    self.timePassed = self.timePassed + dt
    
    if self.timePassed >= kFlapSpeed then
    
        self.timePassed = 0
        self.currentFlapFrame = self.currentFlapFrame + 1
        self.flapImage:SetTexture(kFlapFrames[(self.currentFlapFrame % #kFlapFrames) + 1])
        
    end
    
    local player = Client.GetLocalPlayer()
    if player then
    
        self.totalAirTime = self.totalAirTime or 0
        self.totalAirTime = player:GetIsOnGround() and self.totalAirTime or self.totalAirTime + dt
        self.keyBackground:SetIsVisible(player:GetIsOnGround() and self.totalAirTime < kTimeNeededToLearnToFly)
        
        if not self.learnedToFly and self.totalAirTime >= kTimeNeededToLearnToFly then
        
            self.learnedToFly = true
            Client.SetOptionInteger("help/guilerkflaphelp", Client.GetOptionInteger("help/guilerkflaphelp", 0) + 1)
            
        end
        
    end
    
end

function GUILerkFlapHelp:Uninitialize()

    GUI.DestroyItem(self.keyBackground)
    self.keyBackground = nil
    
end