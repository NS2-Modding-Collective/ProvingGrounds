// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\GUIWorldText.lua
//
// Created by: Andreas Urwalek (andi@unknownworlds.com)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

class 'GUIWorldText' (GUIScript)

GUIWorldText.kFont = "fonts/AgencyFB_small.fnt"
GUIWorldText.kYAnim = -30


local function CreateMessageItem(self)

    local messageItem = GetGUIManager():CreateTextItem()
    messageItem:SetFontName(GUIWorldText.kFont)
    messageItem:SetTextAlignmentX(GUIItem.Align_Center)
    messageItem:SetTextAlignmentY(GUIItem.Align_Center)
    
    table.insert(self.messages, messageItem)

end

local function RemoveMessageItem(self, messageItem)

    table.removevalue(self.messages, messageItem)
    GUI.DestroyItem(messageItem)

end

function GUIWorldText:Initialize()

    GUIScript.Initialize(self)
    
    self.messages = {}

end

function GUIWorldText:Uninitialize()

    for _, messageItem in ipairs(self.messages) do    
        GUI.DestroyItem(messageItem)    
    end
    
    self.messages = nil
    
end

function GUIWorldText:Update(deltaTime)

    if not self.messages then
        Print("Warning: GUIWorldText script has not been cleaned up properly")
        return
    end
    
    local messages = PlayerUI_GetWorldMessages()    
    local messageDiff = #messages - #self.messages
    
    if messageDiff > 0 then
    
        // add new messages
        for i = 1, math.abs(messageDiff) do        
            CreateMessageItem(self)        
        end    
    
    elseif messageDiff < 0 then
    
        // remove unused messages
        for i = 1, math.abs(messageDiff) do        
            RemoveMessageItem(self, self.messages[1])        
        end
    
    end
    
    local messageItem = nil
    local animYOffset = 0
    local position = nil
    local useColor = ConditionalValue(PlayerUI_IsOnMarineTeam(), Color(kMarineTeamColorFloat), Color(kAlienTeamColorFloat))
    
    for index, message in ipairs(messages) do
    
        messageItem = self.messages[index]
        animYOffset = message.animationFraction * GUIWorldText.kYAnim
        position = Vector(message.x, message.y + animYOffset, 0)        
        useColor.a = 1 - message.animationFraction
        
        messageItem:SetText(message.text)
        messageItem:SetPosition(position)
        messageItem:SetColor(useColor)
    
    end

end