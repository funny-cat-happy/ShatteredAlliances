local simdefs = include("sim/simdefs")
local simquery = include("sim/simquery")
local Conditions = include("sim/btree/conditions")

function Conditions.HasInvisible(sim, unit)
    return not unit:getTraits().invisible
end
