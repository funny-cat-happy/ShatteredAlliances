local hud = include("hud/hud")
local rig_util = include("gameplay/rig_util")
local cdefs = include("client_defs")
local simdefs = include("sim/simdefs")
local alarm_states = include("sim/alarm_states")
local simquery = include("sim/simquery")

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
    local stage = hud._game.simCore:getTrackerStage(math.min(simdefs.TRACKER_MAXCOUNT, trackerNumber))
    local colourIndex = math.min(#cdefs.TRACKER_COLOURS, stage + 1)
    local colour = cdefs.TRACKER_COLOURS[colourIndex]

    -- Show the tracker number
    hud._screen.binder.alarm.binder.trackerTxt:setText(tostring(stage) .. '/9')
    hud._screen.binder.alarm.binder.trackerTxt:setColor(colour.r, colour.g, colour.b, 1)
    hud._screen.binder.alarm.binder.alarmLvlTitle:setColor(colour.r, colour.g, colour.b, 1)
    hud._screen.binder.alarm.binder.alarmDisc:setProgress(0.5)


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

upvalueUtil.findAndReplace(hud.onSimEvent, "runTrackerAdvance", newRunTrackerAdvance)
upvalueUtil.findAndReplace(hud.refreshHud, "refreshTrackerAdvance", newRefreshTrackerAdvance)

local oldInit = hud.init
hud.init = function(self, game)
    oldInit(self, game)
    self._screen.binder.alarm.binder.trackerAnimFive:setVisible(false)
    self._screen.binder.alarm.binder.alarmLvlTitle:setText(STRINGS.SA.HUD.ALARM_TITLE)
end

local oldRefreshHud = hud.refreshHud
hud.refreshHud = function(self)
    oldRefreshHud(self)
    self._screen.binder.alarm.binder.advancedAlarm:setVisible(true)
end
