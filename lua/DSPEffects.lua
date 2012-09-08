// ======= Copyright (c) 2003-2012, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\DSPEffects.lua
//
//    Created by:   Charlie Cleveland (charlie@unknownworlds.com) and
//                  Max McGuire (max@unknownworlds.com)
//
// From FMOD documentation:
//
// DSP_Mixer        This unit does nothing but take inputs and mix them together then feed the result to the soundcard unit.
// DSP_Oscillator   This unit generates sine/square/saw/triangle or noise tones.
// DSP_LowPass      This unit filters sound using a high quality, resonant lowpass filter algorithm but consumes more CPU time.
// DSP_ITLowPass    This unit filters sound using a resonant lowpass filter algorithm that is used in Impulse Tracker, but with limited cutoff range (0 to 8060hz).
// DSP_HighPass     This unit filters sound using a resonant highpass filter algorithm.
// DSP_Echo         This unit produces an echo on the sound and fades out at the desired rate.
// DSP_Flange       This unit produces a flange effect on the sound.
// DSP_Distortion   This unit distorts the sound.
// DSP_Normalize    This unit normalizes or amplifies the sound to a certain level.
// DSP_ParamEQ      This unit attenuates or amplifies a selected frequency range.
// DSP_PitchShift   This unit bends the pitch of a sound without changing the speed of playback.
// DSP_Chorus       This unit produces a chorus effect on the sound.
// DSP_Reverb       This unit produces a reverb effect on the sound.
// DSP_VSTPlugin    This unit allows the use of Steinberg VST plugins.
// DSP_WinampPlugin This unit allows the use of Nullsoft Winamp plugins.
// DSP_ITEcho       This unit produces an echo on the sound and fades out at the desired rate as is used in Impulse Tracker.
// DSP_Compressor   This unit implements dynamic compression (linked multichannel, wideband).
// DSP_LowPassSimple This unit filters sound using a simple lowpass with no resonance, but has flexible cutoff and is fast.
// DSP_Delay            This unit produces different delays on individual channels of the sound.
// DSP_Tremolo      This unit produces a tremolo/chopper effect on the sound.
//            
// ========= For more information, visit us at http://www.unknownworlds.com =======================

local masterCompressorId = -1
local nearDeathId = -1
local shadeDisorientFlangeId = -1
local shadeDisorientLoPassId = -1

function CreateDSPs()

    // Used to adjust the master volume.
    masterCompressorId = Client.CreateDSP(SoundSystem.DSP_Compressor)
    
    // Near-death effect low-pass filter.
    nearDeathId = Client.CreateDSP(SoundSystem.DSP_LowPassSimple)    
    Client.SetDSPFloatParameter(nearDeathId, 0, 2738)   
    
    /*
    shadeDisorientFlangeId = Client.CreateDSP(SoundSystem.DSP_Flange)    
    
    shadeDisorientLoPassId = Client.CreateDSP(SoundSystem.DSP_LowPassSimple)
    */
    
    // Note: These are causing an out of range error and don't doing anything currently.
    //             threshold
    //Client.SetDSPFloatParameter(dspId, 0, .320)
    //               attack
    //Client.SetDSPFloatParameter(dspId, 1, .320)
    //               release
    //Client.SetDSPFloatParameter(dspId, 2, .320)
    //            make up gain
    //Client.SetDSPFloatParameter(dspId, 4, .320)
    
end

// Set to 0 to disable
function UpdateShadeDSPs()

    local scalar = 0    
    
    local player = Client.GetLocalPlayer()
    if player and HasMixin(player, "Disorientable") then
        scalar = player:GetDisorientedAmount()
    end

    // Simon - Shade disorient drymix
    Client.SetDSPFloatParameter(shadeDisorientFlangeId, 0, .922)
    // Simon - Shade disorient wetmix
    Client.SetDSPFloatParameter(shadeDisorientFlangeId, 1, .766)
    // Simon - Shade disorient depth
    Client.SetDSPFloatParameter(shadeDisorientFlangeId, 2, .550)
    // Simon - Shade disorient rate
    Client.SetDSPFloatParameter(shadeDisorientFlangeId, 3,  0.6)
    
    // Simon - Shade disorient low-pass filter
    local kMinFrequencyValue = 10
    Client.SetDSPFloatParameter(shadeDisorientLoPassId, 0, kMinFrequencyValue + 523)
    
    local active = scalar > 0
    Client.SetDSPActive(shadeDisorientFlangeId, active)
    Client.SetDSPActive(shadeDisorientLoPassId, active)
    
