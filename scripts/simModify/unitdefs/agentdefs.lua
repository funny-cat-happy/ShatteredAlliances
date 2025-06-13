local util = include("modules/util")
local commondefs = include("sim/unitdefs/commondefs")
local speechdefs = include("sim/speechdefs")
local simdefs = include("sim/simdefs")
local SCRIPTS = include('client/story_scripts')


local DECKARD_SOUNDS =
{
    bio = "SpySociety/VoiceOver/Missions/Bios/Decker",
    escapeVo = "SpySociety/VoiceOver/Missions/Escape/Operator_Escape_Agent_Deckard",
    speech = "SpySociety/Agents/dialogue_player",
    step = simdefs.SOUNDPATH_FOOTSTEP_MALE_HARDWOOD_NORMAL,
    stealthStep = simdefs.SOUNDPATH_FOOTSTEP_MALE_HARDWOOD_SOFT,

    wallcover = "SpySociety/Movement/foley_trench/wallcover",
    crouchcover = "SpySociety/Movement/foley_trench/crouchcover",
    fall = "SpySociety/Movement/foley_trench/fall",
    fall_knee = "SpySociety/Movement/bodyfall_agent_knee_hardwood",
    fall_kneeframe = 9,
    fall_hand = "SpySociety/Movement/bodyfall_agent_hand_hardwood",
    fall_handframe = 20,
    land = "SpySociety/Movement/deathfall_agent_hardwood",
    land_frame = 35,
    getup = "SpySociety/Movement/foley_trench/getup",
    grab = "SpySociety/Movement/foley_trench/grab_guard",
    pin = "SpySociety/Movement/foley_trench/pin_guard",
    pinned = "SpySociety/Movement/foley_trench/pinned",
    peek_fwd = "SpySociety/Movement/foley_trench/peek_forward",
    peek_bwd = "SpySociety/Movement/foley_trench/peek_back",
    move = "SpySociety/Movement/foley_trench/move",
    hit = "SpySociety/HitResponse/hitby_ballistic_flesh",
}

local agent_templates = {
    SA_sentry =
    {
        type = "simunit",
        agentID = "SA_agent",
        name = STRINGS.SA.AGENTS.CORA.NAME,
        fullname = STRINGS.SA.AGENTS.CORA.ALT_1.FULLNAME,
        codename = STRINGS.SA.AGENTS.CORA.ALT_1.CODENAME,
        loadoutName = STRINGS.UI.ON_FILE,
        file = STRINGS.SA.AGENTS.CORA.FILE,
        yearsOfService = STRINGS.SA.AGENTS.CORA.YEARS_OF_SERVICE,
        age = STRINGS.SA.AGENTS.CORA.AGE,
        homeTown = STRINGS.SA.AGENTS.CORA.HOMETOWN,
        gender = "female",
        class = "Sentry",
        toolTip = STRINGS.AGENTS.DECKARD.ALT_1.TOOLTIP,
        onWorldTooltip = commondefs.onAgentTooltip,
        profile_icon_36x36 = "gui/profile_icons/stealth_36.png",
        profile_icon_64x64 = "gui/profile_icons/stealth1_64x64.png",
        splash_image = "gui/agents/deckard_1024.png",

        team_select_img = {
            "gui/agents/team_select_1_deckard.png",
        },

        profile_anim = "portraits/stealth_guy_face",
        kanim = "kanim_stealth_male",
        hireText = STRINGS.AGENTS.DECKARD.RESCUED,
        centralHireSpeech = SCRIPTS.INGAME.CENTRAL_AGENT_ESCAPE_DECKARD,
        traits = util.extend(commondefs.DEFAULT_AGENT_TRAITS) { mp = 8, mpMax = 8, },
        skills = util.extend(commondefs.DEFAULT_AGENT_SKILLS) {},
        startingSkills = { stealth = 2 },
        abilities = util.tconcat({ "sprint", }, commondefs.DEFAULT_AGENT_ABILITIES),
        children = {},
        sounds = DECKARD_SOUNDS,
        speech = speechdefs.stealth_1,
        blurb = STRINGS.SA.AGENTS.CORA.ALT_1.BIO,
        upgrades = { "augment_deckard", "item_tazer", "item_cloakingrig_deckard" },
    },
}
return agent_templates
