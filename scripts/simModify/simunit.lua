---@class simunit
local simunit = include("sim/simunit")

setmetatable(simunit, nil)
simunit.isAI = function(self)
    local playerOwner = self:getPlayerOwner()
    return playerOwner ~= nil and playerOwner:isAI()
end
