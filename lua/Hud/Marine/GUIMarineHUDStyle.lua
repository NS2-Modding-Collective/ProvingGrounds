// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\GUIMarineHUDStyle.lua
//
// Created by: Andreas Urwalek (a_urwa@sbox.tugraz.at)
//
// texture names, coordinates and colors used in the marine hud
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

kScanLinesBigTexture = "ui/marine_HUD_scanLinesBig.dds"
kScanLinesBigCoords = { 0, 0, 316, 192 }
kScanLinesBigWidth = kScanLinesBigCoords[3] - kScanLinesBigCoords[1]
kScanLinesBigHeight = kScanLinesBigCoords[4] - kScanLinesBigCoords[2]

kScanLinesSmallTexture = "ui/marine_HUD_scanLinesSmall.dds"
kScanLinesSmallCoords = { 0, 0, 314, 96 }
kScanLinesSmallWidth = kScanLinesSmallCoords[3] - kScanLinesSmallCoords[1]
kScanLinesSmallHeight = kScanLinesSmallCoords[4] - kScanLinesSmallCoords[2]

kBrightColor = Color(147/255, 206/255, 1, 1)
kBrightColorTransparent = Color(kBrightColor.r, kBrightColor.g, kBrightColor.b, 0.3)

kDarkColor = Color(0.55, 0.55, 0.65, 1)
kDarkColorTransparent = Color(kDarkColor.r, kDarkColor.g, kDarkColor.b, 0.3)

kGreyColor = Color(0.5, 0.5, 0.5, 1)
kGreyColorTransparent = Color(kGreyColor.r, kGreyColor.g, kGreyColor.b, 0.3)
