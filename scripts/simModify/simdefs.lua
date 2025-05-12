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


    TRG_INCOGNITA_ACTION = 0,
}
return _M

---@class customSimdefsWrap
---@field SA customSimdefs

---@alias simdefs customSimdefsWrap|systemSimdefs
