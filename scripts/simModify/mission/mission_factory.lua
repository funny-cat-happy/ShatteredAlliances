local array = include("modules/array")
local util = include("modules/util")
local cdefs = include("client_defs")
---@type simdefs
local simdefs = include("sim/simdefs")
local simquery = include("sim/simquery")
local mission_util = include("sim/missions/mission_util")
local escape_mission = include("sim/missions/escape_mission")
local unitdefs = include("sim/unitdefs")
local simfactory = include("sim/simfactory")
local itemdefs = include("sim/unitdefs/itemdefs")
local serverdefs = include("modules/serverdefs")
local cdefs = include("client_defs")

local SCRIPTS = include('client/story_scripts')
local mission = class(escape_mission)


local ALLY_SUPPORT =
{
    trigger = simdefs.TRG_START_TURN,
    ---comment
    ---@param sim engine
    ---@param triggerData any
    fn = function(sim, triggerData)
        if triggerData:getTraits().playerType and triggerData:getTraits().playerType == simdefs.SA.PLAYER_TYPE.ALLY and #(triggerData:getUnits()) <= 0 then
            return true
        end
    end
}

local function allySupport(script, sim, mission)
    script:waitFor(ALLY_SUPPORT)
    sim:getAlly():doTrackerSpawn(sim, 1, simdefs.SA.ALLY_UNIT.ALLY_INVISIBLE_KILLER)
    -- ally_player:doTrackerSpawn(sim, 1, simdefs.TRACKER_SPAWN_UNIT_ENFORCER)
end

---comment
---@param scriptMgr scriptHook
---@param sim engine
function mission:init(scriptMgr, sim)
    escape_mission.init(self, scriptMgr, sim)
    sim.exit_warning = function()
        if not self.loot_outer and not self.loot_inner then
            return STRINGS.LEVEL.HUD_WARN_EXIT_MISSION_FACTORY
        end
    end
    scriptMgr:addHook("ALLY-ENTER", allySupport, nil, self)
end

function mission.pregeneratePrefabs(cxt, tagSet)
    escape_mission.pregeneratePrefabs(cxt, tagSet)
    table.insert(tagSet[1], "vault")
end

return mission
