// =========================================================================================
//
// lua\Avatar_Client.lua
//
//    Created by:   Andy 'Soul Rider' Wilson for Proving Grounds Mod
//
// ================================================================================================

Avatar.k2DHUDFlash = "ui/marine_hud_2d.swf"

Avatar.kCameraRollSpeedModifier = 0.5
Avatar.kCameraRollTiltModifier = 0.05

Avatar.kViewModelRollSpeedModifier = 7
Avatar.kViewModelRollTiltModifier = 0.15

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

// Tilt the camera based on the wall the Avatar is attached to.
function Avatar:PlayerCameraCoordsAdjustment(cameraCoords)

    if self.currentCameraRoll ~= 0 then

        local viewModelTiltAngles = Angles()
        viewModelTiltAngles:BuildFromCoords(cameraCoords)
        
        if self.currentCameraRoll then
            viewModelTiltAngles.roll = viewModelTiltAngles.roll + self.currentCameraRoll
        end
        
        local viewModelTiltCoords = viewModelTiltAngles:GetCoords()
        viewModelTiltCoords.origin = cameraCoords.origin
        
        return viewModelTiltCoords
        
    end
    
    return cameraCoords

end

local function UpdateCameraTilt(self, deltaTime)

    if self.currentCameraRoll == nil then
        self.currentCameraRoll = 0
    end
    if self.goalCameraRoll == nil then
        self.goalCameraRoll = 0
    end
    if self.currentViewModelRoll == nil then
        self.currentViewModelRoll = 0
    end
    
    // Don't rotate if too close to upside down (on ceiling).
    if not Client.GetOptionBoolean("CameraAnimation", false) or math.abs(self.wallWalkingNormalGoal:DotProduct(Vector.yAxis)) > 0.9 then
        self.goalCameraRoll = 0
    else
    
        local wallWalkingNormalCoords = Coords.GetLookIn( Vector.origin, self:GetViewCoords().zAxis, self.wallWalkingNormalGoal )
        local wallWalkingRoll = Angles()
        wallWalkingRoll:BuildFromCoords(wallWalkingNormalCoords)
        self.goalCameraRoll = wallWalkingRoll.roll
        
    end 
    
    self.currentCameraRoll = LerpGeneric(self.currentCameraRoll, self.goalCameraRoll * Avatar.kCameraRollTiltModifier, math.min(1, deltaTime * Avatar.kCameraRollSpeedModifier))
    self.currentViewModelRoll = LerpGeneric(self.currentViewModelRoll, self.goalCameraRoll, math.min(1, deltaTime * Avatar.kViewModelRollSpeedModifier))

end

function Avatar:OnProcessIntermediate(input)

    Player.OnProcessIntermediate(self, input)
    UpdateCameraTilt(self, input.time)

end

function Avatar:OnProcessSpectate(deltaTime)

    Player.OnProcessSpectate(self, deltaTime)
    UpdateCameraTilt(self, deltaTime)

end


function Avatar:GetSpeedDebugSpecial()
    return 0
end

function Avatar:ModifyViewModelCoords(viewModelCoords)

    if self.currentViewModelRoll ~= 0 then

        local roll = self.currentViewModelRoll and self.currentViewModelRoll * Avatar.kViewModelRollTiltModifier or 0
        local rotationCoords = Angles(0, 0, roll):GetCoords()
        
        return viewModelCoords * rotationCoords
    
    end
    
    return viewModelCoords

end

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