// ===========================================
//
// lua\PurpleAvatar.lua
//
//    Created by:   Andy 'Soul Rider' Wilson for Proving Grounds
//
// ============================================

Script.Load("lua/Avatar.lua")
Script.Load("lua/AvatarVariantMixin.lua")

if Client then
    Script.Load("lua/TeamMessageMixin.lua")
end

class 'PurpleAvatar' (Avatar)

PurpleAvatar.kMapName = "purpleavatar"

local networkVars =
{         
}
AddMixinNetworkVars(AvatarVariantMixin, networkVars)

function PurpleAvatar:OnCreate()

    Avatar.OnCreate(self)

    if Client then
        InitMixin(self, TeamMessageMixin, { kGUIScriptName = "GUIMarineTeamMessage" })
    end

end

if Client then

    function PurpleAvatar:GetBaseSkinColor()
	    return Color(0.731, 0.243, 0.999, 1)
	end
	
	function PurpleAvatar:GetAccentSkinColor()
	    return Color(0.942, 0.621, 0.903, 1)
	end
	
	function PurpleAvatar:GetTrimSkinColor()
	    return Color(0.976, 0.594, 0.711, 1)
	end
	
	function PurpleAvatar:InitializeSkin()
		self.skinBaseColor = self:GetBaseSkinColor() 
		self.skinAccentColor = self:GetAccentSkinColor() 
		self.skinTrimColor = self:GetTrimSkinColor() 
		self.skinAtlasIndex = 0	//ColorMap atlas texture is 0 indexed
	end
	

end

function PurpleAvatar:OnInitialized()
    
    // SetModel must be called before Player.OnInitialized is called so the attach points in
    // the Marine are valid to attach weapons to. This is far too subtle...
    // Player.OnInitialised is called in Avatar.OnInitialized - AW Proving Grounds

    Avatar.OnInitialized(self)

    if Client then  
        self:InitializeSkin()
    end   

end

Shared.LinkClassToMap("PurpleAvatar", PurpleAvatar.kMapName)