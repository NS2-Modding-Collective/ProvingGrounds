// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\GUIInsight_TopBar.lua
//
// Created by: Jon 'Huze' Hughes (jon@jhuze.com)
//
// Spectator: Displays team names and gametime
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

class "GUIInsight_TopBar" (GUIScript)

local isVisible

local kBackgroundTexture = "ui/topbar.dds"
local kIconTexturePurple = "ui/alien_commander_textures.dds"
local kIconTextureGreen = "ui/marine_commander_textures.dds"

local kTimeFontName = "fonts/AgencyFB_medium.fnt"
local kTimeFontScale = GUIScale(Vector(1, 1, 0))
local kGreenFontName = "fonts/AgencyFB_medium.fnt"
local kPurpleFontName = "fonts/AgencyFB_medium.fnt"
local kTeamFontScale = GUIScale(Vector(1, 1, 0))

local kScoreFontScale = GUIScale(Vector(1.2, 1.2, 0))

local kInfoFontName = "fonts/AgencyFB_small.fnt"
local kInfoFontScale = GUIScale(Vector(1, 1, 0))

local kBackgroundSize = GUIScale(Vector(400, 35, 0))
local kScoresSize = GUIScale(Vector(50,32, 0))
local kTeamNameSize = GUIScale(Vector(150, 24, 0))
local kIconSize = GUIScale(Vector(32, 32, 0))
local kButtonSize = GUIScale(Vector(8, 8, 0))

local kButtonOffset = GUIScale(Vector(0,20,0))

local background
local gameTime

local scoresBackground
local teamsSwapButton
local greenPlusButton
local greenMinusButton
local purplePlusButton
local purpleMinusButton

local greenTeamScore
local purpleTeamScore

local greenNameBackground
local greenTeamName

local purpleNameBackground
local purpleTeamName

local function CreateIconTextItem(team, parent, position, texture, coords)

    local background = GUIManager:CreateGraphicItem()
    if team == kTeam1Index then
        background:SetAnchor(GUIItem.Left, GUIItem.Top)
    else
        background:SetAnchor(GUIItem.Right, GUIItem.Top)
    end
    background:SetColor(Color(0,0,0,0))
    background:SetSize(kIconSize)
    parent:AddChild(background)

    local icon = GUIManager:CreateGraphicItem()
    icon:SetSize(kIconSize)
    icon:SetAnchor(GUIItem.Left, GUIItem.Top)
    icon:SetPosition(position)
    icon:SetTexture(texture)
    icon:SetTexturePixelCoordinates(unpack(coords))
    background:AddChild(icon)
    
    local value = GUIManager:CreateTextItem()
    value:SetFontName(kInfoFontName)
    value:SetScale(kInfoFontScale)
    value:SetAnchor(GUIItem.Left, GUIItem.Center)
    value:SetTextAlignmentX(GUIItem.Align_Min)
    value:SetTextAlignmentY(GUIItem.Align_Center)
    value:SetColor(Color(1, 1, 1, 1))
    value:SetPosition(position + Vector(kIconSize.x + GUIScale(5), 0, 0))
    background:AddChild(value)
    
    return value
    
end

local function CreateButtonItem(parent, position, color)

    local button = GUIManager:CreateGraphicItem()
    button:SetSize(kButtonSize)
    button:SetPosition(position - kButtonSize/2)
    button:SetColor(color)
    button:SetIsVisible(false)
    parent:AddChild(button)
    
    return button
    
end

