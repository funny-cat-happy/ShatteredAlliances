---@class engine
---@field _firewall INCFirewall
local simengine = include("sim/engine")
local allyplayer = SAInclude("simModify/allyplayer")
local simactions = include("sim/simactions")
local simdefs = include("sim/simdefs")
local util = include("modules/util")
local binops = include("modules/binary_ops")
local mathutil = include("modules/mathutil")
local array = include("modules/array")
local level = include("sim/level")
---@type simdefs
local simdefs = include("sim/simdefs")
local simevents = include("sim/simevents")
local simunit = include("sim/simunit")
local pcplayer = include("sim/pcplayer")
local aiplayer = include("sim/aiplayer")
local line_of_sight = include("sim/line_of_sight")
local simquery = include("sim/simquery")
local simactions = include("sim/simactions")
local simfactory = include("sim/simfactory")
local simstats = include("sim/simstats")
local inventory = include("sim/inventory")
local abilitydefs = include("sim/abilitydefs")
local unitdefs = include("sim/unitdefs")
local skilldefs = include("sim/skilldefs")
local mainframe = include("sim/mainframe")
local rand = include("modules/rand")
local speechdefs = include("sim/speechdefs")
local win_conditions = include("sim/win_conditions")
local cdefs = include("client_defs")
local simguard = include("modules/simguard")
local version = include("modules/version")
local alarm_states = include("sim/alarm_states")
local firewall = SAInclude("simModify/incfirewall")

local oldInit = simengine.init
simengine.init = function(self, params, levelData, ...)
    oldInit(self, params, levelData, ...)
    self._turn = 3
    table.insert(self._players, 1, allyplayer(self))
    self._firewall = firewall(self)
end

simengine.getFirewall = function(self)
    return self._firewall
end
simengine.trackerAdvance = function(self, delta, txt, scan)
end

simengine.applyAction = function(self, action)
    local choiceCount = self._choiceCount

    --simlog( "APPLY: (%u) %s", self._seed, util.stringize(action) )

    -- Apply all the choices that are stored in this action.
    if action.choices then
        for i, choice in pairs(action.choices) do
            assert(self._choices[i] == nil)
            self._choices[i] = choice
        end
    end

    -- Update the sim with the number of retries (for tutorial branching)
    self:getTags().retries = math.max(self:getTags().retries or 0, action.retries or 0)
    self:getTags().rewindError = self:getTags().rewindError or action.rewindError
    self._actionCount = self._actionCount + 1

    local skipAction = self:triggerEvent(simdefs.TRG_ACTION, { pre = true, ClassType = action.name, unpack(action) })
        .abort

    if not skipAction then
        -- Be sure to copy the action before unpacking, as the action data should be immutable.
        simactions[action.name](self, unpack(util.tcopy(action)))

        self:triggerEvent(simdefs.TRG_ACTION, { ClassType = action.name, unpack(action) })
    end

    -- Update win conditions after every action	
    self:updateWinners()

    if self:getCurrentPlayer() and self:getCurrentPlayer():isNPC() and self:getCurrentPlayer():isAlly() then
        self:getCurrentPlayer():thinkHard(self)
        -- And again after ally moves.
        self:updateWinners()
    end

    if self:getCurrentPlayer() and self:getCurrentPlayer():isNPC() and not self:getCurrentPlayer():isAlly() then
        self:getCurrentPlayer():thinkHard(self)
        -- And again after AI moves.
        self:updateWinners()
    end

    -- Store all the choices that were made.
    -- THIS MUST BE LAST.
    for i = choiceCount + 1, self._choiceCount do
        if action.choices == nil then
            action.choices = {}
        end
        action.choices[i] = self._choices[i]
    end
end
---comment
---@param self engine
---@return aiplayer
simengine.getNPC = function(self)
    for i, player in ipairs(self._players) do
        if player:isNPC() and not player:isAlly() then
            return player
        end
    end
end


simengine.getAlly = function(self)
    for i, player in ipairs(self._players) do
        if player:getTraits().playerType and player:getTraits().playerType == simdefs.SA.PLAYER_TYPE.ALLY then
            return player
        end
    end
end

function simengine:canPlayerSee(player, x, y)
    local allyPlayer = player:getPlayerAlly(self)
    if allyPlayer then
        for i, playerUnit in ipairs(allyPlayer:getUnits()) do
            if self:canUnitSee(playerUnit, x, y) then
                return true
            end
        end
    end
    for i, playerUnit in ipairs(player:getUnits()) do
        if self:canUnitSee(playerUnit, x, y) then
            return true
        end
    end
    return false
end

