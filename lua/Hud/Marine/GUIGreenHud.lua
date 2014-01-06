// =========================================================================================
//
// lua\GUIGreenHud.lua
//
//    Created by:   Andy 'Soul Rider' Wilson for Proving Grounds Mod
//
// ================================================================================================

Script.Load("lua/GUIUtility.lua")
Script.Load("lua/GUIAnimatedScript.lua")

Script.Load("lua/Hud/Marine/GUIMarineStatus.lua")
Script.Load("lua/Hud/GUIEvent.lua")
Script.Load("lua/Hud/Marine/GUIMarineHUDStyle.lua")
Script.Load("lua/Hud/GUIInventory.lua")
Script.Load("lua/TechTreeConstants.lua")

class 'GUIGreenHUD' (GUIAnimatedScript)

// position and size for stencil buffer
GUIGreenHUD.kStencilSize = Vector(400, 256, 0)
GUIGreenHUD.kStencilPos = Vector(0, 128, 0)

GUIGreenHUD.kFrameTexture = PrecacheAsset("ui/green_HUD_frame.dds")
GUIGreenHUD.kFrameTopLeftCoords = { 0, 0, 680, 384 }
GUIGreenHUD.kFrameTopRightCoords = { 680, 0, 1360, 384 }
GUIGreenHUD.kFrameBottomLeftCoords = { 0, 384, 680, 768 }
GUIGreenHUD.kFrameBottomRightCoords = { 680, 384, 1360, 768 }
GUIGreenHUD.kFrameSize = Vector(1000, 600, 0)

// FONT

GUIGreenHUD.kTextFontName = "fonts/AgencyFB_small.fnt"

GUIGreenHUD.kGameTimeTextFontSize = 26
GUIGreenHUD.kGameTimeTextPos = Vector(210, -170, 0)

GUIGreenHUD.kLocationTextSize = 22
GUIGreenHUD.kLocationTextOffset = Vector(180, 46, 0)

// the hud will not show more notifications than at this intervall to prevent too much spam
GUIGreenHUD.kNotificationUpdateIntervall = 0.2

// COLORS

GUIGreenHUD.kBackgroundColor = Color(0x01 / 0xFF, 0x8F / 0xFF, 0xFF / 0xFF, 1)

// animation callbacks

function AnimFadeIn(scriptHandle, itemHandle)
    itemHandle:FadeIn(1, nil, AnimateLinear, AnimFadeOut)
end

function AnimFadeOut(scriptHandle, itemHandle)
    itemHandle:FadeOut(1, nil, AnimateLinear, AnimFadeIn)
end

function GUIGreenHUD:Initialize()

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
    //self.gameTimeText:SetFontName(GUIGreenHUD.kTextFontName)
    //self.gameTimeText:SetAnchor(GUIItem.Left, GUIItem.Bottom)
    //self.gameTimeText:SetColor(kBrightColor)
    //self.gameTimeText:SetTextAlignmentX(GUIItem.Align_Center)
    //self.gameTimeText:AddAsChildTo(self.background)
       
    self.locationText = self:CreateAnimatedTextItem()
    self.locationText:SetFontName(GUIGreenHUD.kTextFontName)
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

