local util = include("modules/util")

local function earlyInit(modApi)
	local scriptPath = modApi:getScriptPath()
	rawset(_G, "SA_PATH", rawget(_G, "SA_PATH") or scriptPath)
	include(SA_PATH .. '/modulesModify/log')
end
local function init(modApi)
	modApi.requirements = {}
	local dataPath = modApi:getDataPath()
	KLEIResourceMgr.MountPackage(dataPath .. "/buildout/gui.kwad", "data")
end


local function load(modApi, options, params, options_raw)
	modApi:insertUIElements(include(SA_PATH .. "/clientModify/hud/hud_modify"))
end
local function lateInit(modApi)
	include(SA_PATH .. "/clientModify/hud/hud")
	include(SA_PATH .. "/clientModify/gameplay/modal_thread")

	include(SA_PATH .. "/simModify/aiplayer")
	include(SA_PATH .. "/simModify/allyplayer")
	include(SA_PATH .. "/simModify/engine")
end

local function initStrings(modApi)
	local dataPath = modApi:getDataPath()
	local scriptPath = modApi:getScriptPath()
	local MOD_STRINGS = include(scriptPath .. "/strings")
	modApi:addStrings(dataPath, "SA", MOD_STRINGS)
end


return {
	earlyInit = earlyInit,
	init = init,
	load = load,
	lateInit = lateInit,
	-- lateLoad = lateLoad,
	initStrings = initStrings,
}
