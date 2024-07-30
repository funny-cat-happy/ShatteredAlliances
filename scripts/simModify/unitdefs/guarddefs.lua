local util = include("modules/util")
local simdefs = include("sim/simdefs")
local commondefs = include("sim/unitdefs/commondefs")
local itemdefs = include("sim/unitdefs/itemdefs")
local speechdefs = include("sim/speechdefs")
local SOUNDS = commondefs.SOUNDS

local DEFAULT_IDLES = commondefs.DEFAULT_IDLES
local DEFAULT_ABILITIES = commondefs.DEFAULT_ABILITIES
local onGuardTooltip = commondefs.onGuardTooltip
local DEFAULT_DRONE = commondefs.DEFAULT_DRONE

local npc_templates =
{
    ally_guard_enforcer_reinforcement =
    {
        type = "simunit",
        name = STRINGS.SA.GUARDS.ALLY_ELITE_ENFORCER,
        profile_anim = "portraits/portrait_animation_template",
        profile_build = "portraits/enforcer2_build",
        profile_image = "enforcer_2.png",
        profile_icon_36x36 = "gui/profile_icons/security_36.png",
        onWorldTooltip = onGuardTooltip,
        kanim = "kanim_guard_male_enforcer_2",
        traits = util.extend(commondefs.basic_guard_traits)
            {
                heartMonitor = "enabled",
                enforcer = true,
                dashSoundRange = 8,
            },
        speech = speechdefs.NPC,
        voices = { "KO_Heavy" },
        skills = {},
        abilities = util.extend(DEFAULT_ABILITIES) {},
        children = { itemdefs.item_npc_smg, itemdefs.item_npc_scangrenade },
        sounds = SOUNDS.GUARD,
        brain = "AllyBrain",
    },
}
return npc_templates
