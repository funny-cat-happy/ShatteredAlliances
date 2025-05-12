local agentPanel = include("hud/agent_panel").agent_panel
local function newRefreshPlayerInfo(unit, binder)
    binder.bioIcon:setVisible(false)
    binder.agentProfileImg:setVisible(true)
    binder.agentProfileImg:setImage("gui/profile_icons/warez_shopCat.png")
    binder.agentProfileAnim:setVisible(false)
    binder.agentName:setText(STRINGS.SA.UI.SHOPCAT_NAME)
    binder.agentProfileBtn:setDisabled(true)
    binder.agentProfileBtn.onClick = nil
    binder.agentProfileBtn:setTooltip()
end

upvalueUtil.findAndReplace(agentPanel.refreshPanel, "refreshPlayerInfo", newRefreshPlayerInfo)
