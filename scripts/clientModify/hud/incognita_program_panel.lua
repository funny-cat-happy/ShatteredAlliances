local util = include("client_util")
local mathutil = include("modules/mathutil")
local cdefs = include("client_defs")
local array = include("modules/array")
local mui_defs = include("mui/mui_defs")
local world_hud = include("hud/hud-inworld")
local hudtarget = include("hud/targeting")
local rig_util = include("gameplay/rig_util")
local level = include("sim/level")
local mainframe = include("sim/mainframe")
local simquery = include("sim/simquery")
local simdefs = include("sim/simdefs")



local MODE_HIDDEN = 0
local MODE_VISIBLE = 1

local function updateButtonFromProgram(self, widget, ability, abilityOwner)
    local sim = self._hud._game.simCore
    local enabled, reason = ability:canUseAbility(sim)
    widget:setVisible(true)
    widget.binder.powerTxt:setVisible(true)
    widget.binder.turnsTxt:setVisible(true)
    widget.binder.powerTxt:setText(ability:getDef():getCpuCost() or 0)
    if ability.passive then
        widget.binder.powerTxt:setText("-")
        widget.binder.turnsTxt:setVisible(false)
    end
    widget.binder.turnsTxt:setText(STRINGS.PROGRAMS.PWR)

    widget.binder.hazzardBG:setVisible(false)
    if ability.cooldown then
        if ability.cooldown > 0 then
            widget.binder.powerTxt:setColor(140 / 255, 1, 1, 1)
            widget.binder.turnsTxt:setColor(140 / 255, 1, 1, 1)

            widget.binder.turnsTxt:setVisible(true)
            widget.binder.turnsTxt:setText(STRINGS.PROGRAMS.TURNS)
            widget.binder.powerTxt:setVisible(true)
            widget.binder.powerTxt:setText(ability.cooldown)
            widget.binder.hazzardBG:setVisible(true)
        end
    end

    local txt = ability:getDef().huddesc
    if ability:getDef().maxCooldown then
        txt = txt .. "\n" .. util.sformat(STRINGS.PROGRAMS.COOLDOWN, ability:getDef().maxCooldown)
    end
    widget.binder.descTxt:setText(txt)

    if ability:getDef():getCpuCost() then
        for i, widget in widget.binder:forEach("power") do
            if i <= ability:getDef():getCpuCost() then
                widget:setColor(72 / 255, 128 / 255, 128 / 255)
            else
                widget:setColor(17 / 255, 29 / 255, 29 / 255)
            end
        end
    else
        for i, widget in widget.binder:forEach("power") do
            widget:setColor(17 / 255, 29 / 255, 29 / 255)
        end
    end

    widget:setAlias(ability:getID())
    widget.binder.btn:setTooltip(function() return ability:onTooltip(self._hud._screen, sim, abilityOwner) end)
    widget.binder.btn:setDisabled(false)
    self:programWidgetSetColor(widget, ability)

    if ability:getDef().icon then
        widget.binder.img:setVisible(true)
        widget.binder.img:setImage(ability:getDef().icon)
    end

    if not ability.expose then
        widget.binder.powerTxt:setText("-")
        widget.binder.turnsTxt:setVisible(false)
        widget.binder.img:setVisible(true)
        widget.binder.descTxt:setText("unknown")
        widget.binder.img:setImage("gui/icons/programs_icons/icon-program_Halt.png")
        widget.binder.btn:setTooltip(STRINGS.SA.UI.HIDDEN_PROGRAM_TOOLTIP)
    end
end

local function updateProgramButtons(self, widgetName, player, primeRefresh)
    local panel = self._panel
    local MAX_EMPTY = 5

    for i, widget in panel.binder.incognitaProgramsPanel.binder:forEach("program") do
        if i > MAX_EMPTY then
            panel.binder.incognitaProgramsPanel.binder["empty" .. i]:setVisible(false)
        else
            panel.binder.incognitaProgramsPanel.binder["empty" .. i]:setVisible(true)
            if primeRefresh then
                panel.binder.incognitaProgramsPanel.binder["empty" .. i]:createTransition("activate_above")
            end
        end
        widget:setVisible(false)
    end
    for i, ability in ipairs(player:getPrograms()) do
        local widget = panel.binder.incognitaProgramsPanel.binder["program" .. i]
        updateButtonFromProgram(self, widget, ability, player)
        widget:setVisible(true)
        if primeRefresh then
            widget:createTransition("activate_above")
        end
    end
end

local panel = class()

function panel:init(screen, hud)
    self._screen = screen
    self._hud = hud
    self._panel = screen.binder.mainframePnl
    self._mode = MODE_HIDDEN
    self._installing = {}
    self._iceBreaks = {}
    self._hiddenProgram = -1
    self:hide()
end

function panel:hide()
    self._mode = MODE_HIDDEN
    self:refresh()
end

function panel:show()
    local localPlayer = self._hud._game:getLocalPlayer()
    if localPlayer == nil or self._hud._game.simCore:isGameOver() then
        return
    end
    self._mode = MODE_VISIBLE
    self:refresh(true)
end

function panel:refresh(primeRefresh)
    if self._mode == MODE_HIDDEN then
        self._panel.binder.incognitaProgramsPanel:setVisible(false)
        return
    end
    self._panel.binder.incognitaProgramsPanel:setVisible(true)
    updateProgramButtons(self, "program", self._hud._game.simCore:getNPC(), primeRefresh)
    local aiPlayer = self._hud._game.simCore:getNPC()
    self._panel.binder.cpuNum:setText(util.sformat(STRINGS.FORMATS.PWR,
        string.format("%d/%d", aiPlayer:getCpus(), aiPlayer:getMaxCpus())))
end

function panel:onSimEvent(ev)

end

function panel:programWidgetSetColor(widget, ability, colorOb)
    local sim = self._hud._game.simCore
    local enabled, reason = ability:canUseAbility(sim, sim:getCurrentPlayer())
    local colorImg = util.color.WHITE
    local activeColor = colorOb

    if not colorOb then
        if enabled then
            if ability.color then
                colorOb, activeColor, colorImg = ability.color, util.color.MID_BLUE, ability.color
            else
                colorOb, activeColor = util.color.MID_BLUE, util.color.WHITE
            end
        else
            colorOb, activeColor = util.color.GRAY, util.color.GRAY
            colorImg = ability.color or util.color.GRAY
        end
    end

    widget.binder.img:setColor(colorImg:unpack())

    widget.binder.btn:setColor(0.9, 0, 0)
    widget.binder.btn:setColorInactive(0.9, 0, 0)

    widget.binder.btn:setColorActive(0.9, 0, 0)
    widget.binder.btn:setColorHover(0.9, 0, 0)

    widget.binder.powerTxt:setColor(colorOb:unpack())
    widget.binder.turnsTxt:setColor(colorOb:unpack())
    widget.binder.digi:setColor(colorOb.r, colorOb.g, colorOb.b, 100 / 255)
    widget.binder.descTxt:setColor(colorOb:unpack())
end

return
{
    panel = panel
}
