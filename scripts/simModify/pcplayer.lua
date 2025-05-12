local pcplayer = include("sim/pcplayer")
local simdefs = include("sim/simdefs")
local oldInit = pcplayer.init
pcplayer.init = function(self, sim, agency)
    oldInit(self, sim, agency)
    self._traits.playerType = simdefs.SA.PLAYER_TYPE.PC
end

---comment
---@param sim engine
function pcplayer:getPlayerAlly(sim)
    return sim:getAlly()
end

function pcplayer:isAlly()
    return false
end
