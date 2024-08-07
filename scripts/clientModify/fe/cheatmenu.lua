local simdefs = include("sim/simdefs")
local cheatmenu = include("fe/cheatmenu")


local cheat_item = cheatmenu.cheat_item
table.insert(simdefs.CHEATS, 1, cheat_item("debug", function()
    SALog("clicked")
end))
