local mainframe_common = include("sim/abilities/mainframe_common")
local util = include("client_util")
local simdefs = include("sim/simdefs")

local function createIncognitaProgram(stringTbl)
    return util.extend(mainframe_common.DEFAULT_ABILITY)
        {
            name = stringTbl.NAME,
            desc = stringTbl.DESC,
            huddesc = stringTbl.HUD_DESC,
            shortdesc = stringTbl.SHORT_DESC,
            tipdesc = stringTbl.TIP_DESC,
            evaluate = function()
                return 50
            end
        }
end
local abilities = {
    programLockPick = util.extend(createIncognitaProgram(STRINGS.SA.DAEMON.LOCKPICK))
        {
            icon = "gui/icons/programs_icons/icon-incognita-lockpick.png",
            icon_100 = "gui/icons/programs_icons/icon-incognita-lockpick.png",
            cpu_cost = 2,
            equipped = false,
            executeAbility = function(self, sim, unit, userUnit, targetCell)
                sim:getNPC():addIncognitaIntention("daemonLockPick")
                self:setCooldown(sim)
            end,
            evaluate = function()
                return 40
            end
        },
    programMarch = util.extend(createIncognitaProgram(STRINGS.SA.DAEMON.MARCH))
        {
            icon = "gui/icons/programs_icons/icon-incognita-march.png",
            icon_100 = "gui/icons/programs_icons/icon-incognita-march.png",
            cpu_cost = 2,
            equipped = false,
            executeAbility = function(self, sim, unit, userUnit, targetCell)
                sim:getNPC():addIncognitaIntention("daemonMarch")
                self:setCooldown(sim)
            end,
        },
}
return abilities
