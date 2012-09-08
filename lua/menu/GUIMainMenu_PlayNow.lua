// ======= Copyright (c) 2003-2012, Unknown Worlds Entertainment, Inc. All rights reserved. =====
//
// lua\menu\GUIMainMenu_PlayNow.lua
//
//    Created by:   Brian Cronin (brianc@unknownworlds.com)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

local function UpdateAutoJoin(playNowWindow)

    playNowWindow.lastTimeRefreshedServers = playNowWindow.lastTimeRefreshedServers or 0
    local timeSinceRefreshed = Shared.GetTime() - playNowWindow.lastTimeRefreshedServers
    local timeToCheckForServerUpdate = timeSinceRefreshed > 5
    local forceRefreshTime = timeSinceRefreshed > 60
    if timeToCheckForServerUpdate and Client.GetNumServers() == 0 or forceRefreshTime then
    
        playNowWindow.lastTimeRefreshedServers = Shared.GetTime()
        Client.RebuildServerList()
        
    end
    
    timeSinceRefreshed = Shared.GetTime() - playNowWindow.lastTimeRefreshedServers
    if timeSinceRefreshed > 6 then
    
        local allValidServers = { }
        // Still indexes at 0.
        for s = 0, Client.GetNumServers() - 1 do
        
            if not Client.GetServerRequiresPassword(s) then
            
                local numPlayers = Client.GetServerNumPlayers(s)
                local maxPlayers = Client.GetServerMaxPlayers(s)
                local percentFull = numPlayers / maxPlayers
                local name = Client.GetServerName(s)
                local address = Client.GetServerAddress(s)
                local ping = Client.GetServerPing(s)
                
                table.insert(allValidServers, { numPlayers = numPlayers, maxPlayers = maxPlayers, percentFull = percentFull, name = name, address = address, ping = ping })
                
            end
            
        end
        
        local bestServer = nil
        for vs = 1, #allValidServers do
        
            local possibleServer = allValidServers[vs]
            bestServer = bestServer or possibleServer
            
            // Favor servers with low ping. But ignore ping when it is small enough.
            if possibleServer.ping < bestServer.ping or possibleServer.ping <= 80 then
            
                // Favor servers that are at least half full.
                if possibleServer.percentFull >= 0.5 then
                
                    // Favor servers that are not too full when they are at least half full.
                    if possibleServer.percentFull < bestServer.percentFull then
                        bestServer = possibleServer
                    end
                    
                // Favor servers that are more populated than our current best choice if
                // both are below 50% populated.
                elseif bestServer.percentFull < 0.5 and possibleServer.percentFull > bestServer.percentFull then
                    bestServer = possibleServer
                end
                
            end
            
        end
        
        if bestServer then
            MainMenu_SBJoinServer(bestServer.address)
        end
        
    end
    
end

local function UpdatePlayNowWindowLogic(playNowWindow, mainMenu)

    if playNowWindow:GetIsVisible() then
    
        playNowWindow.searchingForGameText.animateTime = playNowWindow.searchingForGameText.animateTime or Shared.GetTime()
        if Shared.GetTime() - playNowWindow.searchingForGameText.animateTime > 0.85 then
        
            playNowWindow.searchingForGameText.animateTime = Shared.GetTime()
            playNowWindow.searchingForGameText.numberOfDots = playNowWindow.searchingForGameText.numberOfDots or 3
            playNowWindow.searchingForGameText.numberOfDots = playNowWindow.searchingForGameText.numberOfDots + 1
            if playNowWindow.searchingForGameText.numberOfDots > 3 then
                playNowWindow.searchingForGameText.numberOfDots = 0
            end
            
            playNowWindow.searchingForGameText:SetText("SEARCHING" .. string.rep(".", playNowWindow.searchingForGameText.numberOfDots))
            
        end
        
        UpdateAutoJoin(playNowWindow)
        
    end
    
end

local function CreatePlayNowPage(self)

    self.playNowWindow = self:CreateWindow()
    self.playNowWindow:SetWindowName("PLAY NOW")
    self.playNowWindow:SetInitialVisible(false)
    self.playNowWindow:SetIsVisible(false)
    self.playNowWindow:DisableResizeTile()
    self.playNowWindow:DisableSlideBar()
    self.playNowWindow:DisableContentBox()
    self.playNowWindow:SetCSSClass("playnow_window")
    self.playNowWindow:DisableCloseButton()
    
    self.playNowWindow.UpdateLogic = UpdatePlayNowWindowLogic
    
    local eventCallbacks =
    {
        OnShow = function(self)
        
            self.scriptHandle:OnWindowOpened(self)
            MainMenu_OnWindowOpen()
            
        end,
        
        OnHide = function(self)
            self.scriptHandle:OnWindowClosed(self)
        end
    }
    self.playNowWindow:AddEventCallbacks(eventCallbacks)
    
    self.playNowWindow.searchingForGameText = CreateMenuElement(self.playNowWindow.titleBar, "Font", false)
    self.playNowWindow.searchingForGameText:SetCSSClass("playnow_title")
    self.playNowWindow.searchingForGameText:SetText("SEARCHING...")
    
    local cancelButton = CreateMenuElement(self.playNowWindow, "MenuButton")
    cancelButton:SetCSSClass("playnow_cancel")
    cancelButton:SetText("CANCEL")
    
    cancelButton:AddEventCallbacks({ OnClick =
    function() self.playNowWindow:SetIsVisible(false) end })
    