simengine.moveUnit = function(self, unit, moveTable)
    moveTable = util.tdupe(moveTable)
    unit:getTraits().movePath = moveTable
    unit:getTraits().interrupted = nil
    unit:resetAllAiming()

    if unit:getTraits().monster_hacking then
        unit:getTraits().monster_hacking = false
        unit:getSounds().spot = nil
        self:dispatchEvent(simdefs.EV_UNIT_REFRESH, { unit = unit })
    end

    if unit:getTraits().data_hacking then
        local target = self:getUnit(unit:getTraits().data_hacking)
        if target then
            target:getTraits().hacker = nil
        end
        unit:getTraits().data_hacking = nil
        unit:getSounds().spot = nil
        self:dispatchEvent(simdefs.EV_UNIT_REFRESH, { unit = unit })
    end

    local zz = KLEIProfiler.Push("moveUnit")

    local steps, canMove, canMoveReason = nil, true, simdefs.CANMOVE_OK
    local totalMoves = #moveTable
    local moveCost = 0
    local door

    assert(totalMoves > 0)
    local start_cell, end_cell

    self:startTrackerQueue(true)

    local tilesMoved = 0


    if #moveTable > 0 and unit:getTraits().disguiseOn and not unit:getTraits().sneaking then
        unit:setDisguise(false)
    end

    while #moveTable > 0 do
        local move = table.remove(moveTable, 1)
        start_cell = self:getCell(unit:getLocation())
        end_cell = self:getCell(move.x, move.y)

        -- Must have sufficient movement available
        canMove, canMoveReason = simquery.canMoveUnit(self, unit, move.x, move.y)
        if not canMove then
            if canMoveReason == simdefs.CANMOVE_NOMP then
                end_cell = start_cell
                break
            end
        end

        local facing = simquery.getDirectionFromDelta(end_cell.x - start_cell.x, end_cell.y - start_cell.y)
        local reverse = math.abs(facing - unit:getFacing()) == 4

        if not steps and canMoveReason ~= simdefs.CANMOVE_NOMP and canMoveReason ~= simdefs.CANMOVE_DYNAMIC_IMPASS then
            steps = 0
            self:dispatchEvent(simdefs.EV_UNIT_START_WALKING, { unit = unit, reverse = reverse })
        end

        if facing ~= unit:getFacing() then
            unit:updateFacing(facing)

            --the facing change might invalidate our unit
            if not unit:isValid() or unit:getTraits().interrupted or unit:isKO() then
                canMoveReason = simdefs.CANMOVE_INTERRUPTED
                break
            end
        end

        -- need to open door if its in the way
        for dir, exit in pairs(start_cell.exits) do
            if exit.cell == end_cell then
                if exit.door and exit.closed and simquery.canModifyExit(unit, simdefs.EXITOP_OPEN, start_cell, dir) then
                    local stealth = unit:getTraits().sneaking
                    self:modifyExit(start_cell, dir, simdefs.EXITOP_OPEN, unit, stealth)
                    door = { cell = start_cell, dir = dir, stealth = stealth }
                    if exit.keybits == simdefs.DOOR_KEYS.GUARD then
                        door.forceClose = true
                    end
                end
                break
            end
        end

        --the door opening might invalidate our unit
        if not unit:isValid() or unit:getTraits().interrupted or unit:isKO() then
            canMoveReason = simdefs.CANMOVE_INTERRUPTED
            break
        end


        -- if possible, turn lasers off while moving
        canMove, canMoveReason = simquery.canMoveUnit(self, unit, move.x, move.y)
        if canMoveReason == simdefs.CANMOVE_DYNAMIC_IMPASS then
            for _, cellUnit in ipairs(end_cell.units) do
                if cellUnit:getTraits().emitterID and cellUnit:canControl(unit) then
                    cellUnit:deactivate(self)
                end
            end
            canMove, canMoveReason = simquery.canMoveUnit(self, unit, move.x, move.y)
        end

        --the laser changing might invalidate our unit
        if not unit:isValid() or unit:getTraits().interrupted or unit:isKO() then
            canMoveReason = simdefs.CANMOVE_INTERRUPTED
            break
        end

        self:triggerEvent(simdefs.TRG_UNIT_WARP_PRE, { unit = unit, from_cell = start_cell, to_cell = end_cell })
        --triggering a warp_pre might invalidate our unit
        if not unit:isValid() or unit:getTraits().interrupted or unit:isKO() then
            canMoveReason = simdefs.CANMOVE_INTERRUPTED
            break
        end

        if not canMove then
            -- The move order is based on player-centric (limited) information, so it may not ACTUALLY be possible to do the move. If not, just abort.
            assert(canMoveReason and canMoveReason ~= simdefs.CANMOVE_OK)
            break
        end

        if unit:getPlayerOwner() ~= self:getPC() then
            if steps == 0 then
                self:getPC():trackFootstep(self, unit, start_cell.x, start_cell.y)
            end
            self:getPC():trackFootstep(self, unit, end_cell.x, end_cell.y)
        end

        -- Must consume MP before warping or it won't be consumed if an interrupt occurs!
        local moveCost = nil
        if unit:getTraits().movingBody then
            local dragCost = simdefs.DRAGGING_COST

            if unit:hasTrait("dragCostMod") then
                dragCost = dragCost - unit:getTraits().dragCostMod
            end

            --easier to drag agents
            local body = unit:getTraits().movingBody
            if not body:getTraits().isGuard then
                dragCost = dragCost - 1
            end

            --never improve moving if you're dragging!
            dragCost = math.max(simdefs.MIN_DRAGGING_COST, dragCost)

            moveCost = simquery.getMoveCost(start_cell, end_cell) * dragCost
        elseif unit:getTraits().sneaking then
            moveCost = simquery.getMoveCost(start_cell, end_cell) * simdefs.SNEAKING_COST
        else
            moveCost = simquery.getMoveCost(start_cell, end_cell)
        end
        unit:useMP(moveCost, self)

        self:warpUnit(unit, end_cell, facing, reverse)

        -- Warp unit can possibly trigger this unit to despawn
        if not unit:isValid() then
            canMoveReason = simdefs.CANMOVE_INTERRUPTED
            break
        end

        self:emitSound({ hiliteCells = unit:isPC(), range = simquery.getMoveSoundRange(unit, start_cell) }, end_cell.x,
            end_cell.y, unit)

        if unit:getTraits().cloakDistance and unit:getTraits().cloakDistance > 0 then
            unit:getTraits().cloakDistance = unit:getTraits().cloakDistance - moveCost
            if unit:getTraits().cloakDistance <= 0 then
                unit:setInvisible(false)
                unit:getTraits().cloakDistance = nil
            end
        end

        -- If interrupted or otherwise KO'd from warpUnit, abort now.
        if unit:getTraits().interrupted or unit:isKO() then
            canMoveReason = simdefs.CANMOVE_INTERRUPTED
            break
        end

        self:processReactions(unit)

        if unit:isValid() and #moveTable == 0 and move.facing then
            unit:updateFacing(move.facing)
        end

        steps = steps + 1

        -- Retaliatory actions taken during the move may invalidate this unit.
        if not unit:isValid() or unit:getTraits().interrupted or unit:isKO() then
            canMoveReason = simdefs.CANMOVE_INTERRUPTED
            break
        end

        --close door if we just went through it
        if door and not door.cell.exits[door.dir].closed and unit:getTraits().closedoors and (unit:getTraits().walk == true or door.forceClose) then
            self:modifyExit(door.cell, door.dir, simdefs.EXITOP_CLOSE, unit, door.stealth)
            door = nil
        end
        tilesMoved = tilesMoved + 1
    end

    if unit:isValid() then
        unit:getTraits().movePath = nil
        unit:getTraits().interrupted = nil
        if steps then
            self:dispatchEvent(simdefs.EV_UNIT_STOP_WALKING, { unit = unit })
        end
    end
    self:startTrackerQueue(false)

    KLEIProfiler.Pop(zz)

    return canMoveReason, end_cell
