// =========================================================================================
//
// lua\Avatar_Client.lua
//
//    Created by:   Andy 'Soul Rider' Wilson for Proving Grounds Mod
//
// ================================================================================================

Avatar.k2DHUDFlash = "ui/marine_hud_2d.swf"

function Avatar:GetHealthbarOffset()
    return 1.2
end

function Avatar:UpdateClientEffects(deltaTime, isLocal)
    
    Player.UpdateClientEffects(self, deltaTime, isLocal)
    
    if isLocal then
        
        local avatarHUD = ClientUI.GetScript("Hud/Marine/GUIMarineHUD")
        if avatarHUD then
            avatarHUD:SetIsVisible(self:GetIsAlive())
        end

        local blurEnabled = self.buyMenu ~= nil
        self:SetBlurEnabled(blurEnabled)
    
    end
    
end

function Avatar:OnUpdateRender()

    PROFILE("Avatar:OnUpdateRender")
    
    Player.OnUpdateRender(self)
    
    local model = self:GetRenderModel()

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

function Avatar:UpdateMisc(input)

    Player.UpdateMisc(self, input)
    
end

// Give dynamic camera motion to the player
/*
function Avatar:PlayerCameraCoordsAdjustment(cameraCoords) 

    if self:GetIsFirstPerson() then
        
        if self:GetIsStunned() then
            local attachPointOffset = self:GetAttachPointOrigin("Head") - cameraCoords.origin
            attachPointOffset.x = attachPointOffset.x * .5
            attachPointOffset.z = attachPointOffset.z * .5
            cameraCoords.origin = cameraCoords.origin + attachPointOffset
        end
    
    end
    
    return cameraCoords

end*/

function Avatar:OnCountDown()

    Player.OnCountDown(self)
    
    local script = ClientUI.GetScript("Hud/Marine/GUIMarineHUD")
    if script then
        script:SetIsVisible(false)
    end
    
end

function Avatar:OnCountDownEnd()

    Player.OnCountDownEnd(self)
    
    local script = ClientUI.GetScript("Hud/Marine/GUIMarineHUD")
    if script then
    
        script:SetIsVisible(true)
        script:TriggerInitAnimations()
        
    end
    
end

function Avatar:CreateTrailCinematic()

    local options = {
            numSegments = 2,
            collidesWithWorld = false,
            visibilityChangeDuration = 0.2,
            fadeOutCinematics = true,
            stretchTrail = false,
            trailLength = 1,
            minHardening = 0.01,
            maxHardening = 0.2,
            hardeningModifier = 0.8,
            trailWeight = 0
        }

    self.trailCinematic = Client.CreateTrailCinematic(RenderScene.Zone_Default)
    self.trailCinematic:SetCinematicNames(kFadeTrailDark)    
    self.trailCinematic:AttachToFunc(self, TRAIL_ALIGN_MOVE, Vector(0, 1.3, 0.2) )                
    self.trailCinematic:SetRepeatStyle(Cinematic.Repeat_Endless)
    self.trailCinematic:SetOptions(options)

    self.scanTrailCinematic = Client.CreateTrailCinematic(RenderScene.Zone_Default)
    self.scanTrailCinematic:SetCinematicNames(kFadeTrailGlow)    
    self.scanTrailCinematic:AttachToFunc(self, TRAIL_ALIGN_MOVE, Vector(0, 1.3, 0.2) )                
    self.scanTrailCinematic:SetRepeatStyle(Cinematic.Repeat_Endless)
    self.scanTrailCinematic:SetOptions(options)

end

function Avatar:DestroyTrailCinematic()

    if self.trailCinematic then
    
        Client.DestroyTrailCinematic(self.trailCinematic)
        self.trailCinematic = nil
    
    end
    
    if self.scanTrailCinematic then
    
        Client.DestroyTrailCinematic(self.scanTrailCinematic)
        self.scanTrailCinematic = nil
    
    end

end