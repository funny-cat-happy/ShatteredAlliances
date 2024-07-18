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
local simdefs = include("sim/simdefs")
local guiex = include("client/guiex")
local simquery = include("sim/simquery")
local serverdefs = include("modules/serverdefs")
local mui_group = include("mui/widgets/mui_group")
local simfactory = include("sim/simfactory")
local alarm_states = include("sim/alarm_states")


local STATE_NULL = 0
local STATE_ABILITY_TARGET = 4
local STATE_ITEM_TARGET = 5
local STATE_REPLAYING = 9

local MAINFRAME_ZOOM = 0.2

local MAX_PATH = 15

local DEFAULT_MAINFRAME = 0
local SHOW_MAINFRAME = 1
local HIDE_MAINFRAME = 2

local function onClickWallsButton(hud, button, event)
    if not hud._game:isReplaying() then
        hud:setShortWalls(not hud._isShortWall)
    end
end

local function onClickRotateCamera(hud, orientationDelta)
    if not hud._game:isReplaying() then
        local camera = hud._game:getCamera()
        camera:rotateOrientation(camera:getOrientation() + orientationDelta)
    end
end

local function refreshTooltip(self)
    self._forceTooltipRefresh = true
end

local function onClickRewindGame(hud)
    hud._screen.binder.rewindBtn:blink()
    if not hud._game:isReplaying() then
        local viz_manager = include("gameplay/viz_manager")
        local shouldShow = viz_manager:checkShouldShow("modal-rewind-tutorial")
        if shouldShow then
            modalDialog.showRewindTutorialDialog()
        end

        local numRewinds = hud._game.simCore:getTags().rewindsLeft
        local result = modalDialog.showUseRewind(nil, util.sformat(STRINGS.UI.REWINDS_REMAINING, numRewinds))
        if result == modalDialog.OK then
            inputmgr.setInputEnabled(false)
            KLEIRenderScene:setDesaturation(rig_util.linearEase("desat_ease"))
            MOAIFmodDesigner.playSound("SpySociety/HUD/gameplay/HUD_undoAction")
            rig_util.wait(30)
            inputmgr.setInputEnabled(true)
            hud._game:rewindTurns()
            KLEIRenderScene:setDesaturation()
        end
    end
end

local function clearMovementRange(self)
    -- Hide movement range hilites.
    self._game.boardRig:clearMovementTiles()
    self._game.boardRig:clearCloakTiles()

    -- Clear movement cells
    self._revealCells = nil
    self._cloakCells = nil
end

local function hideTitleSwipe(hud)
    hud._screen.binder.swipe:setVisible(false)
end

local function showMovement(hud, unit, moveTable, pathCost)
    local sim = hud._game.simCore

    if hud._movePreview then
        hud._game.boardRig:unchainCells(hud._movePreview.hiliteID)
        local rig = hud._game.boardRig:getUnitRig(hud._movePreview.unitID)
        local prevUnit = sim:getUnit(hud._movePreview.unitID)
        if rig and not hud._abilityPreview then
            rig:previewMovement(0)
        end
        hud._movePreview = nil

        hud._home_panel:refreshAgent(prevUnit)
    end

    if moveTable then
        hud._movePreview = { unitID = unit:getID(), pathCost = pathCost }
        if unit:getMP() >= pathCost then
            hud._movePreview.hiliteID = hud._game.boardRig:chainCells(moveTable)
            local rig = hud._game.boardRig:getUnitRig(unit:getID())
            if rig then
                rig:previewMovement(pathCost)
                hud._abilityPreview = false
            end
        else
            hud._movePreview.hiliteID = hud._game.boardRig:chainCells(moveTable, { r = 0.2, g = 0.2, b = 0.2, a = 0.8 },
                nil, true)
        end

        hud._home_panel:refreshAgent(unit)
    end
end

local function previewMovement(hud, unit, cellx, celly)
    local sim = hud._game.simCore
    local simdefs = sim:getDefs()

    hud._bValidMovement = false

    if unit and sim:getCurrentPlayer() and unit:getPlayerOwner() == sim:getCurrentPlayer() and unit:hasTrait("mp") and unit:canAct() then
        local startcell = sim:getCell(unit:getLocation())
        local endcell = startcell
        if cellx and celly then
            endcell = sim:getCell(cellx, celly)
        end

        if startcell ~= endcell and endcell then
            local moveTable, pathCost = sim:getQuery().findPath(sim, unit, startcell, endcell,
                math.max(MAX_PATH, unit:getMP()))
            if moveTable then
                hud._bValidMovement = unit:getMP() >= pathCost
                table.insert(moveTable, 1, { x = startcell.x, y = startcell.y })
                showMovement(hud, unit, moveTable, pathCost)
                return
            end
        end
    end

    showMovement(hud, nil)
