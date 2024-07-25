local simengine = include("sim/engine")
local allyplayer = include(SA_PATH .. "/simModify/allyplayer")

local oldInit = simengine.init

simengine.init = function(self, params, levelData, ...)
    oldInit(self, params, levelData, ...)
    self._turn = 3
    table.insert(self._players,1,allyplayer(self))
end
