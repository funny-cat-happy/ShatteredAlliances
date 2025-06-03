---@class customSimdefs
local _M = {
    PLAYER_TYPE = {
        PC = 0,
        AI = 1,
        ALLY = 2
    },
    ALLY_UNIT = {
        ALLY_INVISIBLE_KILLER = "ally_guard_enforcer_reinforcement"
    },


    FIREWALL_UPPER_LIMIT = 9,
    FIREWALL_STATUS = {
        ACTIVATE = "ACTIVATE",
        HACKING = "HACKING",
        REBOOTING = "REBOOTING",
        DEACTIVATE = "DEACTIVATE",
    },


    TRG_INCOGNITA_ACTION = 1001,
    TRG_VIRUS_OUTBREAK = 1002,


    EV_INCFIREWALL_CHANGE = 1001,
}
return _M

---@class customSimdefsWrap
---@field SA customSimdefs

---@alias simdefs customSimdefsWrap|systemSimdefs
