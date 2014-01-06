// =========================================================================================
//
// lua\PurpleAvatar_Client.lua
//
//    Created by:   Andy 'Soul Rider' Wilson for Proving Grounds Mod
//
// ================================================================================================

function PurpleAvatar:UpdateClientEffects(deltaTime, isLocal)
    
    Avatar.UpdateClientEffects(self, deltaTime, isLocal)
    
    if isLocal then
        
        local PurpleAvatarHUD = ClientUI.GetScript("Hud/Marine/GUIPurpleHUD")
        if PurpleAvatarHUD then
            PurpleAvatarHUD:SetIsVisible(self:GetIsAlive())
        end
    
    end
    
end

function PurpleAvatar:OnCountDown()

    Player.OnCountDown(self)
    
    local script = ClientUI.GetScript("Hud/Marine/GUIPurpleHUD")
    if script then
        script:SetIsVisible(false)
    end
    
end

function PurpleAvatar:OnCountDownEnd()

    Player.OnCountDownEnd(self)
    
    local script = ClientUI.GetScript("Hud/Marine/GUIPurpleHUD")
    if script then
    
        script:SetIsVisible(true)
        script:TriggerInitAnimations()
        
    end
    
end