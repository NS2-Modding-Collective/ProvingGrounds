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
Script.Load("lua/Hud/Marine/GUIMarineFuel.lua")
Script.Load("lua/Hud/Marine/GUIMarineHUDStyle.lua")
Script.Load("lua/Hud/GUIInventory.lua")
Script.Load("lua/TechTreeConstants.lua")

class 'GUIMarineHUD' (GUIAnimatedScript)

GUIMarineHUD.kUpgradesTexture = "ui/marine_buildmenu_personal.dds"

local function GetTechIdForArmorLevel(level)

    local armorTechId = {}
    
    armorTechId[1] = kTechId.Armor1
    armorTechId[2] = kTechId.Armor2
    armorTechId[3] = kTechId.Armor3
    
    return armorTechId[level]

end

local function GetTechIdForWeaponLevel(level)

    local weaponTechId = {}
    
    weaponTechId[1] = kTechId.Weapons1
    weaponTechId[2] = kTechId.Weapons2
    weaponTechId[3] = kTechId.Weapons3
    
    return weaponTechId[level]

end

GUIMarineHUD.kDefaultZoom = 0.75

GUIMarineHUD.kUpgradeSize = Vector(80, 80, 0) * 0.8
GUIMarineHUD.kUpgradePos = Vector(-GUIMarineHUD.kUpgradeSize.x - 16, 40, 0)

// position and size for stencil buffer
GUIMarineHUD.kStencilSize = Vector(400, 256, 0)
GUIMarineHUD.kStencilPos = Vector(0, 128, 0)

// initial squares which fade out
GUIMarineHUD.kNumInitSquares = 10
GUIMarineHUD.kInitSquareSize = Vector(64, 80, 0)
GUIMarineHUD.kInitSquareColors = Color(0x01 / 0xFF, 0x8D / 0xFF, 0xFF / 0xFF, 0.3)

// TEXTURES
GUIMarineHUD.kFrameTexture = "ui/marine_HUD_frame.dds"
GUIMarineHUD.kFrameTopLeftCoords = { 0, 0, 680, 384 }
GUIMarineHUD.kFrameTopRightCoords = { 680, 0, 1360, 384 }
GUIMarineHUD.kFrameBottomLeftCoords = { 0, 384, 680, 768 }
GUIMarineHUD.kFrameBottomRightCoords = { 680, 384, 1360, 768 }
GUIMarineHUD.kFrameSize = Vector(1000, 600, 0)

// FONT

GUIMarineHUD.kTextFontName = "fonts/AgencyFB_small.fnt"
GUIMarineHUD.kNanoShieldFontName = "fonts/AgencyFB_large.fnt"
GUIMarineHUD.kNanoShieldFontSize = 20

GUIMarineHUD.kGameTimeTextFontSize = 26
GUIMarineHUD.kGameTimeTextPos = Vector(210, -170, 0)

GUIMarineHUD.kLocationTextSize = 22
GUIMarineHUD.kLocationTextOffset = Vector(180, 46, 0)

// the hud will not show more notifications than at this intervall to prevent too much spam
GUIMarineHUD.kNotificationUpdateIntervall = 0.2

// we update this only at initialize and then only once every 2 seconds
GUIMarineHUD.kPassiveUpgradesUpdateIntervall = 2

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
    
    self.lastArmorLevel = 0
    self.lastWeaponsLevel = 0
    self.lastPassiveUpgradeCheck = 0
    self.lastPowerState = 0
    self.lastNanoShieldState = false
    
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
    
    self.nanoshieldBackground = self:CreateAnimatedGraphicItem()
    self.nanoshieldBackground:SetIsScaling(false)
    self.nanoshieldBackground:SetSize( Vector(Client.GetScreenWidth(), Client.GetScreenHeight(), 0) )
    self.nanoshieldBackground:SetPosition( Vector(0, 0, 0) ) 
    self.nanoshieldBackground:SetIsVisible(true)
    self.nanoshieldBackground:SetColor( Color(0.3, 0.3, 1, 0.0) )
    self.nanoshieldBackground:SetLayer(kGUILayerPlayerHUDBackground)
    
    self.nanoshieldText = GetGUIManager():CreateTextItem()
    self.nanoshieldText:SetFontName(GUIMarineHUD.kNanoShieldFontName)
    self.nanoshieldText:SetScale(GetScaledVector())
    self.nanoshieldText:SetAnchor(GUIItem.Middle, GUIItem.Bottom)
    self.nanoshieldText:SetTextAlignmentX(GUIItem.Align_Center)
    self.nanoshieldText:SetTextAlignmentY(GUIItem.Align_Center)
    self.nanoshieldText:SetPosition(Vector(0, -32, 0))
    self.nanoshieldText:SetText(Locale.ResolveString("NANO_SHIELD_ACTIVE"))
    self.nanoshieldText:SetIsVisible(false)
    self.nanoshieldText:SetColor( Color(0.8, 0.8, 1, 0.8) )
    self.nanoshieldBackground:AddChild(self.nanoshieldText)
    
    // create all hud elements
    
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
    
    self.armorLevel = GetGUIManager():CreateGraphicItem()
    self.armorLevel:SetTexture(GUIMarineHUD.kUpgradesTexture)
    self.armorLevel:SetAnchor(GUIItem.Right, GUIItem.Center)
    self.background:AddChild(self.armorLevel)
    
    self.weaponLevel = GetGUIManager():CreateGraphicItem()
    self.weaponLevel:SetTexture(GUIMarineHUD.kUpgradesTexture)
    self.weaponLevel:SetAnchor(GUIItem.Right, GUIItem.Center)
    self.background:AddChild(self.weaponLevel)
    
    self.statusDisplay = CreateStatusDisplay(self, kGUILayerPlayerHUDForeground1, self.background)
    
    local style = { }
    style.textColor = kBrightColor
    style.textureSet = "marine"
    self.fuelDisplay = CreateFuelDisplay(self, kGUILayerPlayerHUDForeground1, self.background)
    self.inventoryDisplay = CreateInventoryDisplay(self, kGUILayerPlayerHUDForeground1, self.background)
    
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
           
    if self.fuelDisplay then
        self.fuelDisplay:Destroy()
        self.fuelDisplay = nil
    end
    
    if self.inventoryDisplay then
        self.inventoryDisplay:Destroy()
        self.inventoryDisplay = nil
    end