end

local function transition(hud, state, stateData)
    if state == hud._state then
        return
    end

    local sim = hud._game.simCore

    if hud._state == STATE_REPLAYING then
        hud._game:skip()
    end

    if hud._stateData and hud._stateData.hiliteID then
        hud._game.boardRig:unhiliteCells(hud._stateData.hiliteID)
    elseif hud._stateData and hud._stateData.ability then
        if hud._stateData.ability.endTargeting then
            hud._stateData.ability:endTargeting(hud)
        end
        if hud._stateData.targetHandler and hud._stateData.targetHandler.endTargeting then
            hud._stateData.targetHandler:endTargeting(hud)
        end
    end

    if state == STATE_ABILITY_TARGET and stateData and stateData.ability then
        if stateData.ability.startTargeting then
            stateData.ability:startTargeting(hud)
        end
        if stateData.targetHandler and stateData.targetHandler.startTargeting then
            stateData.targetHandler:startTargeting(agent_panel.buttonLocator(hud))
        end
    end

    hud._state = state
    hud._stateData = stateData


    if hud._state == STATE_NULL then
        hud._hideCubeCursor = false
        MOAISim.setCursor(cdefs.CURSOR_DEFAULT)

        if hud:getSelectedUnit() and not hud:getSelectedUnit()._isPlayer then
            hud:showMovementRange(hud:getSelectedUnit())
            previewMovement(hud, hud:getSelectedUnit(), hud._tooltipX, hud._tooltipY)
        end
    else
        if hud._state == STATE_ITEM_TARGET then
            hud._hideCubeCursor = true
            MOAISim.setCursor(cdefs.CURSOR_TARGET)
        end

        clearMovementRange(hud)
        showMovement(hud, nil)
    end

    hud:refreshHud()
end

local function onClickEndTurn(hud, button, event)
    transition(hud, STATE_NULL)

    if not hud._game.simCore:getTags().isTutorial then
        hud._missionPanel:stopTalkingHead()
    end
    hud._game:doEndTurn()
end

local function onClickMenu(hud)
    if hud._state ~= STATE_NULL then
        hud:transitionNull()
    else
        local result = hud._pause_dialog:show()
        if result == hud._pause_dialog.QUIT then
            MOAIFmodDesigner.stopMusic()
            hud._game:quitToMainMenu()
        elseif result == hud._pause_dialog.RETIRE then
            hud._game:doAction("resignMission")
        end
    end
end

