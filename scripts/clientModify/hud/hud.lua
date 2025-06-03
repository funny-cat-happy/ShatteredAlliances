local hud = include("hud/hud")
local util = include("client_util")
local mathutil = include("modules/mathutil")
local array = include("modules/array")
local color = include("modules/color")
local gameobj = include("modules/game")
local mui = include("mui/mui")
local mui_defs = include("mui/mui_defs")
local mui_tooltip = include("mui/mui_tooltip")
local modalDialog = include("states/state-modal-dialog")
local modal_thread = include("gameplay/modal_thread")
local agent_panel = include("hud/agent_panel")
local home_panel = include("hud/home_panel")
local pause_dialog = include("hud/pause_dialog")
local console_panel = include("hud/console_panel")
local hudtarget = include("hud/targeting")
local world_hud = include("hud/hud-inworld")
local agent_actions = include("hud/agent_actions")
local cdefs = include("client_defs")
local rig_util = include("gameplay/rig_util")
local resources = include("resources")
local level = include("sim/level")
local mui_util = include("mui/mui_util")
---@type simdefs
local simdefs = include("sim/simdefs")
local guiex = include("client/guiex")
local simquery = include("sim/simquery")
local serverdefs = include("modules/serverdefs")
local mui_group = include("mui/widgets/mui_group")
local simfactory = include("sim/simfactory")
local alarm_states = include("sim/alarm_states")

local lastFirewall = simdefs.SA.FIREWALL_UPPER_LIMIT
local STATE_NULL = 0
local STATE_ABILITY_TARGET = 4
local STATE_ITEM_TARGET = 5
local STATE_REPLAYING = 9

