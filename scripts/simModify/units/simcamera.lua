local simcamera = include("sim/units/simcamera")
local simdefs = include("sim/simdefs")

function simcamera:onWarp(sim, oldcell, cell)
    if not oldcell and cell then
        sim:addTrigger(simdefs.TRG_START_TURN, self)
        self:setPlayerOwner(sim:getNPC())
    else
        if not cell and oldcell then
            sim:removeTrigger(simdefs.TRG_START_TURN, self)
            sim:removeTrigger(simdefs.TRG_OVERWATCH, self)
        end
    end
end
