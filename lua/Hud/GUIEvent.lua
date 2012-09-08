// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\GUIEvent.lua
//
// Created by: Andreas Urwalek (a_urwa@sbox.tugraz.at)
//
// Shows a list of events, for example: Flamethrower researched and commander notifications.
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/Hud/GUINotificationItem.lua")
Script.Load("lua/Utility.lua")

class 'GUIEvent'

function CreateEventDisplay(scriptHandle, hudLayer, frame, useMarineStyle)

    local eventDisplay = GUIEvent()
    eventDisplay.script = scriptHandle
    eventDisplay.hudLayer = hudLayer
    eventDisplay.frame = frame
    eventDisplay.useMarineStyle = useMarineStyle
    eventDisplay:Initialize()
    return eventDisplay

end

GUIEvent.kUnlockTexture = "ui/marine_HUD_unlocked.dds"
GUIEvent.kAlienUnlockTexture = "ui/alien_HUD_unlocked.dds"

GUIEvent.kUnlockFontSize = 16
GUIEvent.kUnlockBottomTextColor = Color(246/255, 254/255, 37/255 )

// borders etc for unlock are multiplied by this
local sizeScale = 1.2

local kUnlockIconParams = nil
local kUnlockIconHeight = 150
local kUnlockIconWidth = 256
local kUnlockIconSize = Vector(kUnlockIconWidth, kUnlockIconHeight, 0)
local function GetUnlockIconParams(unlockId)

    if not kUnlockIconParams then
    
        kUnlockIconParams = { }
        
        kUnlockIconParams[kTechId.FlamethrowerTech] =       { techLevel = 0, coords = { 0, 3 * kUnlockIconHeight, kUnlockIconWidth, 4 * kUnlockIconHeight }, description = "EVT_FLAMETHROWER_RESEARCHED", bottomText = "EVT_BUY_AT_ARMORY" }
        kUnlockIconParams[kTechId.ShotgunTech] =            { techLevel = 0, coords = { 0, 4 * kUnlockIconHeight, kUnlockIconWidth, 5 * kUnlockIconHeight }, description = "EVT_SHOTGUN_RESEARCHED", bottomText = "EVT_BUY_AT_ARMORY" }
        kUnlockIconParams[kTechId.GrenadeLauncherTech] =    { techLevel = 0, coords = { 0, 5 * kUnlockIconHeight, kUnlockIconWidth, 6 * kUnlockIconHeight }, description = "EVT_GRENADE_LAUNCHER_RESEARCHED", bottomText = "EVT_BUY_AT_ARMORY" }
        kUnlockIconParams[kTechId.JetpackTech] =            { techLevel = 0, coords = { 0, 6 * kUnlockIconHeight, kUnlockIconWidth, 7 * kUnlockIconHeight }, description = "EVT_JETPACK_RESEARCHED", bottomText = "EVT_BUY_AT_PROTOTYPE_LAB" }
        kUnlockIconParams[kTechId.ExosuitTech] =            { techLevel = 0, coords = { 0, 7 * kUnlockIconHeight, kUnlockIconWidth, 8 * kUnlockIconHeight }, description = "EVT_EXOSUIT_RESEARCHED", bottomText = "EVT_BUY_AT_PROTOTYPE_LAB" }
        kUnlockIconParams[kTechId.DualMinigunTech] =        { techLevel = 0, coords = { 0, 10 * kUnlockIconHeight, kUnlockIconWidth, 11 * kUnlockIconHeight }, description = "EVT_DUALMINIGUN_RESEARCHED", bottomText = "EVT_BUY_AT_PROTOTYPE_LAB" }
        
        kUnlockIconParams[kTechId.Armor1] = { techLevel = 1, coords = { 0, 8 * kUnlockIconHeight, kUnlockIconWidth, 9 * kUnlockIconHeight }, description = "EVT_ARMOR_LEVEL_1_RESEARCHED" }
        kUnlockIconParams[kTechId.Armor2] = { techLevel = 2, coords = { 0, 8 * kUnlockIconHeight, kUnlockIconWidth, 9 * kUnlockIconHeight }, description = "EVT_ARMOR_LEVEL_2_RESEARCHED" }
        kUnlockIconParams[kTechId.Armor3] = { techLevel = 3, coords = { 0, 8 * kUnlockIconHeight, kUnlockIconWidth, 9 * kUnlockIconHeight }, description = "EVT_ARMOR_LEVEL_3_RESEARCHED" }
        
        kUnlockIconParams[kTechId.Weapons1] = { techLevel = 1, coords = { 0, 9 * kUnlockIconHeight, kUnlockIconWidth, 10 * kUnlockIconHeight }, description = "EVT_WEAPON_LEVEL_1_RESEARCHED" }
        kUnlockIconParams[kTechId.Weapons2] = { techLevel = 2, coords = { 0, 9 * kUnlockIconHeight, kUnlockIconWidth, 10 * kUnlockIconHeight }, description = "EVT_WEAPON_LEVEL_2_RESEARCHED" }
        kUnlockIconParams[kTechId.Weapons3] = { techLevel = 3, coords = { 0, 9 * kUnlockIconHeight, kUnlockIconWidth, 10 * kUnlockIconHeight }, description = "EVT_WEAPON_LEVEL_3_RESEARCHED" }
        
        kUnlockIconParams[kTechId.Leap] = { techLevel = 2, coords = { 0, 3 * kUnlockIconHeight, kUnlockIconWidth, 4 * kUnlockIconHeight }, description = "EVT_LEAP_RESEARCHED" }
        kUnlockIconParams[kTechId.BileBomb] = { techLevel = 2, coords = { 0, 4 * kUnlockIconHeight, kUnlockIconWidth, 5 * kUnlockIconHeight }, description = "EVT_BILE_BOMB_RESEARCHED" }
        kUnlockIconParams[kTechId.Spores] = { techLevel = 2, coords = { 0, 5 * kUnlockIconHeight, kUnlockIconWidth, 6 * kUnlockIconHeight }, description = "EVT_SPORES_RESEARCHED" }
        kUnlockIconParams[kTechId.Blink] = { techLevel = 2, coords = { 0, 6 * kUnlockIconHeight, kUnlockIconWidth, 7 * kUnlockIconHeight }, description = "EVT_BLINK_RESEARCHED" }
        kUnlockIconParams[kTechId.Stomp] = { techLevel = 2, coords = { 0, 7 * kUnlockIconHeight, kUnlockIconWidth, 8 * kUnlockIconHeight }, description = "EVT_STOMP_RESEARCHED" }
        
        kUnlockIconParams[kTechId.Xenocide] = { techLevel = 3, coords = { 0, 8 * kUnlockIconHeight, kUnlockIconWidth, 9 * kUnlockIconHeight }, description = "EVT_XENOCIDE_RESEARCHED" }
        kUnlockIconParams[kTechId.Umbra] = { techLevel = 3, coords = { 0, 10 * kUnlockIconHeight, kUnlockIconWidth, 11 * kUnlockIconHeight }, description = "EVT_UMBRA_RESEARCHED" }
        kUnlockIconParams[kTechId.Vortex] = { techLevel = 3, coords = { 0, 11 * kUnlockIconHeight, kUnlockIconWidth, 12 * kUnlockIconHeight }, description = "EVT_VORTEX_RESEARCHED" }
        
    end
    
    if kUnlockIconParams[unlockId] then
    
        return kUnlockIconParams[unlockId].techLevel, kUnlockIconParams[unlockId].coords,
               Locale.ResolveString(kUnlockIconParams[unlockId].description),
               kUnlockIconParams[unlockId].bottomText and Locale.ResolveString(kUnlockIconParams[unlockId].bottomText) or nil
        
    end
    