local function onHudTooltip(self, screen, wx, wy)
    if self._world_hud._screen:getTooltip() ~= nil then
        return nil
    end

    wx, wy = screen:uiToWnd(wx, wy)
    local cellx, celly = self._game:wndToCell(wx, wy)
    local cell = cellx and celly and self._game.boardRig:getLastKnownCell(cellx, celly)

    local tooltipTxt = wx and wy and self._game:generateTooltip(wx, wy)
    if type(tooltipTxt) == "string" and #tooltipTxt > 0 then
        return tooltipTxt
    elseif not self:canShowElement("tooltips") then
        return nil
    elseif self._state == STATE_ABILITY_TARGET or self._state == STATE_ITEM_TARGET then
        local tt = ""
        if self._stateData.targetHandler and self._stateData.targetHandler.getTooltip then
            tt = self._stateData.targetHandler:getTooltip(cellx, celly) or ""
            if tt then
                tt = tt .. "\n"
            end
        end
        return tt .. STRINGS.UI.HUD_CANCEL_TT
    elseif not cell then
        -- No cell here, no tooltip.
        self._lastTooltipCell, self._lastTooltip = nil, nil
    elseif self._lastTooltipCell == cell and not self._forceTooltipRefresh then
        -- Same cell as last update, dont recreate things.  Shiz be expensive yo!
        return self._lastTooltip
    elseif self._isMainframe then
        self._lastTooltipCell = cell
        self._lastTooltip = self._mainframe_panel:onHudTooltip(screen, cell)
        return self._lastTooltip
    else
        local tooltip = util.tooltip(self._screen)
        local selectedUnit = self:getSelectedUnit()


        -- check to see if there are any interest points here
        local player = self._game:getForeignPlayer()
        local interest = nil
        for i, unit in ipairs(player:getUnits()) do
            local sim = unit:getSim()
            if unit:getBrain() and unit:getBrain():getInterest() and unit:getBrain():getInterest().x == cell.x and unit:getBrain():getInterest().y == cell.y and
                (sim:drawInterestPoints() or unit:getTraits().patrolObserved or unit:getBrain():getInterest().alwaysDraw) then
                if unit:isAlerted() then
                    interest = "hunting"
                else
                    if interest ~= "hunting" then
                        interest = "investigating"
                    end
                end
            end
        end

        -- only put the tip if needed and only 1, not one for each interest present.
        if interest then
            local section = tooltip:addSection()

            local line = cdefs.INTEREST_TOOLTIPS[interest].line
            local icon = cdefs.INTEREST_TOOLTIPS[interest].icon
            section:addAbility(STRINGS.UI.HUD_INTEREST_TT, line, icon)
        end

        local localPlayer = self._game:getLocalPlayer()
        local isWatched = localPlayer and simquery.isCellWatched(self._game.simCore, localPlayer, cellx, celly)

        if selectedUnit and simquery.isUnitWatched(selectedUnit) then
            tooltip:addSection():addWarning(STRINGS.UI.TRACKED, STRINGS.UI.TRACKED_TT,
                "gui/hud3/hud3_tracking_icon_sm.png", cdefs.COLOR_WATCHED_BOLD)
        end

        if isWatched == simdefs.CELL_WATCHED then
            tooltip:addSection():addWarning(STRINGS.UI.WATCHED, STRINGS.UI.WATCHED_TT, nil, cdefs.COLOR_WATCHED_BOLD)
        elseif isWatched == simdefs.CELL_NOTICED then
            tooltip:addSection():addWarning(STRINGS.UI.NOTICED, STRINGS.UI.NOTICED_TT, nil, cdefs.COLOR_NOTICED_BOLD)
        elseif isWatched == simdefs.CELL_HIDDEN then
            tooltip:addSection():addWarning(STRINGS.UI.HIDDEN, STRINGS.UI.HIDDEN_TT, nil)
        end

        if selectedUnit then
            if self._state == STATE_NULL and not selectedUnit._isPlayer then
                -- This cell has NO selectable units, and there is a unit selected.
                local x0, y0 = selectedUnit:getLocation()
                local canMove = (x0 ~= cell.x or y0 ~= cell.y) and self._revealCells ~= nil and
                    array.find(self._revealCells, cell) ~= nil
                if canMove then
                    local section = tooltip:addSection()
                    section:appendHeader(STRINGS.UI.HUD_RIGHT_CLICK, STRINGS.UI.HUD_MOVE)
                end
            end
        end

        if cell.units then
            local nextSelect = nil
            for i, cellUnit in ipairs(cell.units) do
                if cellUnit:getUnitData().onWorldTooltip then
                    local section = tooltip:addSection()
                    cellUnit:getUnitData().onWorldTooltip(section, cellUnit, self)

                    if selectedUnit ~= cellUnit and nextSelect == nil and self._selection:canSelect(cellUnit) then
                        section:appendHeader(STRINGS.UI.HUD_LEFT_CLICK, STRINGS.UI.HUD_SELECT)
                        nextSelect = cellUnit
                    end
                    if cellUnit:getTraits().mainframe_item then
                        local binding = util.getKeyBinding("mainframeMode")
                        if binding then
                            section:appendHeader(mui_util.getBindingName(binding), STRINGS.UI.HUD_MAINFRAME)
                        end
                    end
                end
            end
        end

        self._lastTooltipCell, self._lastTooltip = cell, tooltip
        self._forceTooltipRefresh = nil

        return tooltip
    end
end

