local cheatmenu = include("fe/cheatmenu")
local simdefs = include("sim/simdefs")

local cheat_item = cheatmenu.cheat_item
local function load()
    local SAMenu = {
        cheatmenu.cheat_submenu("SADebug", {
            cheat_item("decrease INC firewall",
                function()
                    if sim then
                        game:doAction("debugAction",
                            function(sim)
                                sim:getFirewall():updateINCFirewallStatus(-1, 0)
                            end)
                    end
                end),
        })
    }
    for _, cheat in pairs(SAMenu) do
        table.insert(simdefs.CHEATS, cheat)
    end
end

return { load = load }
