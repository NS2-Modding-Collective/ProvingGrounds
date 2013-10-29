// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\GUIMarineStatus.lua
//
// Created by: Andy Wilson For Proving Grounds Mod
//
// Manages the health display for the marine hud.
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/Hud/Marine/GUIMarineHUDElement.lua")
Script.Load("lua/Hud/Marine/GUIMarineHUDStyle.lua")

class 'GUIMarineStatus' (GUIMarineHUDElement)

function CreateStatusDisplay(scriptHandle, hudLayer, frame)

    local marineStatus = GUIMarineStatus()
    marineStatus.script = scriptHandle
    marineStatus.hudLayer = hudLayer
    marineStatus.frame = frame
    marineStatus:Initialize()
    
    return marineStatus
    
end


GUIMarineStatus.kStatusTexture = PrecacheAsset("ui/marine_HUD_status.dds")

GUIMarineStatus.kTextXOffset = 95

GUIMarineStatus.kBackgroundCoords = { 0, 0, 300, 121 }
GUIMarineStatus.kBackgroundPos = Vector(30, -160, 0)
GUIMarineStatus.kBackgroundSize = Vector(GUIMarineStatus.kBackgroundCoords[3], GUIMarineStatus.kBackgroundCoords[4], 0)
GUIMarineStatus.kStencilCoords = { 0, 140, 300, 140 + 121 }

GUIMarineStatus.kHealthTextPos = Vector(-20, 36, 0)

GUIMarineStatus.kFontName = "fonts/AgencyFB_large_bold.fnt"

GUIMarineStatus.kHealthBarColor = Color(163/255, 210/255, 220/255, 0.8)

GUIMarineStatus.kHealthBarSize = Vector(206, 28, 0)
GUIMarineStatus.kHealthBarPixelCoords = { 58, 288, 58 + 206, 288 + 28 }
GUIMarineStatus.kHealthBarPos = Vector(58, 24, 0)

GUIMarineStatus.kAnimSpeedDown = 0.2
GUIMarineStatus.kAnimSpeedUp = 0.5

local kBorderTexture = PrecacheAsset("ui/unitstatus_marine.dds")
local kBorderCoords = { 256, 256, 256 + 512, 256 + 128 }
local kBorderMaskPixelCoords = { 256, 384, 256 + 512, 384 + 512 }
local kBorderMaskCircleRadius = 240
local kHealthBorderPos = Vector(-150, -60, 0)
local kHealthBorderSize = Vector(350, 65, 0)
local kRotationDuration = 8

function GUIMarineStatus:Initialize()

    self.scale = 1

    self.lastHealth = 0
    self.spawnArmorParticles = false
    
    self.statusbackground = self.script:CreateAnimatedGraphicItem()
    self.statusbackground:SetAnchor(GUIItem.Left, GUIItem.Bottom)
    self.statusbackground:SetTexture(GUIMarineStatus.kStatusTexture)
    self.statusbackground:SetTexturePixelCoordinates(unpack(GUIMarineStatus.kBackgroundCoords))
    self.statusbackground:AddAsChildTo(self.frame)
    
    self.statusStencil = GetGUIManager():CreateGraphicItem()
    self.statusStencil:SetTexture(GUIMarineStatus.kStatusTexture)
    self.statusStencil:SetTexturePixelCoordinates(unpack(GUIMarineStatus.kStencilCoords))
    self.statusStencil:SetIsStencil(true)
    self.statusStencil:SetClearsStencilBuffer(false)
    self.statusbackground:AddChild(self.statusStencil)
    
    self.healthText = self.script:CreateAnimatedTextItem()
    self.healthText:SetNumberTextAccuracy(1)
    self.healthText:SetFontName(GUIMarineStatus.kFontName)
    self.healthText:SetTextAlignmentX(GUIItem.Align_Min)
    self.healthText:SetTextAlignmentY(GUIItem.Align_Center)
    self.healthText:SetAnchor(GUIItem.Right, GUIItem.Top)
    self.healthText:SetLayer(self.hudLayer + 1)
    self.healthText:SetColor(GUIMarineStatus.kHealthBarColor)
    self.statusbackground:AddChild(self.healthText)
       
    self.healthBar = self.script:CreateAnimatedGraphicItem()
    self.healthBar:SetTexture(GUIMarineStatus.kStatusTexture)
    self.healthBar:SetTexturePixelCoordinates(unpack(GUIMarineStatus.kHealthBarPixelCoords))
    self.healthBar:AddAsChildTo(self.statusbackground)
      
    self.healthBorder = GetGUIManager():CreateGraphicItem()
    self.healthBorder:SetAnchor(GUIItem.Middle, GUIItem.Center)
    self.healthBorder:SetTexture(kBorderTexture)
    self.healthBorder:SetTexturePixelCoordinates(unpack(kBorderCoords))
    self.healthBorder:SetIsStencil(true)
    
    self.healthBorderMask = GetGUIManager():CreateGraphicItem()
    self.healthBorderMask:SetTexture(kBorderTexture)
    self.healthBorderMask:SetAnchor(GUIItem.Middle, GUIItem.Center)
    self.healthBorderMask:SetBlendTechnique(GUIItem.Add)
    self.healthBorderMask:SetTexturePixelCoordinates(unpack(kBorderMaskPixelCoords))
    self.healthBorderMask:SetStencilFunc(GUIItem.NotEqual)
    
    self.healthBorder:AddChild(self.healthBorderMask)
    self.statusbackground:AddChild(self.healthBorder)

