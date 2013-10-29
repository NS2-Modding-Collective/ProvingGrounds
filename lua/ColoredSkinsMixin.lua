//=============================================================================
//
// ColoredSkinsMixin (Skinning System)
// 		Author: Brock 'McGlaspie' Gillespie
//		@McGlaspie  -  mcglaspie@gmail.com		
//
// This Mixin is only applicable to Clients and should not be loaded in any
// other Lua VM (I.e. Server or Predict). The expectedCallbacks should be
// wrapped in a "if Client" condition as a result.
//
// Note: This does NOT apply a material to a given model. It REQUIRES that a
// material with the Color Skins shader program is already being used by the
// entity implementing this mixin. Also, it is import to note this does not
// currently have support for screen fx. It is for texture mapped in-world
// objects only.
//
// Keep in mind this is a Client focused Mixin. So, any changes to the colorization
// or skin toggle should be based on game rules/data that get propogated over
// the network. Otherwise, skin-state or color values won't be synchronized for
// all players. It is strongly advised that the skin state and color values NOT
// be set as network variables. This would significantly increase network traffic,
// slow down rendering, and introduce server side lag.
// 
// TODO Explain usage of atlas textures
// http://en.wikipedia.org/wiki/Texture_atlas
//
//=============================================================================

if Client then
	Shared.PrecacheSurfaceShader("shaders/ColoredSkins.surface_shader")
	Shared.PrecacheSurfaceShader("shaders/ColoredSkins_noemissive.surface_shader")
	//TODO Add additional shaders needed for all models
end


gColoredSkinsToggle = true	//global to specify if colored skins are Active
gColorMapIndexOverrideEnabled = false
gColorMapIndexOverride = 0
gColorMapMaxIndex = 4		//Ideally, this should be defined per Class member
//Above value only allows for 4x4 sized color map texture...which should be ample
gColorOverridesEnabled = false
gSkinColorOverrides = {
	["base"] = nil,
	["accent"] = nil,
	["trim"] = nil
}


//-----------------------------------------------------------------------------


ColoredSkinsMixin = CreateMixin( ColoredSkinsMixin )
ColoredSkinsMixin.type = "ColoredSkin"


ColoredSkinsMixin.expectedMixins = {
	Model = "Needed for setting material parameters"
}

ColoredSkinsMixin.expectedCallbacks = {

	GetBaseSkinColor = "Should return a Color object. This is applied to albedo textures",
	GetAccentSkinColor = "Should return a Color object. This is applied to emissive textures",
	GetTrimSkinColor = "Should return Color object",
	InitializeSkin = "Setup routine for any customization of skin colors applied to material"
	//IntializeSkin() should ALWAYS be called in an Entity's OnInitialize() method within a "is Client" check
	//This is required in order for the color values to correctly propogate to the shader(s). If not, the entity
	//will appear black due to the default Colors variables being initialized that way.
	
}

ColoredSkinsMixin.optionalCallbacks = {}


//-----------------------------------------------------------------------------

//Initial color values are defined when implementing Entity is initialized.
//This does not prevent these colors from being updated according to a
//specific case or game condition. Generally, you do NOT want to be getting
//a "fresh" (I.e. calling Get****SkinColor() every time OnUpdateRender() is
//run. This causes an FPS drop and will increase the more skinned entities 
//are on screen.
function ColoredSkinsMixin:__initmixin()
	
	self.skinBaseColor = Color(0, 0, 0, 0)
	self.skinAccentColor = Color(0, 0, 0, 0)
	self.skinTrimColor = Color(0, 0, 0, 0)
	
	self.skinAtlasIndex = 0
	
	self.skinColoringEnabled = true	//Allows for colored skins to be toggled on per-entity basis
	
end


function ColoredSkinsMixin:GetAtlasIndex()
	return self.skinAtlasIndex
end


function ColoredSkinsMixin:SetAtlasIndex( newIdx )
	//????
end


