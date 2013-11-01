// ========================================================================================
//
// lua\ItemPickups.lua
//
//    Created by:   Andy Wilson for Proving Grounds Mod
//
// =========================================================================================

Script.Load("lua/Mixins/ClientModelMixin.lua")

class 'ItemPickups' (ScriptActor)

ItemPickups.kMapName = "itempickups"

local kPickupRange = 1

local networkVars =
{
}

AddMixinNetworkVars(BaseModelMixin, networkVars)
AddMixinNetworkVars(ClientModelMixin, networkVars)

local function TimeUp(self)
    DestroyEntity(self)
end

function ItemPickups:OnCreate()

    ScriptActor.OnCreate(self)
    
    InitMixin(self, BaseModelMixin)
    InitMixin(self, ClientModelMixin)
    
end


function ItemPickups:OnInitialized()

    ScriptActor.OnInitialized(self)

    if Server then
    
        self:AddTimedCallback(TimeUp, kItemStayTime)
        self.pickupRange = kPickupRange
        self:SetAngles(Angles(0, math.random() * math.pi * 2, 0))
        
        self:OnUpdate(0)
    
    end

end

function ItemPickups:GetCanBeUsed()
    return true    
end

if Server then

    function ItemPickups:OnUpdate(deltaTime)
    
        PROFILE("ItemPickups:OnUpdate")
    
        ScriptActor.OnUpdate(self, deltaTime)    
        
        // update pickup
        local playersNearby = GetEntitiesWithinRange("Avatar", self:GetOrigin(), self.pickupRange)
        Shared.SortEntitiesByDistance(self:GetOrigin(), playersNearby)

        for _, player in ipairs(playersNearby) do
        
            if self:GetIsValidRecipient(player) then
            
                self:OnTouch(player)
                DestroyEntity(self)
                break
                
            end
        
        end
        
    end

end

function ItemPickups:SpawnItem(item, origin)
    
    if origin == nil or angles == nil then
    
        // Randomly choose unobstructed spawn points to spawn the item
        local spawnPoint = nil
        local spawnPoints = nil
        if item == kSpawnItem1 then
            spawnPoints = Server.spawnItem1List
        end
        local numSpawnPoints = table.maxn(spawnPoints)
        
        if numSpawnPoints > 0 then
        
            local spawnPoint = GetRandomClearSpawnPoint(item, spawnPoints)
            if spawnPoint ~= nil then
            
                origin = spawnPoint:GetOrigin()
                
            end
            
        end
        
    end
    
    // Move origin up and drop it to floor to prevent stuck issues with floating errors or slightly misplaced spawns
    if origin ~= nil then
    
        SpawnItemAtPoint(item, origin)
        
        return true
        
    else
        Print("ItemPickups:SpawnItem(item, %s, %s) - Must specify origin.", ToString(origin))
    end
    
    return false
    
end


function ItemPickups:GetPhysicsModelAllowedOverride()
    return false
end

Shared.LinkClassToMap("ItemPickups", ItemPickups.kMapName, networkVars, false)