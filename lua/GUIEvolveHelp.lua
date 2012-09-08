// ======= Copyright (c) 2012, Unknown Worlds Entertainment, Inc. All rights reserved. ==========
//
// lua\GUIEvolveHelp.lua
//
// Created by: Brian Cronin (brianc@unknownworlds.com)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

local kEvolveGraphic = "ui/alien_evolution.dds"
local kWidth = 128
local kHeight = 128

local kBackgroundYOffset = -120

class 'GUIEvolveHelp' (GUIScript)

function GUIEvolveHelp:Initialize()

    self.keyBackground = GUICreateButtonIcon("Buy")
    self.keyBackground:SetAnchor(GUIItem.Middle, GUIItem.Bottom)
    local size = self.keyBackground:GetSize()
    self.keyBackground:SetPosition(Vector(-size.x / 2, -size.y + kBackgroundYOffset, 0))
    self.keyBackground:SetIsVisible(false)
    
    self.currentFlapFrame = 1
    local evolveGraphic = GUIManager:CreateGraphicItem()
    evolveGraphic:SetAnchor(GUIItem.Middle, GUIItem.Top)
    evolveGraphic:SetSize(Vector(kWidth, kHeight, 0))
    evolveGraphic:SetPosition(Vector(-kWidth / 2, -kHeight, 0))
    evolveGraphic:SetTexture(kEvolveGraphic)
    self.keyBackground:AddChild(evolveGraphic)
    
end

function GUIEvolveHelp:Update(dt)

    local helpVisible = false
    local player = Client.GetLocalPlayer()
    if player then
    
        if not self.learnedToEvolve and player:GetGameStarted() then
        
            local nearHive = #GetEntitiesForTeamWithinRange("Hive", player:GetTeamNumber(), player:GetOrigin(), 10) > 0
            local nearbyUnitsUnderAttack = GetAnyNearbyUnitsInCombat(player:GetOrigin(), 20, player:GetTeamNumber())
            if nearHive and not nearbyUnitsUnderAttack and player:GetIsOnGround() then
            
                if player:GetBuyMenuIsDisplaying() then
                
                    self.learnedToEvolve = true
                    Client.SetOptionInteger("help/guievolvehelp", Client.GetOptionInteger("help/guievolvehelp", 0) + 1)
                    
                else
                    helpVisible = true
                end
                
            end
            
        end
        
    end
    
    self.keyBackground:SetIsVisible(helpVisible)
    
end

function GUIEvolveHelp:Uninitialize()

    GUI.DestroyItem(self.keyBackground)
    self.keyBackground = nil
    
end