end
local kThresholdDefault = 0
local masterCompressorThreshold = kThresholdDefault
local kAttackDefault = 50
local masterCompressorAttack = kAttackDefault
local kReleaseDefault = 50
local masterCompressorRelease = kReleaseDefault
local kMakeUpGainDefault = 0
local masterCompressorMakeUpGain = kMakeUpGainDefault

function OnAdjustMasterCompressorThreshold(threshold)

    threshold = tonumber(threshold) or kThresholdDefault
    if threshold < -60 or threshold > 0 then
    
        Print("Warning: Threshold must be between -60 and 0. Defaulting to " .. kThresholdDefault)
        threshold = kThresholdDefault
        
    end
    masterCompressorThreshold = threshold
    Print("New Threshold: " .. masterCompressorThreshold)
    
end
Event.Hook("Console_mct", OnAdjustMasterCompressorThreshold)

function OnAdjustMasterCompressorAttack(attack)

    attack = tonumber(attack) or kAttackDefault
    if attack < 10 or attack > 200 then
    
        Print("Warning: Second parameter attack must be between 10 and 200. Defaulting to " .. kAttackDefault)
        attack = kAttackDefault
        
    end
    masterCompressorAttack = attack
    Print("New Attack: " .. masterCompressorAttack)
    
end
Event.Hook("Console_mca", OnAdjustMasterCompressorAttack)

function OnAdjustMasterCompressorRelease(release)

    release = tonumber(release) or kReleaseDefault
    if release < 20 or release > 1000 then
    
        Print("Warning: Third parameter release must be between 20 and 1000. Defaulting to " .. kReleaseDefault)
        release = kReleaseDefault
        
    end
    masterCompressorRelease = release
    Print("New Release: " .. masterCompressorRelease)
    
end
Event.Hook("Console_mcr", OnAdjustMasterCompressorRelease)

function OnAdjustMasterCompressorMakeUpGain(makeUpGain)

    makeUpGain = tonumber(makeUpGain) or kMakeUpGainDefault
    if makeUpGain < 0 or makeUpGain > 30 then
    
        Print("Warning: Fourth parameter make up gain must be between 0 and 30. Defaulting to " .. kMakeUpGainDefault)
        makeUpGain = kMakeUpGainDefault
        
    end
    masterCompressorMakeUpGain = makeUpGain
    Print("New Make Up Gain: " .. masterCompressorMakeUpGain)
    
end
Event.Hook("Console_mcg", OnAdjustMasterCompressorMakeUpGain)

local kThresholdId = 0
local kAttackId = 1
local kReleaseId = 2
local kMakeUpGainId = 3

function UpdateDSPEffects()

    PROFILE("DSPEffects:UpdateDSPEffects")
    
    Client.SetDSPActive(masterCompressorId, true)
    // Threshold.
    Client.SetDSPFloatParameter(masterCompressorId, kThresholdId, masterCompressorThreshold)
    // Attack.
    Client.SetDSPFloatParameter(masterCompressorId, kAttackId, masterCompressorAttack)
    // Release.
    Client.SetDSPFloatParameter(masterCompressorId, kReleaseId, masterCompressorRelease)
    // Make up gain.
    Client.SetDSPFloatParameter(masterCompressorId, kMakeUpGainId, masterCompressorMakeUpGain)
    
    local player = Client.GetLocalPlayer()
    
    Client.SetDSPActive(nearDeathId, player:GetGameEffectMask(kGameEffect.NearDeath))
    
    // Removed because it is over the top right now.
    //UpdateShadeDSPs()
    
end