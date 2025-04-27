local abilitydefs = include("sim/abilitydefs")
local simdefs = include("sim/simdefs")
local simquery = include("sim/simquery")
local btree = include("sim/btree/btree")
local util = include("modules/util")
local mathutil = include("modules/mathutil")
local abilitydefs = include("sim/abilitydefs")
local speechdefs = include("sim/speechdefs")
local inventory = include("sim/inventory")
local Actions = include("sim/btree/actions")

function Actions.useInvisibleCloak(sim, unit)
    if unit:getTraits().invisible then
        return simdefs.BSTATE_FAILED
    end
    unit:setInvisible(true, nil)
    sim:dispatchEvent(simdefs.EV_UNIT_REFRESH, { unit = unit })
    sim:processReactions(unit)
end
