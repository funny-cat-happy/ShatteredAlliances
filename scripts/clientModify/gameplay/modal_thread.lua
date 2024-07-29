local dialogs = include("gameplay/modal_thread")
local modalDialog = include("states/state-modal-dialog")
local rig_util = include("gameplay/rig_util")
local mui = include("mui/mui")
local sa_util = include(SA_PATH .. '/modulesModify/util')
local util = include("modules.util")

local modal_thread = sa_util.getLocalValue(dialogs.alarmDialog.init, "modal_thread", 1)


local reinforceDialog = class(modal_thread)
function reinforceDialog:init(viz, unit, pan)
    local x, y = unit:getLocation()
    viz.game:cameraPanToCell(x, y)
    viz.game:getCamera():zoomTo(0.3)

    local screen = mui.createScreen("modal-newthreat.lua")
    mui.activateScreen(screen)

    screen.binder.pnl:createTransition("activate_left")

    screen.binder.pnl.binder.portrait:bindBuild(unit:getUnitData().profile_build or unit:getUnitData().profile_anim)
    screen.binder.pnl.binder.portrait:bindAnim(unit:getUnitData().profile_anim)
    screen.binder.pnl.binder.portrait:setVisible(true)

    local corp = viz.game.simCore:getParams().world
    local serverdefs = include("modules/serverdefs")

    screen.binder.pnl.binder.corpIcon:setImage(serverdefs.CORP_DATA[corp].imgs.logoLarge)
    screen.binder.pnl.binder.bodyTxt:setText(unit:getName())

    screen.binder.pnl.binder.caution:setColor(127 / 255, 1, 0, 1)

    screen.binder.pnl.binder.progress:setBGColor(60 / 255, 1, 0, 1)
    screen.binder.pnl.binder.progress:setProgressColor(127 / 255, 1, 0, 1)

    screen.binder.pnl.binder.title.binder.titleTxt2:setColor(127 / 255, 1, 0, 1)
    screen.binder.pnl.binder.title.binder.titleTxt2:setText("REINFORCEMENT ARRIVED")
    screen.binder.pnl.binder.title.binder.titleTxt:setColor(127 / 255, 1, 0, 1)
    screen.binder.pnl.binder.title.binder.titleTxt:setText("ATTENTION")

    modal_thread.init(self, viz, screen)
end

function reinforceDialog:onResume()
    self:waitForLocks('modal')

    mui.activateScreen(self.screen)

    local screen = self.screen
    local val = 0
    while val < 1 do
        if val <= 1 then
            val = math.min(1, val + .02)
            screen.binder.pnl.binder.progress:setProgress(val)
        end

        self:yield()
    end

    rig_util.wait(50)

    return modalDialog.OK
end

dialogs = util.tmerge(dialogs, { reinforceDialog = reinforceDialog })