end

GUIEvent.kTexture = "ui/marine_HUD_notifyFrame.dds"
GUIEvent.kTextureMiddleBackground = "ui/marine_HUD_notifyMiddleBackground.dds"
GUIEvent.kTextureMiddleBorder = "ui/marine_HUD_notifyMiddleBorder.dds"

GUIEvent.kAlienTexture = "ui/alien_HUD_notifyFrame.dds"
GUIEvent.kAlienTextureMiddleBackground = "ui/alien_HUD_notifyMiddleBackground.dds"
GUIEvent.kAlienTextureMiddleBorder = "ui/alien_HUD_notifyMiddleBorder.dds"

GUIEvent.kFramepos = Vector(30 , 380, 0)
GUIEvent.kAlienFramepos = Vector(-128 , 40, 0)

GUIEvent.kBorderTopTextureCoords = { 0, 0, 320, 24 + 6 }

GUIEvent.kBackgroundTopTextureCoords = { 0, 57, 320, 57 + 24 }

GUIEvent.kTopSize = Vector(400, 128, 0)

GUIEvent.kMiddleTextureCoords = { 0, 0, 320, 0 }
GUIEvent.kMiddleWidth = GUIEvent.kMiddleTextureCoords[3]

GUIEvent.kPurchaseableBorderCoords = { 0, 0, 263, 49 }
GUIEvent.kPurchaseableBgCoords = { 0, 49, 262, 98 }