local function showGrafterDialog(hud, itemDef, userUnit, drill)
    assert(hud._choice_dialog == nil)

    local screen = mui.createScreen("modal-grafter.lua")

    hud._choice_dialog = screen
    mui.activateScreen(screen)

    MOAIFmodDesigner.playSound("SpySociety/HUD/gameplay/popup")

    screen.binder.bodyTxt2:setText(string.format(STRINGS.UI.DIALOGS.AUGMENT_MACHINE_BODY_2, itemDef.name))

    screen.binder.pnl.binder.yourface.binder.portrait:bindBuild(userUnit:getUnitData().profile_build or
        userUnit:getUnitData().profile_anim)
    screen.binder.pnl.binder.yourface.binder.portrait:bindAnim(userUnit:getUnitData().profile_anim)

    local augments = userUnit:getAugments()
    local result = nil

    if itemDef then
        screen.binder.pnl.binder.drill:setVisible(false)
        screen.binder.pnl.binder.Item:setVisible(true)

        local item = simfactory.createUnit(itemDef, nil)
        local widget = screen:findWidget("Item")
        widget.binder.img:setImage(item:getUnitData().profile_icon)

        local tooltip = util.tooltip(screen)
        local section = tooltip:addSection()
        item:getUnitData().onTooltip(section, item)
        widget.binder.img:setTooltip(tooltip)
        widget.binder.itemName:setText(item:getName())
    end

    if drill then
        screen.binder.pnl.binder.headerTxt:setText(STRINGS.UI.AUGMENT_DRILL_MODAL_TITLE)

        screen.binder.pnl.binder.Item:setVisible(false)
        screen.binder.pnl.binder.subheader2:setText(STRINGS.UI.AUGMENT_DRILL_MODAL_ACTION)
        screen.binder.pnl.binder.functionTxt2:setText(STRINGS.UI.AUGMENT_DRILL_MODAL_HEADER)
        screen.binder.pnl.binder.bodyTxt2:setText(STRINGS.UI.AUGMENT_DRILL_MODAL_BODY)
        screen:findWidget("installAugmentBtn"):setVisible(false)
        screen.binder.pnl.binder.drill:setVisible(true)

        for i, widget in screen.binder.drill.binder:forEach("augment") do
            if augments[i] then
                widget.binder.img:setVisible(true)
                widget.binder.btn:setVisible(true)
                widget.binder.btn.onClick = function() result = 3 + i end
                local item = augments[i]
                widget.binder.btn:setImage(item:getUnitData().profile_icon)
                local tooltip = util.tooltip(screen)
                local section = tooltip:addSection()
                item:getUnitData().onTooltip(section, item)
                widget.binder.img:setTooltip(tooltip)
                --  widget.binder.img:setColor(1,1,1)
            else
                widget.binder.img:setVisible(false)
                widget.binder.btn:setVisible(false)
            end
        end
    else
        screen.binder.pnl.binder.drill:setVisible(false)
    end


    local maxed = true
    for i, widget in screen.binder:forEach("augment") do
        if augments[i] then
            widget.binder.item:setVisible(true)
            widget.binder.slot:setVisible(false)
            widget.binder.empty:setVisible(false)
            widget.binder.installPlus:setVisible(false)
            local item = augments[i]
            widget.binder.item:setImage(item:getUnitData().profile_icon)
            local tooltip = util.tooltip(screen)
            local section = tooltip:addSection()
            item:getUnitData().onTooltip(section, item)
            widget.binder.item:setTooltip(tooltip)
            widget.binder.item:setColor(1, 1, 1)
        elseif i <= userUnit:getTraits().augmentMaxSize then
            widget.binder.slot:setVisible(true)
            widget.binder.item:setVisible(false)
            widget.binder.empty:setVisible(false)
            widget.binder.installPlus:setVisible(false)
            widget.binder.slot:setTooltip(STRINGS.UI.AUGMENT_GRAFTER_EMPTY_SOCKET)
            widget.binder.slot:setColor(1, 1, 1)
        elseif i == userUnit:getTraits().augmentMaxSize + 1 then
            widget.binder.item:setVisible(false)
            widget.binder.slot:setVisible(false)
            widget.binder.empty:setVisible(false)
            widget.binder.installPlus:setVisible(true)
            widget.binder.installPlus:setTooltip(STRINGS.UI.AUGMENT_GRAFTER_NEW_SOCKET)
            maxed = false
        elseif i <= simdefs.DEFAULT_AUGMENT_CAPACITY then
            widget.binder.item:setVisible(false)
            widget.binder.slot:setVisible(false)
            widget.binder.empty:setVisible(true)
            widget.binder.installPlus:setVisible(false)
            widget.binder.empty:setTooltip(STRINGS.UI.AUGMENT_GRAFTER_FUTURE_SOCKET)
            widget.binder.empty:setColor(0.3, 0.3, 0.3, 0.6)
        else
            widget.binder.installPlus:setVisible(false)
            widget.binder.item:setVisible(false)
            widget.binder.slot:setVisible(false)
            widget.binder.empty:setVisible(false)
        end
    end

    if maxed then
        screen.binder.bodyTxt1:setText(STRINGS.UI.AUGMENT_GRAFTER_MAX_SOCKETS)
    end


    screen:findWidget("cancelBtn").onClick = function() result = 1 end
    if maxed then
        screen:findWidget("installSocketBtn"):setDisabled(true)
    else
        screen:findWidget("installSocketBtn").onClick = function() result = 2 end
    end
    screen:findWidget("installAugmentBtn").onClick = function() result = 3 end
    screen:findWidget("installAugmentBtn"):setText(string.format(STRINGS.UI.DIALOGS.AUGMENT_MACHINE_3,
        util.toupper(itemDef.name)))

    if #augments >= userUnit:getTraits().augmentMaxSize then
        screen:findWidget("installAugmentBtn"):setDisabled(true)
        screen:findWidget("installAugmentBtn"):setTooltip(STRINGS.UI.REASON.NO_FREE_SOCKETS)
    end

    -- We are running in the vizThread coroutine.  Yield until a response is chosen by the UI.
    -- Note that the click handler will be triggered by the main coroutine, but we use a closure
    -- to inform us what the chosen result is.
    while result == nil do
        coroutine.yield()
        result = result or modal_thread.checkAutoClose(hud, hud._game)
    end

    mui.deactivateScreen(screen)
    hud._choice_dialog = nil

    hud._game.simCore:setChoice(result)

    return result