function ColoredSkinsMixin:OnUpdateRender()
	
	PROFILE("ColoredSkinsMixin:OnUpdateRender()")
	
	local model = self:GetRenderModel()
	local enabled = ConditionalValue( gColoredSkinsToggle and self.skinColoringEnabled, 1, 0 )
	
	local baseColor = self.skinBaseColor
	local accentColor = self.skinAccentColor
	local trimColor = self.skinTrimColor
	
	if gColorOverridesEnabled then
		
		if gSkinColorOverrides["base"] ~= nil then
			baseColor = gSkinColorOverrides["base"]
		end
		
		if gSkinColorOverrides["accent"] ~= nil then
			accentColor = gSkinColorOverrides["accent"]
		end
		
		if gSkinColorOverrides["trim"] ~= nil then
			trimColor = gSkinColorOverrides["trim"]
		end
		
	end
	
	local colorMapAtlasIndex = ConditionalValue(
		gColorMapIndexOverrideEnabled,
		gColorMapIndexOverride,
		self.skinAtlasIndex
	)
	
	if model then
		
		/*
		//Example of how color layers can be set via code
		// - This could easily be done in an entity's update routine(s)
		//Just be sure and wrap any changes in a HasMixin(entity, "ColoredSkin") condition
		local ts = math.floor( Shared.GetTime() )
		if math.fmod( ts , 3 ) == 0 and ts < 240 then
			
			local rc = {
				[1] = Color(1, 1, 0),
				[2] = Color(0, 1, 0),
				[3] = Color(1, 0, 0),
				[4] = Color(0, 0, 1),
				[5] = Color(1, 1, 1),
				[6] = Color(0, 0, 0)
			}
			
			self.skinBaseColor = LerpColor( self.skinBaseColor, rc[ math.random(1,6) ] , 0.025 )
			self.skinAccentColor = LerpColor( self.skinAccentColor, rc[ math.random(6,1) ] , 0.5 )
			self.skinTrimColor = LerpColor( self.skinTrimColor, rc[ math.random(6,1) ] , 0.01 )
			
		else
			
			self.skinBaseColor = LerpColor( self.skinBaseColor, self:GetBaseSkinColor(), 0.001 )
			self.skinAccentColor = LerpColor( self.skinAccentColor, self:GetAccentSkinColor() , 0.01 )
			self.skinTrimColor = LerpColor( self.skinTrimColor, self:GetTrimSkinColor() , 0.005 )
			
		end
		*/
		
		//Note: This will apply to all child materials, but ONLY IF they are
		//		all using the same Material Shader.
		//		That means for players (I.e. A marine) the male_face.material 
		//		and male_visor.material need the colored_skins.surface_shader)
		//		set as the shader file in said materials. Each entity needs to
		//		be setup accordingly. Setting the color once will propogate to
		//		"child" materials.
		
		//The RGB values MUST be added to materials due to lack of Vector/Float3/Color parameter support.
		//This appears to be a limitation of current material system.
		//The Alpha value of the Color object is not used, nor supported by the shader(s).
		
		//If these values do NOT have a distinct color. The implementing Entity WILL appear black
		//Because no color specified will amount to setting Color(0,0,0) as the material parameter
		
		model:SetMaterialParameter( "modelColorBaseR", baseColor.r )
		model:SetMaterialParameter( "modelColorBaseG", baseColor.g )
		model:SetMaterialParameter( "modelColorBaseB", baseColor.b )
		model:SetMaterialParameter( "modelColorAccentR", accentColor.r )
		model:SetMaterialParameter( "modelColorAccentG", accentColor.g )
		model:SetMaterialParameter( "modelColorAccentB", accentColor.b )
		model:SetMaterialParameter( "modelColorTrimR", trimColor.r )
		model:SetMaterialParameter( "modelColorTrimG", trimColor.g )
		model:SetMaterialParameter( "modelColorTrimB", trimColor.b )
		
		//Set enabled state
		model:SetMaterialParameter( "colorizeModel", enabled )
		
		//Set Color Map Index of atlas texture
		model:SetMaterialParameter( "colorMapIndex", colorMapAtlasIndex )
		
	end		
	
	
//Handle "Special" cases from here on -------------------------------------
	if self:isa("Avatar") and self == Client.GetLocalPlayer() then	//Don't run on World objects
	
		local viewEnt = self:GetViewModelEntity()
	
		if viewEnt then
		
			local viewModel = viewEnt:GetRenderModel()
			
			if viewModel then
				
				viewModel:SetMaterialParameter( "modelColorBaseR", baseColor.r )
				viewModel:SetMaterialParameter( "modelColorBaseG", baseColor.g )
				viewModel:SetMaterialParameter( "modelColorBaseB", baseColor.b )
				viewModel:SetMaterialParameter( "modelColorAccentR", accentColor.r )
				viewModel:SetMaterialParameter( "modelColorAccentG", accentColor.g )
				viewModel:SetMaterialParameter( "modelColorAccentB", accentColor.b )
				viewModel:SetMaterialParameter( "modelColorTrimR", trimColor.r )
				viewModel:SetMaterialParameter( "modelColorTrimG", trimColor.g )
				viewModel:SetMaterialParameter( "modelColorTrimB", trimColor.b )
				
				//Set enabled state
				viewModel:SetMaterialParameter( "colorizeModel", enabled )
				
				//Set Color Map Index of atlas texture
				viewModel:SetMaterialParameter( "colorMapIndex", colorMapAtlasIndex )
				
			end
			
		end
		
	end
	
end
//End ColoredSkinsMixin -------------------------------------------------------




//-----------------------------------------------------------------------------
//Debugging & Texture Development Tools ---------------------------------------
//	Note: All of these utiliy function assume Utility.lua is in scope