GUIEvent.kFontName = "fonts/AgencyFB_small.fnt"

GUIEvent.kBackgroundAlpha = 1

GUIEvent.kNotificationYOffset = 20

// maximum number of displayed notifications at once
GUIEvent.kMaxNumDisplayedNotifications = 4
// maximum number of stacked notifications
GUIEvent.kMaxNumStackedNotifications = 5

GUIEvent.kNotificationLifeTime = 4

GUIEvent.kNotificationHeight = 95

GUIEvent.kShrinkDelay = 6

GUIEvent.kUnlockFramePos = Vector(-246, -120, 0)
GUIEvent.kAlienUnlockFramePos = Vector(-128, -120, 0)

function GUIEvent:Initialize()

    self.scale = 1
    self.timeLastNotification = Client.GetTime()
    
    self.lastNotificationCount = 0
    self.lastUnlockId = 0

    // list of notifiactions that are required to get displayed
    self.queuedNotifications = {}
    self.displayedNotifications = {}
    self.displayedPurchaseables = {}
    
    self.notificationFrame = GetGUIManager():CreateGraphicItem()
    self.notificationFrame:SetAnchor(GUIItem.Left, GUIItem.Top)
    self.notificationFrame:SetColor(Color(0,0,0,0))
    self.notificationFrame:SetLayer(0)
    self.frame:AddChild(self.notificationFrame)
    
    self.notificationAlign = GetGUIManager():CreateGraphicItem()
    self.notificationAlign:SetAnchor(GUIItem.Left, GUIItem.Top)
    self.notificationAlign:SetColor(Color(0,0,0,0))
    self.notificationAlign:SetLayer(1)
    self.notificationFrame:AddChild(self.notificationAlign)
    
    local texture = ConditionalValue(self.useMarineStyle, GUIEvent.kTexture, GUIEvent.kAlienTexture)
    
    self.borderTop = self.script:CreateAnimatedGraphicItem()
    self.borderTop:SetTexture(texture)
    self.borderTop:SetBlendTechnique(GUIItem.Add)
    self.borderTop:SetColor(Color(1,1,1,0))
    self.borderTop:AddAsChildTo(self.notificationFrame)
    
    local middleTexture = ConditionalValue(self.useMarineStyle, GUIEvent.kTextureMiddleBorder, GUIEvent.kAlienTextureMiddleBorder)
    
    self.middleBorder = self.script:CreateAnimatedGraphicItem()
    self.middleBorder:SetTexture(middleTexture)
    self.middleBorder:SetTexturePixelCoordinates(unpack(GUIEvent.kMiddleTextureCoords))
    self.middleBorder:SetBlendTechnique(GUIItem.Add)
    self.middleBorder:AddAsChildTo(self.notificationFrame)
    
    self.middleBackground = self.script:CreateAnimatedGraphicItem()
    self.middleBackground:SetTexture(middleTexture)
    self.middleBackground:SetTexturePixelCoordinates(unpack(GUIEvent.kMiddleTextureCoords))
    self.middleBackground:SetColor(Color(1,1,1,GUIEvent.kBackgroundAlpha))
    self.middleBackground:AddAsChildTo(self.notificationFrame)
    
    self.unlockFrame = self.script:CreateAnimatedGraphicItem()
    self.unlockFrame:SetAnchor(GUIItem.Right, GUIItem.Center)
    self.unlockFrame:SetColor(Color(0,0,0,0))
    self.frame:AddChild(self.unlockFrame)
    
    local unlockTexture = ConditionalValue(self.useMarineStyle, GUIEvent.kUnlockTexture, GUIEvent.kAlienUnlockTexture)
    
    // used for techLevel
    self.unlockTechLevelStencil = self.script:CreateAnimatedGraphicItem()
    self.unlockTechLevelStencil:SetIsStencil(true)
    self.unlockTechLevelStencil:SetClearsStencilBuffer(true)
    self.unlockTechLevelStencil:AddAsChildTo(self.unlockFrame)
    
    self.unlockScanLines = self.script:CreateAnimatedGraphicItem()
    self.unlockScanLines:SetBlendTechnique(GUIItem.Add)
    self.unlockScanLines:SetTexture(unlockTexture)
    self.unlockScanLines:SetTexturePixelCoordinates(0, 0, kUnlockIconWidth, kUnlockIconHeight)
    self.unlockScanLines:SetColor(Color(1,1,1,0.0))
    self.unlockScanLines:AddAsChildTo(self.unlockFrame)
    
    self.unlockBorder = self.script:CreateAnimatedGraphicItem()
    self.unlockBorder:SetBlendTechnique(GUIItem.Add)
    self.unlockBorder:SetTexture(unlockTexture)
    self.unlockBorder:SetTexturePixelCoordinates(0, kUnlockIconHeight, kUnlockIconWidth, kUnlockIconHeight * 2)
    self.unlockBorder:SetStencilFunc(GUIItem.Equal)
    self.unlockBorder:SetColor(Color(1,1,1,0))
    self.unlockBorder:AddAsChildTo(self.unlockFrame)
    
    self.unlockBackground = self.script:CreateAnimatedGraphicItem()
    self.unlockBackground:SetTexture(unlockTexture)
    self.unlockBackground:SetTexturePixelCoordinates(0, kUnlockIconHeight * 2, kUnlockIconWidth, kUnlockIconHeight * 3)
    self.unlockBackground:SetColor(Color(1,1,1,0))
    self.unlockBackground:SetLayer(self.hudLayer)
    self.unlockBackground:AddAsChildTo(self.unlockFrame)
    
    self.unlockIcon = self.script:CreateAnimatedGraphicItem()
    self.unlockIcon:SetTexture(unlockTexture)
    self.unlockIcon:SetLayer(self.hudLayer + 1)
    self.unlockIcon:SetColor(Color(1,1,1,0))
    self.unlockIcon:AddAsChildTo(self.unlockFrame)
    
    self.unlockDescription = self.script:CreateAnimatedTextItem()
    self.unlockDescription:SetFontSize(GUIEvent.kUnlockFontSize)
    
    local color = Color(ConditionalValue(self.useMarineStyle, kMarineFontColor, kAlienFontColor))
    color.a = 0
    self.unlockDescription:SetColor(color)
    self.unlockDescription:SetTextAlignmentX(GUIItem.Align_Center)
    self.unlockDescription:SetTextAlignmentY(GUIItem.Align_Min)
    self.unlockDescription:SetLayer(self.hudLayer + 1)
    self.unlockDescription:SetFontName(GUIEvent.kFontName)
    self.unlockDescription:AddAsChildTo(self.unlockFrame)
    
    self.unlockBottomText = self.script:CreateAnimatedTextItem()
    self.unlockBottomText:SetFontSize(GUIEvent.kUnlockFontSize)
    self.unlockBottomText:SetColor(Color(1,1,1,0))
    self.unlockBottomText:SetLayer(self.hudLayer + 1)
    self.unlockBottomText:SetTextAlignmentX(GUIItem.Align_Center)
    self.unlockBottomText:SetTextAlignmentY(GUIItem.Align_Max)
    self.unlockBottomText:SetFontName(GUIEvent.kFontName)
    self.unlockBottomText:AddAsChildTo(self.unlockFrame)
    
    self.unlockFlashStencil = self.script:CreateAnimatedGraphicItem()
    self.unlockFlashStencil:SetTexture(unlockTexture)
    self.unlockFlashStencil:SetTexturePixelCoordinates(0, kUnlockIconHeight * 2, kUnlockIconWidth, kUnlockIconHeight * 3)
    self.unlockFlashStencil:SetIsStencil(true)
    self.unlockFlashStencil:SetClearsStencilBuffer(false)
    self.unlockFlashStencil:SetLayer(self.hudLayer + 2)
    self.unlockFlashStencil:AddAsChildTo(self.unlockFrame)
    
    self.unlockFlash = self.script:CreateAnimatedGraphicItem()
    self.unlockFlash:SetColor(Color(1,1,1,0))
    self.unlockFlash:SetStencilFunc(GUIItem.NotEqual)
    self.unlockFlash:SetLayer(self.hudLayer + 2)
    self.unlockFlash:AddAsChildTo(self.unlockFrame)
    
    self.hadNotifications = false

