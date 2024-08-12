local util = include("modules/util")

local function earlyInit(modApi)
	local scriptPath = modApi:getScriptPath()
	rawset(_G, "SA_PATH", rawget(_G, "SA_PATH") or scriptPath)
	include(SA_PATH .. '/modulesModify/log')
	include(SA_PATH .. '/modulesModify/util')
end
local function init(modApi)
	modApi.requirements = { "Sim Constructor", "Expanded Cheats" }
	local dataPath = modApi:getDataPath()
	KLEIResourceMgr.MountPackage(dataPath .. "/buildout/gui.kwad", "data")

    include(SA_PATH .. "/simModify/btree/allybrain")
	include(SA_PATH .. "/clientModify/fe/cheatmenu")
end


local function load(modApi, options, params, options_raw)
	modApi:insertUIElements(include(SA_PATH .. "/clientModify/hud/hud_modify"))
	local guarddefs = include(SA_PATH .. "/simModify/unitdefs/guarddefs")
    for name, guarddef in pairs(guarddefs) do
        modApi:addGuardDef(name, guarddef)
    end
	include(SA_PATH .. "/clientModify/fe/cheatmenu")
end

local function lateLoad(modApi, options, params, options_raw)
	
end
local function lateInit(modApi)
	--modify game hud
	include(SA_PATH .. "/clientModify/hud/hud")
	include(SA_PATH .. "/clientModify/gameplay/modal_thread")

	--add allyplayer
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
	lateLoad = lateLoad,
	initStrings = initStrings,
}
