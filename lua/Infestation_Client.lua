// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\Infestation.lua
//
//    Created by:   Andreas Urwalek (a_urwa@sbox.tugraz.at)
//
// Patch of infestation created by alien commander.
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

kClientInfestationCystLimit = 90
gClientInfestationCystCount = 0

Infestation.kClientGeometryUpdateRate = 10

// this is not an absolute number, just the "attempts" to find a place for infestation geometry
Infestation.kNumInfestationCinematics = 60

// floating point accuracy for finding a place
local kCoordAccuracy = 100

// maximum offest from source position
local kCinematicMaxOffset = 4
local kCinematicMinOffset = 0.2

// the decals opacity drop off on the borders, so we increase it's radius client side to make the visuals match the game play
local kClientAddRange = 1
local kClientScalarRange = 1.1

// lets the infestation decals genlty shrink and expand
local kClientPulseAmount = 0.05

local math_sin              = math.sin
local Shared_GetTime        = Shared.GetTime
local Shared_GetEntity      = Shared.GetEntity
local Entity_invalidId      = Entity.invalidId
local Client_GetLocalPlayer = Client.GetLocalPlayer

Infestation.kGeometryCinematics =
{
    PrecacheAsset("cinematics/alien/infestation/infestation1.cinematic"),
    PrecacheAsset("cinematics/alien/infestation/infestation2.cinematic"),
    PrecacheAsset("cinematics/alien/infestation/infestation3.cinematic")
}

local function GetDisplayInfestationBlobs(self)

    if PlayerUI_IsOverhead() and self:GetCoords().yAxis:DotProduct(Vector(0, 1, 0)) < 0.2 then
        return false
    end

    return true    

end

function Infestation:OnInitialized()

    ScriptActor.OnInitialized(self)
    
    self:SetSynchronizes(false)
    self:SetUpdates(true)
    
    local player = Client.GetLocalPlayer()
    
    if player and not player:isa("Commander") then
        self:CreateClientGeometry()
    end

    self.decal = Client.CreateRenderDecal()
    self.infestationMaterial = Client.CreateRenderMaterial()
    self.infestationMaterial:SetMaterial("materials/infestation/infestation_decal.material")
    
    self.decal:SetMaterial(self.infestationMaterial)
    self.decal:SetCoords(self:GetCoords())

end

// calculates coordinates for the infestation cinematics, so it's only done once (once when you see it)
function Infestation:InitClientGeometry()

    self.infestationCoords = { }
    local xOffset = 0
    local zOffset = 0
    local maxRadius = self:GetMaxRadius()

    for j = 1, Infestation.kNumInfestationCinematics do
    
        // limit cysts depending on patch size and by global count
        if #self.infestationCoords >= maxRadius * 2 or gClientInfestationCystCount >= kClientInfestationCystLimit then
            break
        end    
    
        local hostCoords = self:GetCoords()
        local startPoint = hostCoords.origin + hostCoords.yAxis * 0.2
        
        local xDirection = 1
        local yDirection = 1
        
        if math.random(-2, 1) < 0 then
            xDirection = -1
        end
        
        if math.random(-2, 1) < 0 then
            yDirection = -1
        end
        
        local minRand = kCinematicMinOffset * kCoordAccuracy
        local maxRand = (self:GetMaxRadius() / 2) * kCoordAccuracy
        // Note: There is currently a bug where in some cases maxRand < minRand.
        maxRand = math.max(maxRand, minRand + 0.1)
        xOffset = (math.random(minRand, maxRand) / kCoordAccuracy) * xDirection
        zOffset = (math.random(minRand, maxRand) / kCoordAccuracy) * yDirection
        
        startPoint = startPoint + hostCoords.xAxis * xOffset
        startPoint = startPoint + hostCoords.zAxis * zOffset
        
        local endPoint = startPoint - hostCoords.yAxis * 1
        local trace = Shared.TraceRay(startPoint, endPoint, CollisionRep.Default, PhysicsMask.Bullets, EntityFilterAll())
        
        local angles = Angles(0, 0, 0)
        angles.yaw = GetYawFromVector(trace.normal)
        angles.pitch = GetPitchFromVector(trace.normal) + (math.pi / 2)
        
        local normalCoords = angles:GetCoords()
        normalCoords.origin = trace.endPoint
        
        if trace.endPoint ~= endPoint then
            table.insert(self.infestationCoords, CopyCoords(normalCoords))
            gClientInfestationCystCount = gClientInfestationCystCount + 1
        end
    
    end

end