function GUIInsight_TopBar:Initialize()

    isVisible = true
        
    local texSize = GUIScale(Vector(512,57,0))
    local texCoord = {0,0,512,57}
    local texPos = Vector(-texSize.x/2,0,0)
    background = GUIManager:CreateGraphicItem()
    background:SetAnchor(GUIItem.Middle, GUIItem.Top)
    background:SetTexture(kBackgroundTexture)
    background:SetTexturePixelCoordinates(unpack(texCoord))
    background:SetSize(texSize)
    background:SetPosition(texPos)
    background:SetLayer(kGUILayerInsight)
    
    gameTime = GUIManager:CreateTextItem()
    gameTime:SetFontName(kTimeFontName)
    gameTime:SetScale(kTimeFontScale)
    gameTime:SetAnchor(GUIItem.Middle, GUIItem.Top)
    gameTime:SetPosition(GUIScale(Vector(0, 5, 0)))
    gameTime:SetTextAlignmentX(GUIItem.Align_Center)
    gameTime:SetTextAlignmentY(GUIItem.Align_Min)
    gameTime:SetColor(Color(1, 1, 1, 1))
    gameTime:SetText("")
    background:AddChild(gameTime)
    
    local scoresTexSize = GUIScale(Vector(512,71,0))
    local scoresTexCoord = {0,57,512,128}    
    
    scoresBackground = GUIManager:CreateGraphicItem()
    scoresBackground:SetTexture(kBackgroundTexture)
    scoresBackground:SetTexturePixelCoordinates(unpack(scoresTexCoord))
    scoresBackground:SetSize(scoresTexSize)
    scoresBackground:SetAnchor(GUIItem.Middle, GUIItem.Top)
    scoresBackground:SetPosition(Vector(-scoresTexSize.x/2, texSize.y - GUIScale(15), 0))
    scoresBackground:SetIsVisible(false)
    background:AddChild(scoresBackground)
    
    greenTeamScore = GUIManager:CreateTextItem()
    greenTeamScore:SetFontName(kTimeFontName)
    greenTeamScore:SetScale(kScoreFontScale)
    greenTeamScore:SetAnchor(GUIItem.Middle, GUIItem.Center)
    greenTeamScore:SetTextAlignmentX(GUIItem.Align_Center)
    greenTeamScore:SetTextAlignmentY(GUIItem.Align_Center)
    greenTeamScore:SetPosition(GUIScale(Vector(-30, -5, 0)))
    greenTeamScore:SetColor(Color(1, 1, 1, 1))
    scoresBackground:AddChild(greenTeamScore)
    
    purpleTeamScore = GUIManager:CreateTextItem()
    purpleTeamScore:SetFontName(kTimeFontName)
    purpleTeamScore:SetScale(kScoreFontScale)
    purpleTeamScore:SetAnchor(GUIItem.Middle, GUIItem.Center)
    purpleTeamScore:SetTextAlignmentX(GUIItem.Align_Center)
    purpleTeamScore:SetTextAlignmentY(GUIItem.Align_Center)
    purpleTeamScore:SetPosition(GUIScale(Vector(30, -5, 0)))
    purpleTeamScore:SetColor(Color(1, 1, 1, 1))
    scoresBackground:AddChild(purpleTeamScore)
    
    greenTeamName = GUIManager:CreateTextItem()
    greenTeamName:SetFontName(kGreenFontName)
    greenTeamName:SetScale(kTeamFontScale)
    greenTeamName:SetAnchor(GUIItem.Middle, GUIItem.Center)
    greenTeamName:SetTextAlignmentX(GUIItem.Align_Center)
    greenTeamName:SetTextAlignmentY(GUIItem.Align_Center)
    greenTeamName:SetPosition(GUIScale(Vector(-scoresTexSize.x/4, -7, 0)))
    greenTeamName:SetColor(Color(1, 1, 1, 1))
    scoresBackground:AddChild(greenTeamName)
    
    purpleTeamName = GUIManager:CreateTextItem()
    purpleTeamName:SetFontName(kPurpleFontName)
    purpleTeamName:SetScale(kTeamFontScale)
    purpleTeamName:SetAnchor(GUIItem.Middle, GUIItem.Center)
    purpleTeamName:SetTextAlignmentX(GUIItem.Align_Center)
    purpleTeamName:SetTextAlignmentY(GUIItem.Align_Center)
    purpleTeamName:SetPosition(GUIScale(Vector(scoresTexSize.x/4, -7, 0)))
    purpleTeamName:SetColor(Color(1, 1, 1, 1))
    scoresBackground:AddChild(purpleTeamName)
      
    teamsSwapButton = CreateButtonItem(scoresBackground, kButtonOffset, Color(1,1,1,0.5))
    teamsSwapButton:SetAnchor(GUIItem.Middle, GUIItem.Center)
    
    greenPlusButton = CreateButtonItem(scoresBackground, kButtonOffset + Vector(-kButtonSize.x,-kButtonSize.y,0), Color(0,1,0,0.5))
    greenPlusButton:SetAnchor(GUIItem.Middle, GUIItem.Center)
    
    purplePlusButton = CreateButtonItem(scoresBackground, kButtonOffset + Vector(kButtonSize.x,-kButtonSize.y,0), Color(0,1,0,0.5))
    purplePlusButton:SetAnchor(GUIItem.Middle, GUIItem.Center)
    
    greenMinusButton = CreateButtonItem(scoresBackground, kButtonOffset + Vector(-kButtonSize.x,kButtonSize.y,0), Color(1,0,0,0.5))
    greenMinusButton:SetAnchor(GUIItem.Middle, GUIItem.Center)
    
    purpleMinusButton = CreateButtonItem(scoresBackground, kButtonOffset + Vector(kButtonSize.x,kButtonSize.y,0), Color(1,0,0,0.5))
    purpleMinusButton:SetAnchor(GUIItem.Middle, GUIItem.Center)
        
    self:SetTeams(InsightUI_GetTeam1Name(), InsightUI_GetTeam2Name())
    self:SetScore(InsightUI_GetTeam1Score(), InsightUI_GetTeam2Score())
        
