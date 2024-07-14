local mui = include('mui/mui')
local discprogressbar = include('mui_discprogressbar')
log:write('tt')
log:flush()
local oldInitMui = mui.initMui
mui.initMui = function(width, height, fn)
    oldInitMui(width, height, fn)
    mui.internals._widgetFactory["discprogressbar"] = discprogressbar
    log:write('tt')
    log:flush()
end
