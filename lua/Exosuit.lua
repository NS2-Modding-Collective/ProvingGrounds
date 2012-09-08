// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\Weapons\Exosuit.lua
//
//    Created by:   Andreas Urwalek (andi@unknownworlds.com.at)
//
//    Pickupable entity.
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/ScriptActor.lua")
Script.Load("lua/Mixins/ModelMixin.lua")
Script.Load("lua/TeamMixin.lua")
Script.Load("lua/PickupableMixin.lua")

class 'Exosuit' (ScriptActor)

Exosuit.kMapName = "exosuit"

Exosuit.kModelName = PrecacheAsset("models/marine/exosuit/exosuit_cm.model")
local kAnimationGraph = PrecacheAsset("models/marine/exosuit/exosuit_spawn_only.animation_graph")

Exosuit.kPickupSound = PrecacheAsset("sound/NS2.fev/marine/common/pickup_Exosuit")
Exosuit.kEmptySound = PrecacheAsset("sound/NS2.fev/marine/common/Exosuit_empty")

Exosuit.kThinkInterval = .5

local networkVars = { }

AddMixinNetworkVars(BaseModelMixin, networkVars)
AddMixinNetworkVars(ModelMixin, networkVars)
AddMixinNetworkVars(TeamMixin, networkVars)

function Exosuit:OnCreate ()

    ScriptActor.OnCreate(self)
    
    InitMixin(self, BaseModelMixin)
    InitMixin(self, ModelMixin)
    InitMixin(self, TeamMixin)
    
    InitMixin(self, PickupableMixin, { kRecipientType = "Marine" })
    
    self:SetPhysicsGroup(PhysicsGroup.WeaponGroup)
    
end
/*
function Exosuit:GetCheckForRecipient()
    return false
end    
*/
function Exosuit:OnInitialized()

    ScriptActor.OnInitialized(self)
    
    self:SetModel(Exosuit.kModelName, kAnimationGraph)
    
end

function Exosuit:GetCanBeUsed(player)    
    return self:GetIsValidRecipient(player)    
end

function Exosuit:OnTouch(recipient)
    recipient:GiveExo()
end

if Server then

    function Exosuit:OnUse(player, elapsedTime, useAttachPoint, usePoint, useSuccessTable)

        if self:GetIsValidRecipient(player) then
            DestroyEntity(self)
            player:GiveExo()
        end

    end

end

// only give Exosuits to standard marines
function Exosuit:GetIsValidRecipient(recipient)
    return not recipient:isa("JetpackMarine") and not recipient:isa("Exo")
end

function Exosuit:GetIsPermanent()
    return true
end  

Shared.LinkClassToMap("Exosuit", Exosuit.kMapName, networkVars)