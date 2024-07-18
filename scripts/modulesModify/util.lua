local util = include("modules/util")


local function SALog(val)
    MOAILogMgr.log(util.stringize(val))
end

rawset(_G, "SALog", rawget(_G, "SALog") or SALog)
