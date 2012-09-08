// ======= Copyright (c) 2012, Unknown Worlds Entertainment, Inc. All rights reserved. ==========
//
// lua\HelpMixin.lua
//
//    Created by:   Brian Cronin (brianc@unknownworlds.com)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

HelpMixin = CreateMixin(HelpMixin)
HelpMixin.type = "Help"

assert(Server == nil)

function HelpMixin:__initmixin()
    self.activeHelpWidget = nil
end

function HelpMixin:AddHelpWidget(setGUIName, limit)

    if self == Client.GetLocalPlayer() then
    
        // Only draw if we have hints enabled 
        if Client.GetOptionBoolean( "showHints", true ) then
    
            // Only one help widget allowed at a time.
            if self.activeHelpWidget == nil then
            
                -- Don't display widgets the ready room
                if self:GetTeamNumber() ~= kNeutralTeamType then

                    local optionName = "help/" .. string.lower(setGUIName)
                    local currentAmount = Client.GetOptionInteger(optionName, 0)
                    if currentAmount < limit then
                        self.activeHelpWidget = GetGUIManager():CreateGUIScript(setGUIName)
                    end
                
                end
                
            end
            
        end
    
    end
    
end

local function DestroyUI(self)

    if self.activeHelpWidget then
        GetGUIManager():DestroyGUIScript(self.activeHelpWidget)
    end
    self.activeHelpWidget = nil
    
end

function HelpMixin:OnKillClient()
    DestroyUI(self)
end

function HelpMixin:OnDestroy()
    DestroyUI(self)
end