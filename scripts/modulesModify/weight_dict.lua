---@class weight_dict
local weight_dict = class()
function weight_dict:init(sim)
    self.data = {}
    self.sim = sim
end

function weight_dict:add(key, value)
    table.insert(self.data, { key = key, value = value })
end

function weight_dict:sort()
    table.sort(self.data, function(a, b)
        return a.value > b.value
    end)
end

function weight_dict:randomPop(probability)
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

function weight_dict:length()
    return #self.data
end

function weight_dict:print()
    SALog(self.data, 2)
end

return weight_dict