end


function GUIInsight_TopBar:Uninitialize()

    GUI.DestroyItem(background)
    background = nil

end

function GUIInsight_TopBar:OnResolutionChanged(oldX, oldY, newX, newY)

    self:Uninitialize()
    
    self:Initialize()

end

function GUIInsight_TopBar:SetIsVisible(bool)

    isVisible = bool
    background:SetIsVisible(bool)

end

function GUIInsight_TopBar:SendKeyEvent(key, down)

    if isVisible then
        local cursor = MouseTracker_GetCursorPos()
        local inBackground, posX, posY = GUIItemContainsPoint(scoresBackground, cursor.x, cursor.y)
        if inBackground then
        
            if key == InputKey.MouseButton0 and down then

                local inSwap, posX, posY = GUIItemContainsPoint(teamsSwapButton, cursor.x, cursor.y)
                if inSwap then
                    Shared.ConsoleCommand("teams swap")
                end
                local inMPlus, posX, posY = GUIItemContainsPoint(greenPlusButton, cursor.x, cursor.y)
                if inMPlus then
                    Shared.ConsoleCommand("score1 +")
                end
                local inMMinus, posX, posY = GUIItemContainsPoint(greenMinusButton, cursor.x, cursor.y)
                if inMMinus then
                    Shared.ConsoleCommand("score1 -")
                end
                local inAPlus, posX, posY = GUIItemContainsPoint(purplePlusButton, cursor.x, cursor.y)
                if inAPlus then
                    Shared.ConsoleCommand("score2 +")
                end
                local inAMinus, posX, posY = GUIItemContainsPoint(purpleMinusButton, cursor.x, cursor.y)
                if inAMinus then
                    Shared.ConsoleCommand("score2 -")
                end
                --Shared.ConsoleCommand("teams reset")
                return true
                
            end
            
        end    
    
    end

    return false

end

function GUIInsight_TopBar:Update(deltaTime)

    local startTime = PlayerUI_GetGameStartTime()

    if startTime ~= 0 then
        startTime = Shared.GetTime() - startTime
    end

    local minutes = math.floor(startTime/60)
    local seconds = startTime - minutes*60
    local gameTimeText = string.format("%d:%02d", minutes, seconds)

    gameTime:SetText(gameTimeText)

    local cursor = MouseTracker_GetCursorPos()
    local inBackground, posX, posY = GUIItemContainsPoint(scoresBackground, cursor.x, cursor.y)
    teamsSwapButton:SetIsVisible(inBackground)
    greenPlusButton:SetIsVisible(inBackground)
    greenMinusButton:SetIsVisible(inBackground)
    purplePlusButton:SetIsVisible(inBackground)
    purpleMinusButton:SetIsVisible(inBackground)

end

function GUIInsight_TopBar:SetTeams(team1Name, team2Name)

    if team1Name == nil and team2Name == nil then
    
        scoresBackground:SetIsVisible(false)
            
    else

        scoresBackground:SetIsVisible(true)
        if team1Name == nil then
            purpleTeamName:SetText(team2Name)
        elseif team2Name == nil then
            greenTeamName:SetText(team1Name)
        else        
            greenTeamName:SetText(team1Name)
            purpleTeamName:SetText(team2Name)
        end
        
    end
    
end

function GUIInsight_TopBar:SetScore(team1Score, team2Score)

    greenTeamScore:SetText(tostring(team1Score))
    purpleTeamScore:SetText(tostring(team2Score))

end