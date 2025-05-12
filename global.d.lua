---@class SAStringWrap
---@field SA SAString

---@type GameString|SAStringWrap
STRINGS = nil

---@class UpvalueUtil
---@field find fun(fn:function, condition:string, maxDepth?:number):function
---@field findAndReplace fun(fn:function, condition:string, newValue:function, maxDepth?:number):function
upvalueUtil = nil
