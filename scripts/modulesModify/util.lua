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
        SALog("Function executed successfully")
    end
end

local function printAllUpvalues(fn, maxDepth, callChain)
    maxDepth = maxDepth or 3
    callChain = callChain or 'root'
    
    local upvIdx = 1
    local upvName, value
    
    repeat
        upvName, value = debug.getupvalue(fn, upvIdx)
        if upvName then
            local currentChain = callChain .. "->" .. upvName
            SALog(string.format("%s = %s", currentChain, tostring(value)))
            
            if type(value) == "function" and maxDepth > 0 then
                printAllUpvalues(value, maxDepth - 1, currentChain)
            end
        end
        upvIdx = upvIdx + 1
    until upvName == nil
end

local function printUpvalue(fn, condition, maxDepth, callChain)
    maxDepth = maxDepth or 3
    callChain = callChain or (type(condition) == 'string' and condition or 'root')

    local upvName, value
    local upvIdx = 1
    repeat
        upvName, value = debug.getupvalue(fn, upvIdx)
        upvIdx = upvIdx + 1
        callChain = callChain .. "->" .. upvName

        if upvName == condition or (type(condition) == "function" and condition(upvName, value)) then
            SALog(callChain)
            return value, upvIdx, fn
        end

        if type(value) == "function" then
            if maxDepth > 0 then
                local subV, subIdx, subFn = printUpvalue(value, condition, maxDepth - 1, callChain)
                if subIdx then
                    return subV, subIdx, subFn
                end
            end
        end
    until upvName == nil
end

local SAUtil = {
    getLocalValue = getLocalValue,
    debugFunc = debugFunc,
    printUpvalue = printUpvalue,
    printAllUpvalues = printAllUpvalues,
}
rawset(_G, "SAUtil", rawget(_G, "SAUtil") or SAUtil)