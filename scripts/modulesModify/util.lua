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

local function debugFunc(fn, ...)
    local args = { ... }
    local function errorHandler(err)
        local message = "Error: " .. err .. "\n" .. debug.traceback()
        SALog(message)
    end
    local status = xpcall(function()
        fn(unpack(args))
    end, errorHandler)
    if status then
        print("Function executed successfully")
    end
end
return {
    getLocalValue = getLocalValue,
    debugFunc = debugFunc,
}
