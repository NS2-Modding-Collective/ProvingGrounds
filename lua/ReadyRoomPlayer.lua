// ======= Copyright (c) 2003-2012, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\ReadyRoomPlayer.lua
//
//    Created by:   Brian Cronin (brainc@unknownworlds.com)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/Player.lua")
Script.Load("lua/Mixins/BaseMoveMixin.lua")
Script.Load("lua/Mixins/GroundMoveMixin.lua")
Script.Load("lua/Mixins/JumpMoveMixin.lua")
Script.Load("lua/Mixins/CameraHolderMixin.lua")
Script.Load("lua/ScoringMixin.lua")
//Script.Load("lua/Avatar.lua")
Script.Load("lua/AvatarVariantMixin.lua")

/**
 * ReadyRoomPlayer is a simple Player class that adds the required Move type mixin
 * to Player. Player should not be instantiated directly.
 */
class 'ReadyRoomPlayer' (Player)

ReadyRoomPlayer.kMapName = "ready_room_player"
ReadyRoomPlayer.kWalkBackwardSpeedScalar = 1

local networkVars = { }

AddMixinNetworkVars(BaseMoveMixin, networkVars)
AddMixinNetworkVars(GroundMoveMixin, networkVars)
AddMixinNetworkVars(JumpMoveMixin, networkVars)
AddMixinNetworkVars(CameraHolderMixin, networkVars)
AddMixinNetworkVars(ScoringMixin, networkVars)
AddMixinNetworkVars(AvatarVariantMixin, networkVars)

function ReadyRoomPlayer:OnCreate()

    InitMixin(self, BaseMoveMixin, { kGravity = Player.kGravity })
    InitMixin(self, GroundMoveMixin)
    InitMixin(self, JumpMoveMixin)
    InitMixin(self, CameraHolderMixin, { kFov = kDefaultFov })
    InitMixin(self, ScoringMixin, { kMaxScore = kMaxScore })
    InitMixin(self, AvatarVariantMixin )
    
    Player.OnCreate(self)
    
end

function ReadyRoomPlayer:OnInitialized()

    Player.OnInitialized(self)
    
    self:SetModel(AvatarVariantMixin.kDefaultModelName, AvatarVariantMixin.kMarineAnimationGraph)
    
end

function ReadyRoomPlayer:GetPlayerStatusDesc()
    return kPlayerStatus.Void
end

if Client then

    function ReadyRoomPlayer:OnCountDown()
    end
    
    function ReadyRoomPlayer:OnCountDownEnd()
    end
    
end

// Maximum speed a player can move backwards
function ReadyRoomPlayer:GetMaxBackwardSpeedScalar()
    return ReadyRoomPlayer.kWalkBackwardSpeedScalar
end

function ReadyRoomPlayer:GetHealthbarOffset()
    return 0.8
end

Shared.LinkClassToMap("ReadyRoomPlayer", ReadyRoomPlayer.kMapName, networkVars)
