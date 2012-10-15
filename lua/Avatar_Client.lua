// ======= Copyright (c) 2003-2012, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\Avatar_Client.lua
//
//    Created by:   Charlie Cleveland (charlie@unknownworlds.com) and
//                  Max McGuire (max@unknownworlds.com)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

Avatar.kInfestationFootstepCinematic = PrecacheAsset("cinematics/marine/infestation_footstep.cinematic")

local kSensorBlipSize = 25

local kMarineHealthbarOffset = Vector(0, 1.2, 0)
function Avatar:GetHealthbarOffset()
    return kMarineHealthbarOffset
end

function Avatar:OnInitLocalClient()

    Player.OnInitLocalClient(self)
    
    self.notifications = {}
    
    if self:GetTeamNumber() ~= kTeamReadyRoom then

        if self.avatarHUD == nil then
            self.avatarHUD = GetGUIManager():CreateGUIScript("Hud/Marine/GUIAvatarHUD")
        end
        
        if self.pickups == nil then
            self.pickups = GetGUIManager():CreateGUIScript("GUIPickups")
        end

        if self.hints == nil then
            //self.hints = GetGUIManager():CreateGUIScript("GUIHints")
        end
       
        if self.unitStatusDisplay == nil then
            self.unitStatusDisplay = GetGUIManager():CreateGUIScript("GUIUnitStatus")
            self.unitStatusDisplay:EnableMarineStyle()
        end 
        
    end
    
end

// check if player aims at a Weldable unit and return it's percentage
function Avatar:GetCurrentWeldPercentage()

    local activeWeapon = self:GetActiveWeapon()
    
    if activeWeapon then
    
        local target = self:GetCrossHairTarget()
        if target and GetAreFriends(self, target) then
        
            local weldPercentage = HasMixin(target, "Weldable") and target:GetWeldPercentage() or 1
            local buildPercentage = HasMixin(target, "Construct") and target:GetBuiltFraction() or 1
            
            return ConditionalValue(weldPercentage > buildPercentage, buildPercentage, weldPercentage)
        
        end
        
    end
    
    return 0
    
end

function Avatar:GetHudParams()

    if self.hudParams == nil then
    
        self.hudParams = {}
        self.hudParams.timeDamageTaken = nil
        // scalar 0-1        
        self.hudParams.damageIntensity = 0
        // boolean to check if a hud cinematic should be played,  init with true so respawning / ejecting from CS / joining team will trigger it
        self.hudParams.initProjectingCinematic = true
    
    end
    
    return self.hudParams

end

function Avatar:SetHudParams(hudParams)
    self.hudParams = hudParams
end

function Avatar:UpdateClientEffects(deltaTime, isLocal)
    
    Player.UpdateClientEffects(self, deltaTime, isLocal)
    
    if isLocal then
        
        self:UpdateGhostModel()
        
        if self.avatarHUD then
            self.avatarHUD:SetIsVisible(self:GetIsAlive())
        end

        local blurEnabled = false
        self:SetBlurEnabled(blurEnabled)
                
    end
    
end

function Avatar:OnUpdateRender()

    PROFILE("Avatar:OnUpdateRender")
    
    Player.OnUpdateRender(self)
      
end

function Avatar:CloseMenu()

    if self.buyMenu then
    
        GetGUIManager():DestroyGUIScript(self.buyMenu)
        self.buyMenu = nil
        MouseTracker_SetIsVisible(false)
        return true
        
    end
   
    return false
    
end

function Avatar:AddNotification(locationId, techId)

    local locationName = ""

    if locationId ~= 0 then
        locationName = Shared.GetString(locationId)
    end

    table.insert(self.notifications, { LocationName = locationName, TechId = techId })

end

// this function returns the oldest notification and clears it from the list
function Avatar:GetAndClearNotification()

    local notification = nil

    if table.count(self.notifications) > 0 then
    
        notification = { LocationName = self.notifications[1].LocationName, TechId = self.notifications[1].TechId }
        table.remove(self.notifications, 1)
    
    end
    
    return notification

end

function Avatar:TriggerFootstep()

    Player.TriggerFootstep(self)

end

gCurrentHostStructureId = Entity.invalidId

function AvatarUI_SetHostStructure(structure)

    if structure then
        gCurrentHostStructureId = structure:GetId()
    end    

end

function AvatarUI_GetCurrentHostStructure()

    if gCurrentHostStructureId and gCurrentHostStructureId ~= Entity.invalidId then
        return Shared.GetEntity(gCurrentHostStructureId)
    end

    return nil    

end

// Bring up buy menu
function Avatar:BuyMenu(structure)
    
    // Don't allow display in the ready room
    if self:GetTeamNumber() ~= 0 and Client.GetLocalPlayer() == self then
    
        if not self.buyMenu then
            self.buyMenu = GetGUIManager():CreateGUIScript("GUIMarineBuyMenu")
            
            AvatarUI_SetHostStructure(structure)
            
            if structure then
                self.buyMenu:SetHostStructure(structure)
            end
        end
        
    end
    
end

function Avatar:UpdateMisc(input)

    Player.UpdateMisc(self, input)
    
    if not Shared.GetIsRunningPrediction() then

        if input.move.x ~= 0 or input.move.z ~= 0 then

            self:CloseMenu()
            
        end
        
    end
    
end

function Avatar:OnCountDown()

    Player.OnCountDown(self)
    
    if self.avatarHUD then
        self.avatarHUD:SetIsVisible(false)
    end

end

function Avatar:OnCountDownEnd()

    Player.OnCountDownEnd(self)
    
    if self.avatarHUD then
        self.avatarHUD:SetIsVisible(true)
    end

end

function Avatar:OnOrderSelfComplete(orderType)

    self:TriggerEffects("complete_order")

end

function Avatar:GetSpeedDebugSpecial()
    return self:GetSprintTime() / SprintMixin.kMaxSprintTime
end

function Avatar:OnUpdateSprint()

    /*if self.loopingSprintSoundEntId ~= Entity.invalidId then
    
        local soundEnt = Shared.GetEntity(self.loopingSprintSoundEntId)
        if soundEnt then
        
            // Note: This line is resulting in console spam:
            // SoundEventInstance::SetParameter(marine/common/sprint_loop, tired = 0.998213, 1): getValue():
            // Do not check in unless this is resolved. This method is not ideal in any case.
            soundEnt:SetParameter("tired", self:GetTiredScalar(), 1)
            
        end 
        
    end*/
    
end

function Avatar:UpdateGhostModel()

    self.currentTechId = nil
    self.ghostStructureCoords = nil
    self.ghostStructureValid = false
    self.showGhostModel = false
    
    local weapon = self:GetActiveWeapon()

    if weapon and weapon:isa("LayMines") then
    
        self.currentTechId = kTechId.Mine
        self.ghostStructureCoords = weapon:GetGhostModelCoords()
        self.ghostStructureValid = weapon:GetIsPlacementValid()
        self.showGhostModel = weapon:GetShowGhostModel()
    
    end

end

function Avatar:GetShowGhostModel()
    return self.showGhostModel
end    

function Avatar:GetGhostModelTechId()
    return self.currentTechId
end

function Avatar:GetGhostModelCoords()
    return self.ghostStructureCoords
end

function Avatar:GetIsPlacementValid()
    return self.ghostStructureValid
end
