// ======= Copyright (c) 2012, Unknown Worlds Entertainment, Inc. All rights reserved. ==========
//
// lua\GUIExoArmorDisplay.lua
//
// Created by: Brian Cronin (brianc@unknownworlds.com)
//
// Displays the armor amount on the Exo HUD.
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

// Global state that can be externally set to adjust the display.
armorAmount = 0

local background = nil
local text = nil

local kTexture = "models/marine/exosuit/exosuit_view_panel_armor.dds"

function Update(dt)
    text:SetText(tostring(armorAmount))
end

function Initialize()

    GUI.SetSize(256, 256)
    
    background = GUI.CreateItem()
    background:SetSize(Vector(256, 256, 0))
    background:SetPosition(Vector(0, 0, 0))
    background:SetTexturePixelCoordinates(0, 0, 256, 256)
    background:SetTexture(kTexture)
    background:SetBlendTechnique(GUIItem.Add)
    
    text = GUI.CreateItem()
    // Text items always manage their own rendering.
    text:SetOptionFlag(GUIItem.ManageRender)
    text:SetFontName("MicrogrammaDMedExt")
    text:SetFontIsBold(true)
    text:SetFontSize(42)
    text:SetTextAlignmentX(GUIItem.Align_Center)
    text:SetTextAlignmentY(GUIItem.Align_Center)
    text:SetAnchor(GUIItem.Middle, GUIItem.Center)
    text:SetPosition(Vector(18, 28, 0))
    text:SetColor(Color(0.537, 0.643, 0.666, 1))
    
end

Initialize()