---@class simquery
local simquery = include("sim/simquery")


local tileDir =
{
    [0] = { 1, 0 },
    [2] = { 0, 1 },
    [4] = { -1, 0 },
    [6] = { 0, -1 },
}

simquery.isNotLoadBearingWall = function(sim, cell, dir)
    if simquery.checkIsWall(sim, cell, dir) then
        if simquery.getDirCell(sim, cell, dir) then
            return true
        else
            return false
        end
    end
end

simquery.getDirCell = function(sim, cell, dir)
    return sim:getCell(cell.x + tileDir[dir][1], cell.y + tileDir[dir][2])
end
