local util = include("modules/util")
local simdefs = include("sim/simdefs")
local commondefs = include("sim/unitdefs/commondefs")
local tool_templates = include("sim/unitdefs/itemdefs")

-------------------------------------------------------------
--

local MAINFRAME_TRAITS = commondefs.MAINFRAME_TRAITS
local SAFE_TRAITS = commondefs.SAFE_TRAITS

local onMainframeTooltip = commondefs.onMainframeTooltip
local onSoundBugTooltip = commondefs.onSoundBugTooltip
local onBeamTooltip = commondefs.onBeamTooltip
local onConsoleTooltip = commondefs.onConsoleTooltip
local onStoreTooltip = commondefs.onStoreTooltip
local onDeviceTooltip = commondefs.onDeviceTooltip
local onSafeTooltip = commondefs.onSafeTooltip


local prop_templates =
{
    factory_core =
    {
        type = "factorycore",
        name = STRINGS.SA.PROPS.FACTORY_POWER_CORE,
        rig = "corerig",
        onWorldTooltip = onDeviceTooltip,
        kanim = "kanim_powersource",
        abilities = {},
        traits = util.extend(MAINFRAME_TRAITS)
            {
                moveToDevice = true,
                cover = true,
                impass = { 0, 0 },
                sightable = true,
                recap_icon = nil,
                PWR_gen = 5,
                mainframe_status = "inactive",
            },
        sounds = { appeared = "SpySociety/HUD/gameplay/peek_positive", reboot_start = "SpySociety/Actions/reboot_initiated_generator", reboot_end = "SpySociety/Actions/reboot_complete_generator" }
    },
}
return prop_templates
