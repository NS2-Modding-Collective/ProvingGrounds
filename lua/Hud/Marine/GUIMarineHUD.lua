// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\GUIMarineHUD.lua
//
// Created by: Andreas Urwalek (a_urwa@sbox.tugraz.at)
//
// Animated 3d Hud for Marines.
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/GUIUtility.lua")
Script.Load("lua/GUIAnimatedScript.lua")

Script.Load("lua/Hud/Marine/GUIMarineStatus.lua")
Script.Load("lua/Hud/GUIEvent.lua")
Script.Load("lua/Hud/Marine/GUIMarineHUDStyle.lua")
Script.Load("lua/Hud/GUIInventory.lua")
Script.Load("lua/TechTreeConstants.lua")

class 'GUIMarineHUD' (GUIAnimatedScript)

// position and size for stencil buffer
GUIMarineHUD.kStencilSize = Vector(400, 256, 0)
GUIMarineHUD.kStencilPos = Vector(0, 128, 0)

GUIMarineHUD.kFrameTexture = PrecacheAsset("ui/marine_HUD_frame.dds")
GUIMarineHUD.kFrameTopLeftCoords = { 0, 0, 680, 384 }
GUIMarineHUD.kFrameTopRightCoords = { 680, 0, 1360, 384 }
GUIMarineHUD.kFrameBottomLeftCoords = { 0, 384, 680, 768 }
GUIMarineHUD.kFrameBottomRightCoords = { 680, 384, 1360, 768 }
GUIMarineHUD.kFrameSize = Vector(1000, 600, 0)

// FONT

GUIMarineHUD.kTextFontName = "fonts/AgencyFB_small.fnt"

GUIMarineHUD.kGameTimeTextFontSize = 26
GUIMarineHUD.kGameTimeTextPos = Vector(210, -170, 0)

GUIMarineHUD.kLocationTextSize = 22
GUIMarineHUD.kLocationTextOffset = Vector(180, 46, 0)

// the hud will not show more notifications than at this intervall to prevent too much spam
GUIMarineHUD.kNotificationUpdateIntervall = 0.2

// COLORS

GUIMarineHUD.kBackgroundColor = Color(0x01 / 0xFF, 0x8F / 0xFF, 0xFF / 0xFF, 1)

// animation callbacks

function AnimFadeIn(scriptHandle, itemHandle)
    itemHandle:FadeIn(1, nil, AnimateLinear, AnimFadeOut)
end

function AnimFadeOut(scriptHandle, itemHandle)
    itemHandle:FadeOut(1, nil, AnimateLinear, AnimFadeIn)
end

function GUIMarineHUD:Initialize()

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
      
    //self.gameTimeText = self:CreateAnimatedTextItem()
    //self.gameTimeText:SetLayer(kGUILayerPlayerHUDForeground2)
    //self.gameTimeText:SetFontName(GUIMarineHUD.kTextFontName)
    //self.gameTimeText:SetAnchor(GUIItem.Left, GUIItem.Bottom)
    //self.gameTimeText:SetColor(kBrightColor)
    //self.gameTimeText:SetTextAlignmentX(GUIItem.Align_Center)
    //self.gameTimeText:AddAsChildTo(self.background)
       
    self.locationText = self:CreateAnimatedTextItem()
    self.locationText:SetFontName(GUIMarineHUD.kTextFontName)
    self.locationText:SetTextAlignmentX(GUIItem.Align_Max)
    self.locationText:SetTextAlignmentY(GUIItem.Align_Min)
    self.locationText:SetAnchor(GUIItem.Left, GUIItem.Top)
    self.locationText:SetLayer(kGUILayerPlayerHUDForeground2)
    self.locationText:SetColor(kBrightColor)
    self.locationText:SetFontIsBold(true)
    self.locationText:AddAsChildTo(self.background)
    
    
    self.statusDisplay = CreateStatusDisplay(self, kGUILayerPlayerHUDForeground1, self.background)
    self.eventDisplay = CreateEventDisplay(self, kGUILayerPlayerHUDForeground1, self.background, true)
    
    local style = { }
    style.textColor = kBrightColor
    style.textureSet = "marine"
  
	self:Reset()
    
    self:Update(0)

end

