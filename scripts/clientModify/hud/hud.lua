local hud = include("hud/hud")
local rig_util = include("gameplay/rig_util")
local cdefs = include("client_defs")
local simdefs = include("sim/simdefs")
local alarm_states = include("sim/alarm_states")
local simquery = include("sim/simquery")

local function find(fn, condition, maxDepth)
    maxDepth = maxDepth or 3

    local upvName, value
    local upvIdx = 1
    repeat
        upvName, value = debug.getupvalue(fn, upvIdx)
        upvIdx = upvIdx + 1
        SALog({ upvName, fn, upvIdx })
        if upvName == condition or (type(condition) == "function" and condition(upvName, value)) then
            return value, upvIdx, fn
        end

        if type(value) == "function" then
            if maxDepth > 0 then
                local subV, subIdx, subFn = find(value, condition, maxDepth - 1)
                if subIdx then
                    return subV, subIdx, subFn
                end
            end
        end
    until upvName == nil
end

local function findAndReplace(fn, condition, newValue, maxDepth)
    local value, upvIdx, subFn = find(fn, condition, maxDepth)

    debug.setupvalue(subFn, upvIdx, newValue)

    return value, upvIdx, subFn
end

upvalueUtil = {
    find = find,
    findAndReplace = findAndReplace
}

local function refreshTrackerMusic(hud, stage)
    stage = math.max(stage, hud._musicStage or 0)
    local isClimax = stage >= simdefs.TRACKER_MAXSTAGE or hud._game.simCore:getClimax()

    -- Check special conditions for max-intensity/climax.
    if not isClimax then
        for i, unit in pairs(hud._game.simCore:getPC():getAgents()) do
            if simquery.isUnitUnderOverwatch(unit) then
                isClimax = true
                break
            end
        end
    end

    -- And cue the music
    MOAIFmodDesigner.setMusicProperty("intensity", stage)
    if isClimax then
        MOAIFmodDesigner.setMusicProperty("kick", 1)
    else
        MOAIFmodDesigner.setMusicProperty("kick", 0)
    end

    hud._musicStage = stage
end

local function newRefreshTrackerAdvance(hud, trackerNumber)
    SALog("a")
    local stage = hud._game.simCore:getTrackerStage(math.min(simdefs.TRACKER_MAXCOUNT, trackerNumber))
    local colourIndex = math.min(#cdefs.TRACKER_COLOURS, stage + 1)
    local colour = cdefs.TRACKER_COLOURS[colourIndex]

    -- Show the tracker number
    hud._screen.binder.alarm.binder.trackerTxt:setText(tostring(stage) .. '/9')
    hud._screen.binder.alarm.binder.trackerTxt:setColor(colour.r, colour.g, colour.b, 1)
    hud._screen.binder.alarm.binder.alarmLvlTitle:setColor(colour.r, colour.g, colour.b, 1)


    local params = hud._game.params

    local tip = STRINGS.UI.ADVANCED_ALARM_TOOLTIP
    if params.missionEvents and params.missionEvents.advancedAlarm then
        tip = STRINGS.UI.ADVANCED_ALARM_TOOLTIP
    end

    local alarmList = hud._game.simCore:getAlarmTypes()
    local next_alarm = simdefs.ALARM_TYPES[alarmList][stage + 1]


    if next_alarm then
        tip = tip .. alarm_states.alarm_level_tips[next_alarm]
    else
        tip = tip .. STRINGS.UI.ALARM_NEXT_AFTER_SIX
    end

    hud._screen.binder.alarm:setTooltip(tip)

    refreshTrackerMusic(hud, stage)
end

local function newRunTrackerAdvance(hud, txt, delta, tracker, subtxt)
    -- SALog({ txt, delta, tracker, subtxt })
    if txt then
        hud:showWarning(txt, nil, subtxt, (delta + 3) * cdefs.SECONDS)
    end

    hud._screen.binder.alarm.binder.alarmRing1:setAnim("idle")
    hud._screen.binder.alarm.binder.alarmRing1:setVisible(true)
    hud._screen.binder.alarm.binder.alarmRing1:getProp():setListener(KLEIAnim.EVENT_ANIM_END,
        function(anim, animname)
            if animname == "idle" then
                hud._screen.binder.alarm.binder.alarmRing1:setVisible(false)
            end
        end)

    newRefreshTrackerAdvance(hud, tracker + delta)

    rig_util.wait(30)
    MOAIFmodDesigner.playSound(cdefs.SOUND_HUD_ADVANCE_TRACKER_NUMBER)
end
-- upvalueUtil.findAndReplace(hud.onSimEvent, "runTrackerAdvance", newRunTrackerAdvance)
-- upvalueUtil.findAndReplace(hud.refreshHud, "refreshTrackerAdvance", newRefreshTrackerAdvance)
local value, upvIdx, fn = find(hud.onSimEvent, "runTrackerAdvance", 1)
SALog({ value, upvIdx, fn, hud.onSimEvent })
SALog(debug.getupvalue(fn, 8))
SALog(debug.getupvalue(fn, 9))
SALog(debug.getupvalue(fn, 10))
-- debug.setupvalue(fn, upvIdx, newRunTrackerAdvance)
-- value, upvIdx, fn = find(hud.refreshHud, "refreshTrackerAdvance")
-- debug.setupvalue(fn, upvIdx, newRefreshTrackerAdvance)
-- value, upvIdx, fn = find(hud.onSimEvent, "refreshTrackerAdvance")
-- value, upvIdx, fn=upvalueUtil.findAndReplace(hud.onSimEvent, "runTrackerAdvance", newRunTrackerAdvance)
-- SALog({ value, upvIdx, fn })