end

function GUIEvent:SetIsVisible(isVisible)
    self.frame:SetIsVisible(isVisible)
end

function GUIEvent:Reset(scale)

    self.scale = scale
    
    if self.useMarineStyle then
        self.notificationFrame:SetPosition(GUIEvent.kFramepos * self.scale)
    else
        self.notificationFrame:SetPosition(GUIEvent.kAlienFramepos * self.scale)
    end
    
    if self.useMarineStyle then
        self.unlockFrame:SetAnchor(GUIItem.Right, GUIItem.Center)
    else
        self.unlockFrame:SetAnchor(GUIItem.Middle, GUIItem.Top)
    end    
    
    self.notificationAlign:SetPosition(self.scale * Vector(0, GUIEvent.kNotificationYOffset, 0))
    
    self.borderTop:SetUniformScale(self.scale)
    self.borderTop:SetSize(GUIEvent.kTopSize)
    
    self.middleBorder:SetUniformScale(self.scale)
    self.middleBorder:SetPosition(Vector(0, GUIEvent.kTopSize.y, 0))
    self.middleBorder:SetSize(Vector(GUIEvent.kMiddleWidth, 0, 0))
    
    self.middleBackground:SetUniformScale(self.scale)
    self.middleBackground:SetPosition(Vector(0, GUIEvent.kTopSize.y, 0))
    self.middleBackground:SetSize(Vector(GUIEvent.kMiddleWidth, 0, 0))
    
    self.middleBorder:SetColor(Color(1,1,1,0))
    self.middleBackground:SetColor(Color(1,1,1,0))
    
    self:SetFrameHeight(28, 0.5)
    
    self.unlockFrame:SetUniformScale(self.scale)
    
    if self.useMarineStyle then
        self.unlockFrame:SetPosition(GUIEvent.kUnlockFramePos)
    else
        self.unlockFrame:SetPosition(GUIEvent.kAlienUnlockFramePos)
    end

    self.unlockTechLevelStencil:SetUniformScale(self.scale)
    self.unlockTechLevelStencil:SetSize(Vector(22, 0, 0) * sizeScale)
    
    self.unlockBorder:SetUniformScale(self.scale)
    self.unlockBorder:SetSize(kUnlockIconSize * sizeScale)    

    self.unlockScanLines:SetUniformScale(self.scale)
    self.unlockScanLines:SetSize(kUnlockIconSize * sizeScale)
    
    self.unlockBackground:SetUniformScale(self.scale)
    self.unlockBackground:SetSize(kUnlockIconSize * sizeScale)  

    self.unlockDescription:SetUniformScale(self.scale)
    self.unlockDescription:SetScale(Vector(1,1,1) * self.scale)
    self.unlockDescription:SetPosition(Vector((kUnlockIconWidth * sizeScale)/2, 20, 0))

    self.unlockBottomText:SetUniformScale(self.scale)
    self.unlockBottomText:SetScale(Vector(1,1,1) * self.scale)
    self.unlockBottomText:SetPosition(Vector((kUnlockIconWidth * sizeScale)/2, kUnlockIconHeight, 0))

    self.unlockIcon:SetUniformScale(self.scale)
    self.unlockIcon:SetSize(kUnlockIconSize * sizeScale)
    self.unlockIcon:SetPosition(Vector(0, -10, 0))
    
    self.unlockFlashStencil:SetUniformScale(self.scale)
    self.unlockFlashStencil:SetSize(kUnlockIconSize * sizeScale)
    
    self.unlockFlash:SetUniformScale(self.scale)
    self.unlockFlash:SetSize(kUnlockIconSize * sizeScale)
    
    self:ClearNotifications()