function GUIMarineHUD:InitFrame()

    self.topLeftFrame = GetGUIManager():CreateGraphicItem()
    self.topLeftFrame:SetTexture(GUIMarineHUD.kFrameTexture)
    self.topLeftFrame:SetAnchor(GUIItem.Left, GUIItem.Top)
    self.topLeftFrame:SetTexturePixelCoordinates(unpack(GUIMarineHUD.kFrameTopLeftCoords))
    self.background:AddChild(self.topLeftFrame)
    
    self.topRightFrame = GetGUIManager():CreateGraphicItem()
    self.topRightFrame:SetTexture(GUIMarineHUD.kFrameTexture)
    self.topRightFrame:SetAnchor(GUIItem.Right, GUIItem.Top)
    self.topRightFrame:SetTexturePixelCoordinates(unpack(GUIMarineHUD.kFrameTopRightCoords))
    self.background:AddChild(self.topRightFrame)
    
    self.bottomLeftFrame = GetGUIManager():CreateGraphicItem()
    self.bottomLeftFrame:SetTexture(GUIMarineHUD.kFrameTexture)
    self.bottomLeftFrame:SetAnchor(GUIItem.Left, GUIItem.Bottom)
    self.bottomLeftFrame:SetTexturePixelCoordinates(unpack(GUIMarineHUD.kFrameBottomLeftCoords))
    self.background:AddChild(self.bottomLeftFrame)
    
    self.bottomRightFrame = GetGUIManager():CreateGraphicItem()
    self.bottomRightFrame:SetTexture(GUIMarineHUD.kFrameTexture)
    self.bottomRightFrame:SetAnchor(GUIItem.Right, GUIItem.Bottom)
    self.bottomRightFrame:SetTexturePixelCoordinates(unpack(GUIMarineHUD.kFrameBottomRightCoords))
    self.background:AddChild(self.bottomRightFrame)

end


function GUIMarineHUD:Uninitialize()

    GUIAnimatedScript.Uninitialize(self)

    if self.statusDisplay then
        self.statusDisplay:Destroy()
        self.statusDisplay = nil
    end
    
    if self.eventDisplay then    
        self.eventDisplay:Destroy()   
        self.eventDisplay = nil 
    end
end

function GUIMarineHUD:SetStatusDisplayVisible(visible)
    self.statusDisplay:SetIsVisible(visible)
end

function GUIMarineHUD:SetFrameVisible(visible)

    self.topLeftFrame:SetIsVisible(visible)
    self.topRightFrame:SetIsVisible(visible)
    self.bottomLeftFrame:SetIsVisible(visible)
    self.bottomRightFrame:SetIsVisible(visible)
    
end

function GUIMarineHUD:SetInventoryDisplayVisible(visible)
    self.inventoryDisplay:SetIsVisible(visible)
end

function GUIMarineHUD:Reset()
    
    // --- kGUILayerPlayerHUDForeground1
   
    self.statusDisplay:Reset(self.scale)
    self.eventDisplay:Reset(self.scale)
        
    self.locationText:SetUniformScale(self.scale)
    self.locationText:SetScale(GetScaledVector())
    self.locationText:SetPosition(GUIMarineHUD.kLocationTextOffset)

    self.topLeftFrame:SetSize(GUIMarineHUD.kFrameSize * self.scale)
    
    self.topRightFrame:SetSize(GUIMarineHUD.kFrameSize * self.scale)
    self.topRightFrame:SetPosition(Vector(-GUIMarineHUD.kFrameSize.x, 0, 0) * self.scale)
    
    self.bottomLeftFrame:SetSize(GUIMarineHUD.kFrameSize * self.scale)
    self.bottomLeftFrame:SetPosition(Vector(0, -GUIMarineHUD.kFrameSize.y, 0) * self.scale)
    
    self.bottomRightFrame:SetSize(GUIMarineHUD.kFrameSize * self.scale)
    self.bottomRightFrame:SetPosition(Vector(-GUIMarineHUD.kFrameSize.x, -GUIMarineHUD.kFrameSize.y, 0) * self.scale)

end


function GUIMarineHUD:TriggerInitAnimations()
    
end

function GUIMarineHUD:Update(deltaTime)

    PROFILE("GUIMarineHUD:Update")
    
    /*
    if PlayerUI_GetHasNewOrder() then
        self.minimapScript:SetDesiredZoom(0.3)
    else
        self.minimapScript:SetDesiredZoom(1)
    end
    */
    
    // Update health bar
    self.statusDisplay:Update(deltaTime, { PlayerUI_GetPlayerHealth(), PlayerUI_GetPlayerMaxHealth() } )
    GUIAnimatedScript.Update(self, deltaTime)   
 
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
end
    
function GUIMarineHUD:SetIsVisible(isVisible)
    self.background:SetIsVisible(isVisible)
end


function GUIMarineHUD:OnAnimationCompleted(animatedItem, animationName, itemHandle)

    
end

function GUIMarineHUD:OnLocalPlayerChanged(newPlayer)
    
    self:SetStatusDisplayVisible(true)
    self:SetFrameVisible(true)
    if newPlayer:GetTeamNumber() ~= kTeamReadyRoom and Client.GetIsControllingPlayer() then
        self:TriggerInitAnimations()     
    end
    
end

function GUIMarineHUD:OnResolutionChanged(oldX, oldY, newX, newY)

    self.scale = newY / kBaseScreenHeight 
    self.background:SetSize( Vector(newX, newY, 0) )
    
    self:Reset()
    
end