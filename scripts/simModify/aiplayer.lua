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
