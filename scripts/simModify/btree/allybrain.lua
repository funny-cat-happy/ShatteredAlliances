local Brain = include("sim/btree/brain")
local btree = include("sim/btree/btree")
local actions = include("sim/btree/actions")
local conditions = include("sim/btree/conditions")
local simfactory = include("sim/simfactory")
local simdefs = include("sim/simdefs")
local speechdefs = include("sim/speechdefs")
local mathutil = include("modules/mathutil")
local simquery = include("sim/simquery")
local CommonBrain = include("sim/btree/commonbrain")

require("class")

local function UseInvisibleCloak()
    return btree.Sequence("UseInvisibleCloak",
        {
            btree.Condition(conditions.HasInvisible),
            btree.Action(actions.useInvisibleCloak),
        })
end

local GuardBrain = class(Brain, function(self)
    Brain.init(self, "AllyBrain",
        btree.Selector(
            {
                UseInvisibleCloak(),
                CommonBrain.RangedCombat(),
                CommonBrain.Investigate(),
            })
    )
end)

local function createBrain()
    return GuardBrain()
end

simfactory.register(createBrain)

return
{
    createBrain = createBrain,
}
