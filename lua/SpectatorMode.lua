// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\SpectatorMode.lua
//
// Created by: Marc Delorme (marc@unknownworlds.com)
//
// SpectatorMode is a mode for the spectator player.
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================


class 'SpectatorMode'

SpectatorMode.mixin = nil
SpectatorMode.name  = nil

/**
 * Call when the spectator enter this mode
 */
function SpectatorMode:Initialize(spectator)
	self.spectator = spectator
end

/**
 * Call when the spectator leave the mode
 */
function SpectatorMode:Uninitialize()
end

/**
 * Call when the spectator is updated
 */
function SpectatorMode:Update(input)
end