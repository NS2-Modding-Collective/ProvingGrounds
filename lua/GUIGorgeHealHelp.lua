// ======= Copyright (c) 2012, Unknown Worlds Entertainment, Inc. All rights reserved. ==========
//
// lua\GUIGorgeHealHelp.lua
//
// Created by: Brian Cronin (brianc@unknownworlds.com)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

local kLeapTextureName = "ui/gorge_spit.dds"

local kIconWidth = 128
local kIconHeight = 128
local kBackgroundYOffset = -120

class 'GUIGorgeHealHelp' (GUIScript)

function GUIGorgeHealHelp:Initialize()

    self.keyBackground = GUICreateButtonIcon("SecondaryAttack")
    self.keyBackground:SetAnchor(GUIItem.Middle, GUIItem.Bottom)
    local size = self.keyBackground:GetSize()
    self.keyBackground:SetPosition(Vector(-size.x / 2, -size.y + kBackgroundYOffset, 0))
    
    self.healImage = GUIManager:CreateGraphicItem()
    self.healImage:SetAnchor(GUIItem.Middle, GUIItem.Top)
    self.healImage:SetSize(Vector(kIconWidth, kIconHeight, 0))
    self.healImage:SetPosition(Vector(-kIconWidth / 2, -kIconHeight, 0))
    self.healImage:SetTexture(kLeapTextureName)
    self.keyBackground:AddChild(self.healImage)
    
end

local function WeaponSupportsHeal(weapon)
    return weapon and HasMixin(weapon, "HealSpray")
end

local function GetHealingRequired(player)

    local status = PlayerUI_GetUnitStatusInfo()
    
    for s = 1, #status do
    
        local unitStatus = status[s].Status
        // Needs to be healable or buildable and within heal range.
        if (unitStatus == kUnitStatus.Damaged or unitStatus == kUnitStatus.Unbuilt) and
           (status[s].WorldOrigin - player:GetEyePos()):GetLengthSquared() <= (kHealsprayRadius * kHealsprayRadius) then
            return true
        end
        
    end
    
    return false
    
end

function GUIGorgeHealHelp:Update(dt)

    self.keyBackground:SetIsVisible(false)
    
    local player = Client.GetLocalPlayer()
    if player then
    
        local activeWeapon = player:GetActiveWeapon()
        local enableWidget = not self.healed and WeaponSupportsHeal(activeWeapon) and GetHealingRequired(player)
        if enableWidget and player:GetSecondaryAttackLastFrame() then
        
            self.healed = true
            Client.SetOptionInteger("help/guigorgehealhelp", Client.GetOptionInteger("help/guigorgehealhelp", 0) + 1)
            
        end
        
        if not self.healed and enableWidget then
            self.keyBackground:SetIsVisible(true)
        end
        
    end
    
end

function GUIGorgeHealHelp:Uninitialize()

    GUI.DestroyItem(self.keyBackground)
    self.keyBackground = nil
    
end