//TODO Move below and create additional utility functions
//Debugging and/or for when "complex" material parameter values allowed
local function ColorAsParam( color )
	return string.format("(%0.3f, %0.3f, %0.3f)", color.r, color.g, color.b )
end

local function ColorAsParamInt( color )
	//return string.format("(%0.3f, %0.3f, %0.3f)", color.r, color.g, color.b )	//TODO adjust for returning Int vals
end


if Client then

	local function OnCommandGetEntityColorInfo()
		
		if Shared.GetCheatsEnabled() then
			
			local player = Client.GetLocalPlayer()
			if player then
				
				local viewCoords = player:GetViewAngles():GetCoords()	//FIXME This is not working in this context
				
				local trace = Shared.TraceRay(player:GetOrigin(), player:GetOrigin() + viewCoords.zAxis * 1000, CollisionRep.Damage, PhysicsMask.Bullets, EntityFilterOne(player))
				if trace.fraction < 1 then
					
					if trace.entity and HasMixin(trace.entity, "ColoredSkin") then
						
						Print( trace.entity:GetClassName() .. " ColoredSkinsMixin Info" )
						Print("\t ColorMap Atlas Index: " .. tostring( trace.entity.skinAtlasIndex ) )
						Print("\t BaseColor = " .. ColorAsParam( trace.entity.skinBaseColor ) )
						Print("\t AccentColor = " .. ColorAsParam( trace.entity.skinBaseColor ) )
						Print("\t TrimColor = " .. ColorAsParam( trace.entity.skinBaseColor ) )
						Print("\t SkinEnabled = " .. tostring( trace.entity.skinColoringEnabled ) )
						
					end
				
				end
				
			end
		
		end

	end


	local function OnCommandToggleColoredSkins()
		
		if Shared.GetCheatsEnabled() then
			
			gColoredSkinsToggle = ConditionalValue(
				gColoredSkinsToggle == true,
				false,
				true
			)
			
		end

	end


	local function OnCommandChangeColorMapIndex(enable)

		if Shared.GetCheatsEnabled() then
			
			//Toggle flipping through indicies
			if enable == "true" or enable == "1" then
				gColorMapIndexOverrideEnabled = true
			elseif enable == "0" or enable == "false" then
				gColorMapIndexOverrideEnabled = false
			end
			
			if gColorMapIndexOverrideEnabled then
				
				if gColorMapIndexOverride + 1 > gColorMapMaxIndex then
					gColorMapIndexOverride = 0	//Roll back to begining of atlas
				else
					gColorMapIndexOverride = gColorMapIndexOverride + 1
				end
				
			end
		
		end

	end


	local function OnCommandOverrideSkinColor(layer, color)
		
		if Shared.GetCheatsEnabled() then
		
			if not layer and not color and not team then
			//toggle color override state
				gColorOverridesEnabled = ConditionalValue( gColorOverridesEnabled, false, true )
			end
			
			if layer and color then	//Require both params
				
				if layer == "base" or layer == "accent" or layer == "trim" then
					
					//Color values override all colorized model in world for specified layer
					local red, green, blue = 0
					local validColor = true
					local colorValues = StringSplit( color, ",", 3)
					
					for i, cval in ipairs(colorValues) do
						
						local colorIntVal = tonumber( cval )
						Print( tostring( colorIntVal ) )
						if colorIntVal == nil then
							validColor = false
							break
						end
						
						if colorIntVal >= 0 and colorIntVal <= 255 then
							
							if i == 1 then
								red = colorIntVal
							elseif i == 2 then
								green = colorIntVal
							elseif i == 3 then
								blue = colorIntVal
							end
							
						else
							Print("ColoredSkinsMixin: Color(" .. color .. "), a channel value is invalid. Only 0-255 allowed")
							validColor = false
							break
						end
						
					end
					
					if validColor then
						gSkinColorOverrides[layer] = Color( ColorValue(red), ColorValue(green), ColorValue(blue), 1 )	//alpha ignored
						Print("ColoredSkinsMixin: Set global color override: Layer[" .. layer .. "] as " .. ColorAsParam( gSkinColorOverrides[layer] ) )
					else
						Print("ColoredSkinsMixin: Invalid color parameter supplied")
					end
				
				end
				
			end
			
		end
		
	end
	
	
	
	Event.Hook( "Console_skins", OnCommandToggleColoredSkins )			//Toggle
	Event.Hook( "Console_skinsindex", OnCommandChangeColorMapIndex )	//Toggle/Cycler
	Event.Hook( "Console_skins_colors", OnCommandOverrideSkinColor )	//Toggle and value setter

	Event.Hook( "Console_skins_entinfo", OnCommandGetEntityColorInfo )	//FIXME not getting player or performing trace...
	
end	//end Client

