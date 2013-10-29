// =============================================================================================
//
// lua\SpawnItem.lua
//
//    Created by:   Andy Wilson for Proving Grounds
//
// ==============================================================================================

Script.Load("lua/Mixins/ClientModelMixin.lua")

class 'SpawnItem' (ScriptActor)

SpawnItem.kMapName = "spawnitem"

local kPickupRange = 1

local networkVars =
{
}

AddMixinNetworkVars(BaseModelMixin, networkVars)
AddMixinNetworkVars(ClientModelMixin, networkVars)


function SpawnItem:OnCreate()

    ScriptActor.OnCreate(self)
    
    InitMixin(self, BaseModelMixin)
    InitMixin(self, ClientModelMixin)
    
end

function SpawnItem:OnInitialized()

    ScriptActor.OnInitialized(self)

    if Server then

        self.pickupRange = kPickupRange
        self:SetAngles(Angles(0, math.random() * math.pi * 2, 0))
        
        self:OnUpdate(0)
    
    end

end

if Server then

    function SpawnItem:OnUpdate(deltaTime)
    
        PROFILE("SpawnItem:OnUpdate")
    
        ScriptActor.OnUpdate(self, deltaTime)    
        
end

function SpawnItem:GetPhysicsModelAllowedOverride()
    return false
end

Shared.LinkClassToMap("SpawnItem", SpawnItem.kMapName, networkVars, false)