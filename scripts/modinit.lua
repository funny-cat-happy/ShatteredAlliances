local util = include("modules/util")


local function init(modApi)
	modApi.requirements = {}
	local dataPath = modApi:getDataPath()
	KLEIResourceMgr.MountPackage(dataPath .. "/buildout/gui.kwad", "data")
	local scriptPath = modApi:getScriptPath()
	rawset(_G, "SA_PATH", rawget(_G, "SA_PATH") or scriptPath)
end


local function load(modApi, options, params, options_raw)

end

-- local function initStrings(modApi)
-- local dataPath = modApi:getDataPath(
-- local scriptPath = modApi:getScriptPath()
-- local MOD_STRINGS = include(scriptPath .. "/strings")
-- modApi:addStrings(dataPath, "SHATTEREDALLIANCES", MOD_STRINGS)
-- end
local function lateInit(modApi)
	-- local serverdefs = include("modules/serverdefs")
	-- serverdefs.GENERAL_MISSIONS.TERMINALS.icon = "gui/collaboration.png"
	-- serverdefs.SITUATIONS.executive_terminals.ui.icon = "collaboration.png"
	-- log:write(util.stringize(serverdefs.SITUATIONS.executive_terminals.ui.icon))
	-- log:flush()
	-- local scriptPath = modApi:getScriptPath()
	-- include(scriptPath .. "/clientModify/mui")
	local stateMainMenu = include('states/state-main-menu')
	local mui = include("mui/mui")
	local screen
	local oldLoad = stateMainMenu.onLoad
	stateMainMenu.onLoad = function(self)
		oldLoad(self)
		screen = mui.createScreen("test.lua")
		mui.activateScreen(screen)
		screen.binder.alarm.binder.alarmRing1:setVisible(false)
		screen.binder.alarm.binder.alarmRing1:setColor(1, 0, 0, 1)
		screen.binder.alarm.binder.alarmRing1:setAnim("idle")
		screen.binder.alarm.binder.alarmRing1:setVisible(true)
		screen.binder.alarm.binder.alarmRing1:getProp():setListener(KLEIAnim.EVENT_ANIM_END,
			function(anim, animname)
				if animname == "idle" then
					screen.binder.alarm.binder.alarmRing1:setVisible(false)
				end
			end)
	end
end


return {
	init = init,
	load = load,
	lateInit = lateInit,
	-- lateLoad = lateLoad,
	-- initStrings = initStrings
}
