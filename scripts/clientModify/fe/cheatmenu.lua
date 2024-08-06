local cheatmenu = include("fe/cheatmenu")
local util = include("client_util")
local sa_util = include(SA_PATH .. '/modulesModify/util')

local oldCheatMenuInit = cheatmenu.menu.init
-- local cheat_item = sa_util.getLocalValue(oldCheatMenuInit, "cheat_item")
sa_util.debugFunc(sa_util.getLocalValue, oldCheatMenuInit, "cheat_item",5)
cheatmenu.menu.init = function(self, screen, debugenv)
    self.screen = screen
    self.debugenv = debugenv
    self.listbox = screen.binder.listbox
    local onItemSelected = sa_util.getLocalValue(oldCheatMenuInit, "onItemSelected")
    self.listbox.onItemSelected = util.makeDelegate(nil, onItemSelected, self)
    local onItemClicked = sa_util.getLocalValue(oldCheatMenuInit, "onItemClicked")
    self.listbox.onItemClicked = util.makeDelegate(nil, onItemClicked, self)
    self.menuStack = {}
    self.lastSelection = {}
    local CHEAT_MENU = sa_util.getLocalValue(oldCheatMenuInit, "CHEAT_MENU")
    table.insert(CHEAT_MENU.submenu, 1, cheat_item("debug", function()
        SALog("clicked")
    end))
    self:pushMenu(CHEAT_MENU)
    self:refresh()
end
