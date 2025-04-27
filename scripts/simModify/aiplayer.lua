local aiplayer = include("sim/aiplayer")
local simdefs = include("sim/simdefs")

aiplayer.isAlly = function(self)
    return false
end

local oldInit = aiplayer.init
aiplayer.init = function(self, sim)
    oldInit(self, sim)
    self._traits.playerType = simdefs.PLAYER_TYPE.AI
end
function aiplayer:getPlayerAlly(sim)
    return nil
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
