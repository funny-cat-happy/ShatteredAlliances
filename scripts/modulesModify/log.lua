local util = include("modules/util")


function SALog(val, maxRecurse)
    maxRecurse = maxRecurse or 1
    MOAILogMgr.log("SALog:\n" .. util.stringize(val, maxRecurse))
end