end

function GUIMarineHUD:SetIsVisible(isVisible)
    self.background:SetIsVisible(isVisible)
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
    self.inventoryDisplay:Reset(self.scale)
    
    self.armorLevel:SetPosition(GUIMarineHUD.kUpgradePos * self.scale)
    self.armorLevel:SetSize(GUIMarineHUD.kUpgradeSize * self.scale)
    self.armorLevel:SetIsVisible(false)
    
    self.weaponLevel:SetPosition(Vector(GUIMarineHUD.kUpgradePos.x, GUIMarineHUD.kUpgradePos.y + GUIMarineHUD.kUpgradeSize.y + 8, 0) * self.scale)
    self.weaponLevel:SetSize(GUIMarineHUD.kUpgradeSize * self.scale)
    self.weaponLevel:SetIsVisible(false)

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
    
    // Update health / armor bar
    self.statusDisplay:Update(deltaTime, { PlayerUI_GetPlayerHealth(), PlayerUI_GetPlayerMaxHealth(), PlayerUI_GetPlayerArmor(), PlayerUI_GetPlayerMaxArmor(), PlayerUI_GetPlayerParasiteState() } )
       
    // Update notifications and events
    if self.lastNotificationUpdate + GUIMarineHUD.kNotificationUpdateIntervall < Client.GetTime() then
    
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
    
    // Update passive upgrades
    local armorLevel = 0
    local weaponLevel = 0
    
    if PlayerUI_GetIsPlaying() then
    
        armorLevel = PlayerUI_GetArmorLevel()
        weaponLevel = PlayerUI_GetWeaponLevel()
        
    end
    
    if armorLevel ~= self.lastArmorLevel then
    
        self:ShowNewArmorLevel(armorLevel)
        self.lastArmorLevel = armorLevel
        
    end
    
    if weaponLevel ~= self.lastWeaponLevel then
    
        self:ShowNewWeaponLevel(weaponLevel)
        self.lastWeaponLevel = weaponLevel
        
    end

    local useColor = Color(1, 1, 1, 1)        
    if not AvatarUI_GetHasArmsLab() then
        useColor = Color(1, 0, 0, 1)
    end
    self.weaponLevel:SetColor(useColor)
    self.armorLevel:SetColor(useColor)
    
    // Updates animations
    GUIAnimatedScript.Update(self, deltaTime)
        
end

function GUIMarineHUD:SetIsVisible(isVisible)
    self.background:SetIsVisible(isVisible)
end

function GUIMarineHUD:ShowNewArmorLevel(armorLevel)

    if armorLevel ~= 0 then
    
        local textureCoords = GetTextureCoordinatesForIcon(GetTechIdForArmorLevel(armorLevel), true)
        self.armorLevel:SetIsVisible(true)
        self.armorLevel:SetTexturePixelCoordinates(unpack(textureCoords))
        
    end

end

function GUIMarineHUD:ShowNewWeaponLevel(weaponLevel)

    if weaponLevel ~= 0 then
    
        local textureCoords = GetTextureCoordinatesForIcon(GetTechIdForWeaponLevel(weaponLevel), true)
        self.weaponLevel:SetIsVisible(true)
        self.weaponLevel:SetTexturePixelCoordinates(unpack(textureCoords))
    end

end

function GUIMarineHUD:OnResolutionChanged(oldX, oldY, newX, newY)

    self.scale = newY / kBaseScreenHeight 
    self.background:SetSize( Vector(newX, newY, 0) )
    self.nanoshieldBackground:SetSize( Vector(newX, newY, 0) )
    
    self:Reset()
    
end