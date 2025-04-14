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
	local simdefs = include(SA_PATH .. "/simModify/simdefs")
	for k, v in pairs(simdefs) do
		modApi:addSimdef(k, v)
	end
end


local function load(modApi, options, params, options_raw)
	modApi:insertUIElements(include(SA_PATH .. "/clientModify/hud/hud_modify"))
	local guarddefs = include(SA_PATH .. "/simModify/unitdefs/guarddefs")
	for name, guarddef in pairs(guarddefs) do
		modApi:addGuardDef(name, guarddef)
	end
	local give_spell = include(SA_PATH .. "/clientModify/fe/cheatmenu")
	local cheatmenu = include("fe/cheatmenu")


	local cheat_item = cheatmenu.cheat_item
	local simdefs = include("sim/simdefs")
	if rawget(simdefs, "CHEATS") then
		table.insert(simdefs.CHEATS, cheat_item("debug", function()
			SALog("debug")
		end))
	end
	-- Add the new custom situations
	include(SA_PATH .. "/simModify/mission/mission_factory")
	local serverdefs_mod = include(SA_PATH .. "/modulesModify/serverdefs")
	modApi:addSituation(serverdefs_mod.MISSION_FACTORY_SITUATION, "mission_factory", SA_PATH .. "/simModify/mission")
end

local function lateLoad(modApi, options, params, options_raw)
	--add new situation
	local fn = include(SA_PATH .. "/modulesModify/serverdefs")
	fn.lateLoad()
end
local function lateInit(modApi)
	--modify game hud
	include(SA_PATH .. "/clientModify/hud/hud")
	include(SA_PATH .. "/clientModify/gameplay/modal_thread")

	--add allyplayer
	include(SA_PATH .. "/simModify/aiplayer")
	include(SA_PATH .. "/simModify/allyplayer")
	include(SA_PATH .. "/simModify/pcplayer")
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
