// ======= Copyright (c) 2012, Unknown Worlds Entertainment, Inc. All rights reserved. ==========
//
// lua\GUIMarineHealthRequestHelp.lua
//
// Created by: Charlie Cleveland (charlie@unknownworlds.com)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

local kRequestHealthImage = "ui/marine_health_call.dds"
local kRequestHealthFrameWidth = 128
local kRequestHealthFrameHeight = 128

local kBackgroundYOffset = -120

class 'GUIMarineHealthRequestHelp' (GUIScript)

function GUIMarineHealthRequestHelp:Initialize()

    self.keyBackground = GUICreateButtonIcon("Taunt")
    self.keyBackground:SetAnchor(GUIItem.Middle, GUIItem.Bottom)
    local size = self.keyBackground:GetSize()
    self.keyBackground:SetPosition(Vector(-size.x / 2, -size.y + kBackgroundYOffset, 0))
    
    self.requestHealthImage = GUIManager:CreateGraphicItem()
    self.requestHealthImage:SetAnchor(GUIItem.Middle, GUIItem.Top)
    self.requestHealthImage:SetSize(Vector(kRequestHealthFrameWidth, kRequestHealthFrameHeight, 0))
    self.requestHealthImage:SetPosition(Vector(-kRequestHealthFrameWidth / 2, -kRequestHealthFrameHeight, 0))
    self.requestHealthImage:SetTexture(kRequestHealthImage)
    self.keyBackground:AddChild(self.requestHealthImage)
    
end

function GUIMarineHealthRequestHelp:Update(dt)

    local player = Client.GetLocalPlayer()
    if player then

        assert(HasMixin(player, "Live"))
        
        local needsMedpack = (player:GetHealth() <= 50)        

        local newVisibility = needsMedpack and (player.timeOfLastTaunt == nil or (Shared.GetTime() > player.timeOfLastTaunt + 20) )

        if self.keyBackground:GetIsVisible() and (newVisibility == false) then
            Client.SetOptionInteger("help/guimarinehealthrequesthelp", Client.GetOptionInteger("help/guimarinehealthrequesthelp", 0) + 1)
        end
        
        self.keyBackground:SetIsVisible(newVisibility)
        
    end
    
end

function GUIMarineHealthRequestHelp:Uninitialize()

    GUI.DestroyItem(self.keyBackground)
    self.keyBackground = nil
    
end