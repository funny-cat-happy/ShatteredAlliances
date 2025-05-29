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
            expose = false,
            evaluate = function()
                return 50
            end,
            canUseAbility = function(self, sim)
                local player = sim:getNPC()
                if player == nil then
                    return false
                end
                if (self.cooldown or 0) > 0 then
                    return false
                end
                if player:getCpus() < self:getCpuCost() then
                    return false
                end
                if player:getIncognitaLockOut() then
                    return false
                end
                return true
            end,
            executeAbility = function(self, sim, unit, userUnit, targetCell)
                if self.id == nil then
                    return false
                end
                self:useCPUs(sim)
                sim:getNPC():addIncognitaIntention("daemon" .. self.id)
                self:setCooldown(sim)
                return true
            end,
        }
end
local abilities = {
    programLockPick = util.extend(createIncognitaProgram(STRINGS.SA.DAEMON.LOCKPICK))
        {
            id = "LockPick",
            icon = "gui/icons/programs_icons/icon-incognita-lockpick.png",
            icon_100 = "gui/icons/programs_icons/icon-incognita-lockpick.png",
            cpu_cost = 2,
            equipped = false,
            evaluate = function()
                return 40
            end
        },
    programMarch = util.extend(createIncognitaProgram(STRINGS.SA.DAEMON.MARCH))
        {
            id = "March",
            icon = "gui/icons/programs_icons/icon-incognita-march.png",
            icon_100 = "gui/icons/programs_icons/icon-incognita-march.png",
            cpu_cost = 2,
            equipped = false,
        },
}
return abilities
