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
            expose = false,
            exploreCost = 2,
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

local function createVirus(stringTbl)
    return util.extend(createDaemon(stringTbl))
        {
            virus = true,
            expose = true,
            exploreCost = 2,
            turns = 1,
            stage = 1,
            weight = 1,
            onTrigger = function(self, sim, evType, evData, userUnit)
                if evType == simdefs.TRG_START_TURN then
                    local player = evData
                    if player:isPC() then
                        if self.turns then
                            self.turns = self.turns - 1
                            if (self.turns or 0) == 0 then
                                sim:triggerEvent(simdefs.SA.TRG_VIRUS_OUTBREAK)
                                self:executeTimedAbility(sim, player)
                            end
                        end
                    end
                end
            end,
            executeTimedAbility = function(self, sim)
                sim:getNPC():removeAbility(sim, self)
            end,
            onSpawnAbility = function(self, sim, player)
                sim:addTrigger(simdefs.TRG_START_TURN, self)
            end,
        }
end

local incognita_daemon = {
    daemonLockPick = util.extend(createIncognitaDaemon(STRINGS.SA.DAEMON.LOCKPICK))
        {
            id = "LockPick",
            icon = "gui/icons/programs_icons/icon-incognita-lockpick.png",
            decrease_firewalls = 1,
            onSpawnAbility = function(self, sim, player)
                sim:addTrigger(simdefs.SA.TRG_INCOGNITA_ACTION, self)
            end,

            onDespawnAbility = function(self, sim)
                local firewallsToBreak = self.decrease_firewalls
                if firewallsToBreak and firewallsToBreak > 0 then
                    sim:getFirewall():updateINCFirewallStatus(-firewallsToBreak)
                end
                sim:removeTrigger(simdefs.SA.TRG_INCOGNITA_ACTION, self)
            end,

            executeTimedAbility = function(self, sim)
                sim:getNPC():removeAbility(sim, self)
            end,
        },
    daemonMarch = util.extend(createIncognitaDaemon(STRINGS.SA.DAEMON.MARCH))
        {
            id = "March",
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
    virusExtract = util.extend(createVirus(STRINGS.SA.DAEMON.EXTRACT))
        {
            stage = 1,
            extractPWR = 3,
            icon = "gui/icons/daemon_icons/Daemons0005.png",
            onDespawnAbility = function(self, sim)
                sim:getNPC():addCPUs(self.extractPWR)
                sim:getPC():addCPUs(-self.extractPWR)
                sim:removeTrigger(simdefs.TRG_START_TURN, self)
                sim:dispatchEvent(simdefs.EV_SHOW_DAEMON,
                    {
                        name = self.name,
                        icon = self.icon,
                        txt = util.sformat(self.activedesc,
                            self.extractPWR),
                    })
            end,
        },
    virusWorm = util.extend(createVirus(STRINGS.SA.DAEMON.WORM))
        {
            stage = 1,
            decreaseMP = 2,
            icon = "gui/icons/daemon_icons/Daemons0005.png",
            onDespawnAbility = function(self, sim)
                for i, unit in pairs(sim:getPC():getUnits()) do
                    if unit:getMP() then
                        unit:addMP(self.decreaseMP)
                    end
                end
                sim:removeTrigger(simdefs.TRG_START_TURN, self)
                sim:dispatchEvent(simdefs.EV_SHOW_DAEMON,
                    {
                        name = self.name,
                        icon = self.icon,
                        txt = util.sformat(self.activedesc,
                            self.decreaseMP),
                    })
            end,
        },
    virusOverdrive = util.extend(createVirus(STRINGS.SA.DAEMON.OVERDRIVE))
        {
            stage = 3,
            addPoint = 1,
            icon = "gui/icons/daemon_icons/Daemons0005.png",
            onDespawnAbility = function(self, sim)
                sim:getNPC():updateIntentionPoints(self.addPoint)
                sim:removeTrigger(simdefs.TRG_START_TURN, self)
                sim:dispatchEvent(simdefs.EV_SHOW_DAEMON,
                    {
                        name = self.name,
                        icon = self.icon,
                        txt = util.sformat(self.activedesc,
                            self.addPoint),
                    })
            end,
        },
}
return incognita_daemon
