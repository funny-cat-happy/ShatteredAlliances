local pcplayer = include("sim/pcplayer")
local simdefs = include("sim/simdefs")
local oldInit = pcplayer.init
pcplayer.init = function(self, sim, agency)
    oldInit(self, sim, agency)
    self._traits.playerType = simdefs.PLAYER_TYPE.PC
end
