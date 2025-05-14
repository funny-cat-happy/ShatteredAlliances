local talkinghead = include("client/fe/talkinghead")
local util = include("client_util")
local cdefs = include("client_defs")
local mathutil = include("modules/mathutil")
local rig_util = include("gameplay/rig_util")
local mui_defs = include("mui/mui_defs")
local mui = include("mui/mui")

talkinghead.ShowLine = function(self, idx, immediateMode)
    self.line_idx = idx

    if self.next_button then
        self.next_button:setText(idx == #self.script and STRINGS.UI.OK or STRINGS.UI.NEXT) --localize me!
    end

    if self.prev_button then
        self.prev_button:setText(STRINGS.UI.PREV)
        self.prev_button:setVisible(idx > 1)
    end


    self:Stop()

    if idx < #self.script then
        if self.next_button then
            self.next_button:blink(0)
        end
    end

    local line = self.script[idx]
    self.line = line

    --play the voice
    local playing_voice = false

    if not self.notransitions and (line.anim ~= self.talking_head_anim or self.line_idx == 1) then
        self.widget:createTransition("activate_left")
    end
    self.talking_head_anim = line.anim

    --set up the talker and the talker's name
    if self.profile and line.anim then
        if self.profileImg then
            self.profileImg:setVisible(false)
        end

        self.profile:setVisible(true)
        if line.build then
            self.profile:bindBuild(line.build)
        else
            self.profile:bindBuild(line.anim)
        end
        self.profile:bindAnim(line.anim)
    end

    if self.profileImg and line.img then
        if self.profile then
            self.profile:setVisible(false)
        end

        self.profileImg:setVisible(true)
        self.profileImg:setImage(line.img)
    end

    if line.name then
        self.name:setText(line.name .. ":")
    else
        self.name:setText("")
    end




    --spool text and play a typing sound
    local textLength = string.len(string.gsub(string.gsub(line.text, " ", ""), "\n", ""))

    local function dotextspool()
        if immediateMode then
            self.body_text:spoolText(line.text, 9999)
        else
            self.body_text:spoolText(line.text, line.voice and 30 or 60)
            MOAIFmodDesigner.playSound("SpySociety/HUD/menu/text_print_2_LP", "talkinghead_type")
            self._typeThread = MOAICoroutine.new()
            local txt = self.body_text
            self._typeThread:run(function()
                while txt:isSpooling() do
                    coroutine.yield()
                end
                MOAIFmodDesigner.stopSound("talkinghead_type")
                self._typeThread = nil
            end)
        end
    end


    --if we are playing a voice, auto-advance the dialog when it ends. If no voice, the player will just have to click next
    if line.voice then
        self._scriptThread = MOAICoroutine.new()
        self._scriptThread:run(function()
            if self.line_idx == 1 and self.do_init_delay then
                rig_util.wait(.3 * cdefs.SECONDS)
            end

            dotextspool()
            MOAIFmodDesigner.playSound(line.voice, "talkinghead_voice")

            while MOAIFmodDesigner.isPlaying("talkinghead_voice") or MOAIFmodDesigner.isPlaying("talkinghead_type") do
                coroutine.yield()
            end

            if line.delay then
                rig_util.wait(line.delay * cdefs.SECONDS)
            end

            if self.line_idx < #self.script then
                self:ShowLine(self.line_idx + 1)
            else
                if self.next_button then
                    self.next_button:blink(0.2, 2, 2, { r = 1, g = 1, b = 1, a = 1 })
                end
            end
        end)
    else
        dotextspool()
    end
end
