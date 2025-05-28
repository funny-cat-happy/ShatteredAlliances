local commondefs = include("sim/unitdefs/commondefs")
local util = include("modules/util")


local oldOnGuardTooltip = commondefs.onGuardTooltip
commondefs.onGuardTooltip = function(tooltip, unit)
    commondefs.onAgentTooltip(tooltip, unit)

    local traits = unit:getTraits()

    if traits.isSupportGuard then
        tooltip:addAbility(STRINGS.UI.TOOLTIPS.GRENADE_GUARD, STRINGS.UI.TOOLTIPS.GRENADE_GUARD_DESC,
            "gui/icons/arrow_small.png")
    end

    if traits.mainframe_suppress_rangeMax then
        tooltip:addAbility(string.format(STRINGS.UI.TOOLTIPS.NULL_ZONE),
            util.sformat(STRINGS.UI.TOOLTIPS.NULL_ZONE_DESC, traits.mainframe_suppress_rangeMax),
            "gui/icons/arrow_small.png")
    end

    if traits.isDrone then
        tooltip:addAbility(STRINGS.UI.TOOLTIPS.CONTROLLABLE, STRINGS.UI.TOOLTIPS.CONTROLLABLE_DESC,
            "gui/icons/arrow_small.png")
    end

    if not traits.hasHearing then
        tooltip:addAbility(STRINGS.UI.TOOLTIPS.NO_HEARING, STRINGS.UI.TOOLTIPS.NO_HEARING_DESC,
            "gui/icons/arrow_small.png")
    end
    if not traits.canKO then
        tooltip:addAbility(STRINGS.UI.TOOLTIPS.KO_IMMUNE, STRINGS.UI.TOOLTIPS.KO_IMMUNE_DESC, "gui/icons/arrow_small.png")
    end
    if traits.heartMonitor == "enabled" then
        tooltip:addAbility(STRINGS.UI.TOOLTIPS.HEART_MONITOR, STRINGS.UI.TOOLTIPS.HEART_MONITOR_DESC,
            "gui/icons/item_icons/items_icon_small/icon-item_heart_monitor_small.png")
    end
    if traits.shieldArmor then
        tooltip:addAbility(STRINGS.UI.TOOLTIPS.BARRIER, STRINGS.UI.TOOLTIPS.BARRIER_DESC,
            "gui/icons/item_icons/items_icon_small/icon-item_personal_shield_small.png")
    elseif traits.armor and traits.armor > 0 then
        tooltip:addAbility(string.format(STRINGS.UI.TOOLTIPS.HEAVY_ARMOR, traits.armor),
            STRINGS.UI.TOOLTIPS.HEAVY_ARMOR_DESC, "gui/hud3/hud3_armor_tutorial_icon.png")
    end
    if traits.resistKO then
        tooltip:addAbility(string.format(STRINGS.UI.TOOLTIPS.KO_RESISTANT, traits.resistKO),
            STRINGS.UI.TOOLTIPS.KO_RESISTANT_DESC, "gui/icons/arrow_small.png")
    end

    if (traits.LOSperipheralArc or 0) == (2 * math.pi) and traits.LOSarc < (math.pi * 2) then
        tooltip:addAbility(STRINGS.UI.TOOLTIPS.ADVANCED_PERIPHERAL_BOOST,
            STRINGS.UI.TOOLTIPS.ADVANCED_PERIPHERAL_BOOST_DESC, "gui/icons/arrow_small.png")
    elseif (traits.LOSarc or 0) > (math.pi / 2) then
        if traits.LOSarc <= math.pi then
            tooltip:addAbility(STRINGS.UI.TOOLTIPS.PERIPHERAL_BOOST, STRINGS.UI.TOOLTIPS.PERIPHERAL_BOOST_DESC,
                "gui/icons/arrow_small.png")
        end
    elseif (traits.LOSarc or 0) == (math.pi * 2) then
        tooltip:addAbility(STRINGS.SA.UI.TOOLTIPS.TRUE_PERCEPTION,
            STRINGS.SA.UI.TOOLTIPS.TRUE_PERCEPTION_DESC, "gui/icons/arrow_small.png")
    end

    if traits.neutralize_shield then
        tooltip:addAbility(string.format(STRINGS.UI.TOOLTIPS.PROTECTIVE_SHIELDS, traits.neutralize_shield),
            STRINGS.UI.TOOLTIPS.PROTECTIVE_SHIELDS_DESC,
            "gui/icons/item_icons/items_icon_small/icon-item_personal_shield_small.png", nil, true)
    end
    if traits.empDeath then
        tooltip:addAbility(string.format(STRINGS.UI.TOOLTIPS.EMP_VULNERABLE), STRINGS.UI.TOOLTIPS.EMP_VULNERABLE_DESC,
            "gui/icons/arrow_small.png", nil, true)
    end

    if traits.mainframeRecapture then
        tooltip:addAbility(string.format(STRINGS.UI.TOOLTIPS.COUNTER_HACK),
            util.sformat(STRINGS.UI.TOOLTIPS.COUNTER_HACK_DESC, traits.mainframeRecapture), "gui/icons/arrow_small.png")
    end
    if traits.koDaemon then
        tooltip:addAbility(string.format(STRINGS.UI.TOOLTIPS.KO_DEAMON),
            string.format(STRINGS.UI.TOOLTIPS.KO_DEAMON_DESC), "gui/icons/arrow_small.png")
    end

    if traits.lookaroundRange and not traits.no_look_around then
        tooltip:addAbility(string.format(STRINGS.UI.TOOLTIPS.DRONE_SCAN),
            string.format(STRINGS.UI.TOOLTIPS.DRONE_SCAN_DESC), "gui/icons/arrow_small.png")
    end

    if traits.magnetic_reinforcement then
        tooltip:addAbility(string.format(STRINGS.UI.TOOLTIPS.MAGNETIC_REINFOREMENTS),
            string.format(STRINGS.UI.TOOLTIPS.MAGNETIC_REINFOREMENTS_DESC), "gui/icons/arrow_small.png")
    end

    local abilities = unit:getAbilities()

    for i, ability in ipairs(abilities) do
        if ability.buffAbility then
            tooltip:addAbility(string.format(ability.name), string.format(ability.buffDesc), "gui/icons/arrow_small.png")
        end
    end

    --NEW TOOLTIPS
    if traits.neural_scanned then
        tooltip:addAbility(string.format(STRINGS.UI.TOOLTIPS.NEURAL_SCANNED),
            string.format(STRINGS.UI.TOOLTIPS.NEURAL_SCANNED_DESC), "gui/icons/arrow_small.png")
    end
    if traits.pulseScan then
        tooltip:addAbility(string.format(STRINGS.UI.TOOLTIPS.PULSE_SCANNER),
            util.sformat(STRINGS.UI.TOOLTIPS.PULSE_SCANNER_DESC, traits.range), "gui/icons/arrow_small.png")
    end
    if traits.AOEFirewallsBuff then
        tooltip:addAbility(string.format(STRINGS.UI.TOOLTIPS.AOE_FIREWALL_BUFF),
            util.sformat(STRINGS.UI.TOOLTIPS.AOE_FIREWALL_BUFF_DESC, traits.AOEFirewallsBuffRange,
                traits.AOEFirewallsBuff), "gui/icons/arrow_small.png")
    end
    if traits.noInterestDistraction then
        tooltip:addAbility(string.format(STRINGS.UI.TOOLTIPS.FOCUSED_AI),
            util.sformat(STRINGS.UI.TOOLTIPS.FOCUSED_AI_DESC), "gui/icons/arrow_small.png")
    end
    if traits.buffArmorOnKO then
        tooltip:addAbility(string.format(STRINGS.UI.TOOLTIPS.KO_ARMOR_BUFF),
            util.sformat(STRINGS.UI.TOOLTIPS.KO_ARMOR_BUFF_DESC, traits.buffArmorOnKO), "gui/icons/arrow_small.png")
    end

    if traits.searchedAnarchy5 then
        tooltip:addAbility(string.format(STRINGS.UI.TOOLTIPS.SEARCHED_ADVANCED),
            util.sformat(STRINGS.UI.TOOLTIPS.SEARCHED_ADVANCED_DESC), "gui/icons/arrow_small.png")
    elseif traits.searched then
        tooltip:addAbility(string.format(STRINGS.UI.TOOLTIPS.SEARCHED), util.sformat(STRINGS.UI.TOOLTIPS.SEARCHED_DESC),
            "gui/icons/arrow_small.png")
    end

    if traits.heartBeatPacket == "enabled" then
        tooltip:addAbility(STRINGS.SA.UI.TOOLTIPS.HEART_BEAT_PACKET,
            util.sformat(STRINGS.SA.UI.TOOLTIPS.HEART_BEAT_PACKET_DESC, traits.recyclePWR),
            "gui/icons/item_icons/items_icon_small/icon-item_heart_beat_packet_small.png")
    end

    for i, tooltipFunction in ipairs(mod_manager:getTooltipDefs().onGuardTooltips) do
        tooltipFunction(tooltip, unit)
    end

    upvalueUtil.find(oldOnGuardTooltip, "onFooterTooltip")(tooltip, unit)
end

commondefs.basic_robot_traits = util.extend(commondefs.basic_guard_traits)
    {
        heartBeatPacket = "enabled",
        recyclePWR = 5
    }
