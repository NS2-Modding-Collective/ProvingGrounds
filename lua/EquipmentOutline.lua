// ======= Copyright (c) 2012, Unknown Worlds Entertainment, Inc. All rights reserved. ==========    
//    
// lua\EquipmentOutline.lua    
//    
//    Created by:   Andreas Urwalek (andi@unknownworlds.com) and
//                  Max McGuire (max@unknownworlds.com)
//    
// ========= For more information, visit us at http://www.unknownworlds.com =====================    

local _renderMask       = 0x4
local _invRenderMask    = bit.bnot(_renderMask)
local _maxDistance      = 25
local _enabled          = true

function EquipmentOutline_Initialize()

    EquipmentOutline_camera = Client.CreateRenderCamera()
    EquipmentOutline_camera:SetTargetTexture("*equipment_outline", true)
    EquipmentOutline_camera:SetRenderMask( _renderMask )
    EquipmentOutline_camera:SetIsVisible( false )
    EquipmentOutline_camera:SetCullingMode( RenderCamera.CullingMode_Frustum )
    EquipmentOutline_camera:SetRenderMode( RenderCamera.RenderMode_Depth )
    
    EquipmentOutline_screenEffect = Client.CreateScreenEffect("shaders/EquipmentOutline.screenfx")
    EquipmentOutline_screenEffect:SetActive(false)    
    
end

function EquipmentOutline_Shudown()

    Client.DestroyRenderCamera(_camera)
    EquipmentOutline_camera = nil
    
    Client.DestroyScreenEffect(_screenEffect)
    EquipmentOutline_screenEffect = nil

end

/** Enables or disabls the hive vision effect. When the effect is not needed it should 
 * be disabled to boost performance. */
function EquipmentOutline_SetEnabled(enabled)

    EquipmentOutline_camera:SetIsVisible(enabled and _enabled)
    EquipmentOutline_screenEffect:SetActive(enabled and _enabled) 
   
end

/** Must be called prior to rendering */
function EquipmentOutline_SyncCamera(camera)

    EquipmentOutline_camera:SetCoords( camera:GetCoords() )
    EquipmentOutline_camera:SetFov( camera:GetFov() )
    EquipmentOutline_camera:SetFarPlane( _maxDistance + 1 )
    EquipmentOutline_screenEffect:SetParameter("time", Shared.GetTime())
    EquipmentOutline_screenEffect:SetParameter("maxDistance", _maxDistance)
   
end

/** Adds a model to the hive vision */
function EquipmentOutline_AddModel(model)

    local renderMask = model:GetRenderMask()
    model:SetRenderMask( bit.bor(renderMask, _renderMask) )
    
end

/** Removes a model from the hive vision */
function EquipmentOutline_RemoveModel(model)

    local renderMask = model:GetRenderMask()
    model:SetRenderMask( bit.band(renderMask, _invRenderMask) )
    
end

// for debugging
local function OnCommandOutline(enabled)
    _enabled = enabled ~= "false"
end

function EquipmentOutline_UpdateModel(forEntity)

    local player = Client.GetLocalPlayer()

    // Check if player can pickup this item
    local visible = false
    visible = player ~= nil and forEntity:GetIsValidRecipient(player)       

    // Update the visibility status.
    if visible ~= forEntity.equipmentVisible then
    
        local model = HasMixin(forEntity, "Model") and forEntity:GetRenderModel() or nil
        if model ~= nil then
        
            if visible then
                EquipmentOutline_AddModel( model )
            else
                EquipmentOutline_RemoveModel( model )
            end                    
            forEntity.equipmentVisible = visible    
            
        end
        
    end

end

Event.Hook("Console_outline", OnCommandOutline)