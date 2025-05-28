----------------------------------------------------------------
-- Copyright (c) 2012 Klei Entertainment Inc.
-- All Rights Reserved.
-- SPY SOCIETY.
----------------------------------------------------------------

local util = include("modules/util")
local array = include("modules/array")
local simunit = include("sim/simunit")
local simquery = include("sim/simquery")
local simdefs = include("sim/simdefs")
local simfactory = include("sim/simfactory")
local inventory = include("sim/inventory")
local abilitydefs = include("sim/abilitydefs")
local cdefs = include("client_defs")

-----------------------------------------------------
-- Local functions

local factorycore = { ClassType = "factorycore" }

function factorycore:onWarp(sim, oldcell, cell)
    if oldcell then
        self:deactivate(sim)
    end

    if cell then
        self._parent = sim:getNPC()
        self:activate(sim)
    end
end

function factorycore:activate(sim)
    if self:getTraits().mainframe_status == "inactive" then
        self:getTraits().mainframe_status = "active"
        sim:addTrigger(simdefs.TRG_START_TURN, self)
        sim:dispatchEvent(simdefs.EV_PLAY_SOUND, "SpySociety/Actions/mainframe_object_on")
    end
end

function factorycore:deactivate(sim)
    sim:triggerEvent(simdefs.TRG_UNIT_DISABLED, self)
    if self:getTraits().mainframe_status == "active" then
        self:getTraits().mainframe_status = "inactive"
        sim:removeTrigger(simdefs.TRG_START_TURN, self)
        self:destroyTab()
        sim:dispatchEvent(simdefs.EV_PLAY_SOUND, "SpySociety/Actions/mainframe_object_off")
    end
end

function factorycore:onTrigger(sim, evType, evData)
    if evType == simdefs.TRG_START_TURN then
        local pwr_gen = self:getTraits().PWR_gen
        if evData:isNPC() and self:isAI() then
            sim:getCurrentPlayer():addCPUs(pwr_gen, sim)
            sim:dispatchEvent(simdefs.EV_SHOW_WARNING,
                {
                    txt = util.sformat(STRINGS.SA.UI.FACTORY_CORE_ALERT, pwr_gen, evData:getTraits().name),
                    color = cdefs.COLOR_CORP_WARNING,
                    sound = nil,
                })
        elseif evData:isPC() and self:isPC() then
            sim:getCurrentPlayer():addCPUs(pwr_gen, sim)
            sim:dispatchEvent(simdefs.EV_SHOW_WARNING,
                {
                    txt = util.sformat(STRINGS.SA.UI.FACTORY_CORE_ALERT, pwr_gen, evData:getTraits().name),
                    color = cdefs.COLOR_PLAYER_WARNING,
                    sound = nil,
                })
        end
    end
end

function factorycore:removeChild(childUnit)
    simunit.removeChild(self, childUnit)
    if childUnit:getTraits().artifact then
        self:processEMP(2)
        self:getSim():triggerEvent(simdefs.TRG_UNIT_DISABLED, self)
    end
end

-----------------------------------------------------
-- Interface functions

local function createfactorycore(unitData, sim)
    return simunit.createUnit(unitData, sim, factorycore)
end

simfactory.register(createfactorycore)

return
{
    createfactorycore = createfactorycore,
}