function GUIGreenHUD:InitFrame()

    self.topLeftFrame = GetGUIManager():CreateGraphicItem()
    self.topLeftFrame:SetTexture(GUIGreenHUD.kFrameTexture)
    self.topLeftFrame:SetAnchor(GUIItem.Left, GUIItem.Top)
    self.topLeftFrame:SetTexturePixelCoordinates(unpack(GUIGreenHUD.kFrameTopLeftCoords))
    self.background:AddChild(self.topLeftFrame)
    
    self.topRightFrame = GetGUIManager():CreateGraphicItem()
    self.topRightFrame:SetTexture(GUIGreenHUD.kFrameTexture)
    self.topRightFrame:SetAnchor(GUIItem.Right, GUIItem.Top)
    self.topRightFrame:SetTexturePixelCoordinates(unpack(GUIGreenHUD.kFrameTopRightCoords))
    self.background:AddChild(self.topRightFrame)
    
    self.bottomLeftFrame = GetGUIManager():CreateGraphicItem()
    self.bottomLeftFrame:SetTexture(GUIGreenHUD.kFrameTexture)
    self.bottomLeftFrame:SetAnchor(GUIItem.Left, GUIItem.Bottom)
    self.bottomLeftFrame:SetTexturePixelCoordinates(unpack(GUIGreenHUD.kFrameBottomLeftCoords))
    self.background:AddChild(self.bottomLeftFrame)
    
    self.bottomRightFrame = GetGUIManager():CreateGraphicItem()
    self.bottomRightFrame:SetTexture(GUIGreenHUD.kFrameTexture)
    self.bottomRightFrame:SetAnchor(GUIItem.Right, GUIItem.Bottom)
    self.bottomRightFrame:SetTexturePixelCoordinates(unpack(GUIGreenHUD.kFrameBottomRightCoords))
    self.background:AddChild(self.bottomRightFrame)

end


function GUIGreenHUD:Uninitialize()

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

function GUIGreenHUD:SetStatusDisplayVisible(visible)
    self.statusDisplay:SetIsVisible(visible)
end

function GUIGreenHUD:SetFrameVisible(visible)

    self.topLeftFrame:SetIsVisible(visible)
    self.topRightFrame:SetIsVisible(visible)
    self.bottomLeftFrame:SetIsVisible(visible)
    self.bottomRightFrame:SetIsVisible(visible)
    
end

function GUIGreenHUD:SetInventoryDisplayVisible(visible)
    self.inventoryDisplay:SetIsVisible(visible)
end

function GUIGreenHUD:Reset()
    
    // --- kGUILayerPlayerHUDForeground1
   
    self.statusDisplay:Reset(self.scale)
    self.eventDisplay:Reset(self.scale)
        
    self.locationText:SetUniformScale(self.scale)
    self.locationText:SetScale(GetScaledVector())
    self.locationText:SetPosition(GUIGreenHUD.kLocationTextOffset)

    self.topLeftFrame:SetSize(GUIGreenHUD.kFrameSize * self.scale)
    
    self.topRightFrame:SetSize(GUIGreenHUD.kFrameSize * self.scale)
    self.topRightFrame:SetPosition(Vector(-GUIGreenHUD.kFrameSize.x, 0, 0) * self.scale)
    
    self.bottomLeftFrame:SetSize(GUIGreenHUD.kFrameSize * self.scale)
    self.bottomLeftFrame:SetPosition(Vector(0, -GUIGreenHUD.kFrameSize.y, 0) * self.scale)
    
    self.bottomRightFrame:SetSize(GUIGreenHUD.kFrameSize * self.scale)
    self.bottomRightFrame:SetPosition(Vector(-GUIGreenHUD.kFrameSize.x, -GUIGreenHUD.kFrameSize.y, 0) * self.scale)

end


function GUIGreenHUD:TriggerInitAnimations()
    
end

function GUIGreenHUD:Update(deltaTime)

    PROFILE("GUIGreenHUD:Update")
    
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
    
function GUIGreenHUD:SetIsVisible(isVisible)
    self.background:SetIsVisible(isVisible)
end


function GUIGreenHUD:OnAnimationCompleted(animatedItem, animationName, itemHandle)

    
end

function GUIGreenHUD:OnLocalPlayerChanged(newPlayer)
    
    self:SetStatusDisplayVisible(true)
    self:SetFrameVisible(true)
    if newPlayer:GetTeamNumber() ~= kTeamReadyRoom and Client.GetIsControllingPlayer() then
        self:TriggerInitAnimations()     
    end
    
end

function GUIGreenHUD:OnResolutionChanged(oldX, oldY, newX, newY)

    self.scale = newY / kBaseScreenHeight 
    self.background:SetSize( Vector(newX, newY, 0) )
    
    self:Reset()
    
end