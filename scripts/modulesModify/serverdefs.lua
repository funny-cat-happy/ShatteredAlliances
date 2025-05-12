local serverdefs = include("modules/serverdefs")
local array = include("modules/array")
local util = include("client_util")
local mathutil = include("modules/mathutil")
local agentdefs = include("sim/unitdefs/agentdefs")
local skilldefs = include("sim/skilldefs")
local simdefs = include("sim/simdefs")

local INITIAL_MISSION_TAGS = { "destroy_factory", "plastech", "not_close" }

local function lateLoad()
    serverdefs.createNewCampaign = function(agency, campaignDifficulty, difficultyOptions)
        local version = include("modules/version")
        local campaign =
        {
            agency = agency,
            location = agency.startLocation,
            play_t = 0,
            hours = 0,
            previousDay = -1,
            currentDay = 0,
            incognitaLevel = 0,
            version = version.VERSION,
            situations = {},
            missionCount = 0,
            missionTotal = 0,
            miniserversSeen = 0,
            missionsPlayedThisDay = 0,
            recent_build_number = util.formatGameInfo(),
            save_time = os.time(),
            creation_time = os.time(),
            missionEvents = {},
        }

        campaign.seed = config.LOCALSEED()
        campaign.campaignDifficulty = campaignDifficulty
        campaign.difficultyOptions = util.tcopy(difficultyOptions)
        campaign.agency.cash = difficultyOptions.startingCredits
        campaign.agency.cpus = difficultyOptions.startingPower
        serverdefs.createCampaignSituations(campaign, 1, INITIAL_MISSION_TAGS, 1)


        campaign.campaignEvents = mod_manager:getCampaignEvents()

        return campaign
    end
end

local MISSION_FACTORY_SITUATION = {
    levelFile = "lvl_procgen",
    ui = {
        moreInfo = STRINGS.MISSIONS.LOCATIONS.GUARD_OFFICE.MORE_INFO,
        insetTitle = STRINGS.MISSIONS.LOCATIONS.GUARD_OFFICE.INSET_TITLE,
        insetTxt = STRINGS.MISSIONS.LOCATIONS.GUARD_OFFICE.INSET_TXT,
        locationName = STRINGS.MISSIONS.LOCATIONS.GUARD_OFFICE.NAME,
        playerdescription = STRINGS.MISSIONS.LOCATIONS.GUARD_OFFICE.DESCRIPTION,
        reward = STRINGS.MISSIONS.LOCATIONS.GUARD_OFFICE.REWARD,
        insetVoice = {
            "SpySociety/VoiceOver/Missions/MapScreen/Location_RegionalSecurityOffice",
            "SpySociety/VoiceOver/Missions/MapScreen/Location_RegionalSecurityOffice_2",
        },
        insetImg = "gui/menu pages/corp_select/New_mission_icons/terminal thing.png",
        icon = "gui/mission_previews/collaboration.png",
        objectives = serverdefs.createGeneralMissionObj(STRINGS.MISSIONS.ESCAPE.OBJ_GUARD_OFFICE),
        secondary_objectives = serverdefs.createGeneralSecondaryMissionObj(),
    },
    strings = STRINGS.MISSIONS.ESCAPE,
    scripts = { "mission_factory" },
    tags = { "destroy_factory" },
}

return { lateLoad = lateLoad, MISSION_FACTORY_SITUATION = MISSION_FACTORY_SITUATION }
