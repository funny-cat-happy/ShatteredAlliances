local Brain = include("sim/btree/brain")
local btree = include("sim/btree/btree")
local actions = include("sim/btree/actions")
local conditions = include("sim/btree/conditions")
local simfactory = include("sim/simfactory")
local simdefs = include("sim/simdefs")
local speechdefs = include("sim/speechdefs")
local mathutil = include("modules/mathutil")
local simquery = include("sim/simquery")

local BrainDefine = {}

BrainDefine.Investigate = function()
    return
        btree.Sequence("Investigate/Hunt",
            {
                btree.Condition(conditions.HasInterest),
                btree.Action(actions.ReactToInterest),
                actions.MoveToInterest(),
                btree.Action(actions.MarkInterestInvestigated),
                btree.Sequence("Finish",
                    {
                        btree.Not(btree.Condition(conditions.IsUnitPinning)),
                        btree.Action(actions.RemoveInterest),
                        btree.Selector("MoveOn",
                            {
                                btree.Sequence("Hunt",
                                    {
                                        btree.Action(actions.RequestNewHuntTarget),
                                    }),
                                btree.Sequence("Investigate",
                                    {
                                        btree.Action(actions.FinishSearch),
                                    }),
                            }),
                    }),
            })
end

BrainDefine.RangedCombat = function()
    return
        btree.Sequence("Combat",
            {
                btree.Condition(conditions.HasTarget),
                btree.Action(actions.ReactToTarget),
                btree.Condition(conditions.CanShootTarget),
                btree.Action(actions.ShootAtTarget),
            })
end


return BrainDefine
