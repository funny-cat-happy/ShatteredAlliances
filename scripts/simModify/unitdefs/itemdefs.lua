local util = include("modules/util")
local commondefs = include("sim/unitdefs/commondefs")
local simdefs = include("sim/simdefs")


local SA_tool_templates = {
    item_acheron_breach_charge = util.extend(commondefs.item_template) {
        name = STRINGS.SA.ITEMS.ACHERON_BREACH_CHARGE,
        desc = STRINGS.SA.ITEMS.ACHERON_BREACH_CHARGE_TOOLTIP,
        flavor = STRINGS.SA.ITEMS.ACHERON_BREACH_CHARGE_FLAVOR,
        icon = "itemrigs/FloorProp_AmmoClip.png",
        profile_icon = "gui/icons/item_icons/items_icon_small/icon-item_shocktrap_small.png",
        profile_icon_100 = "gui/icons/item_icons/icon-item_shock trap.png",
        traits = { cooldown = 0, cooldownMax = 7, applyFn = "isNotLoadBearingWall", wallDevice = "simcharge", range = 1 },
        requirements = {},
        abilities = { "wallMechanism", "carryable" },
        value = 400,
        floorWeight = 1,
    },
}

return SA_tool_templates
