local function earlyInit(modApi)
	local scriptPath = modApi:getScriptPath()
	rawset(_G, "SA_PATH", rawget(_G, "SA_PATH") or scriptPath)
	rawset(_G, "SAInclude", rawget(_G, "SAInclude") or function(striptPath)
		return include(scriptPath .. "/" .. striptPath)
	end)
	SAInclude('modulesModify/log')
	SAInclude('modulesModify/util')
end
local function init(modApi)
	modApi.requirements = { "Sim Constructor", "Expanded Cheats" }
	local dataPath = modApi:getDataPath()
	KLEIResourceMgr.MountPackage(dataPath .. "/buildout/gui.kwad", "data")

	SAInclude("simModify/btree/actions")
	SAInclude("simModify/btree/conditions")
	SAInclude("simModify/btree/allybrain")

	SAInclude("clientModify/fe/cheatmenu")

	SAInclude('clientModify/gameplay/boardrig')
	SAInclude('clientModify/gameplay/agentrig')

	local simdefs = SAInclude("simModify/simdefs")
	for k, v in pairs(simdefs) do
		modApi:addSimdef(k, v)
	end
end


local function load(modApi, options, params, options_raw)
	modApi:insertUIElements(SAInclude("clientModify/hud/hud_insert"))
	modApi:modifyUIElements(SAInclude("clientModify/hud/hud_modification"))
	local guarddefs = SAInclude("simModify/unitdefs/guarddefs")
	for name, guarddef in pairs(guarddefs) do
		modApi:addGuardDef(name, guarddef)
	end
	local give_spell = SAInclude("clientModify/fe/cheatmenu")
	local cheatmenu = include("fe/cheatmenu")


	local cheat_item = cheatmenu.cheat_item
	local simdefs = include("sim/simdefs")
	if rawget(simdefs, "CHEATS") then
		table.insert(simdefs.CHEATS, cheat_item("debug", function()
			SALog("debug")
		end))
	end
	-- Add the new custom situations
	SAInclude("simModify/mission/mission_factory")
	local serverdefs_mod = SAInclude("modulesModify/serverdefs")
	modApi:addSituation(serverdefs_mod.MISSION_FACTORY_SITUATION, "mission_factory", SA_PATH .. "/simModify/mission")
	-- add mainframe ability
	local mainframe_abilities = SAInclude("simModify/abilities/player_mainframe_abilities")
	for name, ability in pairs(mainframe_abilities) do
		modApi:addMainframeAbility(name, ability)
	end
end

local function lateLoad(modApi, options, params, options_raw)
	--add new situation
	local fn = SAInclude("modulesModify/serverdefs")
	fn.lateLoad()
end
local function lateInit(modApi)
	--modify game hud
	SAInclude("clientModify/hud/hud")
	SAInclude("clientModify/hud/agent_panel")
	SAInclude("clientModify/hud/mainframe_panel")
	SAInclude("clientModify/hud/home_panel")
	SAInclude("clientModify/gameplay/modal_thread")

	--add allyplayer
	SAInclude("simModify/simplayer")
	SAInclude("simModify/aiplayer")
	SAInclude("simModify/allyplayer")
	SAInclude("simModify/pcplayer")
	SAInclude("simModify/engine")
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
