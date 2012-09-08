// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\OverheadSpectatorMode.lua
//
// Created by: Marc Delorme (marc@unknownworlds.com)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/SpectatorMode.lua")
Script.Load("lua/Mixins/OverheadMoveMixin.lua")
if Client then
    Script.Load("lua/GUIManager.lua")
end

class 'OverheadSpectatorMode' (SpectatorMode)

OverheadSpectatorMode.mixin = OverheadMoveMixin
OverheadSpectatorMode.name  = "Overhead"

/**
 * Call when the spectator enter this mode
 */
function OverheadSpectatorMode:Initialize(spectator)

	self.spectator = spectator

	InitMixin(self.spectator, OverheadSpectatorMode.mixin)

	self.spectator:SetDesiredCamera( 0.3, { follow = true })

	// Set Overhead view angle
	local overheadAngle = Angles((70/180)*math.pi, (90/180)*math.pi, 0)
	self.spectator:SetBaseViewAngles(Angles(0,0,0))
	self.spectator:SetViewAngles( overheadAngle )

	if Client and self.spectator == Client.GetLocalPlayer() then

        GetGUIManager():CreateGUIScriptSingle("GUIInsight_Overhead")
        MouseTracker_SetIsVisible(true, nil, true)

		// Turn off some world property
		SetCommanderPropState(true)
		Client.SetEnableFog(false)
		SetSkyboxDrawState(false)
	    Client.SetSoundGeometryEnabled(false)
	    Client.SetGroupIsVisible(kCommanderInvisibleGroupName, false)
	    Client.SetEnableFog(false)
	    Client.SetMouseVisible(true)

	    Client.SetPitch(overheadAngle.pitch)
		Client.SetYaw(overheadAngle.yaw)

        self.atmospherics = Client.GetOptionBoolean( kAtmosphericsOptionsKey, false )
        
        if self.atmospherics then
        
            Client.SetOptionBoolean( kAtmosphericsOptionsKey, false )
            
        end

	end

end

/**
 * Call when the spectator leave the mode
 */
function OverheadSpectatorMode:Uninitialize()

	self.spectator:SetDesiredCamera( 0.3, { follow = true })
    local position = self.spectator:GetOrigin()
    
    -- Pick a height to set the spectator at
    -- Either a raytrace to the ground (better value)
    -- Or use the heightmap if the ray goes off the map
    local trace = GetCommanderPickTarget(self.spectator, self.spectator:GetOrigin(), true, false, false)
    local traceHeight = trace.endPoint.y
    local mapHeight = GetHeightmap():GetElevation(position.x, position.z) - 10
    
    -- Assume the trace is off the map if it's far from the heightmap
    -- Is there a better way to test this?
    local traceOffMap = math.abs(traceHeight-mapHeight) > 25
    local bestHeight = ConditionalValue(traceOffMap, mapHeight, traceHeight)
    position.y = bestHeight
    
	local viewAngles = self.spectator:GetViewAngles()
	viewAngles.pitch = 0
	self.spectator:SetOrigin(position)
	self.spectator:SetViewAngles(viewAngles)

	RemoveMixin(self.spectator, OverheadSpectatorMode.mixin)

	if Client then
		
        GetGUIManager():DestroyGUIScriptSingle("GUIInsight_Overhead")
        MouseTracker_SetIsVisible(false)

		// Turn on the world property disabled
		SetCommanderPropState(false)
		Client.SetEnableFog(true)
		SetSkyboxDrawState(true)
		Client.SetSoundGeometryEnabled(true)
	    Client.SetGroupIsVisible(kCommanderInvisibleGroupName, true)
	    Client.SetEnableFog(true)
	    Client.SetMouseVisible(false)

	    Client.SetPitch(viewAngles.pitch)

        if self.atmospherics then
        
            Client.SetOptionBoolean( kAtmosphericsOptionsKey, self.atmospherics )
            
        end

	end	

end

/**
 * Call when the spectator is updated
 */
function OverheadSpectatorMode:Update(input)
end