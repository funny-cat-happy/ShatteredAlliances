local mainframe_common = include("sim/abilities/mainframe_common")
local util = include("client_util")
local simdefs = include("sim/simdefs")

local DEFAULT_ABILITY = mainframe_common.DEFAULT_ABILITY
local abilities = {
    lock = util.extend(DEFAULT_ABILITY)
        {

            name = STRINGS.SA.PROGRAMS.LOCK.NAME,
            desc = STRINGS.SA.PROGRAMS.LOCK.DESC,
            huddesc = STRINGS.SA.PROGRAMS.LOCK.HUD_DESC,
            shortdesc = STRINGS.SA.PROGRAMS.LOCK.SHORT_DESC,
            tipdesc = STRINGS.SA.PROGRAMS.LOCK.TIP_DESC,

            icon = "gui/icons/programs_icons/icon-player-lock.png",
            icon_100 = "gui/icons/programs_icons/icon-player-lock.png",
            cpu_cost = 2,
            increase_firewalls = 1,
            equipped = false,
            value = 300,
            executeAbility = function(self, sim, unit, userUnit, targetCell)
                self:useCPUs(sim)

                local firewallsToLock = self.increase_firewalls

                if sim:getPC():getTraits().firewallLockPenalty and firewallsToLock > 0 then
                    firewallsToLock = math.max(firewallsToLock - sim:getPC():getTraits().firewallBreakPenalty, 1)
                end

                if firewallsToLock and firewallsToLock > 0 then
                    sim:updateINCFirewallStatus(firewallsToLock)
                end
                sim:dispatchEvent(simdefs.EV_PLAY_SOUND, "SA/Actions/program_lock")
                self:setCooldown(sim)
            end,
        },
    ratchet = util.extend(DEFAULT_ABILITY)
        {

            name = STRINGS.SA.PROGRAMS.RATCHET.NAME,
            desc = STRINGS.SA.PROGRAMS.RATCHET.DESC,
            huddesc = STRINGS.SA.PROGRAMS.RATCHET.HUD_DESC,
            shortdesc = STRINGS.SA.PROGRAMS.RATCHET.SHORT_DESC,
            tipdesc = STRINGS.SA.PROGRAMS.RATCHET.TIP_DESC,

            icon = "gui/icons/programs_icons/icon-player-ratchet.png",
            icon_100 = "gui/icons/programs_icons/icon-player-ratchet.png",
            cpu_cost = 2,
            increase_firewalls = 1,
            increase_limit = 1,
            equipped = false,
            value = 300,
            executeAbility = function(self, sim, unit, userUnit, targetCell)
                self:useCPUs(sim)

                local firewallsToLock = self.increase_firewalls

                if sim:getPC():getTraits().firewallLockPenalty and firewallsToLock > 0 then
                    firewallsToLock = math.max(firewallsToLock - sim:getPC():getTraits().firewallBreakPenalty, 1)
                end

                if firewallsToLock and firewallsToLock > 0 then
                    sim:updateINCFirewallStatus(firewallsToLock, self.increase_limit)
                end
                sim:dispatchEvent(simdefs.EV_PLAY_SOUND, "SA/Actions/program_ratchet")
                self:setCooldown(sim)
            end,
        },
}
return abilities
