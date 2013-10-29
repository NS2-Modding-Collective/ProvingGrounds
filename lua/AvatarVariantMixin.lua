// =========================================================================================
//
// lua\AvatarVariantMixin.lua
//
//    Created by:   Andy 'Soul Rider' Wilson for Proving Grounds Mod
//
// ================================================================================================

Script.Load("lua/Globals.lua")
Script.Load("lua/NS2Utility.lua")

AvatarVariantMixin = CreateMixin(AvatarVariantMixin)
AvatarVariantMixin.type = "AvatarVariant"

local kDefaultVariantData = kAvatarVariantData[ kDefaultAvatarVariant ]

// Utiliy function for other models that are dependent on marine variant
function GenerateAvatarViewModelPaths(weaponName)

    local viewModels = { male = { }, female = { } }
    
    local function MakePath( prefix, suffix )
        return "models/marine/"..weaponName.."/"..prefix..weaponName.."_view"..suffix..".model"
    end
    
    for variant, data in pairs(kAvatarVariantData) do
        viewModels.male[variant] = PrecacheAssetSafe( MakePath("", data.viewModelFilePart), MakePath("", kDefaultVariantData.viewModelFilePart) )
    end
    
    for variant, data in pairs(kAvatarVariantData) do
        viewModels.female[variant] = PrecacheAssetSafe( MakePath("female_", data.viewModelFilePart), MakePath("female_", kDefaultVariantData.viewModelFilePart) )
    end
    
    return viewModels
    
end

// precache models fror all variants
AvatarVariantMixin.kModelNames = { male = { }, female = { } }

local function MakeModelPath( gender, suffix )
    return "models/marine/"..gender.."/"..gender..suffix..".model"
end

for variant, data in pairs(kAvatarVariantData) do
    AvatarVariantMixin.kModelNames.male[variant] = PrecacheAssetSafe( MakeModelPath("male", data.modelFilePart), MakeModelPath("male", kDefaultVariantData.modelFilePart) )
end

for variant, data in pairs(kAvatarVariantData) do
    AvatarVariantMixin.kModelNames.female[variant] = PrecacheAssetSafe( MakeModelPath("female", data.modelFilePart), MakeModelPath("female", kDefaultVariantData.modelFilePart) )
end

AvatarVariantMixin.kDefaultModelName = AvatarVariantMixin.kModelNames.male[kDefaultAvatarVariant]

AvatarVariantMixin.kMarineAnimationGraph = PrecacheAsset("models/marine/male/male.animation_graph")

AvatarVariantMixin.networkVars =
{
    shoulderPadIndex = "integer (0 to 4)",
    isMale = "boolean",
    variant = "enum kAvatarVariant",
}

function AvatarVariantMixin:__initmixin()

    self.isMale = true
    self.variant = kDefaultAvatarVariant
    self.shoulderPadIndex = 0
    
end

function AvatarVariantMixin:GetGenderString()
    return self.isMale and "male" or "female"
end

function AvatarVariantMixin:GetIsMale()
    return self.isMale
end

function AvatarVariantMixin:GetVariant()
    return self.variant
end

function AvatarVariantMixin:GetEffectParams(tableParams)
    tableParams[kEffectFilterSex] = self:GetGenderString()
end

function AvatarVariantMixin:GetVariantModel()
    return AvatarVariantMixin.kModelNames[ self:GetGenderString() ][ self.variant ]
end

if Server then

    // Usually because the client connected or changed their options.
    function AvatarVariantMixin:OnClientUpdated(client)
    
        Player.OnClientUpdated(self, client)
        
        local data = client.variantData
        if data == nil then
            return
        end
        
        local changed = data.isMale ~= self.isMale or data.avatarVariant ~= self.variant
        
        self.isMale = data.isMale
        
        // Some entities using AvatarVariantMixin don't care about model changes.
        if self.GetIgnoreVariantModels and self:GetIgnoreVariantModels() then
            return
        end
        
        if GetHasVariant(kAvatarVariantData, data.avatarVariant, client) then
        
            // Cleared, pass info to clients.
            self.variant = data.avatarVariant
            assert(self.variant ~= -1)
            local modelName = self:GetVariantModel()
            assert(modelName ~= "")
            self:SetModel(modelName, AvatarVariantMixin.kMarineAnimationGraph)
            
        else
            Print("ERROR: Client tried to request marine variant they do not have yet")
        end
        
        // Set the highest level shoulder pad.
        self.shoulderPadIndex = 0
        for padId = 1, #kShoulderPad2ProductId do
        
            if GetHasShoulderPad(padId, client) then
                self.shoulderPadIndex = padId
            end
            
        end
        
        if changed then
        
            // Trigger a weapon switch, to update the view model
            if self:GetActiveWeapon() ~= nil then
                self:GetActiveWeapon():OnDraw(self)
            end
            
        end
        
    end
    
end

if Client then

    function AvatarVariantMixin:OnUpdateRender()

        // update player patch
        if self:GetRenderModel() ~= nil then
            self:GetRenderModel():SetMaterialParameter("patchIndex", self.shoulderPadIndex-1)

            // TEMP
            //self:GetRenderModel():SetMaterialParameter("patchIndex", self:GetClientIndex()%3 - 1 )

            // TEMP
            //self:GetRenderModel():SetMaterialParameter("patchIndex", 1 )
        end
    
    end

end
