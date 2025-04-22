local boardrig = include("gameplay/boardrig")
local resources = include("resources")
local unitrig = include("gameplay/unitrig")
local doorrig2 = include("gameplay/doorrig2")
local zonerig = include("gameplay/zonerig")
local itemrig = include("gameplay/itemrig")
local wallrig2 = include("gameplay/wallrig2")
local wall_vbo = include("gameplay/wall_vbo")
local postrig = include("gameplay/postrig")
local cellrig = include("gameplay/cellrig")
local coverrig = include("gameplay/coverrig")
local pathrig = include("gameplay/pathrig")
local agentrig = include("gameplay/agentrig")
local decorig = include("gameplay/decorig")
local lightrig = include("gameplay/lightrig")
local overlayrigs = include("gameplay/overlayrigs")
local sound_ring_rig = include("gameplay/sound_ring_rig")
local world_sounds = include("gameplay/world_sounds")
local fxbackgroundrig = include("gameplay/fxbackgroundrig")
local hilite_radius = include("gameplay/hilite_radius")
local viz_thread = include("gameplay/viz_thread")
local util = include("modules/util")
local mathutil = include("modules/mathutil")
local array = include("modules/array")
local animmgr = include("anim-manager")
local cdefs = include("client_defs")
local serverdefs = include("modules/serverdefs")
local simdefs = include("sim/simdefs")
local simquery = include("sim/simquery")
local level = include("sim/level")
local modalDialog = include("states/state-modal-dialog")

local oldOnSimEvent = boardrig.onSimEvent

boardrig.onSimEvent = function(self, ev, eventType, eventData)
    if eventType == simdefs.EV_LOS_REFRESH then
        if eventData.seer and (eventData.seer:getPlayerOwner() == self:getLocalPlayer() or eventData.seer:getPlayerOwner():getPlayerAlly(self:getSim()) == self:getLocalPlayer()) then
            if #eventData.cells > 0 and eventData.seer:getLocation() then
                local reveal_los = include("gameplay/viz_handlers/reveal_los")
                self._game.viz:addThread(reveal_los(self, ev))
            else
                self:revealAll(self:getClientCells(eventData.cells))
            end
            self._pathRig:refreshAllTracks()
        elseif eventData.player and (eventData.player == self:getLocalPlayer() or eventData.player:getPlayerAlly(self:getSim()) == self:getLocalPlayer()) then
            self:revealAll(self:getClientCells(eventData.cells))
        end

        if eventData.seer then
            self:refreshLOSCaster(eventData.seer:getID())
        end
    else
        return oldOnSimEvent(self, ev, eventType, eventData)
    end
end

local function getLOSCasterSource(boardRig, seer)
    local x, y = seer:getLocation()
    local range = seer:getTraits().LOSrange

    if seer:getTraits().mainframe_camera then
        -- HAX
        local facing = seer:getFacing()
        if facing % 2 == 1 then
            local dx, dy = simquery.getDeltaFromDirection(facing)
            x, y = x - dx * 0.5, y - dy * 0.5
            if range then
                range = range + mathutil.dist2d(0, 0, dx, dy) * 0.5
            end
        end
    end

    x, y = boardRig:cellToWorld(x, y)
    range = range and boardRig:cellToWorldDistance(range)

    return x, y, range
end

boardrig.refreshLOSCaster = function(self, seerID)
    local seer = self._game.simCore:getUnit(seerID)
    local localPlayer = self:getLocalPlayer()

    -- The hasLOS condition needs to (unfortunately) be matched with whatever is determined in sim:refreshUnitLOS in order
    -- to correctly reflect the sim state.
    local hasLOS = seer and seer:getLocation() ~= nil
    hasLOS = hasLOS and seer:getTraits().hasSight and not seer:isKO() and not seer:getTraits().grappler
    hasLOS = hasLOS and self:canSeeLOS(seer)

    if hasLOS then
        local unitRig = self:getUnitRig(seerID)
        local bAgentLOS = seer:getPlayerOwner() == localPlayer or
            seer:getPlayerOwner():getPlayerAlly(self:getSim()) == localPlayer
        local bEnemyLOS = not bAgentLOS and not seer:isPC()

        if unitRig == nil or unitRig.refreshLOSCaster == nil or not unitRig:refreshLOSCaster(seerID) then
            local x0, y0, range = getLOSCasterSource(self, seer)
            local losArc = simquery.getLOSArc(seer)
            assert(losArc >= 0, losArc)

            local arcStart = seer:getFacingRad() - losArc / 2
            local arcEnd = seer:getFacingRad() + losArc / 2

            if bAgentLOS then
                self._game.shadow_map:insertLOS(KLEIShadowMap.ALOS_DIRECT, seerID, arcStart, arcEnd, range, x0, y0)
            elseif bEnemyLOS then
                self._game.shadow_map:insertLOS(KLEIShadowMap.ELOS_DIRECT, seerID, arcStart, arcEnd, range, x0, y0)
                if seer:getTraits().LOSperipheralArc then
                    local range = seer:getTraits().LOSperipheralRange and
                        self:cellToWorldDistance(seer:getTraits().LOSperipheralRange)
                    local losArc = seer:getTraits().LOSperipheralArc
                    local arcStart = seer:getFacingRad() - losArc / 2
                    local arcEnd = seer:getFacingRad() + losArc / 2

                    self._game.shadow_map:insertLOS(KLEIShadowMap.ELOS_PERIPHERY, seerID + simdefs.SEERID_PERIPHERAL,
                        arcStart, arcEnd, range, x0, y0)
                end
            end
        end

        if bEnemyLOS then
            self:refreshBlindSpots(seer)
        else
            self:clearBlindSpots(seerID)
        end
    else
        self:clearBlindSpots(seerID)

        self._game.shadow_map:removeLOS(seerID)
        self._game.shadow_map:removeLOS(seerID + simdefs.SEERID_PERIPHERAL)
    end
end

boardrig.canPlayerSeeUnit = function(self, unit)
    local localPlayer = self:getLocalPlayer()
    if not localPlayer then
        return true -- Spectator
    else
        if unit:getTraits().noghost and localPlayer:isPC() and unit:getLocation() and localPlayer:getLastKnownCell(self._game.simCore, unit:getLocation()) then
            return true -- Non-ghostables are always visible in presentation (not necessarily 'visible' sim-speaking)
        else
            return self:getSim():canPlayerSeeUnit(localPlayer, unit) or
            self:getSim():canPlayerSeeUnit(localPlayer:getPlayerAlly(self:getSim()), unit)
        end
    end
end
