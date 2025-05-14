local SCRIPTS = include('client/story_scripts')
local util = include("modules/util")

local Central = SCRIPTS.Central
local Monster = SCRIPTS.Monster
local Incognita = SCRIPTS.Incognita
local function Ralf(text, voice)
    return {
        text = text,
        anim = "portraits/portrait_animation_template",
        build = "portraits/executive_build",
        name = STRINGS.SA.UI.RALF_TITLE,
        voice = voice,
    }
end

local story_scripts =
{
    CAMPAIGN_MAP =
    {
        MISSIONS = {
            factory = {
                Central(STRINGS.SA.MISSIONS.FACTORY[1]),
                Ralf(STRINGS.SA.MISSIONS.FACTORY[2]),
                Monster(STRINGS.SA.MISSIONS.FACTORY[3]),
                Central(STRINGS.SA.MISSIONS.FACTORY[4]),
                Ralf(STRINGS.SA.MISSIONS.FACTORY[5]),
                Central(STRINGS.SA.MISSIONS.FACTORY[6]),
            }
        }
    }
}
return story_scripts
