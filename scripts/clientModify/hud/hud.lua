local hud = include("hud/hud")
local sa_util = include(SA_PATH .. '/modulesModify/util')
local util = include("client_util")
local modalDialog = include("states/state-modal-dialog")
local modal_thread = include("gameplay/modal_thread")
local console_panel = include("hud/console_panel")
local cdefs = include("client_defs")
local rig_util = include("gameplay/rig_util")
local simdefs = include("sim/simdefs")
local alarm_states = include("sim/alarm_states")

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
    sa_util.getLocalValue(hud.onSimEvent, "refreshTrackerMusic")(hud, stage)
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

local oldOnsimEvent = hud.onSimEvent
hud.onSimEvent = function(self, ev)
    local sim = self._game.simCore
    local simdefs = sim.getDefs()

    if ev.eventType == simdefs.EV_HIDE_PROGRAM or ev.eventType == simdefs.EV_SLIDE_IN_PROGRAM then
        self._mainframe_panel:onSimEvent(ev)
    end

    local mfMode = sa_util.getLocalValue(oldOnsimEvent, "checkForMainframeEvent", 1)(simdefs, ev.eventType, ev.eventData)
    if mfMode == sa_util.getLocalValue(oldOnsimEvent, "SHOW_MAINFRAME", 1) then
        if not self._isMainframe then
            self:showMainframe()
        end
        self._mainframe_panel:onSimEvent(ev)
    elseif mfMode == sa_util.getLocalValue(oldOnsimEvent, "HIDE_MAINFRAME", 1) and self._isMainframe then
        self:hideMainframe()
    end

    if ev.eventType == simdefs.EV_HUD_REFRESH then
        self:refreshHud()
    elseif ev.eventType == simdefs.EV_UNIT_DRAG_BODY or ev.eventType == simdefs.EV_UNIT_DROP_BODY then
        self._home_panel:refreshAgent(ev.eventData.unit)
    elseif ev.eventType == simdefs.EV_TURN_START then
        local currentPlayer = self._game.simCore:getCurrentPlayer()

        self._game.boardRig:onStartTurn(currentPlayer and currentPlayer:isPC())

        if currentPlayer ~= nil then
            if currentPlayer ~= self._game:getLocalPlayer() then
                self._oldPlayerMainframeState = self._isMainframe
            end

            self:refreshHud()

            local txt, color, sound
            local corpTurn = false
            -- if currentPlayer:isNPC() then
            --     txt = STRINGS.UI.ENEMY_ACTIVITY
            --     color = { r = 1, g = 0, b = 0, a = 1 }
            --     sound = cdefs.SOUND_HUD_GAME_ACTIVITY_CORP
            --     corpTurn = true
            -- else
            --     txt = STRINGS.UI.AGENT_ACTIVITY
            --     color = { r = 140 / 255, g = 255 / 255, b = 255 / 255, a = 1 }
            --     sound = cdefs.SOUND_HUD_GAME_ACTIVITY_AGENT
            -- end
            if currentPlayer:isNPC() then
                txt = STRINGS.SA.HUD.ALLIANCE_ACTIVITY
                color = { r = 84 / 255, g = 255 / 255, b = 159 / 255, a = 1 }
                sound = cdefs.SOUND_HUD_GAME_ACTIVITY_CORP
                corpTurn = true
            else
                txt = STRINGS.UI.AGENT_ACTIVITY
                color = { r = 140 / 255, g = 255 / 255, b = 255 / 255, a = 1 }
                sound = cdefs.SOUND_HUD_GAME_ACTIVITY_AGENT
            end

            local turn = math.ceil((sim:getTurnCount() + 1) / 2)

            sa_util.getLocalValue(oldOnsimEvent, "startTitleSwipe", 1)(self, txt, color, sound, corpTurn, turn)
            rig_util.wait(30)
            sa_util.getLocalValue(oldOnsimEvent, "stopTitleSwipe", 1)(self)
        end
        local selectedUnit = self:getSelectedUnit()
        if selectedUnit and selectedUnit:isValid() then
            self._game:getCamera():fitOnscreen(self._game:cellToWorld(selectedUnit:getLocation()))
        end
    elseif ev.eventType == simdefs.EV_WAIT_DELAY then
        rig_util.wait(ev.eventData)
    elseif ev.eventType == simdefs.EV_TURN_END then
        self:hideItemsPanel()
        if ev.eventData and not ev.eventData:isNPC() then
            sa_util.getLocalValue(oldOnsimEvent, "stopTitleSwipe", 1)(self)
        end
    elseif ev.eventType == simdefs.EV_ADVANCE_TRACKER then
        if ev.eventData.alarmOnly or (ev.eventData.tracker + ev.eventData.delta >= simdefs.TRACKER_MAXCOUNT) then
            --	self._game.post_process:colorCubeLerp( "data/images/cc/cc_default.png", "data/images/cc/screen_shot_out_test1_cc.png", 1.0, MOAITimer.PING_PONG, 0,0.5 )			
            if not self._playingAlarmLoop then
                MOAIFmodDesigner.playSound("SpySociety/HUD/gameplay/alarm_LP", "alarm")
                self._playingAlarmLoop = true
            end
        end
        if not ev.eventData.alarmOnly then
            newRunTrackerAdvance(self, ev.eventData.txt, ev.eventData.delta, ev.eventData.tracker, ev.eventData.subtxt)
        end
    elseif ev.eventType == "used_radio" then
        local stage = self._game.simCore:getTrackerStage(ev.eventData.tracker)
        sa_util.getLocalValue(oldOnsimEvent, "refreshTrackerMusic", 1)(self, stage)
    elseif ev.eventType == simdefs.EV_LOOT_ACQUIRED and not ev.eventData.silent then
        if not self._game.debugStep then
            self._game.viz:addThread(modal_thread.programDialog(self._game.viz,
                STRINGS.UI.LOOT_MODAL_TITLE,
                util.toupper(ev.eventData.lootUnit:getName()),
                util.sformat(STRINGS.UI.LOOT_MODAL1, ev.eventData.lootUnit:getName(), ev.eventData.unit:getName()),
                ev.eventData.icon))
        end
    elseif ev.eventType == simdefs.EV_PUSH_QUIET_MIX then
        --play stinger to hide the new music
        MOAIFmodDesigner.playSound("SpySociety/Music/stinger_finalroom")
        FMODMixer:pushMix("nomusic")
        MOAIFmodDesigner.playSound("SpySociety/AMB/finalroom", "AMB3")
    elseif ev.eventType == simdefs.EV_FADE_TO_BLACK then
        sa_util.getLocalValue(oldOnsimEvent, "fadeToBlack", 1)(self)
    elseif ev.eventType == simdefs.EV_CREDITS_REFRESH then
        sa_util.getLocalValue(oldOnsimEvent, "refreshHudValues", 1)(self)
    elseif ev.eventType == simdefs.EV_SHORT_WALLS then
        if not self._isShortWall then
            self:setShortWalls(true)
        end
    elseif ev.eventType == simdefs.EV_GRAFTER_DIALOG then
        return sa_util.getLocalValue(oldOnsimEvent, "showGrafterDialog", 1)(self, ev.eventData.itemDef,
            ev.eventData.userUnit, ev.eventData.drill)
    elseif ev.eventType == simdefs.EV_INSTALL_AUGMENT_DIALOG then
        return sa_util.getLocalValue(oldOnsimEvent, "showInstallAugmentDialog", 1)(self, ev.eventData.item,
            ev.eventData.unit)
    elseif ev.eventType == simdefs.EV_EXEC_DIALOG then
        return sa_util.getLocalValue(oldOnsimEvent, "showExecDialog", 1)(self, ev.eventData.headerTxt,
            ev.eventData.bodyTxt, ev.eventData.options,
            ev.eventData.corps, ev.eventData.names)
    elseif ev.eventType == simdefs.EV_ITEMS_PANEL then
        if ev.eventData then
            if ev.eventData.shopUnit then
                local shop_panel = include("hud/shop_panel")
                if ev.eventData.shopUnit:getTraits().storeType == "research" then
                    self:showItemsPanel(shop_panel.research(self, ev.eventData.shopperUnit, ev.eventData.shopUnit,
                        STRINGS.UI.SHOP_RESEARCH, nil, true))
                elseif ev.eventData.shopUnit:getTraits().storeType == "server" then
                    self:showItemsPanel(shop_panel.server(self, ev.eventData.shopperUnit, ev.eventData.shopUnit))
                elseif ev.eventData.shopUnit:getTraits().storeType == "miniserver" then
                    self:showItemsPanel(shop_panel.server(self, ev.eventData.shopperUnit, ev.eventData.shopUnit,
                        STRINGS.UI.SHOP_MINISERVER, true))
                else
                    self:showItemsPanel(shop_panel.shop(self, ev.eventData.shopperUnit, ev.eventData.shopUnit))
                end
            else
                local items_panel = include("hud/items_panel")
                if ev.eventData.targetUnit then
                    self:showItemsPanel(items_panel.loot(self, ev.eventData.unit, ev.eventData.targetUnit))
                else
                    self:showItemsPanel(items_panel.pickup(self, ev.eventData.unit, ev.eventData.x, ev.eventData.y))
                end
            end
        elseif self._itemsPanel then
            self._itemsPanel:refresh()
        end
    elseif ev.eventType == simdefs.EV_CMD_DIALOG then
        console_panel.panel(self, ev.eventData)
    elseif ev.eventType == simdefs.EV_AGENT_LIMIT then
        if not self._game.debugStep then
            modalDialog.show(STRINGS.UI.WARNING_MAX_AGENTS)
        end
    elseif ev.eventType == simdefs.EV_UNIT_FLY_TXT then
        if ev.eventData.unit and not ev.eventData.x and not ev.eventData.x then
            ev.eventData.x, ev.eventData.y = ev.eventData.unit:getLocation()
        end
        local wx, wy = self._game:cellToWorld(ev.eventData.x, ev.eventData.y)
        local color = ev.eventData.color
        local txt = ev.eventData.txt
        local target = ev.eventData.target
        local sound = ev.eventData.sound
        local soundDelay = ev.eventData.soundDelay
        local delay = ev.eventData.delay
        self:showFlyText(wx, wy, txt, color, target, sound, soundDelay, delay)
    elseif ev.eventType == simdefs.EV_FLY_IMAGE then
        if ev.eventData.unit and not ev.eventData.x and not ev.eventData.x then
            ev.eventData.x, ev.eventData.y = ev.eventData.unit:getLocation()
        end
        local wx, wy = self._game:cellToWorld(ev.eventData.x, ev.eventData.y)
        self:showFlyImage(wx, wy, "agent1", eventData.duration)
    elseif ev.eventType == simdefs.EV_HUD_SUBTRACT_CPU then
        self:subtractCPU(ev.eventData.delta)
    elseif ev.eventType == simdefs.EV_SKILL_LEVELED then
        if self._itemsPanel then
            self._itemsPanel:refresh()
        end
    elseif ev.eventType == simdefs.EV_SET_MUSIC_PARAM then
        MOAIFmodDesigner.setMusicProperty(ev.eventData.param, ev.eventData.value)
    elseif ev.eventType == simdefs.EV_UNIT_TAB then
        self._tabs:refreshUnitTab(ev.eventData)
    elseif ev.eventType == simdefs.EV_UNIT_OBSERVED then
        MOAIFmodDesigner.playSound("SpySociety/HUD/gameplay/observe_guard")
        self._tabs:refreshUnitTab(ev.eventData)

        local reveal_path = include("gameplay/viz_handlers/reveal_path")
        self._game.viz:addThread(reveal_path(self._game.boardRig, ev.eventData:getID(), ev))
    elseif ev.eventType == simdefs.EV_SHOW_MODAL then
        local result = modalDialog.show(ev.eventData.txt, ev.eventData.header)
    elseif ev.eventType == simdefs.EV_BLINK_REWIND then
        local widget = self._screen.binder.rewindBtn
        local boardrig = self._game.boardRig
        local blinkFunction = function()
            widget:blink(0.2, 2, 2)
            boardrig:wait(6 * cdefs.SECONDS)
            widget:blink()
        end
        self._screen.binder.rewindBtn:onUpdate(blinkFunction)
    end
end
