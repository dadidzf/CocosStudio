local GameScene = class("GameScene", cc.load("mvc").ViewBase)
local Effect = import(".Effect")
local StringMgr = import(".StringMgr")
local GameEndLayer = import(".GameEndLayer")

local _distance = 5

function GameScene:onCreate()
    -- background
    local backGround = cc.Sprite:create("background.png")
        :move(display.cx, display.cy)
        :addTo(self, -2)

    -- touch
    self:addTouch()
    self:onUpdate(handler(self, self.update))

    -- labels
    self.m_timeLabel = ccui.Text:create("0.00", "", 96)
        :move(display.cx, display.height - 60)
        :addTo(self)
        :setColor(cc.WHITE)

    self.m_rangeLabel = ccui.Text:create("(+/- 0.1)", "", 32)
        :move(display.cx, display.height - 150)
        :addTo(self)
        :setColor(cc.WHITE)

    self.m_scoreLabel = cc.Label:createWithBMFont("score.fnt", "0") 
        :move(display.cx, display.height*0.75)
        :addTo(self)
    self.m_score = 0

    self.m_gameTips = ccui.Text:create(StringMgr.oneSecondTips, "", 32)
        :move(display.cx, display.height*0.2)
        :addTo(self)
        :setTouchEnabled(false)
    self.m_gameTips:runAction(cc.RepeatForever:create(cc.Blink:create(2, 1)))

    self.m_gameFinger1 = ccui.ImageView:create("finger1.png")
        :move(display.cx, display.height*0.35)
        :addTo(self)
        :setScale(1.2)

    self.m_gameFinger = ccui.ImageView:create("finger.png")
        :move(display.cx, display.height*0.35)
        :addTo(self)

    self.m_gameFinger:setVisible(false)
    self.m_gameFinger1:runAction(
        cc.RepeatForever:create(
            cc.Sequence:create(
                cc.ScaleTo:create(1.0, 1.0),
                cc.CallFunc:create(function ()
                    self.m_gameFinger1:setVisible(false)
                    self.m_gameFinger:setVisible(true)
                end),
                cc.DelayTime:create(1.0),
                cc.CallFunc:create(function ()
                    self.m_gameFinger1:setVisible(true)
                    self.m_gameFinger:setVisible(false)
                end),
                cc.ScaleTo:create(1.0, 1.2),
                nil
                )
            )
        )

    self.m_isGameOver = false

    self:createEffect()
end

function GameScene:addTouch()
    local listener = cc.EventListenerTouchOneByOne:create()
    listener:registerScriptHandler(handler(self, self.onTouchBegin), cc.Handler.EVENT_TOUCH_BEGAN)
    listener:registerScriptHandler(handler(self, self.onTouchMoved), cc.Handler.EVENT_TOUCH_MOVED)
    listener:registerScriptHandler(handler(self, self.onTouchEnd), cc.Handler.EVENT_TOUCH_ENDED)

    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self)

    self.m_listener = listener
end

function GameScene:update(t)
    if self.m_startPressTime then
        local diffTime = socket.gettime() - self.m_startPressTime
        self.m_timeLabel:setString(string.format("%.3f", diffTime))

        if self.m_effect then
            self.m_effect:updateProgress(diffTime - math.floor(diffTime))
        end
    end
end

function GameScene:onTouchBegin(touch, event)
    if self.m_particle then
        return false
    end
    
    if self.m_gameTips then
        self.m_gameTips:removeFromParent()
        self.m_gameTips = nil
    end

    if self.m_gameFinger then
        self.m_gameFinger:removeFromParent()
        self.m_gameFinger = nil
    end

    if self.m_gameFinger1 then
        self.m_gameFinger1:removeFromParent()
        self.m_gameFinger1 = nil
    end
    
    self.m_startPressTime = socket.gettime()
    self.m_timeLabel:setString("0.00")

    self:createEffect()

    self.m_particle = cc.ParticleSystemQuad:create("particle_texture.plist") 
        :addTo(self)
        :move(self:convertToNodeSpace(touch:getLocation()))
    return true
end

function GameScene:onTouchMoved(touch, event)
    if self.m_particle then
        self.m_particle:move(self:convertToNodeSpace(touch:getLocation()))
    end
end

function GameScene:createEffect()
    if not tolua.isnull(self.m_effect) then
        self.m_effect:removeFromParent()
        self.m_effect = nil
    end

    if self.m_score >= _distance*8 then
        return
    end
    
    self.m_effect = Effect:create(self.m_score <= _distance and 6 or nil)
        :addTo(self, -1)
        :move(display.cx, display.cy)
end

function GameScene:onTouchEnd(touch, event)
    self:update()
    self.m_finalPressTime = socket.gettime() - self.m_startPressTime
    self.m_timeLabel:setString(string.format("%.3f", self.m_finalPressTime))
    self.m_startPressTime = nil

    if self:isGameEnd() then
        print("Game End !")
        local gameEndLayer = GameEndLayer:create(self.m_score)
            :addTo(self)
        self.m_scoreLabel:runAction(cc.FadeTo:create(1.0, 0))
        
        if not tolua.isnull(self.m_effect) then
            self.m_effect:removeFromParent()
            self.m_effect = nil
        end

        if cc.UserDefault:getInstance():getBoolForKey("sound", true) then
            self.m_audioHandler = AudioEngine.getInstance():playEffect("over.mp3")
        end
    else
        self.m_score = self.m_score + 1
        self.m_rangeLabel:setString(string.format("(+/- %.2f)", self:getCurrentRange()))
        self.m_scoreLabel:runAction(cc.Sequence:create(
            cc.ScaleTo:create(0.3, 1.6),
            cc.CallFunc:create(function ()
                self.m_scoreLabel:setString(tostring(self.m_score))
            end),
            cc.ScaleTo:create(0.3, 1),
            nil
            ))

        if cc.UserDefault:getInstance():getBoolForKey("sound", true) then
            self.m_audioHandler = AudioEngine.getInstance():playEffect("score.mp3")
        end
    end

    self.m_particle:removeFromParent()
    self.m_particle = nil
    --AudioEngine.getInstance():stopEffect(self.m_audioHandler)
end

function GameScene:isGameEnd()
    local val = math.floor(1000*(self.m_finalPressTime - 1.0))/1000
    if math.abs(val) > self:getCurrentRange() then
        return true
    else
        return false
    end
end

function GameScene:getCurrentRange()
    local distance = _distance
    local ret = 0.1

    if self.m_score < distance*8 then
        if self.m_score > 7*distance then
            ret = 0.03
        elseif self.m_score > 6*distance then
            ret = 0.04
        elseif self.m_score > 5*distance then
            ret = 0.05
        elseif self.m_score > 4*distance then
            ret = 0.06
        elseif self.m_score > 3*distance then
            ret = 0.07
        elseif self.m_score > 2*distance then
            ret = 0.08
        elseif self.m_score > 1*distance then
            ret = 0.09
        else
            ret = 0.1
        end
    else
        if self.m_score > 10*distance then
            ret = 0.03
        elseif self.m_score > 9*distance then
            ret = 0.05
        else
            ret = 0.08
        end
    end

    return ret
end

return GameScene
