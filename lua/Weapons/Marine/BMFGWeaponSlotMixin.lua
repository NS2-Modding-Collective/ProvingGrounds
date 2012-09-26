// ======= Copyright (c) 2003-2012, Unknown Worlds Entertainment, Inc. All rights reserved. =====
//
// lua\Weapons\Marine\BMFGWeaponSlotMixin.lua
//
//    Created by:   Andy 'Soul Rider' Wilson for Proving Grounds
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

BMFGWeaponSlotMixin = CreateMixin(BMFGWeaponSlotMixin)
BMFGWeaponSlotMixin.type = "BMFGWeaponSlot"

BMFGWeaponSlotMixin.networkVars =
{
    BMFGWeaponSlot = "enum BMFG.kSlotNames"
}

function BMFGWeaponSlotMixin:__initmixin()
    self.BMFGWeaponSlot = BMFG.kSlotNames.None
end

function BMFGWeaponSlotMixin:SetBMFGWeaponSlot(slot)
    self.BMFGWeaponSlot = slot
end

function BMFGWeaponSlotMixin:GetBMFGWeaponSlotName()
    return string.lower(EnumToString(BMFG.kSlotNames, self.BMFGWeaponSlot))
end

function BMFGWeaponSlotMixin:GetIsLeftSlot()
    return self.BMFGWeaponSlot == BMFG.kSlotNames.Left
end

function BMFGWeaponSlotMixin:GetIsRightSlot()
    return self.BMFGWeaponSlot == BMFG.kSlotNames.Right
end

function BMFGWeaponSlotMixin:GetBMFGWeaponSlot()
    return self.BMFGWeaponSlot
end