end

local function CreateJoinServerPage(self)
    self:CreateServerListWindow()
end

local function CreateHostGamePage(self)

    self.createGame = CreateMenuElement(self.playWindow:GetContentBox(), "Image")
    self.createGame:SetCSSClass("play_now_content")
    self:CreateHostGameWindow()
    
end

local function CreateFindPeoplePage(self)
    self:CreateFindPeopleWindow()
end

local function ShowServerWindow(self)

    self.playWindow.refreshButton:SetIsVisible(true)
    self.joinServerButton:SetIsVisible(true)
    self.highlightServer:SetIsVisible(true)
    self.selectServer:SetIsVisible(true)
    self.serverRowNames:SetIsVisible(true)
    self.serverTable:SetIsVisible(true)
    self.playWindow:EnableSlideBar()
    self.playWindow:ResetSlideBar()

end

local function HideServerWindow(self)

    self.playWindow.refreshButton:SetIsVisible(false)
    self.joinServerButton:SetIsVisible(false)
    self.highlightServer:SetIsVisible(false)
    self.selectServer:SetIsVisible(false)
    self.serverRowNames:SetIsVisible(false)
    self.serverTable:SetIsVisible(false)

end

function GUIMainMenu:SetPlayContentInvisible()

    HideServerWindow(self)
    self.createGame:SetIsVisible(false)
    self.findPeopleWindow:SetIsVisible(false)
    self.playNowWindow:SetIsVisible(false)
    self.playWindow:DisableSlideBar()
    self.playWindow:ResetSlideBar()
    self.hostGameButton:SetIsVisible(false)

end

function GUIMainMenu:CreatePlayWindow()

    self.playWindow = self:CreateWindow()
    self:SetupWindow(self.playWindow, "PLAY")
    self.playWindow:DisableSlideBar()
    
    local back = CreateMenuElement(self.playWindow, "MenuButton")
    back:SetCSSClass("back")
    back:SetText("BACK")
    back:AddEventCallbacks( { OnClick = function() self.playWindow:SetIsVisible(false) end } )
    
    local tabs = 
        {
            { label = "JOIN", func = function(self) self.scriptHandle:SetPlayContentInvisible() ShowServerWindow(self.scriptHandle) end },
            { label = "PICK UP GAME", func = function(self) self.scriptHandle:SetPlayContentInvisible() self.scriptHandle.findPeopleWindow:SetIsVisible(true) end},
            { label = "QUICK JOIN", func = function(self) self.scriptHandle:SetPlayContentInvisible() self.scriptHandle.playNowWindow:SetIsVisible(true) end },
            { label = "START SERVER", func = function(self) self.scriptHandle:SetPlayContentInvisible() self.scriptHandle.createGame:SetIsVisible(true) self.scriptHandle.hostGameButton:SetIsVisible(true) end }

        }
        
    local xTabWidth = 256

    local tabBackground = CreateMenuElement(self.playWindow, "Image")
    tabBackground:SetCSSClass("tab_background")
    tabBackground:SetIgnoreEvents(true)
    
    local tabAnimateTime = 0.1
        
    for i = 1,#tabs do
    
        local tab = tabs[i]
        local tabButton = CreateMenuElement(self.playWindow, "MenuButton")
        
        local function ShowTab()
            for j =1,#tabs do
                local tabPosition = tabButton.background:GetPosition()
                tabBackground:SetBackgroundPosition( tabPosition, false, tabAnimateTime ) 
            end
        end
    
        tabButton:SetCSSClass("tab")
        tabButton:SetText(tab.label)
        tabButton:AddEventCallbacks({ OnClick = tab.func })
        tabButton:AddEventCallbacks({ OnClick = ShowTab })
        
        local tabWidth = tabButton:GetWidth()
        tabButton:SetBackgroundPosition( Vector(tabWidth * (i - 1), 0, 0) )
        
    end

    CreateJoinServerPage(self)
    CreatePlayNowPage(self)
    CreateHostGamePage(self)
    CreateFindPeoplePage(self)
    
    self:SetPlayContentInvisible()
    ShowServerWindow(self)
    
end