end
---comment
---@param self engine
---@param unit simunit
---@param speechIndex unknown
simengine.emitSpeech = function(self, unit, speechIndex)
    if not unit:isDead() and unit:getSpeech() then
        local speechData = unit:getSpeech()[speechIndex]
        if speechData ~= nil then
            local p = speechData[1]
            if self:nextRand() <= p then
                -- Speech might or might not "make sound"
                if speechData.sound then
                    local x0, y0 = unit:getLocation()
                    if unit:getPlayerOwner() ~= self:getAlly() then
                        self:emitSound(speechData.sound, x0, y0, unit)
                    end

                    -- GLIMPSE UNIT IF HEARD
                    local player = self:getPC()
                    local heard = false
                    for i, unitListen in ipairs(player:getUnits()) do
                        local x1, y1 = unitListen:getLocation()
                        if x1 and y1 then
                            local distance = mathutil.dist2d(x0, y0, x1, y1)
                            if distance <= simdefs.SOUND_RANGE_2 and simquery.canHear(unitListen) then
                                heard = true
                                break
                            end
                        end
                    end
                    if heard == true then
                        player:glimpseUnit(self, unit:getID())
                    end
                    -- END GLIMPSE TEST
                end

                self:dispatchEvent(simdefs.EV_UNIT_SPEAK,
                    { unit = unit, speech = speechData.speech, speechData = speechData[2], range = simdefs.SOUND_RANGE_2 })
            end
        end
    end
end
