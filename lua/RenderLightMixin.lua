// ======= Copyright (c) 2003-2013, Unknown Worlds Entertainment, Inc. All rights reserved. =======    
//    
// lua\RenderLightMixin.lua    
//    
//    Created by:   Andreas Urwalek (andi@unknownworlds.com)    
//    
// ========= For more information, visit us at http://www.unknownworlds.com =====================  

RenderLightMixin = CreateMixin(RenderLightMixin)
RenderLightMixin.type = "RenderLight"

function RenderLightMixin:__initmixin()
    assert(Client)
end

function RenderLightMixin:OnInitialized()

    self.light = Client.CreateRenderLight()
    self.light:SetType(RenderLight.Type_Point)
    self.light:SetCastsShadows(false)
    self.light:SetRadius(4)
    self.light:SetIntensity(3)
    
    local color = self:GetRenderLightColor() or Color(1,1,1,1)
    
    self.light:SetColor(color)
    self.light:SetCoords(self:GetCoords())
        
end    

function RenderLightMixin:OnDestroy()    
    
    if self.light then
    
        Client.DestroyRenderLight(self.light)
        self.light = nil
    
    end
    
end

function RenderLightMixin:OnUpdateRender()
    
    if self.light then
        self.light:SetCoords(self:GetCoords())
    end

end

