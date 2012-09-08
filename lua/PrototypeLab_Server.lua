// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\PrototypeLab.lua
//
//    Created by:   Andreas Urwalek (a_urwa@sbox.tugraz.at)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

// west/east = x/-x
// north/south = -z/z

local indexToUseOrigin = {
    // West
    Vector(PrototypeLab.kResupplyUseRange, 0, 0), 
    // North
    Vector(0, 0, -PrototypeLab.kResupplyUseRange),
    // South
    Vector(0, 0, PrototypeLab.kResupplyUseRange),
    // East
    Vector(-PrototypeLab.kResupplyUseRange, 0, 0)
}

// Check if friendly players are nearby and facing PrototypeLab
function PrototypeLab:OnThink()

    ScriptActor.OnThink(self)

    self:UpdateLoggedIn()   
    
    self:SetNextThink(PrototypeLab.kThinkTime)
    
end

function PrototypeLab:UpdateLoggedIn()

    local players = GetEntitiesForTeamWithinRange("Marine", self:GetTeamNumber(), self:GetOrigin(), 2 * PrototypeLab.kResupplyUseRange)
    local ptLabCoords = self:GetAngles():GetCoords()
    
    for i = 1, 4 do
    
        local newState = false
        
        if GetIsUnitActive(self) then
        
            local worldUseOrigin = self:GetModelOrigin() + ptLabCoords:TransformVector(indexToUseOrigin[i])
            
            for playerIndex, player in ipairs(players) do
            
                // See if player is nearby
                if player:GetIsAlive() and (player:GetModelOrigin() - worldUseOrigin):GetLength() < PrototypeLab.kResupplyUseRange then
                
                    newState = true
                    break
                    
                end
                
            end
            
        end
        
        if newState ~= self.loggedInArray[i] then
        
            if newState then
                self:TriggerEffects("prototypelab_open")
            else
                self:TriggerEffects("prototypelab_close")
            end
            
            self.loggedInArray[i] = newState
            
        end
        
    end
    
    // Copy data to network variables (arrays not supported)    
    self.loggedInWest = self.loggedInArray[1]
    self.loggedInNorth = self.loggedInArray[2]
    self.loggedInSouth = self.loggedInArray[3]
    self.loggedInEast = self.loggedInArray[4]
    
end    
