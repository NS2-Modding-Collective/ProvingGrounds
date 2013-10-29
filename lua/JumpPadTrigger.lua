//=======================================================================
//
//   	Created For Proving Grounds by Andy Wilson  
//      lua\JumpPadTrigger.lua
//      
//===========================================================================

class 'JumpPadTrigger' (Trigger)

JumpPadTrigger.kMapName = "jump_pad_trigger"


local networkVars =
{
}

local fireDirection = Vector(0,1,0)
local fireForce = 45

local function fireJumpPad(self, entity)
       
    fireVelocity = fireDirection * fireForce
    entity:SetVelocity(fireVelocity)

end

function JumpPadTrigger:OnCreate()
 
    Trigger.OnCreate(self)  
    
end

function JumpPadTrigger:OnInitialized()

    Trigger.OnInitialized(self) 
    self:SetTriggerCollisionEnabled(true) 
end

function JumpPadTrigger:OnTriggerEntered(enterEnt, triggerEnt)

    if enterEnt:isa("Player") then
         fireJumpPad(self, enterEnt)
    end
end

Shared.LinkClassToMap("JumpPadTrigger", JumpPadTrigger.kMapName, networkVars)