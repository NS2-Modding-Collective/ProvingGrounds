// ========================================================================================
//
// lua\GreenAvatar.lua
//
//    Created by:   Andy 'Soul Rider' Wilson for Proving Grounds
//
// ========================================================================================

Script.Load("lua/AvatarVariantMixin.lua")
Script.Load("lua/Avatar.lua")

if Client then
    Script.Load("lua/TeamMessageMixin.lua")
end



class 'GreenAvatar' (Avatar)

GreenAvatar.kMapName = "greenavatar"

local networkVars =
{         
}

AddMixinNetworkVars(AvatarVariantMixin, networkVars)

function GreenAvatar:OnCreate()

    Avatar.OnCreate(self)
        
    if Client then
        InitMixin(self, TeamMessageMixin, { kGUIScriptName = "GUIMarineTeamMessage" })    
    end


end

if Client then

    function GreenAvatar:GetBaseSkinColor()
	    return Color(0.078, 0.978, 0.384, 1)
	end
	
	function GreenAvatar:GetAccentSkinColor()
	    return Color(0.756, 0.982, 1, 1)
	end
	
	function GreenAvatar:GetTrimSkinColor()
	    return Color(0.725, 0.921, 0.949, 1)
	end
	
	function GreenAvatar:InitializeSkin()
		self.skinBaseColor = self:GetBaseSkinColor() 
		self.skinAccentColor = self:GetAccentSkinColor() 
		self.skinTrimColor = self:GetTrimSkinColor() 
		self.skinAtlasIndex = 0	//ColorMap atlas texture is 0 indexed
	end
	

end

function GreenAvatar:OnInitialized()
    
    // SetModel must be called before Player.OnInitialized is called so the attach points in
    // the Marine are valid to attach weapons to. This is far too subtle...
    // Player.OnInitialised is called in Avatar.OnInitialized - AW Proving Grounds

    Avatar.OnInitialized(self)
    if Client then  
        self:InitializeSkin()
    end
end

Shared.LinkClassToMap("GreenAvatar", GreenAvatar.kMapName)