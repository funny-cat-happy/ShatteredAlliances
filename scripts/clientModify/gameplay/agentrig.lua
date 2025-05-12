local agentrig = include("gameplay/agentrig").rig
---comment
---@param self table
---@param unit simunit
---@param interest any
---@return boolean
agentrig.shouldDrawInterest = function(self, unit, interest)
    if not unit or not interest then
        return false
    end

    if unit:isDead() or unit:isKO() then
        return false
    end

    if unit:getPlayerOwner():isAlly() then
        return true
    end

    if interest.investigated then
        return false
    end

    if unit:isAlerted() and unit:getTraits().vip then
        return false
    end

    return true
end

agentrig.drawInterest = function(self, interest, alerted)
    local x0, y0 = self._boardRig:cellToWorld(interest.x, interest.y)
    local sim = self._boardRig:getSim()

    if sim:drawInterestPoints()
        or self:getUnit():getTraits().patrolObserved
        or interest.alwaysDraw
        or self._boardRig:getLocalPlayer() == nil
        or self._boardRig:getLocalPlayer():isNPC()
        or self:getUnit():getTraits().ally then
        if not self.interestProp then
            self._boardRig._game.fxmgr:addAnimFx({
                kanim = "gui/guard_interest_fx",
                symbol = "effect",
                anim = "in",
                x =
                    x0,
                y = y0
            })

            self.interestProp = self:createHUDProp("kanim_hud_interest_point_fx", "interest_point", "in",
                self._boardRig:getLayer("ceiling"), nil, x0, y0)
            self.interestProp:setListener(KLEIAnim.EVENT_ANIM_END,
                function(anim, animname)
                    if animname == "in" then
                        self.interestProp:setCurrentAnim("idle")
                    end
                end)

            self.interestProp:setSymbolModulate("interest_border", 255 / 255, 255 / 255, 0 / 255, 1)
            self.interestProp:setSymbolModulate("down_line", 255 / 255, 255 / 255, 0 / 255, 1)
            self.interestProp:setSymbolModulate("down_line_moving", 255 / 255, 255 / 255, 0 / 255, 1)
            self.interestProp:setSymbolModulate("interest_line_moving", 255 / 255, 255 / 255, 0 / 255, 1)
        end

        if interest.alerted or alerted then
            self.interestProp:setSymbolVisibility("thought_alert", true)
            self.interestProp:setSymbolVisibility("thought_investigate", false)
            self.interestProp:setSymbolVisibility("thought_bribe", false)
        else
            self.interestProp:setSymbolVisibility("thought_alert", false)
            self.interestProp:setSymbolVisibility("thought_investigate", true)
            self.interestProp:setSymbolVisibility("thought_bribe", false)
        end

        self.interestProp:setVisible(true)
        self.interestProp:setLoc(x0, y0)
    end
end
