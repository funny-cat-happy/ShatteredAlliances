local simdefs = include("sim/simdefs")
local cheatmenu = include("fe/cheatmenu")


local cheat_item = cheatmenu.cheat_item
local give_spell = class(cheatmenu.cheat_submenu)

local function giveSpell(spellName, spellLevel)
    -- Code that spawns the spell goes here
end
function give_spell:init()
    local submenu = {}

    local item = cheatmenu.cheat_item("debug", function()
        SALog("test")
    end)
    table.insert(submenu, item)

    cheatmenu.cheat_submenu.init(self, "Give spell", submenu)
end

if rawget(simdefs, "CHEATS") then
    table.insert(simdefs.CHEATS, give_spell())
end