end

local function showExecDialog(hud, headerTxt, bodyTxt, options, corps, names)
    assert(hud._choice_dialog == nil)

    local screen

    screen = mui.createScreen("modal-execterminals.lua")

    hud._choice_dialog = screen
    mui.activateScreen(screen)

    MOAIFmodDesigner.playSound("SpySociety/HUD/gameplay/popup")

    screen.binder.targetTitle:setText(headerTxt)
    screen.binder.objTxt:setText(bodyTxt)

    --selected agent
    local unit = hud:getSelectedUnit()
    if unit ~= nil and unit.getUnitData then
        screen.binder.pnl.binder.portrait:bindBuild(unit:getUnitData().profile_build or unit:getUnitData().profile_anim)
        screen.binder.pnl.binder.portrait:bindAnim(unit:getUnitData().profile_anim)
        screen.binder.pnl.binder.portrait:setVisible(true)
    else
        screen.binder.pnl.binder.yourface:setVisible(false)
    end

    for i, location in screen.binder.pnl.binder:forEach("location") do
        local corp = corps[i]
        local name = names[i]
        local nameIcon = serverdefs.SITUATIONS[name].ui.icon
        local corpIcon = serverdefs.CORP_DATA[corp].imgs.logoLarge
        location.binder.corpLogo:setImage(corpIcon)
        location.binder.locationImg:setImage(nameIcon)
    end

    -- Fill out the dialog options.
    local result = nil
    local x = 1
    for i, location in screen.binder.pnl.binder:forEach("location") do
        local btn = location.binder.btn
        if options[i] == nil then
            btn:setVisible(false)
        else
            btn:setVisible(true)
            btn:setText("<c:8CFFFF>" .. options[i] .. "</>")
            btn.onClick = util.makeDelegate(nil, function() result = i end)

            local txt = string.format("<ttheader>%s</>\n%s", util.toupper(options[i]),
                serverdefs.SITUATIONS[names[i]].ui.moreInfo)
            btn:setTooltip(txt)
            x = x + 1
        end
    end

    -- We are running in the vizThread coroutine.  Yield until a response is chosen by the UI.
    -- Note that the click handler will be triggered by the main coroutine, but we use a closure
    -- to inform us what the chosen result is.
    while result == nil do
        coroutine.yield()
        result = result or modal_thread.checkAutoClose(hud, hud._game)
    end

    mui.deactivateScreen(screen)
    hud._choice_dialog = nil

    hud._game.simCore:setChoice(result)

    return result
end

local function showInstallAugmentDialog(hud, item, unit)
    assert(hud._choice_dialog == nil)
    assert(item)
    assert(unit)

    local screen

    screen = mui.createScreen("modal-install-augment.lua")

    hud._choice_dialog = screen
    mui.activateScreen(screen)

    MOAIFmodDesigner.playSound("SpySociety/HUD/gameplay/popup")

    --selected agent
    if unit ~= nil and unit.getUnitData then
        screen.binder.pnl.binder.yourface.binder.portrait:bindBuild(unit:getUnitData().profile_build or
            unit:getUnitData().profile_anim)
        screen.binder.pnl.binder.yourface.binder.portrait:bindAnim(unit:getUnitData().profile_anim)
        screen.binder.pnl.binder.portrait:setVisible(true)
    else
        screen.binder.pnl.binder.yourface:setVisible(false)
    end

    if item then
        screen.binder.pnl.binder.Item:setVisible(true)

        local widget = screen:findWidget("Item")
        widget.binder.img:setImage(item:getUnitData().profile_icon)

        local tooltip = util.tooltip(screen)
        local section = tooltip:addSection()
        item:getUnitData().onTooltip(section, item)
        widget.binder.img:setTooltip(tooltip)
        widget.binder.itemName:setText(item:getName())
    end

    -- Fill out the dialog options.
    local result = nil


    screen:findWidget("installAugmentBtn").onClick = util.makeDelegate(nil, function() result = 2 end)
    screen:findWidget("leaveInInventoryBtn").onClick = util.makeDelegate(nil, function() result = 1 end)

    -- We are running in the vizThread coroutine.  Yield until a response is chosen by the UI.
    -- Note that the click handler will be triggered by the main coroutine, but we use a closure
    -- to inform us what the chosen result is.
    while result == nil do
        coroutine.yield()
        result = result or modal_thread.checkAutoClose(hud, hud._game)
    end

    mui.deactivateScreen(screen)
    hud._choice_dialog = nil

    hud._game.simCore:setChoice(result)

    return result
