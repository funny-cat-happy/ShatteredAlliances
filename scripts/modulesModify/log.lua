local util = include("modules/util")


local function SALog(val, maxRecurse)
    maxRecurse = maxRecurse or 1
    MOAILogMgr.log("SALog:\n" .. util.stringize(val, maxRecurse))
end

rawset(_G, "SALog", rawget(_G, "SALog") or SALog)
