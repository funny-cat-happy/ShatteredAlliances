local mainframePanel = include("hud/mainframe_panel").panel
local util = include("client_util")

local oldMainFramePanel = mainframePanel.show
mainframePanel.show = function(self)
    oldMainFramePanel(self)
    self._panel.binder.VSChar:setText("VS")
    self._panel.binder.incognitaName:setText("INCOGNITA")
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
    -- widget.binder.btn.onClick = util.makeDelegate(nil, upvalueUtil.find(oldAddMainframeProgram, "onClickDaemonIcon"),
    --     self)
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
end
upvalueUtil.findAndReplace(oldAddMainframeProgram, "setDaemonPanel", newSetDaemonPanel)
