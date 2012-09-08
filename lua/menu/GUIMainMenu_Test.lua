// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\menu\GUIMainMenu.lua
//
//    Created by:   Andreas Urwalek (a_urwa@sbox.tugraz.at)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/menu/WindowManager.lua")
Script.Load("lua/GUIAnimatedScript.lua")
Script.Load("lua/menu/MenuMixin.lua")
Script.Load("lua/menu/Link.lua")
Script.Load("lua/menu/SlideBar.lua")
Script.Load("lua/menu/ContentBox.lua")
Script.Load("lua/menu/Image.lua")
Script.Load("lua/menu/Checkbox.lua")

class 'GUIMainMenu' (GUIAnimatedScript)

function GUIMainMenu:Initialize()
    
    GUIAnimatedScript.Initialize(self)
    
    // provides a set of functions required for window handling
    AddMenuMixin(self)
    self:SetCursor("ui/Cursor_MenuDefault.dds")
    self:SetWindowLayer(kWindowLayerMainMenu)
    
    LoadCSSFile("ui/menu/test.css")
    
    self.mainWindow = self:CreateWindow()
    self.mainWindow:SetCSSClass("main_frame")
    
    self.mainWindow:DisableTitleBar()
    self.mainWindow:DisableResizeTile()
    self.mainWindow:DisableCanSetActive()
    
    local eventCallbacks = {
        
        OnEscape = function (self)
            if MainMenu_IsInGame() then
                self:SetIsVisible(not self:GetIsVisible())
            end
        end,
        
        OnShow = function (self)
            MainMenu_Open()
        end,

        OnHide = function (self)
            if MainMenu_IsInGame() then
                MainMenu_ReturnToGame()
                return true
            else
                return false
            end    
        end,
        
        OnTab = function (self) Print("OnTab") end,
        OnEnter = function (self) Print("OnEnter") end,
            
    }
    
    self.mainWindow:SetEventCallbacks(eventCallbacks)
 
    self:CreateServerListWindow()
    self:CreateCreditsWindow()
    self:CreateOptionWindow()
    self:CreateCreateWindow()
    
    local TriggerOpenAnimation = function(window)
    
        if not window:GetIsVisible() then
            local desiredPos = window:GetBackground():GetPosition()
            local startPos = Vector(desiredPos.x - 200, Client.GetScreenHeight() / 2, 0)
            
            window:SetBackgroundPosition(startPos, true)
            window:GetBackground():SetPosition(desiredPos, 0.5, nil, AnimateSin)
        end
        
    end
    
    self.logo = CreateMenuElement(self.mainWindow, "Image")
    self.logo.OnShow = function(self) self:SetCSSClass("logo") end

    self:CreateMenuBackground()

    self.serverLink = CreateMenuElement(self.mainWindow, "Link")
    self.serverLink:SetText("Play online")
    self.serverLink:SetCSSClass("play_online")
    self.serverLink.OnClick = function(self)
        TriggerOpenAnimation(self.scriptHandle.serverListWindow)
        self.scriptHandle.serverListWindow:SetIsVisible(true)
    end
    
    self.optionLink = CreateMenuElement(self.mainWindow, "Link")
    self.optionLink:SetText("Options")
    self.optionLink:SetCSSClass("options")
    self.optionLink.OnClick = function(self)
        TriggerOpenAnimation(self.scriptHandle.optionWindow)
        self.scriptHandle.optionWindow:SetIsVisible(true)
    end
    
    self.creditLink = CreateMenuElement(self.mainWindow, "Link")
    self.creditLink:SetText("Credits")
    self.creditLink:SetCSSClass("credits")
    self.creditLink.OnClick = function(self)
        TriggerOpenAnimation(self.scriptHandle.creditLink)
        self.scriptHandle.creditWindow:SetIsVisible(true)
    end

    self.quitLink = CreateMenuElement(self.mainWindow, "Link")
    self.quitLink:SetText("Exit")
    self.quitLink:SetCSSClass("exit")
    self.quitLink.OnClick = function(self)
        Client.Exit()
    end

    self.createLink = CreateMenuElement(self.mainWindow, "Link")
    self.createLink:SetText("Create")
    self.createLink:SetCSSClass("create")
    self.createLink.OnClick = function(self)
        TriggerOpenAnimation(self.scriptHandle.createWindow)
        self.scriptHandle.createWindow:SetIsVisible(true)
    end    

    if MainMenu_IsInGame() then

        self.returnLink = CreateMenuElement(self.mainWindow, "Link")
        self.returnLink:SetText("Return")
        self.returnLink:SetCSSClass("return")
        self.returnLink.OnClick = function(self)
            self.scriptHandle:SetIsVisible(not self.scriptHandle:GetIsVisible())
        end
    
    end

end

function GUIMainMenu:Uninitialize()

    self:DestroyAllWindows()

end

local kInfestationSize = Vector(400, 500, 0)
local kInfestationPos = Vector(-280, -80, 0)
local kAnimationDuration = 5
local kInfestationSoundBegin = "sound/NS2.fev/alien/structures/deploy_large"
local kInfestationSound = "sound/NS2.fev/alien/structures/hive_spawn"

local kInfestationTextures = {

    "ui/menu/infest1.dds",
    "ui/menu/infest2.dds",
    "ui/menu/infest3.dds",
    "ui/menu/infest4.dds",

}

local kUnfoldSound = "sound/NS2.fev/marine/structures/roboticsfactory_open"
local kUnfoldDuration = 2.5

Client.PrecacheLocalSound(kInfestationSoundBegin)
Client.PrecacheLocalSound(kInfestationSound)
Client.PrecacheLocalSound(kUnfoldSound)

