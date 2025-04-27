local mainframePanel = include("hud/mainframe_panel").panel

local oldMainFramePanel = mainframePanel.show
mainframePanel.show = function(self)
    oldMainFramePanel(self)
    -- self._panel.binder.incognitaProfileAnim:getProp():setRenderFilter(nil)
    -- self._panel.binder.incognitaProfileAnim:setVisible(true)
    -- self._panel.binder.incognitaProfileAnim:bindAnim("portraits/incognita_face")
    -- self._panel.binder.incognitaProfileAnim:bindBuild("portraits/incognita_face")
    self._panel.binder.VSChar:setText("VS")
end