end

function GUIMarineStatus:Reset(scale)

    self.scale = scale

    self.statusbackground:SetUniformScale(scale)
    self.statusbackground:SetPosition(GUIMarineStatus.kBackgroundPos)
    self.statusbackground:SetSize(GUIMarineStatus.kBackgroundSize)
    
    self.statusStencil:SetSize(GUIMarineStatus.kBackgroundSize * self.scale)

    self.healthText:SetUniformScale(self.scale)
    self.healthText:SetScale(GetScaledVector())
    self.healthText:SetPosition(GUIMarineStatus.kHealthTextPos)
    
    self.healthBar:SetUniformScale(self.scale)
    self.healthBar:SetSize(GUIMarineStatus.kHealthBarSize)
    self.healthBar:SetPosition(GUIMarineStatus.kHealthBarPos)
       
    self.healthBorder:SetSize(kHealthBorderSize * self.scale)
    self.healthBorder:SetPosition(kHealthBorderPos * self.scale)
    self.healthBorderMask:SetSize(Vector(kBorderMaskCircleRadius * 2, kBorderMaskCircleRadius * 2, 0) * self.scale)
    self.healthBorderMask:SetPosition(Vector(-kBorderMaskCircleRadius, -kBorderMaskCircleRadius, 0) * self.scale)

end

function GUIMarineStatus:Destroy()

    if self.statusbackground then
        self.statusbackground:Destroy()
    end

    if self.healthText then
        self.healthText:Destroy()
    end   

end

function GUIMarineStatus:SetIsVisible(visible)
    self.statusbackground:SetIsVisible(visible)
end

local kLowHealth = 40
local kLowHealthAnimRate = 0.3

local function LowHealthPulsate(script, item)

    item:SetColor(Color(0.7, 0, 0, 1), kLowHealthAnimRate, "ANIM_HEALTH_PULSATE", AnimateQuadratic, 
        function (script, item)        
            item:SetColor(Color(1, 0, 0,1), kLowHealthAnimRate, "ANIM_HEALTH_PULSATE", AnimateQuadratic, LowHealthPulsate )        
        end )

end

// set armor/health and trigger effects accordingly (armor bar particles)
function GUIMarineStatus:Update(deltaTime, parameters)

    if table.count(parameters) < 2 then
        Print("WARNING: GUIMarineStatus:Update received an incomplete parameter table.")
    end
    
    local currentHealth, maxHealth = unpack(parameters)
    
    if currentHealth ~= self.lastHealth then
    
	    local healthFraction = currentHealth / maxHealth
	    local healthBarSize = Vector(GUIMarineStatus.kHealthBarSize.x * healthFraction, GUIMarineStatus.kHealthBarSize.y, 0)
	    local pixelCoords = GUIMarineStatus.kHealthBarPixelCoords
	    pixelCoords[3] = GUIMarineStatus.kHealthBarSize.x * healthFraction + pixelCoords[1]
    
        if currentHealth < self.lastHealth then
            self.healthText:DestroyAnimation("ANIM_TEXT")
            self.healthText:SetText(tostring(math.ceil(currentHealth)))
            self.healthBar:DestroyAnimation("ANIM_HEALTH_SIZE")
            self.healthBar:SetSize(healthBarSize)
            self.healthBar:SetTexturePixelCoordinates(unpack(pixelCoords))
        else
            self.healthText:SetNumberText(tostring(math.ceil(currentHealth)), GUIMarineStatus.kAnimSpeedUp, "ANIM_TEXT")
            self.healthBar:SetSize(healthBarSize, GUIMarineStatus.kAnimSpeedUp, "ANIM_HEALTH_SIZE")
            self.healthBar:SetTexturePixelCoordinates(pixelCoords[1], pixelCoords[2], pixelCoords[3], pixelCoords[4], GUIMarineStatus.kAnimSpeedUp, "ANIM_HEALTH_TEXTURE")
        end
	    
	    self.lastHealth = currentHealth
	    
	    if self.lastHealth < kLowHealth  then
	    
	        if not self.lowHealthAnimPlaying then
                self.lowHealthAnimPlaying = true
                self.healthBar:SetColor(Color(1, 0, 0, 1), kLowHealthAnimRate, "ANIM_HEALTH_PULSATE", AnimateQuadratic, LowHealthPulsate )
                self.healthText:SetColor(Color(1, 0, 0, 1), kLowHealthAnimRate, "ANIM_HEALTH_PULSATE", AnimateQuadratic, LowHealthPulsate )
	        end
	        
	    else
	    
            self.lowHealthAnimPlaying = false
            self.healthBar:DestroyAnimation("ANIM_HEALTH_PULSATE")
            self.healthText:DestroyAnimation("ANIM_HEALTH_PULSATE")
            self.healthBar:SetColor(GUIMarineStatus.kHealthBarColor)
            self.healthText:SetColor(GUIMarineStatus.kHealthBarColor)
            
        end    
    
    end
    
    // update border animation
    local baseRotationPercentage = (Shared.GetTime() % kRotationDuration) / kRotationDuration
    local color = Color(1, 1, 1,  math.sin(Shared.GetTime() * 0.5 ) * 0.5)
    self.healthBorderMask:SetRotation(Vector(0, 0, -2 * math.pi * baseRotationPercentage))   
    self.healthBorderMask:SetColor(color)
    
end
