// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\FollowingSpectatorMode.lua
//
// Created by: Marc Delorme (marc@unknownworlds.com)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/SpectatorMode.lua")
Script.Load("lua/FollowMoveMixin.lua")

class 'FollowingSpectatorMode' (SpectatorMode)

FollowingSpectatorMode.mixin = FollowMoveMixin
FollowingSpectatorMode.name  = "Following"

/**
 * Call when the spectator enter this mode
 */
function FollowingSpectatorMode:Initialize(spectator)
    self.spectator = spectator

    InitMixin(self.spectator, FollowingSpectatorMode.mixin)

end

/**
 * Call when the spectator leave the mode
 */
function FollowingSpectatorMode:Uninitialize()
    RemoveMixin(self.spectator, FollowingSpectatorMode.mixin)

    self.spectator:SetDesiredCameraDistance(0)
end

/**
 * Call when the spectator is updated
 */
function FollowingSpectatorMode:Update(input)
end