local function earlyInit(modApi)
	modApi.requirements = { "Sim Constructor", "Expanded Cheats" }
	local scriptPath = modApi:getScriptPath()
	rawset(_G, "SA_PATH", scriptPath)
	rawset(_G, "SAInclude", function(filePath)
		return include(scriptPath .. "/" .. filePath)
	end)
	SAInclude('modulesModify/log')
	SAInclude('modulesModify/util')
end
local function init(modApi)
	local dataPath = modApi:getDataPath()
	KLEIResourceMgr.MountPackage(dataPath .. "/gui.kwad", "data")
	KLEIResourceMgr.MountPackage(dataPath .. "/anims.kwad", "data")
	KLEIResourceMgr.MountPackage(dataPath .. "/sound.kwad", "data")
	MOAIFmodDesigner.loadFEV("SA.fev")

	SAInclude("simModify/btree/actions")
	SAInclude("simModify/btree/conditions")
	SAInclude("simModify/btree/allybrain")


	SAInclude('clientModify/gameplay/boardrig')
	SAInclude('clientModify/gameplay/agentrig')

	SAInclude("simModify/simunit")

	modApi:addSimdef("SA", SAInclude("simModify/simdefs"))
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

---comment
---@param modApi modApi
---@param options any
---@param params any
---@param options_raw any
local function load(modApi, options, params, options_raw)
	local fn = SAInclude("clientModify/fe/cheatmenu")
	fn.load()
	modApi:insertUIElements(SAInclude("clientModify/hud/hud_insert"))
	modApi:modifyUIElements(SAInclude("clientModify/hud/hud_modification"))
	SAInclude("simModify/unitdefs/commondefs")
	SAInclude("simModify/units/factorycore")
	local guarddefs = SAInclude("simModify/unitdefs/guarddefs")
	for name, guarddef in pairs(guarddefs) do
		modApi:addGuardDef(name, guarddef)
	end
	local propdefs = SAInclude("simModify/unitdefs/propdefs")
	for name, propdef in pairs(propdefs) do
		modApi:addPropDef(name, propdef, true)
	end
	-- Add the new custom situations
	SAInclude("simModify/mission/mission_factory")
	local serverdefs_mod = SAInclude("modulesModify/serverdefs")
	modApi:addSituation(serverdefs_mod.MISSION_FACTORY_SITUATION, "factory", SA_PATH .. "/simModify/mission")
	-- add player program
	local player_mainframe_abilities = SAInclude("simModify/abilities/player_mainframe_abilities")
	for name, ability in pairs(player_mainframe_abilities) do
		modApi:addMainframeAbility(name, ability)
	end
	-- add incognita program
	local player_mainframe_abilities = SAInclude("simModify/abilities/incognita_program_abilities")
	for name, ability in pairs(player_mainframe_abilities) do
		modApi:addMainframeAbility(name, ability)
	end
	-- add incognita daemon
	local incognita_mainframe_abilities = SAInclude("simModify/abilities/incognita_daemon_abilities")
	for name, ability in pairs(incognita_mainframe_abilities) do
		modApi:addDaemonAbility(name, ability)
	end
	--add factory mission story
	local factoryPrefabs = SAInclude("prefabs/factory/prefabt")
	modApi:addPrefabt(factoryPrefabs)
	local SCRIPTS = SAInclude("clientModify/story_scripts")
	modApi:addMapScripts(SCRIPTS.CAMPAIGN_MAP.MISSIONS, "CAMPAIGN_MAP")
	SAInclude("clientModify/fe/talkinghead")
	local worldgen = SAInclude("simModify/worldgen")
	for i, world in pairs(worldgen) do
		modApi:addCorpWorld(i, world)
	end
	local nexusPrefabs = SAInclude("prefabs/nexus/prefabt")
	modApi:addWorldPrefabt(nil, "NEXUS", nexusPrefabs)
end

local function lateLoad(modApi, options, params, options_raw)
	--add new situation
	local fn = SAInclude("modulesModify/serverdefs")
	fn.lateLoad()
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
