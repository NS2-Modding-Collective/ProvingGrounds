// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\GUIAvatarHUD.lua
//
// Created by: Andy 'Soul Rider' for Proving Grounds mod
//
// Animated 3d Hud for Avatars.
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/GUIUtility.lua")
Script.Load("lua/GUIAnimatedScript.lua")
Script.Load("lua/Hud/Marine/GUIMarineStatus.lua")
Script.Load("lua/Hud/Marine/GUIMarineHUDStyle.lua")
Script.Load("lua/Hud/GUIInventory.lua")
Script.Load("lua/TechTreeConstants.lua")

class 'GUIAvatarHUD' (GUIAnimatedScript)

// TEXTURES
GUIAvatarHUD.kFrameTexture = PrecacheAsset ("ui/marine_HUD_frame.dds")
GUIAvatarHUD.kFrameTopLeftCoords = { 0, 0, 680, 384 }
GUIAvatarHUD.kFrameTopRightCoords = { 680, 0, 1360, 384 }
GUIAvatarHUD.kFrameBottomLeftCoords = { 0, 384, 680, 768 }
GUIAvatarHUD.kFrameBottomRightCoords = { 680, 384, 1360, 768 }
GUIAvatarHUD.kFrameSize = Vector(1000, 600, 0)

// FONT

GUIAvatarHUD.kTextFontName = "fonts/AgencyFB_small.fnt"

GUIAvatarHUD.kGameTimeTextFontSize = 26
GUIAvatarHUD.kGameTimeTextPos = Vector(210, -170, 0)

GUIAvatarHUD.kLocationTextSize = 22
GUIAvatarHUD.kLocationTextOffset = Vector(180, 46, 0)

// the hud will not show more notifications than at this intervall to prevent too much spam
GUIAvatarHUD.kNotificationUpdateIntervall = 0.2

// COLORS
GUIAvatarHUD.kBackgroundColor = Color(0x01 / 0xFF, 0x8F / 0xFF, 0xFF / 0xFF, 1)

// animation callbacks
function AnimFadeIn(scriptHandle, itemHandle)
    itemHandle:FadeIn(1, nil, AnimateLinear, AnimFadeOut)
end

function AnimFadeOut(scriptHandle, itemHandle)
    itemHandle:FadeOut(1, nil, AnimateLinear, AnimFadeIn)
end

function GUIAvatarHUD:Initialize()

    GUIAnimatedScript.Initialize(self)
  
    self.scale =  Client.GetScreenHeight() / kBaseScreenHeight
    self.lastNotificationUpdate = Client.GetTime()
    
    // used for global offset
    
    self.background = self:CreateAnimatedGraphicItem()
    self.background:SetIsScaling(false)
    self.background:SetSize( Vector(Client.GetScreenWidth(), Client.GetScreenHeight(), 0) )
    self.background:SetPosition( Vector(0, 0, 0) ) 
    self.background:SetIsVisible(true)
    self.background:SetLayer(kGUILayerPlayerHUDBackground)
    self.background:SetColor( Color(1, 1, 1, 0) )
    
    self:InitFrame()
   
    // create all hud elements
    
    //self.gameTimeText = self:CreateAnimatedTextItem()
    //self.gameTimeText:SetLayer(kGUILayerPlayerHUDForeground2)
    //self.gameTimeText:SetFontName(GUIAvatarHUD.kTextFontName)
    //self.gameTimeText:SetAnchor(GUIItem.Left, GUIItem.Bottom)
    //self.gameTimeText:SetColor(kBrightColor)
    //self.gameTimeText:SetTextAlignmentX(GUIItem.Align_Center)
    //self.gameTimeText:AddAsChildTo(self.background)
    
    self.locationText = self:CreateAnimatedTextItem()
    self.locationText:SetFontName(GUIAvatarHUD.kTextFontName)
    self.locationText:SetTextAlignmentX(GUIItem.Align_Max)
    self.locationText:SetTextAlignmentY(GUIItem.Align_Min)
    self.locationText:SetAnchor(GUIItem.Left, GUIItem.Top)
    self.locationText:SetLayer(kGUILayerPlayerHUDForeground2)
    self.locationText:SetColor(kBrightColor)
    self.locationText:SetFontIsBold(true)
    self.locationText:AddAsChildTo(self.background)
    
    self.statusDisplay = CreateStatusDisplay(self, kGUILayerPlayerHUDForeground1, self.background)
    
    local style = { }
    style.textColor = kBrightColor
    style.textureSet = "marine"
    self.inventoryDisplay = CreateInventoryDisplay(self, kGUILayerPlayerHUDForeground1, self.background)
    
	self:Reset()
    
    self:Update(0)

end