end

function GUIEvent:ClearNotifications()

    for index, notification in ipairs (self.displayedNotifications) do
        _DestroyNotification(notification)   
    end

    self.displayedNotifications = {}

end

function GUIEvent:SetFrameHeight(height, animDuration)

    self.middleBorder:SetSize(Vector(GUIEvent.kMiddleWidth, height, 0), animDuration, "ANIM_MIDDLEBORDER", AnimateSin)
    self.middleBorder:SetTexturePixelCoordinates(0, 0, GUIEvent.kMiddleWidth, height, animDuration, nil, AnimateSin)
    
    self.middleBackground:SetSize(Vector(GUIEvent.kMiddleWidth, height, 0), animDuration, "ANIM_BACKGROUND", AnimateSin)
    self.middleBackground:SetTexturePixelCoordinates(0, 0, GUIEvent.kMiddleWidth, height, animDuration, nil, AnimateSin)

end

function GUIEvent:Update(deltaTime, parameters)

    local notification, newPurchaseable, playSound = parameters[1], parameters[2], parameters[3]
    
    local shiftDown = false
    local remainingNotifications = {}
    
    if notification ~= nil then
    
        // if the new notification matches with the last one, we add it as a child (stack it up) and don't trigger a shift down
        if table.count(self.displayedNotifications) > 0 and self.displayedNotifications[1]:MatchesTo(notification.LocationName, notification.TechId) then
            if self.displayedNotifications[1]:GetNumChildren() < GUIEvent.kMaxNumStackedNotifications - 1 then
                self.displayedNotifications[1]:AddNotification()
            else
                self.displayedNotifications[1]:ResetLifeTime()
            end
        else
            local newNotification = CreateNotificationItem(self.script, notification.LocationName, notification.TechId, self.scale, self.notificationAlign, self.useMarineStyle)
            newNotification:FadeIn(0.5)
            table.insert(self.displayedNotifications, 1, newNotification)
            shiftDown = true
        end
        
    end
    
    local hasNotifications = #self.displayedNotifications ~= 0
    
    if hasNotifications ~= self.hadNotifications then
    
        if hasNotifications then
            self.borderTop:FadeIn(1, "FADE_BORDER_NOTIFICATION")
        else
            self.borderTop:FadeOut(1, "FADE_BORDER_NOTIFICATION")
        end
        
        self.hadNotifications = hasNotifications
    end
    
    for index, displayedNotification in ipairs(self.displayedNotifications) do
    
        if displayedNotification:GetCreationTime() + GUIEvent.kNotificationLifeTime < Client.GetTime() then
            displayedNotification:FadeOut(1)
        end
        
        if displayedNotification:GetIsReadyToBeDestroyed() then
            displayedNotification:Destroy()
        elseif index > GUIEvent.kMaxNumDisplayedNotifications then
            displayedNotification:FadeOut(0.5)
        else
            table.insert(remainingNotifications, displayedNotification)
            
            if shiftDown and index > 1 then
                displayedNotification:ShiftDown()
            end
            
        end
        
    end
    
    self.displayedNotifications = remainingNotifications
    
    if self.lastNotificationCount ~= table.count(self.displayedNotifications) then
    
        local currentNotificationCount = table.count(self.displayedNotifications)
        
        // make shrinking happen slowlier than expanding
        if currentNotificationCount > self.lastNotificationCount then
            self:SetFrameHeight(2 + GUIEvent.kNotificationHeight * currentNotificationCount, 0.5)
        elseif currentNotificationCount == 0 then
            self:SetFrameHeight(24, 0.5)
        end
        
        self.lastNotificationCount = currentNotificationCount

    end
    
    if self.lastUnlockId ~= newPurchaseable then
        
        if newPurchaseable == 0 then

            self:FadeOutUnlockItem(1.5)
        
        else
        
            self:UpdateUnlockDisplay(newPurchaseable)
            self:FadeInUnlockItem(0.5)

            if playSound then
                Client.GetLocalPlayer():TriggerEffects("upgrade_complete")
            end
        
        end
        
        self.lastUnlockId = newPurchaseable
    end

