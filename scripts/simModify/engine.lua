---@class engine
local simengine = include("sim/engine")
local allyplayer = include(SA_PATH .. "/simModify/allyplayer")
local simactions = include("sim/simactions")
local simdefs = include("sim/simdefs")
local util = include("modules/util")

local oldInit = simengine.init

simengine.init = function(self, params, levelData, ...)
    oldInit(self, params, levelData, ...)
    self._turn = 3
    table.insert(self._players, 1, allyplayer(self))
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

simengine.getNPC = function(self)
    for i, player in ipairs(self._players) do
        if player:isNPC() and not player:isAlly() then
            return player
        end
    end
end


simengine.getAlly = function(self)
    for i, player in ipairs(self._players) do
        if player:getTraits().playerType and player:getTraits().playerType == simdefs.PLAYER_TYPE.ALLY then
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
