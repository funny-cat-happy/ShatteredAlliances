local cheatmenu = include("fe/cheatmenu")
local simdefs = include("sim/simdefs")
local cdefs = include("client_defs")
local util = include("modules/util")
local simquery = include("sim/simquery")


local brokenDoor =
{
    door = true,
    closed = false,
    locked = false,
    openSound = simdefs.SOUND_DOOR_OPEN,
    closeSound = simdefs.SOUND_DOOR_CLOSE,
    breakSound = simdefs.SOUND_DOOR_BREAK,
    keybits = simdefs.DOOR_KEYS.OFFICE,
    wallUVs = { unlocked = cdefs.WALL_DOOR_UNLOCKED, locked = cdefs.WALL_DOOR_LOCKED, broken = cdefs.WALL_DOOR_BROKEN },
}

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
            cheat_item("wall info",
                function()
                    if game then
                        local x, y = game:wndToCell(inputmgr:getMouseXY())
                        SALog(sim:getCell(x, y), 4)
                    end
                end),
            cheat_item("remove segment",
                function()
                    if game then
                        local x, y = game:wndToCell(inputmgr:getMouseXY())
                        local cell = sim:getCell(x, y)
                        for _, dir in pairs(simdefs.DIR_SIDES) do
                            if simquery.checkIsWall(sim, cell, dir) then
                                cell.sides[dir] = util.tcopy(brokenDoor)
                                cell.exits[dir] = util.tcopy(brokenDoor)
                                local targetCell = simquery.getDirCell(sim, cell, dir)
                                cell.exits[dir].cell = targetCell
                                SALog(cell, "cell")
                                SALog(targetCell, "targetCell")
                                -- sim:getLOS():removeSegments(cell, dir)
                                sim:modifyExit(cell, dir, simdefs.EXITOP_BREAK_DOOR, nil, false)
                                break
                            end
                        end
                    end
                end),
        })
    }
    for _, cheat in pairs(SAMenu) do
        table.insert(simdefs.CHEATS, cheat)
    end
end

return { load = load }
