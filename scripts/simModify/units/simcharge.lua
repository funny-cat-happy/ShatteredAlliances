----------------------------------------------------------------
-- Copyright (c) 2012 Klei Entertainment Inc.
-- All Rights Reserved.
-- SPY SOCIETY.
----------------------------------------------------------------

local util = include("modules/util")
local array = include("modules/array")
local unitdefs = include("sim/unitdefs")
local simunit = include("sim/simunit")
local simdefs = include("sim/simdefs")
local simquery = include("sim/simquery")
local simfactory = include("sim/simfactory")
local cdefs = include("client_defs")

-----------------------------------------------------
-- Local functions

local brokenDoor =
{
    door = true,
    closed = true,
    locked = false,
    openSound = simdefs.SOUND_DOOR_OPEN,
    closeSound = simdefs.SOUND_DOOR_CLOSE,
    breakSound = simdefs.SOUND_DOOR_BREAK,
    keybits = simdefs.DOOR_KEYS.OFFICE,
    wallUVs = { unlocked = cdefs.WALL_DOOR_UNLOCKED, locked = cdefs.WALL_DOOR_LOCKED, broken = cdefs.WALL_DOOR_BROKEN },
}

local simcharge = { ClassType = "simcharge" }

function simcharge:onWarp(sim, oldcell, cell)
    if oldcell == nil and cell ~= nil then
        sim:addTrigger(simdefs.TRG_END_TURN, self)
    elseif oldcell ~= nil and cell == nil then
        sim:removeTrigger(simdefs.TRG_END_TURN, self)
    end
end

function simcharge:plantCharge(sim, cell, unit)
    sim:emitSound(simdefs.SOUND_SHOCKTRAP, cell.x, cell.y, nil)
    sim:dispatchEvent(simdefs.EV_CAM_PAN, { cell.x, cell.y })
    sim:startTrackerQueue(true)
    sim:startDaemonQueue()
    local x1, y1 = self:getLocation()
    if self:getTraits().range then
        sim:dispatchEvent(simdefs.EV_OVERLOAD_VIZ, { x = x1, y = y1, range = self:getTraits().range })
        local cells = simquery.fillCircle(sim, x1, y1, self:getTraits().range, 0)
        for _, cell in pairs(cells) do
            for _, dir in pairs(simdefs.DIR_SIDES) do
                if simquery.isNotLoadBearingWall(sim, cell, dir) then
                    local targetCell = simquery.getDirCell(sim, cell, dir)
                    local rdir = simquery.getReverseDirection(dir)
                    if not targetCell.isSolid then
                        cell.sides[dir] = nil
                        cell.exits[dir] = { cell = targetCell }
                        targetCell.exits[rdir] = { cell = cell }
                        targetCell.sides[rdir].cell = nil
                        sim:getLOS():removeSegments(cell, dir, targetCell, rdir)
                        sim:dispatchEvent(simdefs.SA.EV_WALL_BROKEN,
                            { cell = cell, rCell = targetCell, dir = dir, rdir = rdir })
                        sim:dispatchEvent(simdefs.EV_EXIT_MODIFIED,
                            { cell = cell, dir = dir, exitOp = simdefs.EXITOP_BREAK_DOOR })
                        local seers = {}
                        for unitID, seerUnit in pairs(sim:getAllUnits()) do
                            local x0, y0 = seerUnit:getLocation()
                            if seerUnit:getTraits().hasSight and x0 then
                                local nx, ny = targetCell.y - cell.y,
                                    targetCell.x - cell.x
                                local cx, cy = (cell.x + targetCell.x) / 2, (cell.y + targetCell.y) / 2
                                if (x0 == cell.x and y0 == cell.y) or (x0 == targetCell.x and y0 == targetCell.y) or
                                    sim:getLOS():withinLOS(seerUnit, cx + nx / 2, cy + ny / 2, cx - nx / 2, cy - ny / 2) then
                                    table.insert(seers, unitID)
                                end
                            end
                        end
                        for i, seerID in ipairs(seers) do
                            local seerUnit
                            if seerID >= simdefs.SEERID_PERIPHERAL then
                                seerUnit = sim:getUnit(seerID - simdefs.SEERID_PERIPHERAL)
                            else
                                seerUnit = sim:getUnit(seerID)
                            end
                            if seerUnit then
                                if seerUnit:hasTrait("hasSight") then
                                    sim:refreshUnitLOS(seerUnit)
                                end
                                if seerUnit:getPlayerOwner() then
                                    seerUnit:getPlayerOwner():glimpseExit(cell.x, cell.y, dir)
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    local unitID = self:getID()
    sim:warpUnit(self, nil)
    sim:despawnUnit(self)
    for i, player in ipairs(sim:getPlayers()) do
        player:glimpseUnit(sim, unitID)
    end
    sim:startTrackerQueue(false)
    sim:processDaemonQueue()
end

function simcharge:onTrigger(sim, evType, evData)
    if evType == simdefs.TRG_END_TURN then
        local cell = sim:getCell(self:getLocation())
        self:plantCharge(sim, cell, evData.unit)
    end
end

-----------------------------------------------------
-- Interface functions

local function applyToWall(sim, cell, direction, unit, userUnit)
    local player = userUnit:getPlayerOwner()
    local range = unit:getTraits().range
    local trap = simfactory.createUnit(unitdefs.prop_templates.acheron_breach_charge, sim)
    trap:getTraits().range = range
    trap:setFacing(direction)
    sim:spawnUnit(trap)
    sim:warpUnit(trap, cell)
    trap:setPlayerOwner(player)
end


local function createCharge(unitData, sim)
    local t = simunit.createUnit(unitData, sim)
    return util.tmerge(t, simcharge)
end

simfactory.register(createCharge)

return
{
    applyToWall = applyToWall,
}
