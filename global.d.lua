---@class SAStringWrap
---@field SA SAString

---@type GameString|SAStringWrap
STRINGS = nil

---@class UpvalueUtil
---@field find fun(fn:function, condition:string, maxDepth?:number):function
---@field findAndReplace fun(fn:function, condition:string, newValue:function, maxDepth?:number):function
upvalueUtil = nil

---@class KLEIResourceMgr
---@field MountPackage fun(rescourcePath:string, virtualFolder:string)
KLEIResourceMgr = nil

---comment
---@param path string
SAInclude = function(path) end

---@type engine
sim = nil

---@type game
game = nil

---@class SAUtil
---@field getLocalValue fun(fn: function, funcname: string, maxDepth: integer):nil
---@field debugFunc fun(fn: function, ...: any):nil
---@field printUpvalue fun(fn: function, condition: string | function, maxDepth: integer, callChain: string):nil
---@field printAllUpvalues fun(fn: function, maxDepth: integer|nil, callChain: string|nil):nil
SAUtil=nil