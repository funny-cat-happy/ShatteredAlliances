local homePanel = include("hud/home_panel").panel
local util = include("client_util")
local cdefs = include("client_defs")
local array = include("modules/array")
local mui_defs = include("mui/mui_defs")
local mui_tooltip = include("mui/mui_tooltip")
local agent_panel = include("hud/agent_panel")
local simquery = include("sim/simquery")


local function onClickMainframeBtn(hud, player)
    hud:onClickMainframeBtn()
end

local function generateMainframeTooltip(hud)
    return mui_tooltip(STRINGS.UI.INCOGNITA_NAME, STRINGS.UI.INCOGNITA_TT, "mainframeMode")
end


homePanel.refresh = function(self)
    local localPlayer = self._hud._game:getLocalPlayer()

    for j, agentGrp in self._panel.binder:forEach("agent") do
        agentGrp:setVisible(false)
    end

    if not localPlayer or localPlayer:isNPC() then
        return
    end

    local item = self._panel_top.binder.incognitaBtn
    item:setAlias("mainframe")
    item:setTooltip(generateMainframeTooltip(self._hud))
    item:setHotkey("mainframeMode")
    item.onClick = util.makeDelegate(nil, onClickMainframeBtn, self._hud, localPlayer)

    if self._hud:isMainframe() then
        item:setText(STRINGS.SA.HUD.DISCONNECT_SHOPCAT)
    else
        item:setText(STRINGS.SA.HUD.CONNECT_SHOAPCAT)
    end
    item:setVisible(self._hud:canShowElement("mainframe"))
    self._panel_top.binder.bg:setVisible(self._hud:canShowElement("mainframe"))
    self._panel_top.binder.incognitaFace:setVisible(self._hud:canShowElement("mainframe"))

    --AGENTS	
    for i, unit in ipairs(localPlayer:getUnits()) do
        if localPlayer:findAgentDefByID(unit:getID()) or unit:getTraits().home_panel then
            self:refreshAgent(unit)
        end
    end
end