end

function GUIEvent:FadeOutUnlockItem(animationSpeed)
    
    self.unlockFrame:DestroyAnimations()
    
    if self.useMarineStyle then
        self.unlockFrame:SetPosition(GUIEvent.kUnlockFramePos, animationSpeed)
    else
        self.unlockFrame:SetPosition(GUIEvent.kAlienUnlockFramePos, animationSpeed)
    end
    

    self.unlockScanLines:DestroyAnimations()
    self.unlockScanLines:FadeOut(animationSpeed)

    self.unlockIcon:DestroyAnimations()
    self.unlockIcon:FadeOut(animationSpeed)
    
    self.unlockBorder:DestroyAnimations()
    self.unlockBorder:FadeOut(animationSpeed)
    
    self.unlockBackground:DestroyAnimations()
    self.unlockBackground:FadeOut(animationSpeed)
    
    self.unlockDescription:DestroyAnimations()
    self.unlockDescription:FadeOut(animationSpeed)
    
    self.unlockBottomText:DestroyAnimations()
    self.unlockBottomText:FadeOut(animationSpeed)

end

function GUIEvent:FadeInUnlockItem(animationSpeed)

    self.unlockFrame:DestroyAnimations()
    
    if self.useMarineStyle then
        self.unlockFrame:SetPosition(GUIEvent.kUnlockFramePos + Vector(-64, 0, 0), animationSpeed)
    else
        self.unlockFrame:SetPosition(GUIEvent.kAlienUnlockFramePos + Vector(0, 128, 0), animationSpeed)
    end

    self.unlockFlash:DestroyAnimations()
    self.unlockFlash:SetColor(Color(1,1,1,1))
    self.unlockFlash:FadeOut(animationSpeed)
    
    self.unlockIcon:DestroyAnimations()
    self.unlockIcon:SetColor(Color(1,1,1,1))
    
    self.unlockBorder:DestroyAnimations()
    self.unlockBorder:SetColor(Color(1,1,1,1))
    
    self.unlockBackground:DestroyAnimations()
    self.unlockBackground:SetColor(Color(1,1,1,1))
    
    self.unlockDescription:DestroyAnimations()
    self.unlockDescription:SetColor(ConditionalValue(self.useMarineStyle, kMarineFontColor, kAlienFontColor))
    
    self.unlockScanLines:DestroyAnimations()
    self.unlockScanLines:SetColor(Color(1,1,1,1))
    
    self.unlockBottomText:DestroyAnimations()
    self.unlockBottomText:SetColor(GUIEvent.kUnlockBottomTextColor)

end

function GUIEvent:UpdateUnlockDisplay(unlockId)

    local techLevel, coords, description, bottomText = GetUnlockIconParams(unlockId)
    
    local stencilHeight = kUnlockIconHeight
    local stencilWidth = 22
    
    if techLevel then
        stencilHeight = kUnlockIconHeight * (1 - techLevel / 3)
    end
    
    self.unlockTechLevelStencil:SetSize(Vector(stencilWidth, stencilHeight, 0) * sizeScale)
 
    self.unlockDescription:SetText(ConditionalValue(description ~= nil, description, ""))    
    self.unlockBottomText:SetText(ConditionalValue(bottomText ~= nil, bottomText, ""))
    
    self.unlockIcon:SetTexturePixelCoordinates(unpack(coords))

end

function GUIEvent:Destroy()

    if self.notificationFrame then
        GUI.DestroyItem(self.notificationFrame)
        self.notificationFrame = nil
    end    

end