// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\CommandStructure.lua
//
//    Created by:   Charlie Cleveland (charlie@unknownworlds.com) and
//                  Max McGuire (max@unknownworlds.com)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/Mixins/ModelMixin.lua")
Script.Load("lua/LiveMixin.lua")
Script.Load("lua/PointGiverMixin.lua")
Script.Load("lua/GameEffectsMixin.lua")
Script.Load("lua/SelectableMixin.lua")
Script.Load("lua/FlinchMixin.lua")
Script.Load("lua/LOSMixin.lua")
Script.Load("lua/TeamMixin.lua")
Script.Load("lua/EntityChangeMixin.lua")
Script.Load("lua/ConstructMixin.lua")
Script.Load("lua/ResearchMixin.lua")
Script.Load("lua/CombatMixin.lua")
Script.Load("lua/ScriptActor.lua")
Script.Load("lua/RagdollMixin.lua")
Script.Load("lua/ObstacleMixin.lua")
Script.Load("lua/CommanderGlowMixin.lua")
Script.Load("lua/ObjectiveInfo.lua")

class 'CommandStructure' (ScriptActor)
CommandStructure.kMapName = "commandstructure"

if Server then
    Script.Load("lua/CommandStructure_Server.lua")
end

local networkVars =
{
    occupied = "boolean",
    commanderId = "entityid",
    attachedId = "entityid",
}

AddMixinNetworkVars(BaseModelMixin, networkVars)
AddMixinNetworkVars(ModelMixin, networkVars)
AddMixinNetworkVars(LiveMixin, networkVars)
AddMixinNetworkVars(GameEffectsMixin, networkVars)
AddMixinNetworkVars(FlinchMixin, networkVars)
AddMixinNetworkVars(TeamMixin, networkVars)
AddMixinNetworkVars(LOSMixin, networkVars)
AddMixinNetworkVars(ConstructMixin, networkVars)
AddMixinNetworkVars(ResearchMixin, networkVars)
AddMixinNetworkVars(CombatMixin, networkVars)
AddMixinNetworkVars(ObstacleMixin, networkVars)

function CommandStructure:OnCreate()

    ScriptActor.OnCreate(self)
    
    InitMixin(self, BaseModelMixin)
    InitMixin(self, ModelMixin)
    InitMixin(self, LiveMixin)
    InitMixin(self, GameEffectsMixin)
    InitMixin(self, FlinchMixin)
    InitMixin(self, TeamMixin)
    InitMixin(self, PointGiverMixin)
    InitMixin(self, SelectableMixin)
    InitMixin(self, EntityChangeMixin)
    InitMixin(self, LOSMixin)
    InitMixin(self, ConstructMixin)
    InitMixin(self, ResearchMixin)
    InitMixin(self, CombatMixin)
    InitMixin(self, RagdollMixin)
    InitMixin(self, ObstacleMixin)
    
    if Client then
        InitMixin(self, CommanderGlowMixin)
    end
    
    self.occupied = true
    self.commanderId = Entity.invalidId
    
    self.maxHealth = LookupTechData(self:GetTechId(), kTechDataMaxHealth)
    self.health = self.maxHealth
    
    self:SetLagCompensated(true)
    self:SetPhysicsType(PhysicsType.Kinematic)
    self:SetPhysicsGroup(PhysicsGroup.BigStructuresGroup)
    
end

function CommandStructure:GetReceivesStructuralDamage()
    return true
end

function CommandStructure:GetIsOccupied()
    return self.occupied
end

function CommandStructure:GetEffectParams(tableParams)

    ScriptActor.GetEffectParams(self, tableParams)
    tableParams[kEffectFilterOccupied] = self.occupied
    
end

if Client then

    
    function CommandStructure:OnDestroy()
    
        ScriptActor.OnDestroy(self)
        
    end
    
end

function CommandStructure:OnUpdateAnimationInput(modelMixin)

    PROFILE("CommandStructure:OnUpdateAnimationInput")
    modelMixin:SetAnimationInput("occupied", self.occupied)
    
end

function CommandStructure:GetCanBeUsedConstructed()
    return not self:GetIsOccupied()
end

Shared.LinkClassToMap("CommandStructure", CommandStructure.kMapName, networkVars)