function GUIAvatarHUD:InitFrame()

    self.topLeftFrame = GetGUIManager():CreateGraphicItem()
    self.topLeftFrame:SetTexture(GUIAvatarHUD.kFrameTexture)
    self.topLeftFrame:SetAnchor(GUIItem.Left, GUIItem.Top)
    self.topLeftFrame:SetTexturePixelCoordinates(unpack(GUIAvatarHUD.kFrameTopLeftCoords))
    self.background:AddChild(self.topLeftFrame)
    
    self.topRightFrame = GetGUIManager():CreateGraphicItem()
    self.topRightFrame:SetTexture(GUIAvatarHUD.kFrameTexture)
    self.topRightFrame:SetAnchor(GUIItem.Right, GUIItem.Top)
    self.topRightFrame:SetTexturePixelCoordinates(unpack(GUIAvatarHUD.kFrameTopRightCoords))
    self.background:AddChild(self.topRightFrame)
    
    self.bottomLeftFrame = GetGUIManager():CreateGraphicItem()
    self.bottomLeftFrame:SetTexture(GUIAvatarHUD.kFrameTexture)
    self.bottomLeftFrame:SetAnchor(GUIItem.Left, GUIItem.Bottom)
    self.bottomLeftFrame:SetTexturePixelCoordinates(unpack(GUIAvatarHUD.kFrameBottomLeftCoords))
    self.background:AddChild(self.bottomLeftFrame)
    
    self.bottomRightFrame = GetGUIManager():CreateGraphicItem()
    self.bottomRightFrame:SetTexture(GUIAvatarHUD.kFrameTexture)
    self.bottomRightFrame:SetAnchor(GUIItem.Right, GUIItem.Bottom)
    self.bottomRightFrame:SetTexturePixelCoordinates(unpack(GUIAvatarHUD.kFrameBottomRightCoords))
    self.background:AddChild(self.bottomRightFrame)

end

function GUIAvatarHUD:Uninitialize()

    GUIAnimatedScript.Uninitialize(self)

    if self.statusDisplay then
        self.statusDisplay:Destroy()
        self.statusDisplay = nil
    end
    
    if self.inventoryDisplay then
        self.inventoryDisplay:Destroy()
        self.inventoryDisplay = nil
    end

end

function GUIAvatarHUD:SetIsVisible(isVisible)
    self.background:SetIsVisible(isVisible)
end

function GUIAvatarHUD:SetStatusDisplayVisible(visible)
    self.statusDisplay:SetIsVisible(visible)
end

function GUIAvatarHUD:SetFrameVisible(visible)

    self.topLeftFrame:SetIsVisible(visible)
    self.topRightFrame:SetIsVisible(visible)
    self.bottomLeftFrame:SetIsVisible(visible)
    self.bottomRightFrame:SetIsVisible(visible)
    
end

function GUIAvatarHUD:SetInventoryDisplayVisible(visible)
    self.inventoryDisplay:SetIsVisible(visible)
end

function GUIAvatarHUD:Reset()
    
    // --- kGUILayerPlayerHUDForeground1
    
    self.statusDisplay:Reset(self.scale)
    self.inventoryDisplay:Reset(self.scale)

    self.locationText:SetUniformScale(self.scale)
    self.locationText:SetScale(GetScaledVector())
    self.locationText:SetPosition(GUIAvatarHUD.kLocationTextOffset)

    self.topLeftFrame:SetSize(GUIAvatarHUD.kFrameSize * self.scale)
    
    self.topRightFrame:SetSize(GUIAvatarHUD.kFrameSize * self.scale)
    self.topRightFrame:SetPosition(Vector(-GUIAvatarHUD.kFrameSize.x, 0, 0) * self.scale)
    
    self.bottomLeftFrame:SetSize(GUIAvatarHUD.kFrameSize * self.scale)
    self.bottomLeftFrame:SetPosition(Vector(0, -GUIAvatarHUD.kFrameSize.y, 0) * self.scale)
    
    self.bottomRightFrame:SetSize(GUIAvatarHUD.kFrameSize * self.scale)
    self.bottomRightFrame:SetPosition(Vector(-GUIAvatarHUD.kFrameSize.x, -GUIAvatarHUD.kFrameSize.y, 0) * self.scale)

end

function GUIAvatarHUD:Update(deltaTime)

    PROFILE("GUIAvatarHUD:Update")
    
    // Update health / armor bar
    self.statusDisplay:Update(deltaTime, { PlayerUI_GetPlayerHealth(), PlayerUI_GetPlayerMaxHealth(), PlayerUI_GetPlayerArmor(), PlayerUI_GetPlayerMaxArmor() } )
       
    // Update notifications and events
    if self.lastNotificationUpdate + GUIAvatarHUD.kNotificationUpdateIntervall < Client.GetTime() then
    
        self.lastNotificationUpdate = Client.GetTime()
        
    end
    
    // Update inventory
    self.inventoryDisplay:Update(deltaTime, { PlayerUI_GetActiveWeaponTechId(), PlayerUI_GetInventoryTechIds() })
    
    // Update game time
    local gameTime = PlayerUI_GetGameStartTime()
    
    if gameTime ~= 0 then
        gameTime = math.floor(Shared.GetTime()) - PlayerUI_GetGameStartTime()
    end
    
    //local minutes = math.floor(gameTime/60)
    //local seconds = gameTime - minutes*60
    //local gameTimeText = string.format("game time: %d:%02d", minutes, seconds)
    
    //self.gameTimeText:SetText(gameTimeText)
    
    // Update minimap
    local locationName = PlayerUI_GetLocationName()
    if locationName then
        locationName = string.upper(locationName)
    else
        locationName = ""
    end
    
    if self.lastLocationText ~= locationName then
    
        // Delete current string and start write animation
        self.locationText:DestroyAnimations()
        self.locationText:SetText("")
        self.locationText:SetText(string.format(Locale.ResolveString("IN_LOCATION"), locationName), 0.8)
        
        self.lastLocationText = locationName
        
    end    
    // Updates animations
    GUIAnimatedScript.Update(self, deltaTime)
        
end

function GUIAvatarHUD:SetIsVisible(isVisible)
    self.background:SetIsVisible(isVisible)
end

function GUIAvatarHUD:OnResolutionChanged(oldX, oldY, newX, newY)

    self.scale = newY / kBaseScreenHeight 
    self.background:SetSize( Vector(newX, newY, 0) )
    
    self:Reset()
    
end