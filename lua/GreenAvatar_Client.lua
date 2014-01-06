// =========================================================================================
//
// lua\GreenAvatar_Client.lua
//
//    Created by:   Andy 'Soul Rider' Wilson for Proving Grounds Mod
//
// ================================================================================================

function GreenAvatar:UpdateClientEffects(deltaTime, isLocal)
    
    Avatar.UpdateClientEffects(self, deltaTime, isLocal)
    
    if isLocal then
        
        local greenAvatarHUD = ClientUI.GetScript("Hud/Marine/GUIGreenHUD")
        if greenAvatarHUD then
            greenAvatarHUD:SetIsVisible(self:GetIsAlive())
        end
    
    end
    
end

function GreenAvatar:OnCountDown()

    Player.OnCountDown(self)
    
    local script = ClientUI.GetScript("Hud/Marine/GUIGreenHUD")
    if script then
        script:SetIsVisible(false)
    end
    
end

function GreenAvatar:OnCountDownEnd()

    Player.OnCountDownEnd(self)
    
    local script = ClientUI.GetScript("Hud/Marine/GUIGreenHUD")
    if script then
    
        script:SetIsVisible(true)
        script:TriggerInitAnimations()
        
    end
    
end