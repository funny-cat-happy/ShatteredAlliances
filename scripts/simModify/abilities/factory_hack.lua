local array = include("modules/array")
local util = include("modules/util")
local cdefs = include("client_defs")
local simdefs = include("sim/simdefs")
local simquery = include("sim/simquery")
local abilityutil = include("sim/abilities/abilityutil")

local factory_hack =
{
    name = STRINGS.DLC1.SCRUB_DATABANK,

    createToolTip = function(self, sim, unit)
        return abilityutil.formatToolTip(STRINGS.DLC1.SCRUB_DATABANK, STRINGS.DLC1.SCRUB_DATABANK_DESC)
    end,

    proxy = true,

    getName = function(self, sim, abilityOwner, abilityUser, targetUnitID)
        return self.name
    end,

    profile_icon = "gui/icons/action_icons/Action_icon_Small/icon-item_hijack_small.png",

    isTarget = function(self, abilityOwner, unit, targetUnit)
        if targetUnit:getTraits().mainframe_status ~= "active" then
            return false
        end

        return true
    end,


    acquireTargets = function(self, targets, game, sim, abilityOwner, unit)
        if simquery.canUnitReach(sim, unit, abilityOwner:getLocation()) then
            return targets.unitTarget(game, { abilityOwner }, self, abilityOwner, unit)
        end
    end,

    canUseAbility = function(self, sim, abilityOwner, unit, targetUnitID)
        local targetUnit = sim:getUnit(targetUnitID)
        local userUnit = abilityOwner:getUnitOwner()

        if abilityOwner:getTraits().mainframe_status ~= "active" then
            return false
        end

        if sim:isVersion("0.17.11") and unit:getTraits().isDrone then
            return false
        end

        if abilityOwner:getTraits().cooldown and abilityOwner:getTraits().cooldown > 0 then
            return false, util.sformat(STRINGS.UI.REASON.COOLDOWN, abilityOwner:getTraits().cooldown)
        end
        if abilityOwner:getTraits().usesCharges and abilityOwner:getTraits().charges < 1 then
            return false, util.sformat(STRINGS.UI.REASON.CHARGES)
        end


        if unit:getTraits().data_hacking or abilityOwner:getTraits().hacker then
            return false, STRINGS.UI.REASON.ALREADY_HACKING
        end

        if abilityOwner:getTraits().mainframe_ice > 0 then
            return false, STRINGS.ABILITIES.TOOLTIPS.UNLOCK_WITH_INCOGNITA
        end

        if not simquery.canUnitReach(sim, unit, abilityOwner:getLocation()) then
            return false
        end

        return abilityutil.checkRequirements(abilityOwner, userUnit)
    end,

    executeAbility = function(self, sim, abilityOwner, unit, targetUnitID)
        local targetUnit = sim:getUnit(targetUnitID)

        local x0, y0 = unit:getLocation()
        local x1, y1 = targetUnit:getLocation()
        local tempfacing = simquery.getDirectionFromDelta(x1 - x0, y1 - y0)
        unit:setFacing(tempfacing)
        sim:dispatchEvent(simdefs.EV_UNIT_USECOMP,
            { unitID = unit:getID(), facing = tempfacing, sound = "SpySociety/Actions/monst3r_jackin", soundFrame = 16, useTinkerMonst3r = true })

        if not abilityOwner:getTraits().progress then
            sim:triggerEvent("factory_hack_start", { unit = abilityOwner })
            abilityOwner:getTraits().progress = 0
        end
        --should this go here? or in that if loop?
        if abilityOwner:getTraits().progress then
            sim:dispatchEvent(simdefs.EV_UNIT_SWTICH_FX, { unit = abilityOwner })
        else
            sim:dispatchEvent(simdefs.EV_UNIT_SWTICH_FX, { unit = abilityOwner, transition = true })
        end

        if sim:isVersion("0.17.11") then
            unit:getTraits().isMeleeAiming = false
            unit:setAiming(false)
        end

        abilityOwner:getTraits().hacker = unit:getID()
        unit:getTraits().data_hacking = abilityOwner:getID()
        unit:getTraits().data_hacking_spotsound = true
        unit:getSounds().spot = "SpySociety/Actions/monst3r_hacking"
        sim:dispatchEvent(simdefs.EV_UNIT_REFRESH, { unit = unit })
    end,

}

return factory_hack
