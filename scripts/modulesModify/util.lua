local util = include("modules/util")


local function SALog(val, maxRecurse)
    MOAILogMgr.log("SA Log:\n" .. util.stringize(val, maxRecurse))
end

rawset(_G, "SALog", rawget(_G, "SALog") or SALog)
