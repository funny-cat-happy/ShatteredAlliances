local aiplayer = include("sim/aiplayer")
---@type simdefs
local simdefs = include("sim/simdefs")
local simplayer = include("sim/simplayer")
local simability = include("sim/simability")
local util = include("modules/util")
local dict = SAInclude("modulesModify/dict")

aiplayer.isAlly = function(self)
    return false
end

function aiplayer:isAI()
    return true
end

local oldInit = aiplayer.init
aiplayer.init = function(self, sim)
    oldInit(self, sim)
    self._traits.playerType = simdefs.SA.PLAYER_TYPE.AI
    self._traits.name = STRINGS.SA.UI.AI_PLAYER_NAME
    self._incognita_program = {}
    self._intention_points = 2
    local ability = simability.create("programLockPick")
    table.insert(self._incognita_program, ability)
    local ability = simability.create("programMarch")
    table.insert(self._incognita_program, ability)
    self._incognitaLockOut = false
    self._cpus = 10
    self._foreverHidden = false
end

function aiplayer:getDaemonHidden()
    return self._foreverHidden
end

function aiplayer:updateIntentionPoints(point)
    return self._intention_points + point < 0 and 1 or self._intention_points + point
end

function aiplayer:getPlayerAlly(sim)
    return nil
end

function aiplayer:getIncognitaLockOut()
    return self._incognitaLockOut
end

aiplayer.updateSenses = function(self, unit)
    local senses = unit:getBrain():getSenses()
    senses:update()

    local target = senses:getCurrentTarget() --refresh target after the update
    unit:getBrain():setTarget(target)
    if target then
        self:createOrJoinCombatSituation(unit, target)
    end
    local interest = nil
    if not target and senses:getCurrentInterest() then
        interest = senses:getCurrentInterest()
        if interest and interest ~= unit:getBrain():getInterest() then
            if interest.alerts then
                if unit:setAlerted(true) and interest.reason == simdefs.REASON_FOUNDCORPSE then
                    unit:getTraits().trackerAlert = { 1, STRINGS.UI.ALARM_GUARD_BODY, unit:getLocation() }
                end
            end
            if unit:isAlerted() then
                if unit:getTraits().vip then
                    self:createOrJoinFleeSituation(unit)
                elseif not (unit:getBrain():getSituation().ClassType == simdefs.SITUATION_HUNT and interest.reason == simdefs.REASON_HUNTING) then
                    self:createOrJoinHuntSituation(unit, interest)
                end
            else
                self:createOrJoinInvestigateSituation(unit, interest)
            end
        end
    end
    unit:getBrain():setInterest(interest)

    if not target and not interest then
        self:returnToIdleSituation(unit)
    end
end

aiplayer.onEndTurn = function(self, sim)
    simplayer.onEndTurn(self, sim)
    if self._sim:getCurrentPlayer() == self then
        self:updateTracker(sim)
    end
end

aiplayer.thinkHard = function(self, sim)
    sim:triggerEvent(simdefs.SA.TRG_INCOGNITA_ACTION, self)
    ---@type dict
    local evaluateDict = dict(sim)
    for key, program in pairs(self:getPrograms()) do
        if program:canUseAbility(sim) then
            evaluateDict:add(program, program.evaluate())
        end
    end
    evaluateDict:sort()
    for i = 1, self._intention_points, 1 do
        local programDict = evaluateDict:randomPop(70)
        if programDict then
            programDict.key:executeAbility(sim)
        end
    end
    sim:endTurn()
end

aiplayer.march = function(self, sim)
    local st = os.clock()
    local steps = 0
    local pcPlayer = sim:getPC()


    self.bunits = util.tdupe(self.prioritisedUnits)
    local maxSteps = 50
    while #self.bunits > 0 and not pcPlayer:isNeutralized(sim) and steps < maxSteps do
        -- Process behaviours once for each outstanding unit.
        local unit = table.remove(self.bunits, 1)
        self:setCurrentAgent(unit)
        if unit:isValid() then
            simlog(simdefs.LOG_AI, "[%s] Thinking", tostring(unit:getID()))
        end
        local thought = self:tickBrain(unit)
        if thought and unit:isValid() then
            if thought == simdefs.BSTATE_RUNNING then
                --we got interrupted!
                simlog(simdefs.LOG_AI, "[%s] Thinking again immediately", tostring(unit:getID()))
                table.insert(self.bunits, 1, unit)
            elseif thought == simdefs.BSTATE_WAITING then
                simlog(simdefs.LOG_AI, "[%s] Thinking again later: %s", tostring(unit:getID()),
                    unit:getBrain().rootNode.status)
                table.insert(self.bunits, unit)
            else
                table.insert(self.processedUnits, unit)
            end
        end
        self:setCurrentAgent(nil)


        steps = steps + 1
    end

    if steps > maxSteps then
        simlog("thinkhard() BAILING -- took %.1f ms", (os.clock() - st) * 1000)
        for i, bunit in ipairs(bunits) do
            simlog("%s [%s]", bunit:getName(), bunit:isValid() and tostring(bunit:getID()) or "killed")
        end
        self.bunits = {}
        steps = 0
        st = os.clock()
    end

    self:cleanUpSituations()
end

aiplayer.getPrograms = function(self)
    return self._incognita_program
end

aiplayer.findProgram = function(self, id)
    for _, program in pairs(self._incognita_program) do
        if program.id == id then
            return program
        end
    end
end

aiplayer.addIncognitaIntention = function(self, abilityID)
    local ability = simability.create(abilityID)
    if ability then
        ability:spawnAbility(self._sim, self)
        table.insert(self._mainframeAbilities, ability)
        self._sim:dispatchEvent(simdefs.EV_MAINFRAME_INSTALL_PROGRAM,
            { idx = #self._mainframeAbilities, ability = ability })
    end
end

aiplayer.addMainframeAbility = function(self, sim, abilityID, hostUnit)
    local count = 0
    for _, ability in ipairs(self._mainframeAbilities) do
        if ability:getID() == abilityID then
            count = count + 1
        end
    end
    local ability = simability.create(abilityID)
    if ability and count < (ability.max_count or math.huge) then
        table.insert(self._mainframeAbilities, ability)
        ability:spawnAbility(self._sim, self, hostUnit)
        if self:isNPC() then
            sim:dispatchEvent(simdefs.EV_MAINFRAME_INSTALL_PROGRAM,
                { idx = #self._mainframeAbilities, ability = ability })
            sim:triggerEvent(simdefs.TRG_DAEMON_INSTALL)
        end
    end
end
