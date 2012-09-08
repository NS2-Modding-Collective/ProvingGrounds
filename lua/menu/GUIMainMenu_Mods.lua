// ======= Copyright (c) 2003-2012, Unknown Worlds Entertainment, Inc. All rights reserved. =====
//
// lua\menu\GUIMainMenu_Mods.lua
//
//    Created by:   Marc Delorme (marc@unknownworlds.com)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

function GUIMainMenu:RefreshModsList()

    self.displayedMods = { }
    self.modsTable:ClearChildren()
    self.selectMod:SetIsVisible(false)
    return Client.RefreshModList()
    
end

function GUIMainMenu:CreateModsWindow()

    self.modsWindow = self:CreateWindow()
    self.modsWindow:DisableCloseButton()
    self:SetupWindow(self.modsWindow, "MODS")
    self.modsWindow:GetContentBox():SetCSSClass("server_list")
    
    local back = CreateMenuElement(self.modsWindow, "MenuButton")
    back:SetCSSClass("back")
    back:SetText("BACK")
    back:AddEventCallbacks( { OnClick = function() self.modsWindow:SetIsVisible(false) end } )
    
    self.highlightMod = CreateMenuElement(self.modsWindow:GetContentBox(), "Image")
    self.highlightMod:SetCSSClass("highlight_server")
    self.highlightMod:SetIgnoreEvents(true)
    self.highlightMod:SetIsVisible(false)
    
    self.blinkingArrow = CreateMenuElement(self.highlightMod, "Image")
    self.blinkingArrow:SetCSSClass("blinking_arrow")
    self.blinkingArrow:GetBackground():SetInheritsParentStencilSettings(false)
    self.blinkingArrow:GetBackground():SetStencilFunc(GUIItem.Always)
    
    self.selectMod = CreateMenuElement(self.modsWindow:GetContentBox(), "Image")
    self.selectMod:SetCSSClass("select_server")
    self.selectMod:SetIsVisible(false)
    self.selectMod:SetIgnoreEvents(true)
    
    self.modsRowNames = CreateMenuElement(self.modsWindow, "Table")
    self.modsTable = CreateMenuElement(self.modsWindow:GetContentBox(), "Table")
    
    --[[
    local columnClassNames =
    {
        "modname",
        "modkind",
        "state",
        "active",
        "subscribed"
    }
    --]]
    
    local columnClassNames =
    {
        "servername",
        "game",
        "map",
        "players",
        "ping"
    }
    
    local rowNames = { { "NAME", "KIND", "STATE", "ACTIVE", "SUBSCRIBED" } }
    
    self.modsRowNames:SetCSSClass("server_list_row_names")
    self.modsRowNames:SetColumnClassNames(columnClassNames)
    -- self.modsRowNames:SetEntryCallbacks(entryCallbacks)
    self.modsRowNames:SetRowPattern( {RenderServerNameEntry} )
    self.modsRowNames:SetTableData(rowNames)
    
    -- MAYBE NEED TO CHANGE
    local rowPattern =
    {
        RenderServerNameEntry
    }
    
    self.modsTable:SetRowPattern(rowPattern)
    self.modsTable:SetCSSClass("server_list")
    self.modsTable:SetColumnClassNames(columnClassNames)
    
    local OnRowCreate = function(row)
    
        local eventCallbacks =
        {
            OnMouseIn = function(self, buttonPressed)
                MainMenu_OnMouseIn()
            end,
            
            OnMouseOver = function(self)
            
                local height = self:GetHeight()
                local topOffSet = self:GetBackground():GetPosition().y + self:GetParent():GetBackground():GetPosition().y
                self.scriptHandle.highlightMod:SetBackgroundPosition(Vector(0, topOffSet, 0), true)
                self.scriptHandle.highlightMod:SetIsVisible(true)
                
            end,
            
            OnMouseOut = function(self)
                self.scriptHandle.highlightMod:SetIsVisible(false)
            end,
            
            OnMouseDown = function(self)
            
                local height = self:GetHeight()
                local topOffSet = self:GetBackground():GetPosition().y + self:GetParent():GetBackground():GetPosition().y
                self.scriptHandle.selectMod:SetBackgroundPosition(Vector(0, topOffSet, 0), true)
                self.scriptHandle.selectMod:SetIsVisible(true)
                -- MainMenu_SelectMod(self:GetId())
                
            end
        }
        
        row:AddEventCallbacks(eventCallbacks)
        row:SetChildrenIgnoreEvents(true)
        
    end
    
    self.modsTable:SetRowCreateCallback(OnRowCreate)
    self.modsTable:SetColumnClassNames(columnClassNames)
    
    self.modsWindow:AddEventCallbacks({ 
        OnShow = function() self:RefreshModsList() end 
    })
    
end

local kModStateNames = { }
kModStateNames[Client.ModVersionState_Unknown] = "Unknown"
kModStateNames[Client.ModVersionState_UnknownInstalled] = "Unknown Installed"
kModStateNames[Client.ModVersionState_NotInstalled] = "Not Installed"
kModStateNames[Client.ModVersionState_UpToDate] = "Up To Date"
kModStateNames[Client.ModVersionState_OutOfDate] = "Out Of Date"
kModStateNames[Client.ModVersionState_QueuedForUpdate] = "Queued For Update"
kModStateNames[Client.ModVersionState_Updating] = "Updating"
kModStateNames[Client.ModVersionState_ErroneousInstall] = "Erroneous Install"

local kModKindNames = { }
-- Work around because Client.ModKind_Unknown is unsigned but should be -1.
--kModKindNames[Client.ModKind_Unknown] = "Unknown"
kModKindNames[-1] = "Unknown"
kModKindNames[Client.ModKind_Level] = "Level"
kModKindNames[Client.ModKind_Gameplay] = "Gameplay"
kModKindNames[Client.ModKind_Game] = "Game"
kModKindNames[Client.ModKind_Server] = "Server"
kModKindNames[Client.ModKind_Cosmetic] = "Cosmetic"
kModKindNames[Client.ModKind_ResourcePack] = "Resource Pack"

function GUIMainMenu:UpdateModsWindow(self)
    
    local reload = false

    for s = 1, Client.GetNumMods() do

        local state = kModStateNames[Client.GetModState(s)]
        local name = Client.GetModTitle(s)
        local active = Client.ModIsActive(s) and "YES" or "NO"
        local subscribed = Client.IsSubscribedToMod(s) and "YES" or "NO"
        local kind = kModKindNames[Client.GetModKind(s)]
        local percent = "100%"
        local stateString = state
        
        local downloading, bytesDownloaded, totalBytes = Client.GetModDownloadProgress(s)
        if downloading then
        
            percent = "0%"
            if totalBytes > 0 then
                percent = string.format("%d%%", math.floor((bytesDownloaded / totalBytes) * 100))
            end
            
            stateString = stateString .. " (" .. percent .. ")"
            
        end
        
        local currentStatus = state .. name .. active .. subscribed .. kind .. percent
        
        if s > #self.displayedMods or self.displayedMods[s].currentStatus ~= currentStatus then
        
            reload = true
            
            if s > #self.displayedMods then
            
                table.insert(self.displayedMods, { index = s, currentStatus = currentStatus })
                self.modsTable:AddRow({ name, kind, stateString, active, subscribed }, s)
                
            else
                
                self.modsTable:UpdateRowData(s, { name, kind, stateString, active, subscribed })
                self.displayedMods[s].currentStatus = currentStatus
                
            end
            
        end
        
    end

    if reload then
        self.modsTable:Sort()
    end
    
end