//=============================================================================
//
// lua\Weapons\ProjectileEffectsMixin.lua
//
// Created by Charlie Cleveland (charlie@unknownworlds.com)
// Copyright (c) 2011, Unknown Worlds Entertainment, Inc.
//
//=============================================================================

Script.Load("lua/FunctionContracts.lua")

ProjectileEffectsMixin = CreateMixin( ProjectileEffectsMixin )
ProjectileEffectsMixin.type = "ProjectileEffects"

ProjectileEffectsMixin.optionalCallbacks =
{
    GetRepeatCinematic = "Should return the name to the cinematic that gets repeated while the entity is active.",
	GetEffectOffset = "Should return a vector which offsets the cinematic by a certain amount (used to place it relative to the model)."
}

// Just stubs at the server.
if Server then

	function ProjectileEffectsMixin:__initmixin()
	end

// This is all client-only.
else

	function ProjectileEffectsMixin:__initmixin()

		if not self.repeatingEffect then
			local repeatCinematic = nil
			if (self.GetRepeatCinematic) then
				repeatCinematic = self:GetRepeatCinematic()
			end
			
			if repeatCinematic ~= nil then
				self.repeatingEffect = Client.CreateCinematic(RenderScene.Zone_Default)    
				self.repeatingEffect:SetCinematic(repeatCinematic)    
				self.repeatingEffect:SetRepeatStyle(Cinematic.Repeat_Endless)
		
				local coords = Coords.GetIdentity()
				coords.origin = self:GetOrigin()
				self.repeatingEffect:SetCoords(coords)
			else
				Shared.Message("Error when binding cinematic to ProjectileEffectsMixin caller. Did you create a GetRepeatCinematic function?")
			end
		end

	end


	function ProjectileEffectsMixin:OnUpdate(deltaTime)
	
		if (self.repeatingEffect) then
			local coords = Coords.GetIdentity()
			coords.origin = self:GetOrigin()
			self.repeatingEffect:SetCoords(coords)
		end
		
	end
	AddFunctionContract(ProjectileEffectsMixin.OnUpdate, { Arguments = { "Entity", "number" }, Returns = { } })

	function ProjectileEffectsMixin:OnDestroy()
	
		if (self.repeatingEffect) then
		    Client.DestroyCinematic(self.repeatingEffect)
            self.repeatingEffect = nil
		end
		
	end
	AddFunctionContract(ProjectileEffectsMixin.OnDestroy, { Arguments = { "Entity" }, Returns = { } })
end