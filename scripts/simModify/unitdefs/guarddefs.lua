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
                enforcer = false,
                dashSoundRange = 8,
                LOSarc = 2 * math.pi,
                sneaking = true,
                hasHearing = false,
                walk = true,
                invisible = false,
                tagged = true,
                ally = true
            },
        speech = speechdefs.NPC,
        voices = { "KO_Heavy" },
        skills = {},
        abilities = util.extend(DEFAULT_ABILITIES) {},
        children = { itemdefs.item_npc_smg, itemdefs.item_npc_scangrenade },
        sounds = SOUNDS.GUARD,
        brain = "AllyBrain",
    },
    thanatos_robot = {
        type = "simunit",
        name = STRINGS.SA.ROBOTS.THANATOS_ROBOT,
        profile_anim = "portraits/portrait_animation_template",
        profile_build = "portraits/ko_heavy_build",
        profile_image = "KO_heavy.png",
        onWorldTooltip = onGuardTooltip,
        kanim = "kanim_guard_male_ko_heavy",
        traits = util.extend(commondefs.basic_robot_traits)
            {
                walk = true,
                enforcer = false,
                dashSoundRange = 8,
                mpMax = 6,
                mp = 6,
                wounds = 0,
                armor = 2,
                LOSarc = math.pi * 2,
                LOSperipheralArc = math.pi * 2,
            },
        dropTable =
        {
            { "item_clip",   8 },
            { "item_stim",   7 },
            { "item_stim_2", 6 },
            { "item_stim_3", 5 },
            { nil,           74 },
        },
        anarchyDropTable =
        {
            { "item_tazer",      5 },
            { "item_stim",       5 },
            { "item_clip",       25 },
            { "item_adrenaline", 15 },
            { nil,               135 }
        },
        speech = speechdefs.NPC,
        voices = { "KO_Heavy", },
        skills = {},
        abilities = util.extend(DEFAULT_ABILITIES) {},
        children = { itemdefs.item_npc_smg },
        idles = DEFAULT_IDLES,
        sounds = SOUNDS.HEAVY,
        brain = "GuardBrain",
    },
}
return npc_templates