function GUIMainMenu:CreateMenuBackground()

    self.menuBackground = CreateMenuElement(self.mainWindow, "Image")
    self.menuBackground:SetCSSClass("menu_bg_closed")
    
    local leftBorder = CreateMenuElement(self.menuBackground, "Image")
    leftBorder:SetCSSClass("border_left")
    
    local rightBorder = CreateMenuElement(self.menuBackground, "Image")
    rightBorder:SetCSSClass("border_right")
    
    self.infestationAnimation = {}
    for i = 1, 4 do
        self.infestationAnimation[i] = CreateGraphicItem(self.menuBackground, true)
        self.infestationAnimation[i]:SetColor(Color(1,1,1,0))
        self.infestationAnimation[i]:SetSize(kInfestationSize)
        self.infestationAnimation[i]:SetPosition(kInfestationPos)
        self.infestationAnimation[i]:SetTexture(kInfestationTextures[i])
    end
    
    local eventCallbacks = {
    
        // trigger initial animation
        OnShow = function (self)
        
            // passing updateChildren == false to prevent updating of children
            self:SetCSSClass("menu_bg_closed", false)
            self:SetCSSClass("menu_bg_open", false)
            
            Shared.PlaySound(nil, kUnfoldSound)
        
            for i = 1, 4 do
                self.scriptHandle.infestationAnimation[i]:SetIsVisible(true)
                self.scriptHandle.infestationAnimation[i]:DestroyAnimations()
                self.scriptHandle.infestationAnimation[i]:SetColor(Color(1,1,1,0))
            end
        
            local function InfestationAnimation(script, item)
            
                local triggerIndex = 0
                if item == script.infestationAnimation[1] then
                    triggerIndex = 2
                elseif item == script.infestationAnimation[2] then
                    triggerIndex = 3
                elseif item == script.infestationAnimation[3] then
                    triggerIndex = 4
                end

                if triggerIndex ~= 0 then
                    script.infestationAnimation[triggerIndex]:FadeIn(kAnimationDuration + 2 * triggerIndex, nil, AnimateLinear, InfestationAnimation)
                    Shared.PlaySound(nil, kInfestationSound)
                end
            
            end

            self.scriptHandle.infestationAnimation[1]:FadeIn(kAnimationDuration, nil, AnimateLinear, InfestationAnimation)
            Shared.PlaySound(nil, kInfestationSoundBegin)
        
        end,
        
        // destroy all animation and reset state
        OnHide = function (self)
        
            for i = 1, 4 do
                self.scriptHandle.infestationAnimation[i]:SetIsVisible(false)
                self.scriptHandle.infestationAnimation[i]:DestroyAnimations()
            end
        
        end
    
    }
    
    self.menuBackground:SetEventCallbacks(eventCallbacks)
    
end    

local function FinishWindowAnimations(self)
    self:GetBackground():EndAnimations()
end    

function GUIMainMenu:CreateServerListWindow()

    self.serverListWindow = self:CreateWindow()
    self.serverListWindow:SetCSSClass("main_menu_window")
    self.serverListWindow:SetInitialVisible(false)
    self.serverListWindow:SetIsVisible(false)
    self.serverListWindow.OnHide = FinishWindowAnimations
    
    local connectButton = CreateMenuElement(self.serverListWindow, "MenuButton")
 
    self.serverListWindow:SetWindowName("Play online")

end

function GUIMainMenu:CreateCreditsWindow()

    self.creditWindow = self:CreateWindow()
    self.creditWindow:SetCSSClass("main_menu_window")
    self.creditWindow:SetInitialVisible(false)
    self.creditWindow:SetIsVisible(false)
    self.creditWindow.OnHide = FinishWindowAnimations
    
    self.creditWindow:SetWindowName("Credits")

end

function GUIMainMenu:CreateOptionWindow()

    self.optionWindow = self:CreateWindow()
    self.optionWindow:SetCSSClass("main_menu_window")
    self.optionWindow:SetInitialVisible(false)
    self.optionWindow:SetIsVisible(false)
    self.optionWindow.OnHide = FinishWindowAnimations
    
    self.optionWindow:SetWindowName("Options")
    
    local contentBox = CreateMenuElement(self.optionWindow, "ContentBox")
    contentBox:SetTopOffset(30)
    contentBox:SetLeftOffset(5)
    
    local slideBar = CreateMenuElement(self.optionWindow, "SlideBar")
    slideBar:SetAlign(GUIItem.Left, GUIItem.Bottom)
    slideBar:SetLeftOffset(5)
    slideBar:SetBottomOffset(5)
    slideBar:Register(contentBox, SLIDE_HORIZONTAL)
    
    local checkBox = CreateMenuElement(self.optionWindow, "Checkbox")
    checkBox:SetAlign(GUIItem.Right, GUIItem.Center)
    checkBox:SetRightOffset(0)
    
    

end

function GUIMainMenu:CreateCreateWindow()

    self.createWindow = self:CreateWindow()
    self.createWindow:SetCSSClass("main_menu_window")
    self.createWindow:SetInitialVisible(false)
    self.createWindow:SetIsVisible(false)
    self.createWindow.OnHide = FinishWindowAnimations
    
    self.createWindow:SetWindowName("Create Server")
    
end

function GUIMainMenu:Update(deltaTime)

    if self:GetIsVisible() then
    
        // update only when visible
        GUIAnimatedScript.Update(self, deltaTime)
    
    end

end

function GUIMainMenu:OnAnimationsEnd(item)
    
    if item == self.menuBackground:GetBackground() then
    
        Print("menu background done")
    
    end
    
end
