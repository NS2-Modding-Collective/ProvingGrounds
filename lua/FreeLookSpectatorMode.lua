// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\FreeLookSpectatorMode.lua
//
// Created by: Marc Delorme (marc@unknownworlds.com)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/SpectatorMode.lua")
Script.Load("lua/Mixins/FreeLookMoveMixin.lua")

class 'FreeLookSpectatorMode' (SpectatorMode)

FreeLookSpectatorMode.mixin = FreeLookMoveMixin
FreeLookSpectatorMode.name  = "FreeLook"

/**
 * Call when the spectator enter this mode
 */
function FreeLookSpectatorMode:Initialize(spectator)
    self.spectator = spectator

    InitMixin(self.spectator, FreeLookSpectatorMode.mixin)

    // Start with a null velocity
    self.spectator:SetVelocity(Vector(0, 0, 0))
    
    local angles = Angles(self.spectator:GetViewAngles())
    local nearestTarget = nil
    local nearestTargetDistance = 25
    local player = self.spectator
    
    local targets = Shared.GetEntitiesWithClassname("Player")
    for index, target in ientitylist(targets) do
    
        if target:GetIsAlive() and target:GetIsVisible() and target:GetCanTakeDamage() and target ~= player then
        
            local dist = (target:GetOrigin() - player:GetOrigin()):GetLength()
            if dist < nearestTargetDistance then
            
                nearestTarget = target
                nearestTargetDistance = dist
                
            end
            
        end
        
    end

    if nearestTarget then
    
        local min, max = nearestTarget:GetModelExtents()
        local diff = nearestTarget:GetOrigin() - self.spectator:GetOrigin()
        local direction = GetNormalizedVector(diff)
        
        angles.yaw   = GetYawFromVector(direction)
        angles.pitch = GetPitchFromVector(direction)
        
    else
        angles.pitch = 0.0
    end
    
    self.spectator:SetBaseViewAngles(Angles(0,0,0))
    self.spectator:SetViewAngles(angles)
    
    if Client and self.spectator == Client.GetLocalPlayer() then

        Client.SetPitch(angles.pitch)
        Client.SetYaw(angles.yaw)

    end
    
end

/**
 * Call when the spectator leave the mode
 */
function FreeLookSpectatorMode:Uninitialize()
    RemoveMixin(self.spectator, FreeLookSpectatorMode.mixin)
end

/**
 * Call when the spectator is updated
 */
function FreeLookSpectatorMode:Update(input)
end