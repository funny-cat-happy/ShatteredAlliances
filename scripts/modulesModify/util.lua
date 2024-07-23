---get local value in origin function
---@param fn function
---@param funcname string
---@param maxDepth integer
---@return unknown
local function getLocalValue(fn, funcname, maxDepth)
    local localValue = upvalueUtil.find(fn, funcname, maxDepth)
    assert(localValue, funcname .. " not exist in " .. tostring(fn))
    return localValue
end

return {
    getLocalValue = getLocalValue,
}
