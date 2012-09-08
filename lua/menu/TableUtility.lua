// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\menu\TableUtility.lua
//
//    Created by:   Andreas Urwalek (a_urwa@sbox.tugraz.at)
//
//    Collection of render functions for tables.
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

function RenderTextEntry(tableEntry, entryData)

    local font = CreateMenuElement(tableEntry, 'Font', false)
    font:SetText(ToString(entryData))
    font:SetCSSClass("text_entry")
    
    return font

end

function RenderServerNameEntry(tableEntry, entryData)

    local font = CreateMenuElement(tableEntry, 'Font', false)
    font:SetText(entryData)
    font:SetCSSClass("servername")
    
    return font
    
end

function RenderPrivateEntry(tableEntry, entryData)
    local image = CreateMenuElement(tableEntry, 'Image', false)
    image:SetCSSClass("private")
    image.background:SetIsVisible(entryData)

    return image
end

function RenderStatusIconsEntry(tableEntry, entryData)

    local friendsIcon = nil 
    if entryData[1] then    
        friendsIcon = CreateMenuElement(tableEntry, 'Image', false)
        friendsIcon:SetCSSClass("friends_icon")
    end

    local lanIcon = nil
    if entryData[2] then 
        lanIcon = CreateMenuElement(tableEntry, 'Image', false)
        lanIcon:SetCSSClass("lan_icon")
    end    
    
    local customGameIcon = nil
    if entryData[3] then
        customGameIcon = CreateMenuElement(tableEntry, 'Image', false)
        customGameIcon:SetCSSClass("custom_game_icon")
    end
    
    return friendsIcon, lanIcon, customGameIcon

end

function RenderMapNameEntry(tableEntry, entryData)

    local font = CreateMenuElement(tableEntry, 'Font', false)
    font:SetText(entryData)
    font:SetCSSClass("map_name")
    
    return font
    
end

function RenderPlayerCountEntry(tableEntry, entryData)

    local playerCount = entryData[1]
    local maxPlayers = entryData[2]
    
    local font = CreateMenuElement(tableEntry, 'Font', false)    
    font:SetText(string.format("%d/%d", playerCount, maxPlayers))
    
    if playerCount >= maxPlayers then
        font:SetCSSClass("player_count_full")
    else
        font:SetCSSClass("player_count_free")
    end    
    
    return font

end

local kModeratePing = 90
local kBadPing = 180

function RenderPingEntry(tableEntry, entryData)

    local font = CreateMenuElement(tableEntry, 'Font', false)
    font:SetText(ToString(entryData))
    
    if entryData >= kBadPing then
        font:SetCSSClass("ping_bad")
    elseif entryData >= kModeratePing then
        font:SetCSSClass("ping_moderate")
    else    
        font:SetCSSClass("ping_good")
    end
    
    return font

end