local function refreshINCFirewall(hud)
    ---@type INCFirewall
    local firewall = hud._game.simCore:getFirewall()
    local colourIndex = math.min(#cdefs.TRACKER_COLOURS, firewall.firewallStage + 1)
    local colour = cdefs.TRACKER_COLOURS[colourIndex]
    if firewall.firewallStatus == simdefs.SA.FIREWALL_STATUS.ACTIVATE then
        hud._screen.binder.alarm.binder.trackerTxt:setText(tostring(firewall.currentFirewall) ..
            '/' .. tostring(firewall.firewallLimit))
    else
        hud._screen.binder.alarm.binder.trackerTxt:setText(firewall.firewallStatus)
    end
    hud._screen.binder.alarm.binder.trackerTxt:setColor(colour.r, colour.g, colour.b, 1)
    hud._screen.binder.alarm.binder.alarmLvlTitle:setColor(colour.r, colour.g, colour.b, 1)
    hud._screen.binder.alarm.binder.alarmDisc:animateProgress(lastFirewall, firewall.currentFirewall, 1)
    local progressColorIndex = firewall.currentFirewall / firewall.firewallLimit
    hud._screen.binder.alarm.binder.alarmDisc:setProgressColor(1 - progressColorIndex, progressColorIndex, 0, 1)
    local tip = STRINGS.SA.UI.INC_FIREWALL_TOOLTIP
    hud._screen.binder.alarm:setTooltip(tip)
    SAUtil.getLocalValue(hud.onSimEvent, "refreshTrackerMusic")(hud, firewall.firewallStage)
    lastFirewall = firewall.currentFirewall
end

local function runINCFirewall(hud)
    hud._screen.binder.alarm.binder.alarmRing1:setAnim("idle")
    hud._screen.binder.alarm.binder.alarmRing1:setVisible(true)
    hud._screen.binder.alarm.binder.alarmRing1:getProp():setListener(KLEIAnim.EVENT_ANIM_END,
        function(anim, animname)
            if animname == "idle" then
                hud._screen.binder.alarm.binder.alarmRing1:setVisible(false)
            end
        end)
    refreshINCFirewall(hud)
end

local oldInit = hud.init
hud.init = function(self, game)
    self.STATE_NULL = STATE_NULL
    self.STATE_ABILITY_TARGET = STATE_ABILITY_TARGET
    self.STATE_ITEM_TARGET = STATE_ITEM_TARGET
    self.STATE_REPLAYING = STATE_REPLAYING

    self._game = game

    self._state = STATE_NULL
    self._stateData = nil
    self._isMainframe = false
    self._movePreview = nil
    self._oldPlayerMainframeState = nil
    self._abilityPreview = false

    self._losUnits = {}

    self._selection = include("hud/selection")(self)
    self._world_hud = world_hud(game)

    self._screen = mui.createScreen("hud.lua")
    self._screen.onTooltip = util.makeDelegate(nil, upvalueUtil.find(oldInit, "onHudTooltip"), self)

    self._agent_panel = agent_panel.agent_panel(self, self._screen)
    self._home_panel = home_panel.panel(self._screen, self)
    self._warnings = include("hud/hud_warnings")(self)
    self._tabs = include("hud/hud_tabs")(self)
    self._objectives = include("hud/hud_objectives")(self)

    do
        local mainframe_panel = include("hud/mainframe_panel")
        self._mainframe_panel = mainframe_panel.panel(self._screen, self)
    end
    do
        local incognita_mainframe_panel = SAInclude("clientModify/hud/incognita_program_panel")
        self._incognita_program_panel = incognita_mainframe_panel.panel(self._screen, self)
    end
    self._pause_dialog = pause_dialog(game)

    self._endTurnButton = self._screen.binder.endTurnBtn
    self._endTurnButton.onClick = util.makeDelegate(nil, upvalueUtil.find(oldInit, "onClickEndTurn"), self)

    self._uploadGroup = self._screen.binder.upload_bar

    self._screen.binder.menuBtn.onClick = util.makeDelegate(nil, upvalueUtil.find(oldInit, "onClickMenu"), self)

    self._screen.binder.topPnl.binder.watermark:setText(config.WATERMARK)
    self._statusLabel = self._screen.binder.statusTxt
    self._tooltipLabel = self._screen.binder.tooltipTxt
    self._tooltipBg = self._screen.binder.tooltipBg

    self._screen.binder.warning:setVisible(false)

    local w, h = game:getWorldSize()
    local scriptDeck = MOAIScriptDeck.new()
    scriptDeck:setRect(-w / 2, -h / 2, w / 2, h / 2)
    scriptDeck:setDrawCallback(
        function(index, xOff, yOff, xFlip, yFlip)
            self:onHudDraw()
        end)

    self.hudProp = MOAIProp2D.new()
    self.hudProp:setDeck(scriptDeck)
    self.hudProp:setPriority(1) -- above the board, below everything else
    game.layers["ceiling"]:insertProp(self.hudProp)

    self._screen.binder.alarm.binder.alarmRing1:setVisible(false)
    self._screen.binder.alarm.binder.alarmRing1:setColor(1, 0, 0, 1)

    -- Time attack enabled!
    if (game.params.difficultyOptions.timeAttack or 0) > 0 then
        self._screen:findWidget("timeProgress"):setVisible(true)
        self._screen:findWidget("totalTimer"):setVisible(true)
        self._screen:findWidget("timeAttackTxt"):setVisible(true)
    end

    self._screen.binder.topPnl.binder.btnToggleWalls.onClick = util.makeDelegate(nil,
        upvalueUtil.find(oldInit, "onClickWallsButton"), self)
    self._screen.binder.topPnl.binder.btnRotateLeft.onClick = util.makeDelegate(nil,
        upvalueUtil.find(oldInit, "onClickRotateCamera"), self, -1)
    self._screen.binder.topPnl.binder.btnRotateRight.onClick = util.makeDelegate(nil,
        upvalueUtil.find(oldInit, "onClickRotateCamera"), self, 1)
    self._screen.binder.rewindBtn.onClick = util.makeDelegate(nil, upvalueUtil.find(oldInit, "onClickRewindGame"), self)

    local camera = game:getCamera()

    mui.activateScreen(self._screen)
    self._screen:addEventHandler(self, mui_defs.EVENT_LostTopMost)

    self:refreshHud()

    local mission_panel = include("hud/mission_panel")
    self._missionPanel = mission_panel(self, self._screen)

    self._blinkyCPUCount = 30
    MOAIFmodDesigner.setAmbientReverb("office")
    self._screen.binder.alarm.binder.trackerAnimFive:setVisible(false)
    self._screen.binder.alarm.binder.alarmLvlTitle:setText(STRINGS.SA.HUD.ALARM_TITLE)
end

local oldHideMainframe = hud.hideMainframe
hud.hideMainframe = function(self)
    if self._isMainframe then
        self._incognita_program_panel:hide()
    end
    oldHideMainframe(self)
end

local oldShowMainframe = hud.showMainframe
hud.showMainframe = function(self)
    if not self._isMainframe then
        self._incognita_program_panel:show()
    end
    oldShowMainframe(self)
end

local oldRefreshHud = hud.refreshHud
hud.refreshHud = function(self)
    upvalueUtil.find(oldRefreshHud, "hideTitleSwipe")(self)
    self:showShotHaze(false)
    refreshINCFirewall(self)
    self:refreshObjectives()
    self:abortChoiceDialog()

    if self._isMainframe or self._state == STATE_REPLAYING then
        upvalueUtil.find(oldRefreshHud, "showMovement")(self, nil)
        upvalueUtil.find(oldRefreshHud, "clearMovementRange")(self)
        self._game.boardRig:selectUnit(nil)
    else
        local selectedUnit = self._selection:getSelectedUnit()
        upvalueUtil.find(oldRefreshHud, "previewMovement")(self, selectedUnit, self._tooltipX, self._tooltipY)
        self:showMovementRange(selectedUnit)
        self._game.boardRig:selectUnit(selectedUnit)
    end

    self._home_panel:refresh()
    self._mainframe_panel:refresh()
    self._incognita_program_panel:refresh()
    self._agent_panel:refreshPanel()
    self._tabs:refreshAllTabs()

    local sim = self._game.simCore
    local showPanels = (sim:getCurrentPlayer() == self._game:getLocalPlayer())

    self._endTurnButton:setVisible(showPanels and self:canShowElement("endTurnBtn"))
    self._screen.binder.homePanel:setVisible(showPanels)
    self._screen.binder.homePanel_top:setVisible(showPanels and self._state ~= STATE_REPLAYING)
    self._screen.binder.resourcePnl:setVisible(showPanels and self:canShowElement("resourcePnl"))
    self._screen.binder.statsPnl:setVisible(showPanels and self:canShowElement("statsPnl"))
    self._screen.binder.alarm:setVisible(self:canShowElement("alarm"))
    self._screen.binder.mainframePnl:setVisible(showPanels)
    self._screen.binder.topPnl:setVisible(self:canShowElement("topPnl"))

    self._screen.binder.mainframePnl.binder.daemonPanel:setVisible(self:canShowElement("daemonPanel"))

    self._screen.binder.agentPanel:setVisible(self:canShowElement("agentPanel"))

    local settings = savefiles.getSettings("settings")
    local user = savefiles.getCurrentGame()

    local canShowRewind = showPanels and (sim:getTags().rewindsLeft or 0) > 0 and not sim:getTags().isTutorial and
        self:canShowElement("rewindBtn")
    self._screen.binder.rewindBtn:setVisible(canShowRewind)
    local tip = mui_tooltip(STRINGS.UI.REWIND, tostring(STRINGS.UI.REWIND_TIP .. sim:getTags().rewindsLeft), nil)
    self._screen.binder.rewindBtn:setTooltip(tip)

    local daysTxt = 0
    local hoursTxt = 0

    local gameModeStr = util.toupper(serverdefs.GAME_MODE_STRINGS[self._game.params.campaignDifficulty])

    if self._game.params.campaignHours then
        daysTxt = math.floor(self._game.params.campaignHours / 24) + 1
        hoursTxt = self._game.params.campaignHours % 24
    end

    local turn = math.ceil((sim:getTurnCount() + 1) / 2)
    local corpData = serverdefs.CORP_DATA[self._game.params.world]
    local situationData = serverdefs.SITUATIONS[self._game.params.situationName]
    if corpData and situationData then
        local locationName = situationData.ui.locationName
        if sim:getTags().newLocationName then
            locationName = sim:getTags().newLocationName
        end
        local missionTxt = corpData.stringTable.SHORTNAME .. " " .. locationName
        self._screen.binder.statsPnl.binder.statsTxt:setText(string.format(STRINGS.UI.HUD_DAYS_TURN_ALARM, turn, daysTxt,
            gameModeStr, missionTxt))
    end

    if sim:getTags().rewindError then
        self:showRegenLevel()
    else
        self:hideRegenLevel()
    end

    if sim:getParams().missionEvents and sim:getParams().missionEvents.advancedAlarm then
        self._screen.binder.alarm.binder.advancedAlarm:setVisible(true)
    else
        self._screen.binder.alarm.binder.advancedAlarm:setVisible(false)
    end

    upvalueUtil.find(oldRefreshHud, "refreshHudValues")(self)

    -- As the HUD can change right beneath the mouse, want to force a tooltip refresh
    upvalueUtil.find(oldRefreshHud, "refreshTooltip")(self)
    self._screen.binder.alarm.binder.advancedAlarm:setVisible(true)
end

local oldOnsimEvent = hud.onSimEvent
hud.onSimEvent = function(self, ev)
    local sim = self._game.simCore
    ---@type simdefs
    local simdefs = sim.getDefs()

    if ev.eventType == simdefs.EV_HIDE_PROGRAM or ev.eventType == simdefs.EV_SLIDE_IN_PROGRAM then
        self._mainframe_panel:onSimEvent(ev)
        self._incognita_program_panel:onSimEvent(ev)
    end

    local mfMode = SAUtil.getLocalValue(oldOnsimEvent, "checkForMainframeEvent", 1)(simdefs, ev.eventType, ev.eventData)
    if mfMode == SAUtil.getLocalValue(oldOnsimEvent, "SHOW_MAINFRAME", 1) then
        if not self._isMainframe then
            self:showMainframe()
        end
        self._mainframe_panel:onSimEvent(ev)
        self._incognita_program_panel:onSimEvent(ev)
    elseif mfMode == SAUtil.getLocalValue(oldOnsimEvent, "HIDE_MAINFRAME", 1) and self._isMainframe then
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
            if currentPlayer:isNPC() then
                if currentPlayer:isAlly() then
                    txt = STRINGS.SA.HUD.ALLIANCE_ACTIVITY
                    color = { r = 84 / 255, g = 255 / 255, b = 159 / 255, a = 1 }
                    sound = cdefs.SOUND_HUD_GAME_ACTIVITY_CORP
                    corpTurn = true
                else
                    txt = STRINGS.UI.ENEMY_ACTIVITY
                    color = { r = 1, g = 0, b = 0, a = 1 }
                    sound = cdefs.SOUND_HUD_GAME_ACTIVITY_CORP
                    corpTurn = true
                end
            else
                txt = STRINGS.UI.AGENT_ACTIVITY
                color = { r = 140 / 255, g = 255 / 255, b = 255 / 255, a = 1 }
                sound = cdefs.SOUND_HUD_GAME_ACTIVITY_AGENT
            end

            local turn = math.ceil((sim:getTurnCount() + 1) / 3)

            SAUtil.getLocalValue(oldOnsimEvent, "startTitleSwipe", 1)(self, txt, color, sound, corpTurn, turn)
            rig_util.wait(30)
            SAUtil.getLocalValue(oldOnsimEvent, "stopTitleSwipe", 1)(self)
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
            SAUtil.getLocalValue(oldOnsimEvent, "stopTitleSwipe", 1)(self)
        end
    elseif ev.eventType == simdefs.SA.EV_INCFIREWALL_CHANGE then
        -- if ev.eventData.alarmOnly or (ev.eventData.tracker + ev.eventData.delta >= simdefs.TRACKER_MAXCOUNT) then
        --	self._game.post_process:colorCubeLerp( "data/images/cc/cc_default.png", "data/images/cc/screen_shot_out_test1_cc.png", 1.0, MOAITimer.PING_PONG, 0,0.5 )			
        --     if not self._playingAlarmLoop then
        --         MOAIFmodDesigner.playSound("SpySociety/HUD/gameplay/alarm_LP", "alarm")
        --         self._playingAlarmLoop = true
        --     end
        -- end
        SALog("firewall event")
        runINCFirewall(self)
    elseif ev.eventType == "used_radio" then
        local stage = self._game.simCore:getTrackerStage(ev.eventData.tracker)
        SAUtil.getLocalValue(oldOnsimEvent, "refreshTrackerMusic", 1)(self, stage)
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
        SAUtil.getLocalValue(oldOnsimEvent, "fadeToBlack", 1)(self)
    elseif ev.eventType == simdefs.EV_CREDITS_REFRESH then
        SAUtil.getLocalValue(oldOnsimEvent, "refreshHudValues", 1)(self)
    elseif ev.eventType == simdefs.EV_SHORT_WALLS then
        if not self._isShortWall then
            self:setShortWalls(true)
        end
    elseif ev.eventType == simdefs.EV_GRAFTER_DIALOG then
        return SAUtil.getLocalValue(oldOnsimEvent, "showGrafterDialog", 1)(self, ev.eventData.itemDef,
            ev.eventData.userUnit, ev.eventData.drill)
    elseif ev.eventType == simdefs.EV_INSTALL_AUGMENT_DIALOG then
        return SAUtil.getLocalValue(oldOnsimEvent, "showInstallAugmentDialog", 1)(self, ev.eventData.item,
            ev.eventData.unit)
    elseif ev.eventType == simdefs.EV_EXEC_DIALOG then
        return SAUtil.getLocalValue(oldOnsimEvent, "showExecDialog", 1)(self, ev.eventData.headerTxt,
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
