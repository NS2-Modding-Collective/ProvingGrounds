Script.Load("lua/RenderLightMixin.lua")
class "HealthPickup" (ScriptActor)

HealthPickup.kMapName = "healthpickup"
HealthPickup.kModelName = PrecacheAsset("models/healthpack/healthpack.model")

local kHealthSound = PrecacheAsset("sound/NS2.fev/marine/common/health")

local function CheckForRecipients(self)

    for _, avatar in ipairs(GetEntitiesWithinRange("Avatar", self:GetOrigin(), 1.7)) do
    
        if avatar:GetIsAlive() and avatar:GetHealth() > 0 and avatar:GetHealth() < 100 then

            avatar:AddHealth(kPickupHealth, false, false)
            PrintToLog("Health is %s", avatar:GetHealth())
            StartSoundEffectAtOrigin(kHealthSound, self:GetOrigin())
            DestroyEntity(self)
            
            return false
            
        end
    
    end

    return true

end

function HealthPickup:SetVelocity(velocity)
    
    if self.physicsBody then
        self.physicsBody:SetLinearVelocity(velocity)
    end
    
end

if Client then

    function HealthPickup:OnCreate()
    
        ScriptActor.OnCreate(self)
        InitMixin(self, RenderLightMixin)

    end
    
end

local function TimeUp(self)
    DestroyEntity(self)
end

function HealthPickup:OnInitialized()

    if Client then

        self.renderModel = Client.CreateRenderModel(RenderScene.Zone_Default)
        self.renderModel:SetModel(Shared.GetModelIndex(HealthPickup.kModelName))
        self.renderModel:SetCoords(self:GetCoords())  

    elseif Server then    
    
        self:AddTimedCallback(CheckForRecipients, 0.1)     

        self.physicsBody = Shared.CreatePhysicsSphereBody(true, 0.2, 15, self:GetCoords())
        self.physicsBody:SetGravityEnabled(true)
        self.physicsBody:SetGroup(PhysicsGroup.WeaponGroup)
        self.physicsBody:SetEntity(self)
        self.physicsBody:SetPhysicsType(CollisionObject.Dynamic)
        self.physicsBody:SetLinearDamping(0)
        self.physicsBody:SetRestitution(0.5)
        self.physicsBody:SetGroupFilterMask(PhysicsMask.DroppedWeaponFilter)
        
        self:AddTimedCallback(TimeUp, 60)
   
    end

end

function HealthPickup:GetRenderLightColor()
    return Color(0.65, 4, 0.65, 1)
end    

function HealthPickup:OnDestroy()

    if self.renderModel then
    
        Client.DestroyRenderModel(self.renderModel)
        self.renderModel = nil
        
    end
    
    if self.physicsBody then
    
        Shared.DestroyCollisionObject(self.physicsBody)
        self.physicsBody = nil
        
    end

end

if Server then
    
    function HealthPickup:OnUpdate(deltaTime)
    
        ScriptActor.OnUpdate(self, deltaTime)
        
        if self:GetIsDestroyed() then
            return
        end
        
        local coords = self.physicsBody:GetCoords()
        self:SetCoords(coords)
        
    end
    
end

function HealthPickup:GetSimplePhysicsBodyType()
    return kSimplePhysicsBodyType.Sphere
end

function HealthPickup:GetSimplePhysicsBodySize()
    return 0.2
end

function HealthPickup:OnUpdateRender()

    if self.renderModel then
        self.renderModel:SetCoords(self:GetCoords())
    end
    
    if self.light then
        self.light:SetCoords(self:GetCoords())
    end

end

Shared.LinkClassToMap("HealthPickup", HealthPickup.kMapName, networkVars)
