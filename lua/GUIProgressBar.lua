
// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\GUIProgressBar.lua
//
// Created by: Andreas Urwalek (andi@unknownworlds.com)
//
// Shows a simple progress bar and text.
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/GUIScript.lua")

class 'GUIProgressBar' (GUIScript)

GUIProgressBar.kFontName = "fonts/AgencyFB_medium.fnt"
GUIProgressBar.kFontScale = GUIScale(Vector(1,1,0)) * 0.7

local kPadding = 4
GUIProgressBar.kBgSize = GUIScale(Vector(420, 64, 0)) * 0.6
GUIProgressBar.kSize = Vector(GUIProgressBar.kBgSize.x - (2 * kPadding), GUIProgressBar.kBgSize.y - (2 * kPadding), 0)

GUIProgressBar.kBgPosition = Vector(GUIProgressBar.kBgSize.x * -.5, GUIScale(-150), 0)

GUIProgressBar.kPosition = Vector(kPadding, kPadding, 0)

GUIProgressBar.kTextYOffset = GUIScale(0)

GUIProgressBar.kBarTexCoords = { 256, 0, 256 + 512, 64 }


local kAlienColor = Color(1, 0.792, 0.227)
local kMarineColor = Color(0.725, 0.921, 0.949, 1)

local kHealthColorsMarine = { Color(0.5, 0, 0), Color(0.5, 0.5, 0), Color(0.0, 0.5, 0.5) }
local kHealthColorsAlien = { Color(0.5, 0, 0), Color(0.5, 0.2, 0), Color(0.5, 0.5, 0.2) }
local kHealthColorsNeutral = { Color(0.1, 0.1, 0.1), Color(0.4, 0.4, 0.4), Color(0.9, 0.9, 0.9) }

kFadeOutDelay = 0

function GUIProgressBar:Initialize()

    self.timeLastProgress = 0

    self.progressBarBg = GUIManager:CreateGraphicItem()
    self.progressBarBg:SetSize(GUIProgressBar.kBgSize)
    self.progressBarBg:SetAnchor(GUIItem.Middle, GUIItem.Bottom)
    self.progressBarBg:SetPosition(GUIProgressBar.kBgPosition)
    self.progressBarBg:SetTexture("ui/progress_bar_bg.dds")
    self.progressBarBg:SetColor(Color(1,1,1,0))
    
    self.progressBar = GUIManager:CreateGraphicItem()
    self.progressBar:SetSize(GUIProgressBar.kSize)
    self.progressBar:SetAnchor(GUIItem.Left, GUIItem.Top)
    self.progressBar:SetPosition(GUIProgressBar.kPosition)
    self.progressBar:SetTexture("ui/commanderbar.dds")
    //self.progressBar:SetTexturePixelCoordinates(unpack(GUIProgressBar.kBarTexCoords))
    self.progressBar:SetInheritsParentAlpha(true)
    //self.progressBar:SetBlendTechnique(GUIItem.Add)
    self.progressBarBg:AddChild(self.progressBar)
    
    self.objectiveTextShadow = GUIManager:CreateTextItem()
    self.objectiveTextShadow:SetAnchor(GUIItem.Middle, GUIItem.Center)
    self.objectiveTextShadow:SetTextAlignmentX(GUIItem.Align_Center)
    self.objectiveTextShadow:SetTextAlignmentY(GUIItem.Align_Center)
    self.objectiveTextShadow:SetPosition(Vector(1, GUIProgressBar.kTextYOffset + 1, 0))
    self.objectiveTextShadow:SetInheritsParentAlpha(true)
    self.objectiveTextShadow:SetFontName(GUIProgressBar.kFontName)
    self.objectiveTextShadow:SetScale(GUIProgressBar.kFontScale)
    self.progressBarBg:AddChild(self.objectiveTextShadow)
    
    self.objectiveText = GUIManager:CreateTextItem()
    self.objectiveText:SetAnchor(GUIItem.Middle, GUIItem.Center)
    self.objectiveText:SetTextAlignmentX(GUIItem.Align_Center)
    self.objectiveText:SetTextAlignmentY(GUIItem.Align_Center)
    self.objectiveText:SetPosition(Vector(0, GUIProgressBar.kTextYOffset, 0))
    self.objectiveText:SetInheritsParentAlpha(true)
    self.objectiveText:SetFontName(GUIProgressBar.kFontName)
    self.objectiveText:SetScale(GUIProgressBar.kFontScale)
    self.objectiveText:SetColor(Color(1,1,1,1))
    self.progressBarBg:AddChild(self.objectiveText)

end

function GUIProgressBar:Uninitialize()

    if self.progressBarBg then
        GUI.DestroyItem(self.progressBarBg)
        self.progressBarBg = nil
    end
    
end

local crosshairPos = Vector(0,0,0)

function GUIProgressBar:Update(deltaTime)
    
    PROFILE("GUIProgressBar:Update")

    local objectiveFraction, objectiveText, teamType = PlayerUI_GetObjectiveInfo()
    local showProgressBar = not PlayerUI_GetIsDead() and PlayerUI_GetIsPlaying() and not PlayerUI_IsACommander() and not PlayerUI_GetBuyMenuDisplaying()

    if showProgressBar and objectiveFraction then

        local useColor = Color(1,1,1,1) 
        local healthColors = kHealthColorsNeutral
        local colorIndex = math.max(math.ceil(3 * objectiveFraction), 1)
        local healthColor = kHealthColorsNeutral[colorIndex]

        if teamType == kMarineTeamType then
            useColor = kMarineColor
            healthColor = kMarineTeamColorFloat // kHealthColorsMarine[colorIndex]
        elseif teamType == kAlienTeamType then
            useColor = kAlienColor
            healthColor = kAlienTeamColorFloat // kHealthColorsAlien[colorIndex]
        end

        self.progressBarBg:SetColor(useColor)
        self.progressBar:SetColor(healthColor)
        //self.objectiveText:SetColor(useColor)
        self.objectiveTextShadow:SetColor(Color(healthColor.r * 0.15, healthColor.g * 0.15, healthColor.b * 0.15, 1))
        
        self.timeLastProgress = Shared.GetTime()
    
    else
    
        if self.timeLastProgress + kFadeOutDelay < Shared.GetTime() then
    
            local useColor = self.progressBarBg:GetColor()
            useColor.a = math.max(0, useColor.a - deltaTime)
            self.progressBarBg:SetColor(useColor)
        
        end
    
    end
    
    if objectiveFraction then
    
        self.progressBar:SetSize(Vector(GUIProgressBar.kSize.x * objectiveFraction, GUIProgressBar.kSize.y, 0))
        
        //local x2Coords = GUIProgressBar.kBarTexCoords[1] + (GUIProgressBar.kBarTexCoords[3] - GUIProgressBar.kBarTexCoords[1]) * objectiveFraction        
        //self.progressBar:SetTexturePixelCoordinates(GUIProgressBar.kBarTexCoords[1], GUIProgressBar.kBarTexCoords[2], x2Coords, GUIProgressBar.kBarTexCoords[4])
    
    end
    
    if objectiveText then
    
        self.objectiveText:SetText(objectiveText)
        self.objectiveTextShadow:SetText(objectiveText)
        
    end
    
end