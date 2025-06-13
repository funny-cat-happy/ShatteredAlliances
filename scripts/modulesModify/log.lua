local util = include("modules/util")

---comment
---@param val any
---@param maxRecurse string|number|nil
---@param title string|nil
function SALog(val, maxRecurse, title)
    local logTitle = "SALog:"
    local recurse = 1
    if type(maxRecurse) == "string" and type(title) == "nil" then
        logTitle = maxRecurse .. ":"
    elseif type(maxRecurse) == "number" and type(title) == "string" then
        recurse = maxRecurse
        logTitle = title .. ":"
    elseif type(maxRecurse) == "number" and type(title) == "nil" then
        recurse = maxRecurse
    end
    MOAILogMgr.log(logTitle .. "\n" .. util.stringize(val, recurse))
end
