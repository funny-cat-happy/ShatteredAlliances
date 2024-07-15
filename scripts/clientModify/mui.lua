local mui = include('mui/mui')
local discprogressbar = include(SA_PATH .. '/clientModify/mui_discprogressbar')


local oldInitMui = mui.initMui
mui.initMui = function(width, height, fn)
    oldInitMui(width, height, fn)
    mui.internals._widgetFactory["discprogressbar"] = discprogressbar
end