end

local function checkForMainframeEvent(simdefs, eventType, eventData)
    if eventType == simdefs.EV_UNIT_MAINFRAME_UPDATE
        or eventType == simdefs.EV_UNIT_UPDATE_ICE
        or eventType == simdefs.EV_MAINFRAME_PARASITE
        or eventType == simdefs.EV_MAINFRAME_MOVE_DAEMON
        or eventType == simdefs.EV_KILL_DAEMON
        or eventType == simdefs.EV_SCRIPT_ENTER_MAINFRAME then
        -- These events require mainframe mode.
        return SHOW_MAINFRAME
    elseif eventType == simdefs.EV_UNIT_START_WALKING or eventType == simdefs.EV_UNIT_START_SHOOTING or eventType == simdefs.EV_SCRIPT_EXIT_MAINFRAME or eventType == simdefs.EV_UNIT_APPEARED then
        -- These events require normal mode.
        return HIDE_MAINFRAME
    end

    -- Any eithe event don't care about the mainframe mode.
    return DEFAULT_MAINFRAME
end

local function refreshHudValues(self)
    local pcPlayer = self._game.simCore:getPC()
    if pcPlayer then
        self._screen.binder.resourcePnl.binder.cpuNum:setText(util.sformat(STRINGS.FORMATS.PWR,
            string.format("%d/%d", pcPlayer:getCpus(), pcPlayer:getMaxCpus())))
        self._screen.binder.resourcePnl.binder.credits:setText(util.sformat(STRINGS.FORMATS.CREDITS,
            tostring(pcPlayer:getCredits())))
    else
        self._screen.binder.resourcePnl.binder.cpuNum:setText("-")
        self._screen.binder.resourcePnl.binder.credits:setText("???")
    end
end

local function fadeToBlack(self)
    local screen = mui.createScreen("screen-overlay.lua")
    mui.activateScreen(screen)

    self._blackOverlay = screen

    local overlay = screen:findWidget("overlay")
    overlay:setVisible(true)

    local fade_time = 2
    local t = 0
    while t < fade_time do
        t = t + 1 / cdefs.SECONDS
        local percent = math.min(t / fade_time, 1)
        overlay:setColor(0, 0, 0, percent)
        coroutine.yield()
    end
end
local function startTitleSwipe(hud, swipeText, color, sound, showCorpTurn, turn)
    MOAIFmodDesigner.playSound(sound)
    hud._screen.binder.swipe:setVisible(true)
    hud._screen.binder.swipe.binder.anim:setColor(color.r, color.g, color.b, color.a)
    hud._screen.binder.swipe.binder.anim:setAnim("pre")
    MOAIFmodDesigner.playSound("SpySociety/HUD/gameplay/turnswitch_in")

    hud._screen.binder.swipe.binder.txt:spoolText(string.format(swipeText))
    hud._screen.binder.swipe.binder.txt:setColor(color.r, color.g, color.b, color.a)

    hud._screen.binder.swipe.binder.turnTxt:spoolText(string.format(STRINGS.UI.TURN, turn), 20)
    hud._screen.binder.swipe.binder.turnTxt:setColor(color.r, color.g, color.b, color.a)

    local stop = false
    hud._screen.binder.swipe.binder.anim:getProp():setPlayMode(KLEIAnim.LOOP)
    hud._screen.binder.swipe.binder.anim:getProp():setListener(KLEIAnim.EVENT_ANIM_END,
        function(anim, animname)
            if animname == "pre" then
                hud._screen.binder.swipe.binder.anim:setAnim("loop")
                stop = true
            end
        end)

    util.fullGC() -- Convenient time to do a full GC. ;}			

    while stop == false do
        coroutine.yield()
    end
end

local function stopTitleSwipe(hud)
    MOAIFmodDesigner.playSound("SpySociety/HUD/gameplay/turnswitch_out")
    rig_util.waitForAnim(hud._screen.binder.swipe.binder.anim:getProp(), "pst")
    hud._screen.binder.swipe:setVisible(false)
end

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

