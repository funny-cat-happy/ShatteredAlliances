local util = include("modules/util")


local function init(modApi)
	modApi.requirements = {}
	local dataPath = modApi:getDataPath()
	KLEIResourceMgr.MountPackage(dataPath .. "/buildout/gui.kwad", "data")
end


-- local function load(modApi, options, params, options_raw)
-- 	log:write('aaaaaaaaaaaaaaa')
-- 	local settings = savefiles.getSettings("settings")
-- 	log:write(settings.data.localeMod)
-- 	log:flush()
-- end

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
	local stateMainMenu = include('states/state-main-menu')
	local mui = include("mui/mui")
    local oldLoad = stateMainMenu.onLoad
	stateMainMenu.onLoad = function(self)
        oldLoad(self)
		log:write('a')
		log:flush()
        local screen = mui.createScreen("test.lua")
		mui.activateScreen(screen)
	end
end


return {
	init = init,
	-- load = load,
	lateInit = lateInit,
	-- lateLoad = lateLoad,
	-- initStrings = initStrings
}
