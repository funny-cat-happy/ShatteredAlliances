local mathutil = include("modules/mathutil")
local array = include("modules/array")
local util = include("modules/util")
---@type simdefs
local simdefs = include("sim/simdefs")
local simquery = include("sim/simquery")
local cdefs = include("client_defs")
local serverdefs = include("modules/serverdefs")
local mainframe_common = include("sim/abilities/mainframe_common")

local createDaemon = mainframe_common.createDaemon

local function createIncognitaDaemon(stringTbl)
    return util.extend(createDaemon(stringTbl))
        {
            incognitaIntention = true,
            turns = 1,
            onTrigger = function(self, sim, evType, evData, userUnit)
                if evType == simdefs.SA.TRG_INCOGNITA_ACTION then
                    local player = evData
                    if player == sim:getCurrentPlayer() and player:isNPC() then
                        if self.turns then
                            self.turns = self.turns - 1
                            if (self.turns or 0) == 0 then
                                self:executeTimedAbility(sim, player)
                            end
                        end
                    end
                end
            end,
        }
end

local incognita_daemon = {
    daemonLockPick = util.extend(createIncognitaDaemon(STRINGS.SA.DAEMON.LOCKPICK))
        {
            icon = "gui/icons/programs_icons/icon-incognita-lockpick.png",
            decrease_firewalls = 1,
            onSpawnAbility = function(self, sim, player)
                sim:addTrigger(simdefs.SA.TRG_INCOGNITA_ACTION, self)
            end,

            onDespawnAbility = function(self, sim)
                local firewallsToBreak = self.decrease_firewalls
                if firewallsToBreak and firewallsToBreak > 0 then
                    sim:updateINCFirewallStatus(-firewallsToBreak)
                end
                sim:removeTrigger(simdefs.SA.TRG_INCOGNITA_ACTION, self)
            end,

            executeTimedAbility = function(self, sim)
                sim:getNPC():removeAbility(sim, self)
            end,
        },
    daemonMarch = util.extend(createIncognitaDaemon(STRINGS.SA.DAEMON.MARCH))
        {
            icon = "gui/icons/programs_icons/icon-incognita-march.png",
            onSpawnAbility = function(self, sim, player)
                sim:addTrigger(simdefs.SA.TRG_INCOGNITA_ACTION, self)
            end,

            onDespawnAbility = function(self, sim)
                sim:getNPC():march(sim)
                sim:removeTrigger(simdefs.SA.TRG_INCOGNITA_ACTION, self)
            end,

            executeTimedAbility = function(self, sim)
                sim:getNPC():removeAbility(sim, self)
            end,
        },
}
return incognita_daemon
