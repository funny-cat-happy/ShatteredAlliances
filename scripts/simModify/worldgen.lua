local serverdefs = include("modules/serverdefs")
local util = include("modules/util")
local weighted_list = include("modules/weighted_list")
local mathutil = include("modules/mathutil")
local array = include("modules/array")
local rand = include("modules/rand")
local cdefs = include("client_defs")
local simdefs = include("sim/simdefs")
local simquery = include("sim/simquery")
local mazegen = include("sim/mazegen")
local roomgen = include("sim/roomgen")
local prefabs = include("sim/prefabs")
local unitdefs = include("sim/unitdefs")
local procgen_context = include("sim/procgen_context")
local npc_abilities = include("sim/abilities/npc_abilities")
local version = include("modules/version")
local worldgen = include("sim/worldgen")

worldgen.findThreatRoom = function(cxt, zoneThreats, fitness)
    local beginnerPatrols = cxt.params.difficultyOptions.beginnerPatrols
    local rooms = util.weighted_list()
    for i, room in ipairs(cxt.rooms) do
        if worldgen.canSpawnThreat(cxt, zoneThreats[room.zoneID], room) then
            if beginnerPatrols then
                local totalDist = 1
                local cx, cy = (room.xmin + room.xmax) / 2, (room.ymin + room.ymax) / 2
                for zoneID, units in pairs(zoneThreats) do
                    for j, threatUnit in ipairs(units) do
                        totalDist = totalDist + mathutil.dist2d(threatUnit.x, threatUnit.y, cx, cy)
                    end
                end
                rooms:addChoice(room, totalDist)
            elseif fitness then
                rooms:addChoice(room, fitness(cxt, room))
            else
                rooms:addChoice(room, 1)
            end
        end
    end

    if not isVersion(cxt.params, "0.17.18") and beginnerPatrols then
        return rooms:removeHighest()
    else
        return rooms:getChoice(cxt.rnd:nextInt(1, rooms:getTotalWeight()))
    end
end


local function spawnUnit(cxt, template, fitness)
    local room, attempts = nil, 0
    local x, y = nil, nil
    while (x == nil or y == nil) and attempts < 20 do
        room = worldgen.findThreatRoom(cxt, {}, fitness)
        if room then
            x, y = worldgen.findGuardSpawn(cxt, {}, room)
        end
        attempts = attempts + 1
    end
    if x and y then
        local templateName = template
        local unit =
        {
            x = x,
            y = y,
            template = templateName,
        }
        if worldgen.isGuard(unit) then
            unit = worldgen.finalizeGuard(cxt, unit)
        end
        if unit then
            table.insert(cxt.units, unit)
        end
    else
        log:write("ERR: couldn't place unit anywhere in room %s", tostring(room and room.roomIndex))
    end
end

local NEXUS = class(procgen_context)

function NEXUS:init(...)
    procgen_context.init(self, ...)

    self.ZONES = { cdefs.ZONE_OM_ENGINE, cdefs.ZONE_OM_MISSION2, cdefs.ZONE_OM_HALL }
    self.HALL_ZONE = cdefs.ZONE_OM_HALL
end

function NEXUS:generatePrefabs()
    local candidates = {}

    self.NUM_CAMERAS = 8

    prefabs.generatePrefabs(self, candidates, "entry_guard", 3)

    prefabs.generatePrefabs(self, candidates, "barrier", math.floor(self.NUM_BARRIERS / 2))
    prefabs.generatePrefabs(self, candidates, "console", 6)

    prefabs.generatePrefabs(self, candidates, "store", 1)

    worldgen.generateMainframes(self, candidates)

    prefabs.generatePrefabs(self, candidates, "camera", self.NUM_CAMERAS, worldgen.cameraFitness(candidates))
    prefabs.generatePrefabs(self, candidates, "decor")

    worldgen.generateLaserGenerators(self, candidates)

    return candidates
end

function NEXUS:generateUnit(unit)
    unit.template = unit.template:gsub("security_laser_emitter_1x1", "security_infrared_wall_emitter_1x1")
    return unit
end

function NEXUS:generateUnits()
    local tagSet = {}
    self:invokeScriptGen("pregenerateUnits", tagSet)
    for _, tag in pairs(tagSet) do
        spawnUnit(self, tag[1], tag[2])
    end
    local OMNI_SPAWN_TABLE =
    {
        PROTECTOR = { omni_protector = 100 },
        SOLDIER = { omni_soldier = 100 },
        CRIER = { omni_crier = 100 },
        OMNI = worldgen.OMNI_GUARD,
        OMNI_NON_SOLDIER = { omni_crier = 50, omni_protector = 50 },
        CAMERA_DRONE = worldgen.CAMERA_DRONE,
    }

    self._patrolGuard = worldgen.OMNI_GUARD

    local spawnList = simdefs.OMNI_SPAWN_TABLE[self.params.difficultyOptions.spawnTable]
    worldgen.generateThreats(self, OMNI_SPAWN_TABLE, spawnList)
    worldgen.generateGuardLoot(self, unitdefs.prop_templates.passcard)
    worldgen.generateGuardLoot(self, unitdefs.prop_templates.passcard)

    self.ice_programs = util.weighted_list(worldgen.OMNI_DAEMONS)
end

return
{
    NEXUS = NEXUS,
}
