local MainScene = class("MainScene", cc.load("mvc").ViewBase)
local Snake = import(".Snake")
local Start = import(".Start")
local BalloonsContainer = import(".BalloonsContainer")

function MainScene:onCreate()
    self:enableNodeEvents()
    
	local spriteFrameCache = cc.SpriteFrameCache:getInstance()
	spriteFrameCache:addSpriteFrames("gui.plist", "gui.png")

    local start = Start:create()
        :move(0, 0)
        :addTo(self, 100)

    local snake = Snake:create(handler(self, self.onSnakeMove))
        :move(display.cx, display.cy)
        :addTo(self)
    self.m_snake = snake
    self.m_balloonsContainer = BalloonsContainer:create() 
        :move(display.cx, display.cy)
        :addTo(self)

    self:addTouch()

    self.m_schedulerCollision = dd.scheduler:scheduleScriptFunc(handler(self, self.updateCollision), 0.01, false)
end

function MainScene:onSnakeMove(diffY)
end

function MainScene:updateCollision()
    local balloonsList = self.m_balloonsContainer:getBalloonsList()
    for index, balloon in pairs(balloonsList) do
        local balloonPos = cc.p(balloon:getPositionX(), balloon:getPositionY())
        local headPos = self.m_snake:getHeadPos()

        dump(balloon:getBoundingBox())
        dump(headPos)
        if cc.rectContainsPoint(balloon:getBoundingBox(), headPos) then
            local snakeNum = self.m_snake:getNumber()
            local ret = balloon:dealSnakeNumber(snakeNum)
            if type(ret) == "number" then
                snakeNum = ret
                self.m_snake:setNumber(snakeNum)
                balloon:removeFromParent()
                balloonsList[index] = nil
            else
                print("--------------------------------", ret)
            end

            break
        end
    end
end

function MainScene:addTouch()
    local listener = cc.EventListenerTouchOneByOne:create()
    listener:registerScriptHandler(handler(self, self.onTouchBegin), cc.Handler.EVENT_TOUCH_BEGAN)
    listener:registerScriptHandler(handler(self, self.onTouchMoved), cc.Handler.EVENT_TOUCH_MOVED)
    listener:registerScriptHandler(handler(self, self.onTouchEnd), cc.Handler.EVENT_TOUCH_ENDED)
    listener:registerScriptHandler(handler(self, self.onTouchEnd), cc.Handler.EVENT_TOUCH_CANCELLED)

    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self)
end

function MainScene:onTouchBegin(touch, event)
    self:unScheduleRecoverDirection()
    self:unScheduleSnakeDirectionChange()
    self.m_scheduler = dd.scheduler:scheduleScriptFunc(handler(self, self.updateSnakeDirection), 0.01, false)

    return true
end

function MainScene:onTouchMoved(touch, event)

end

function MainScene:onTouchEnd(touch, event)
    self:unScheduleSnakeDirectionChange()
    self:unScheduleRecoverDirection()
    self.m_recoverScheduler = dd.scheduler:scheduleScriptFunc(handler(self, self.recoverSnakeDirection), 0.01, false)
end

function MainScene:unScheduleSnakeDirectionChange()
    if self.m_scheduler then
        dd.scheduler:unscheduleScriptEntry(self.m_scheduler)
        self.m_scheduler = nil
    end
end

function MainScene:unScheduleRecoverDirection()
    if self.m_recoverScheduler then
        dd.scheduler:unscheduleScriptEntry(self.m_recoverScheduler)
        self.m_recoverScheduler = nil
    end
end

function MainScene:updateSnakeDirection()
    local curDirection = self.m_snake:getDirection()
    if curDirection < 150 then
        self.m_snake:setDirection(curDirection + 4)
    else
        self:unScheduleSnakeDirectionChange()
    end
end

function MainScene:recoverSnakeDirection()
    local curDirection = self.m_snake:getDirection()
    if curDirection > 30 then
        self.m_snake:setDirection(curDirection - 4)
    else
        self:unScheduleRecoverDirection()
    end
end

function MainScene:onCleanup()
    if self.m_schedulerCollision then
        dd.scheduler:unscheduleScriptEntry(self.m_schedulerCollision)
    end

    self:unScheduleRecoverDirection()
    self:unScheduleSnakeDirectionChange()
end

return MainScene