function Infestation:UpdateGeometryVisibility()

    local numberVisible = 0
    
    if self.infestationCinematics ~= nil then
    
        for index, infestation in ipairs(self.infestationCinematics) do
        
            local origin = infestation.Coords.origin
            local distanceSquared = (origin - self:GetOrigin()):GetLengthSquared()
            if distanceSquared < (self:GetRadius() * self:GetRadius()) then
            
                infestation.Cinematic:SetIsVisible(true)
                numberVisible = numberVisible + 1
                
            else
                infestation.Cinematic:SetIsVisible(false)
            end
            
        end
        
    end
    
    // Update visibility during receeding and growing only
    local numCinematics = self.infestationCinematics and #self.infestationCinematics or 0
    
    local isGrowing = (numberVisible < numCinematics and self.hostAlive)
    local isReceeding = not self.hostAlive
    
    return isGrowing or isReceeding
    
end

local function OnHostKilledClient(self)

    self.maxRadius = self:GetRadius()
    self.radiusCached = nil
    self:AddTimedCallback(Infestation.UpdateGeometryVisibility, 1)
    
end

function Infestation:OnUpdate(deltaTime)

    PROFILE("Infestation:OnUpdate")
    
    ScriptActor.OnUpdate(self, deltaTime)

    if self.clientHostAlive ~= self.hostAlive then
    
        self.clientHostAlive = self.hostAlive
        if not self.hostAlive then
            OnHostKilledClient(self)
        end
        
    end
    
end

function Infestation:CreateClientGeometry()

    if not GetDisplayInfestationBlobs(self) then
        return
    end 

    self.infestationCinematics = { }
    local numCinematicVariations = table.count(Infestation.kGeometryCinematics)
    
    if self.infestationCoords == nil or table.count(self.infestationCoords) == 0 then
        self:InitClientGeometry()
    end
    
    for index, coords in ipairs(self.infestationCoords) do

        local cinematic = Infestation.kGeometryCinematics[(index % numCinematicVariations) + 1]
        
        local infestationCinematic = Client.CreateCinematic(RenderScene.Zone_Default)
        infestationCinematic:SetRepeatStyle(Cinematic.Repeat_Loop)
        infestationCinematic:SetCinematic(cinematic)
        infestationCinematic:SetCoords(coords)
        infestationCinematic:SetIsVisible(false)
        
        table.insert(self.infestationCinematics, { Cinematic = infestationCinematic, Coords = coords, Visible = false })
        
    end
    
    self:AddTimedCallback(Infestation.UpdateGeometryVisibility, 1)
    
end

function Infestation:DestroyClientGeometry()

    if self.infestationCinematics ~= nil then
    
        for index, infestationCinematic in ipairs(self.infestationCinematics) do
            Client.DestroyCinematic(infestationCinematic.Cinematic)
            gClientInfestationCystCount = gClientInfestationCystCount - 1
        end
        
        self.infestationCinematics = nil
        
    end

end

function Infestation:OnUpdateRender()

    PROFILE("Infestation:OnUpdateRender")

    // remove ceiling infestation blobs for commanders, they block their vision otherwise
    
    ScriptActor.OnUpdateRender(self)
    
    local decal = self.decal
    
    if decal then
    
        local radius = self:GetRadius()
    
        local radiusFraction = radius / self.maxRadius
        local radiusMod = math_sin(Shared_GetTime() + (self:GetId() % 10))
        local radiusMod = radiusMod * kClientPulseAmount + (1 - radiusFraction) * radiusMod * radius * .2

        local parentCloakFraction = 0
        local parentCloaked = false
        
        local infestationParentId = self.infestationParentId
        if infestationParentId ~= Entity_invalidId then
        
            local infestationParent = Shared_GetEntity(infestationParentId)
            if infestationParent and HasMixin(infestationParent, "Cloakable") then
                parentCloakFraction = infestationParent:GetCloakedFraction()
                
                if not GetAreEnemies(self, Client_GetLocalPlayer()) then
                    parentCloakFraction = parentCloakFraction * 0.5
                end
                
                parentCloaked = parentCloakFraction > 0.03
            end
        
        end
        
        if parentCloaked or not GetDisplayInfestationBlobs(self) then
            self:DestroyClientGeometry()
        elseif not self.infestationCinematics then
            self:CreateClientGeometry()
        end

        local clientRadius = radius * kClientScalarRange + kClientAddRange * (radiusFraction) + radiusMod
        
        decal:SetExtents( Vector(clientRadius, Infestation.kDecalVerticalSize, clientRadius) )
        self.infestationMaterial:SetParameter("intensity", 1-parentCloakFraction)
        
    end
    
end
