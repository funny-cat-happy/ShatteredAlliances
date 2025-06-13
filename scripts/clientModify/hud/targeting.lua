local targeting = include("hud/targeting")
local simquery = include("sim/simquery")
local world_hud = include("hud/hud-inworld")


local wallTarget = class()
function wallTarget:init(game, walls, ability, abilityOwner, abilityUser)
    self._game = game
    self._walls = walls
    self._ability = ability
    self._abilityOwner = abilityOwner
    self._abilityUser = abilityUser
end

function wallTarget:hasTargets()
    return #self._walls > 0
end

function wallTarget:getDefaultTarget()
    return nil
end

function wallTarget:onInputEvent(event)
end

function wallTarget:startTargeting(cellTargets)
    local agent_panel = include("hud/agent_panel")
    local sim = self._game.simCore
    for i, wall in ipairs(self._walls) do
        local dx, dy = simquery.getDeltaFromDirection(wall.dir)
        local x1, y1 = wall.cell.x + dx, wall.cell.y + dy
        local wx, wy = self._game:cellToWorld((wall.cell.x + x1) / 2, (wall.cell.y + y1) / 2)
        wx, wy = cellTargets:findLocation(wx, wy)
        local widget = self._game.hud._world_hud:createWidget(world_hud.HUD, "Target",
            {
                worldx = wx,
                worldy = wy,
                worldz = 36,
                layoutID = string.format("%d,%d-%d", wall.cell.x, wall.cell.y,
                    wall.dir)
            })
        agent_panel.updateButtonFromAbilityTarget(self._game.hud._agent_panel, widget, self._ability, self._abilityOwner,
            self._abilityUser, wall.cell.x, wall.cell.y, wall.dir)
    end
end

function wallTarget:endTargeting(hud)
    hud._world_hud:destroyWidgets(world_hud.HUD)
end

local function init()
    targeting.wallTarget = wallTarget
end

return { init = init }
