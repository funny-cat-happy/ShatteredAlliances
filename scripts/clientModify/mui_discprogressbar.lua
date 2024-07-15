local mui_widget = require("mui/widgets/mui_widget")
local mui_container = require("mui/widgets/mui_container")
local mui_disccomponent = require(SA_PATH .. "/clientModify/mui_disccomponent")
require("class")

local mui_discprogressbar = class(mui_widget)

function mui_discprogressbar:init(screen, def)
    mui_widget.init(self, def)
    self.disccomponent = mui_disccomponent(screen, def)
    self._cont = mui_container(def)
    self._cont:addComponent(self.disccomponent)
end

function mui_discprogressbar:setProgress(percentage)
    self.disccomponent:setAttr(1, percentage / 100)
end

return mui_discprogressbar
