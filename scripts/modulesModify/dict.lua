---@class dict
local dict = class()
function dict:init(sim)
    self.data = {}
    self.sim = sim
end

function dict:add(key, value)
    table.insert(self.data, { key = key, value = value })
end

function dict:sort()
    table.sort(self.data, function(a, b)
        return a.value > b.value
    end)
end

function dict:randomPop(probability)
    if #self.data < 1 then
        return nil
    elseif #self.data < 2 then
        return table.remove(self.data)
    else
        if self.sim:nextRand(1, 100) <= probability then
            return table.remove(self.data, 1)
        else
            return table.remove(self.data, 2)
        end
    end
end

function dict:length()
    return #self.data
end

function dict:print()
    SALog(self.data, 2)
end

return dict
