---@type simdefs
local simdefs = include("sim/simdefs")
local weightedList = include("modules/weighted_list")
local npcAbilities = include("sim/abilities/npc_abilities")

local function generateVirus(sim, stage)
    local virusList = weightedList()
    for name, daemon in pairs(npcAbilities) do
        if daemon.virus and daemon.stage == stage then
            virusList:addChoice(name, daemon.weight or 1)
        end
    end
    local index = sim:nextRand(virusList:getTotalWeight())
    return virusList:getChoice(index)
end

---@class INCFirewall
local INCFirewall = class()
function INCFirewall:init(sim)
    self.firewallLimit = simdefs.SA.FIREWALL_UPPER_LIMIT
    self.currentFirewall = 6
    self.firewallStage = 1
    self.firewallStatus = simdefs.SA.FIREWALL_STATUS.ACTIVATE
    self._sim = sim
    self._sim:addTrigger(simdefs.TRG_START_TURN, self)
    self._sim:addTrigger(simdefs.SA.TRG_VIRUS_OUTBREAK, self)
end

function INCFirewall:updateINCFirewallStatus(firewall, limit)
    self.currentFirewall = self.currentFirewall + firewall
    if limit then
        self.firewallLimit = self.firewallLimit + limit
    end
    if self.currentFirewall <= 0 then
        self.firewallStatus = simdefs.SA.FIREWALL_STATUS.HACKING
        self.virus = generateVirus(self._sim, self.firewallStage)
        self._sim:getNPC():addMainframeAbility(self._sim, self.virus)
    end
    if firewall ~= 0 or limit ~= 0 then
        self._sim:dispatchEvent(simdefs.SA.EV_INCFIREWALL_CHANGE)
    end
end

function INCFirewall:onTrigger(sim, evType, evData)
    if evType == simdefs.TRG_START_TURN then
        if evData:isPC() then
            if self.firewallStatus == simdefs.SA.FIREWALL_STATUS.ACTIVATE then
                return
            elseif self.firewallStatus == simdefs.SA.FIREWALL_STATUS.HACKING then
                return
            elseif self.firewallStatus == simdefs.SA.FIREWALL_STATUS.REBOOTING then
                return
            end
        end
    elseif evType == simdefs.SA.TRG_VIRUS_OUTBREAK then
        self:resetFirewall()
        self._sim:dispatchEvent(simdefs.SA.EV_INCFIREWALL_CHANGE)
    end
end

function INCFirewall:resetFirewall()
    self.firewallStatus = simdefs.SA.FIREWALL_STATUS.ACTIVATE
    self.currentFirewall = self.firewallLimit
end

return INCFirewall
