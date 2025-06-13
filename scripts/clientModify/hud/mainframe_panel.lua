local mainframePanel = include("hud/mainframe_panel").panel
local util = include("client_util")
local simdefs = include("sim/simdefs")


local oldMainFramePanel = mainframePanel.show
mainframePanel.show = function(self)
    oldMainFramePanel(self)
    self._panel.binder.VSChar:setText("VS")
    self._panel.binder.incognitaName:setText("INCOGNITA")
end

local function canExpose(panel, ability)
    local aiPlayer = panel._hud._game.simCore:getNPC()
    local pcPlayer = panel._hud._game.simCore:getPC()
    if aiPlayer:getDaemonHidden() then
        return false, STRINGS.SA.UI.REASON.DAEMON_FORCE_HIDDEN
    elseif pcPlayer:getCpus() < ability.exploreCost then
        return false, STRINGS.UI.REASON.NOT_ENOUGH_PWR
    elseif panel._hud._game.simCore:getCurrentPlayer() ~= pcPlayer then
        return false, STRINGS.SA.UI.REASON.EXPLORE_NOT_IN_TURN
    else
        return true
    end
end

local function onClickDaemonIcon(panel, ability)
    if ability.expose ~= nil and not ability.expose and canExpose(panel, ability) then
        local program = panel._hud._game.simCore:getNPC():findProgram(ability.id)
        ability.expose = true
        program.expose = true
        panel._hud:refreshHud()
    end
end

local oldAddMainframeProgram = mainframePanel.addMainframeProgram
local newSetDaemonPanel = function(self, widget, ability, player)
    local sim = self._hud._game.simCore
    local clr = { 140 / 255, 0, 0, 1 }
    if ability.reverseDaemon then
        clr = { 0 / 255, 164 / 255, 0 / 255, 1 }
    elseif ability.incognitaIntention then
        clr = { 244 / 255, 255 / 255, 120 / 255, 1 }
    end

    widget:setVisible(true)
    widget.binder.btn.onClick = util.makeDelegate(nil, onClickDaemonIcon, self, ability)
    widget.binder.btn:setTooltip(ability:onTooltip(self._hud, sim, player))
    widget.binder.btn:setColor(unpack(clr))
    widget.binder.icon:setImage(ability:getDef().icon)

    if ability.turns then
        widget.binder.firewallNum:setText(ability.turns)
    elseif ability.duration then
        widget.binder.firewallNum:setText(ability.duration)
    else
        widget.binder.firewallNum:setText("-")
    end
    if ability.expose ~= nil and not ability.expose then
        local _, reason = canExpose(self, ability)
        reason = reason and "/n" .. reason or ""
        widget.binder.firewallNum:setText("-")
        widget.binder.btn:setTooltip(util.sformat(STRINGS.SA.UI.HIDDEN_INTENTION_TOOLTIP, "2") .. reason)
        widget.binder.icon:setImage("gui/icons/programs_icons/icon-program_Halt.png")
    end
end
upvalueUtil.findAndReplace(oldAddMainframeProgram, "setDaemonPanel", newSetDaemonPanel)