local function refreshTrackerAdvance(hud, trackerNumber)
    local stage = hud._game.simCore:getTrackerStage(math.min(simdefs.TRACKER_MAXCOUNT, trackerNumber))
    -- local animWidget = hud._screen.binder.alarm.binder.trackerAnimFive
    local colourIndex = math.min(#cdefs.TRACKER_COLOURS, stage + 1)
    local colour = cdefs.TRACKER_COLOURS[colourIndex]

    -- Show the tracker number
    MOAILogMgr.log("stage:" .. stage)
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

    -- Refresh the alarm ring.
    -- animWidget:setColor(colour:unpack())
    -- if trackerNumber >= simdefs.TRACKER_MAXCOUNT then
    --     animWidget:setAnim("idle_5")
    -- else
    --     animWidget:setAnim("idle_" .. trackerNumber % simdefs.TRACKER_INCREMENT)
    -- end

    refreshTrackerMusic(hud, stage)
end

local function runTrackerAdvance(hud, txt, delta, tracker, subtxt)
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

    -- local animWidget = hud._screen.binder.alarm.binder.trackerAnimFive
    -- for i = 1, delta do
    --     MOAIFmodDesigner.playSound(cdefs.SOUND_HUD_ADVANCE_TRACKER)

    --     local stage = hud._game.simCore:getTrackerStage(math.min(simdefs.TRACKER_MAXCOUNT, tracker + i))
    --     local colourIndex = math.min(#cdefs.TRACKER_COLOURS, stage + 1)
    --     local colour = cdefs.TRACKER_COLOURS[colourIndex]
    --     animWidget:setColor(colour:unpack())
    --     local fillNum = (tracker + i) % simdefs.TRACKER_INCREMENT
    --     if fillNum == 0 then
    --         rig_util.waitForAnim(animWidget:getProp(), "fill_5")
    --     else
    --         rig_util.waitForAnim(animWidget:getProp(), "fill_" .. fillNum)
    --     end
    -- end

    refreshTrackerAdvance(hud, tracker + delta)

    rig_util.wait(30)
    MOAIFmodDesigner.playSound(cdefs.SOUND_HUD_ADVANCE_TRACKER_NUMBER)
end

local oldCreateHud = hud.createHud
hud.createHud = function(...)
    local hudObject = oldCreateHud(...)
    hudObject.init = function(self, game)
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
        MOAILogMgr.log("create new hud")
        self._screen = mui.createScreen("new_hud.lua")
        self._screen.onTooltip = util.makeDelegate(nil, onHudTooltip, self)

        self._agent_panel = agent_panel.agent_panel(self, self._screen)
        self._home_panel = home_panel.panel(self._screen, self)
        self._warnings = include("hud/hud_warnings")(self)
        self._tabs = include("hud/hud_tabs")(self)
        self._objectives = include("hud/hud_objectives")(self)

        do
            local mainframe_panel = include("hud/mainframe_panel")
            self._mainframe_panel = mainframe_panel.panel(self._screen, self)
        end

        self._pause_dialog = pause_dialog(game)

        self._endTurnButton = self._screen.binder.endTurnBtn
        self._endTurnButton.onClick = util.makeDelegate(nil, onClickEndTurn, self)

        self._uploadGroup = self._screen.binder.upload_bar

        self._screen.binder.menuBtn.onClick = util.makeDelegate(nil, onClickMenu, self)

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
        self._screen.binder.alarm.binder.advancedAlarm:setVisible(true)

        -- Time attack enabled!
        if (game.params.difficultyOptions.timeAttack or 0) > 0 then
            self._screen:findWidget("timeProgress"):setVisible(true)
            self._screen:findWidget("totalTimer"):setVisible(true)
            self._screen:findWidget("timeAttackTxt"):setVisible(true)
        end

        self._screen.binder.topPnl.binder.btnToggleWalls.onClick = util.makeDelegate(nil, onClickWallsButton, self)
        self._screen.binder.topPnl.binder.btnRotateLeft.onClick = util.makeDelegate(nil, onClickRotateCamera, self, -1)
        self._screen.binder.topPnl.binder.btnRotateRight.onClick = util.makeDelegate(nil, onClickRotateCamera, self, 1)
        self._screen.binder.rewindBtn.onClick = util.makeDelegate(nil, onClickRewindGame, self)

        local camera = game:getCamera()

        mui.activateScreen(self._screen)
        self._screen:addEventHandler(self, mui_defs.EVENT_LostTopMost)

        self:refreshHud()

        local mission_panel = include("hud/mission_panel")
        self._missionPanel = mission_panel(self, self._screen)

        self._blinkyCPUCount = 30
        MOAIFmodDesigner.setAmbientReverb("office")
    end
    hudObject.onSimEvent = function(self, ev)
        local sim = self._game.simCore
        local simdefs = sim.getDefs()

        if ev.eventType == simdefs.EV_HIDE_PROGRAM or ev.eventType == simdefs.EV_SLIDE_IN_PROGRAM then
            self._mainframe_panel:onSimEvent(ev)
        end

        local mfMode = checkForMainframeEvent(simdefs, ev.eventType, ev.eventData)
        if mfMode == SHOW_MAINFRAME then
            if not self._isMainframe then
                self:showMainframe()
            end
            self._mainframe_panel:onSimEvent(ev)
        elseif mfMode == HIDE_MAINFRAME and self._isMainframe then
            self:hideMainframe()
        end

        if ev.eventType == simdefs.EV_HUD_REFRESH then
            self:refreshHud()
        elseif ev.eventType == simdefs.EV_UNIT_DRAG_BODY or ev.eventType == simdefs.EV_UNIT_DROP_BODY then
            self._home_panel:refreshAgent(ev.eventData.unit)
        elseif ev.eventType == simdefs.EV_TURN_START then
            --self:refreshHud()
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
                    txt = STRINGS.UI.ENEMY_ACTIVITY
                    color = { r = 1, g = 0, b = 0, a = 1 }
                    sound = cdefs.SOUND_HUD_GAME_ACTIVITY_CORP
                    corpTurn = true
                else
                    txt = STRINGS.UI.AGENT_ACTIVITY
                    color = { r = 140 / 255, g = 255 / 255, b = 255 / 255, a = 1 }
                    sound = cdefs.SOUND_HUD_GAME_ACTIVITY_AGENT
                end

                local turn = math.ceil((sim:getTurnCount() + 1) / 2)

                startTitleSwipe(self, txt, color, sound, corpTurn, turn)
                rig_util.wait(30)
                stopTitleSwipe(self)
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
                stopTitleSwipe(self)
            end
        elseif ev.eventType == simdefs.EV_ADVANCE_TRACKER then
            if ev.eventData.alarmOnly or (ev.eventData.tracker + ev.eventData.delta >= simdefs.TRACKER_MAXCOUNT) then
                --    self._game.post_process:colorCubeLerp( "data/images/cc/cc_default.png", "data/images/cc/screen_shot_out_test1_cc.png", 1.0, MOAITimer.PING_PONG, 0,0.5 )
                if not self._playingAlarmLoop then
                    MOAIFmodDesigner.playSound("SpySociety/HUD/gameplay/alarm_LP", "alarm")
                    self._playingAlarmLoop = true
                end
            end
            if not ev.eventData.alarmOnly then
                runTrackerAdvance(self, ev.eventData.txt, ev.eventData.delta, ev.eventData.tracker, ev.eventData.subtxt)
            end
        elseif ev.eventType == "used_radio" then
            local stage = self._game.simCore:getTrackerStage(ev.eventData.tracker)
            refreshTrackerMusic(self, stage)
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
            fadeToBlack(self)
        elseif ev.eventType == simdefs.EV_CREDITS_REFRESH then
            refreshHudValues(self)
        elseif ev.eventType == simdefs.EV_SHORT_WALLS then
            if not self._isShortWall then
                self:setShortWalls(true)
            end
        elseif ev.eventType == simdefs.EV_GRAFTER_DIALOG then
            return showGrafterDialog(self, ev.eventData.itemDef, ev.eventData.userUnit, ev.eventData.drill)
        elseif ev.eventType == simdefs.EV_INSTALL_AUGMENT_DIALOG then
            return showInstallAugmentDialog(self, ev.eventData.item, ev.eventData.unit)
        elseif ev.eventType == simdefs.EV_EXEC_DIALOG then
            return showExecDialog(self, ev.eventData.headerTxt, ev.eventData.bodyTxt, ev.eventData.options,
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
    hudObject.refreshHud = function(self)
        hideTitleSwipe(self)
        self:showShotHaze(false)
        refreshTrackerAdvance(self, self._game.simCore:getTracker())
        self:refreshObjectives()
        self:abortChoiceDialog()

        if self._isMainframe or self._state == STATE_REPLAYING then
            showMovement(self, nil)
            clearMovementRange(self)
            self._game.boardRig:selectUnit(nil)
        else
            local selectedUnit = self._selection:getSelectedUnit()
            previewMovement(self, selectedUnit, self._tooltipX, self._tooltipY)
            self:showMovementRange(selectedUnit)
            self._game.boardRig:selectUnit(selectedUnit)
        end

        self._home_panel:refresh()
        self._mainframe_panel:refresh()
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
            self._screen.binder.statsPnl.binder.statsTxt:setText(string.format(STRINGS.UI.HUD_DAYS_TURN_ALARM, turn,
                daysTxt, gameModeStr, missionTxt))
        end

        if sim:getTags().rewindError then
            self:showRegenLevel()
        else
            self:hideRegenLevel()
        end

        -- if sim:getParams().missionEvents and sim:getParams().missionEvents.advancedAlarm then
        --     self._screen.binder.alarm.binder.advancedAlarm:setVisible(true)
        -- else
        --     self._screen.binder.alarm.binder.advancedAlarm:setVisible(false)
        -- end

        refreshHudValues(self)

        -- As the HUD can change right beneath the mouse, want to force a tooltip refresh
        refreshTooltip(self)
    end
    return hudObject
end
