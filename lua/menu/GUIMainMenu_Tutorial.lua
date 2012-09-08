// ======= Copyright (c) 2003-2012, Unknown Worlds Entertainment, Inc. All rights reserved. =====
//
// lua\menu\GUIMainMenu_Tutorial.lua
//
//    Created by:   Andreas Urwalek (andi@unknownworlds.com)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

local function CreateTutorialPage(self)

    self.tutorial = CreateMenuElement(self.tutorialWindow:GetContentBox(), "Image")
    self.tutorial:SetCSSClass("play_now_content")

    self.tutLink1 = CreateMenuElement(self.tutorial, "Link")
    self.tutLink1:SetCSSClass("tut_link_1")
    self.tutLink1:SetText("Fatman's introduction 1 of 2 (11 mins)")
    self.tutLink1.OnClick = function() Client.ShowWebpage("http://www.youtube.com/watch?v=-usWHmVQlIM&feature=plcp") end
    self.tutLink1:EnableHighlighting()
    
    self.tutLink2 = CreateMenuElement(self.tutorial, "Link")
    self.tutLink2:SetCSSClass("tut_link_2")
    self.tutLink2:SetText("Fatman's introduction 2 of 2 (12 mins)")
    self.tutLink2.OnClick = function() Client.ShowWebpage("http://www.youtube.com/watch?v=zhbs5x34chE&feature=plcp") end
    self.tutLink2:EnableHighlighting()

    self.tutLink3 = CreateMenuElement(self.tutorial, "Link")
    self.tutLink3:SetCSSClass("tut_link_3")
    self.tutLink3:SetText("Playing Marine (4 mins)")
    self.tutLink3.OnClick = function() Client.ShowWebpage("http://www.youtube.com/watch?v=cfYLW69Pk-E&feature=plcp") end
    self.tutLink3:EnableHighlighting()
    
    self.tutLink4 = CreateMenuElement(self.tutorial, "Link")
    self.tutLink4:SetCSSClass("tut_link_4")
    self.tutLink4:SetText("Marine Commander tutorial (12 mins)")
    self.tutLink4.OnClick = function() Client.ShowWebpage("http://www.youtube.com/watch?v=UmjJgZ4FhPU&feature=plcp") end
    self.tutLink4:EnableHighlighting()
    
    self.tutLink5 = CreateMenuElement(self.tutorial, "Link")
    self.tutLink5:SetCSSClass("tut_link_5")
    self.tutLink5:SetText("Playing Skulk (8 mins)")
    self.tutLink5.OnClick = function() Client.ShowWebpage("http://www.youtube.com/watch?v=81xwWq_fO_M&feature=plcp") end
    self.tutLink5:EnableHighlighting()
    
    self.tutLink6 = CreateMenuElement(self.tutorial, "Link")
    self.tutLink6:SetCSSClass("tut_link_6")
    self.tutLink6:SetText("Skulk wall-jumping")
    //self.tutLink6.OnClick = function() Client.ShowWebpage("http://www.youtube.com/watch?v=81xwWq_fO_M&feature=plcp") end
    self.tutLink6:EnableHighlighting()
    
    self.tutLink7 = CreateMenuElement(self.tutorial, "Link")
    self.tutLink7:SetCSSClass("tut_link_7")
    self.tutLink7:SetText("Playing Gorge (27 mins)")
    self.tutLink7.OnClick = function() Client.ShowWebpage("http://www.youtube.com/watch?v=QiDXcVCOoU0&feature=plcp") end
    self.tutLink7:EnableHighlighting()
    
    self.tutLink8 = CreateMenuElement(self.tutorial, "Link")
    self.tutLink8:SetCSSClass("tut_link_8")
    self.tutLink8:SetText("Playing Lerk (9 mins)")
    self.tutLink8.OnClick = function() Client.ShowWebpage("http://www.youtube.com/watch?v=peHXm5-eorI&feature=plcp") end
    self.tutLink8:EnableHighlighting()
    
    self.tutLink9 = CreateMenuElement(self.tutorial, "Link")
    self.tutLink9:SetCSSClass("tut_link_9")
    self.tutLink9:SetText("Alien Commander tutorial (28 mins)")
    self.tutLink9.OnClick = function() Client.ShowWebpage("http://www.youtube.com/watch?v=nBcpfHsxcck") end
    self.tutLink9:EnableHighlighting()
    
    self.tutLink10 = CreateMenuElement(self.tutorial, "Link")
    self.tutLink10:SetCSSClass("tut_link_10")
    self.tutLink10:SetText("Sample competitive play Cyd vs. Nxsl 1/2 (10 mins)")
    self.tutLink10.OnClick = function() Client.ShowWebpage("http://www.youtube.com/watch?v=aNPuIOG1Xoo&feature=plcp") end
    self.tutLink10:EnableHighlighting()
    
    self.tutLink11 = CreateMenuElement(self.tutorial, "Link")
    self.tutLink11:SetCSSClass("tut_link_11")
    self.tutLink11:SetText("Sample competitive play Cyd vs. Nxsl 2/2 (17 mins)")
    self.tutLink11.OnClick = function() Client.ShowWebpage("http://www.youtube.com/watch?v=lPYAJ9h9H6k&feature=plcp") end
    self.tutLink11:EnableHighlighting()

end

local function CreateExplorePage(self)

    self.explore = CreateMenuElement(self.tutorialWindow:GetContentBox(), "Image")
    self.explore:SetCSSClass("play_now_content")
    
    self:CreateExploreWindow()
    
end

function GUIMainMenu:SetTutorialContentInvisible()

    self.tutorial:SetIsVisible(false)
    self.explore:SetIsVisible(false)
    self.tutorialWindow:DisableSlideBar()
    self.tutorialWindow:ResetSlideBar()
    self.exploreButton:SetIsVisible(false)

end

function GUIMainMenu:CreateTutorialWindow()

    self.tutorialWindow = self:CreateWindow()
    self.tutorialWindow:DisableCloseButton()
    self:SetupWindow(self.tutorialWindow, "TRAINING")
    self.tutorialWindow:SetCSSClass("tutorial_window")
    
    local back = CreateMenuElement(self.tutorialWindow, "MenuButton")
    back:SetCSSClass("back")
    back:SetText("BACK")
    back:AddEventCallbacks( { OnClick = function() self.tutorialWindow:SetIsVisible(false) end } )
    
    local tabs = 
        {
            { label = "TUTORIAL", func = function(self) self.scriptHandle:SetTutorialContentInvisible() self.scriptHandle.tutorial:SetIsVisible(true) end },
            { label = "EXPLORE MODE", func = function(self) self.scriptHandle:SetTutorialContentInvisible() self.scriptHandle.explore:SetIsVisible(true) self.scriptHandle.exploreButton:SetIsVisible(true) end },
        }
        
    local xTabWidth = 256

    local tabBackground = CreateMenuElement(self.tutorialWindow, "Image")
    tabBackground:SetCSSClass("tab_background")
    tabBackground:SetIgnoreEvents(true)
    
    local tabAnimateTime = 0.1
        
    for i = 1,#tabs do
    
        local tab = tabs[i]
        local tabButton = CreateMenuElement(self.tutorialWindow, "MenuButton")
        
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

    CreateTutorialPage(self)
    CreateExplorePage(self)
    
    self:SetTutorialContentInvisible()
    self.tutorial:SetIsVisible(true)


end