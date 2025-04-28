local mainframe_common = include("sim/abilities/mainframe_common")
local util = include("client_util")

local DEFAULT_ABILITY = mainframe_common.DEFAULT_ABILITY
local abilities = {
    lock = util.extend(DEFAULT_ABILITY)
        {

            name = STRINGS.SA.PROGRAMS.LOCK.NAME,
            desc = STRINGS.SA.PROGRAMS.LOCK.DESC,
            huddesc = STRINGS.SA.PROGRAMS.LOCK.HUD_DESC,
            shortdesc = STRINGS.SA.PROGRAMS.LOCK.SHORT_DESC,
            tipdesc = STRINGS.SA.PROGRAMS.LOCK.TIP_DESC,

            icon = "gui/icons/programs_icons/icon-program-lock.png",
            icon_100 = "gui/icons/programs_icons/icon-program-lock.png",
            cpu_cost = 2,
            break_firewalls = 1,
            equip_program = true,
            equipped = false,
            value = 300,
        },
}
return abilities
