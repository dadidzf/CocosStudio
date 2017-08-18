local GameScene = class("GameScene", cc.load("mvc").ViewBase)
GameScene.RESOURCE_FILENAME = "game.csb"
GameScene.RESOURCE_BINDING = {
    ["Panel_2"] = {varname = "m_paneltop"},
    ["Panel_1"] = {varname = "m_color"},
    ["Panel_di"] = {varname = "m_di"},
    ["BitmapFontLabel_2"] = {varname = "m_height"},
    ["Button_1"] = {varname = "m_btnpause", events = {{ event = "click", method = "onPause" }}}
}
local MODULE_PATH = ...
local Star = import(".Star")
local Box = import(".Box")

function GameScene:onCreate( ... )
    self:enableNodeEvents()--开启节点事件，让节点在OnCleanup()时移除定时器可执行

    self.m_direction = 1

    self.m_boxlist = {}
    local resourceNode = self:getResourceNode()
    resourceNode:setContentSize(display.size)
    ccui.Helper:doLayout(resourceNode)

    local star = Star:create(nil)
    star:setPosition(cc.p(display.cx, 0))
    local x,y = star:getPosition()
    local y0 = 280-y
    self.backspeed =300
    local move0,move1
    move0 = cc.MoveBy:create(y0/self.backspeed,cc.p(0,y0))
    move1 = cc.EaseInOut:create(move0,1)
    star:runAction(move1)
    self:addChild(star, 1)

    self.height = 0
    self.heightest = 0
    self.m_height:setString(tostring(self.height))
    self.m_speed = 500--方块下落速度

    local meteor = cc.ParticleMeteor:create()
    self.m_meteor1 = meteor
    meteor:setTexture(cc.Director:getInstance():getTextureCache():addImage("ball_white.png"))
    meteor:setPosition(12.5, 12.5)
    meteor:setSpeed(100)
    meteor:setDuration(-1)--设置持续时间-1为永久
    meteor:setStartSize(20)
    meteor:setEndSize(50)
    meteor:setGravity(cc.p(0,0))--设置引力值
    meteor:setAngle(1)--设置角度
    meteor:setLife(0.25)
    meteor:setEmissionRate(120)--发射频率
    star:addChild(meteor)    
    self.m_star = star
    self.m_meteor = meteor
    self:addTouch()
    self:moveup(1000)
    self.m_scheduler = dd.scheduler:scheduleScriptFunc(handler(self, self.updateBox), 1, false)
    self.m_scheduler2= dd.scheduler:scheduleScriptFunc(handler(self, self.checkCollision), 0.01, false)
    self.m_scheduler3= dd.scheduler:scheduleScriptFunc(handler(self, self.starRising), 0.1, false)

end

function GameScene:checkCollision()
    for k,l_box in pairs(self.m_boxlist) do
        local x, y
        x,y = l_box:getPosition()
        local x2,y2
        x2,y2 = self.m_star:getPosition()

        if x2>=(x-self.m_size.width/2) and x2<=(x+self.m_size.width/2) and y2>=(y-self.m_size.height/2) and y2<=(y+self.m_size.height/2)
            then
            self:gameover()
        end
    end

    local x3, y3
    x3,y3 = self.m_star:getPosition()
    if x3<0 then
        self.m_star:setPosition(cc.p(640,y3))
        else if x3>640 then
            self.m_star:setPosition(cc.p(0,y3))
        end
    end
end

function GameScene:starRising()
    self.height = self.height+1
    self.m_height:setString(tostring(self.height))
end

function GameScene:updateBox()
    local randx1 = math.random(-260,240)
    local distance = math.random(600,700)
    local randx2 = randx1+distance
    self:addBox(self.m_speed,randx1)
    self:addBox(self.m_speed,randx2)
    self.m_speed = self.m_speed+1
end

function GameScene:addBox(speed,box_x)
    local box = Box:create(nil)
    local index = #self.m_boxlist+1
    self.m_boxlist[index] = box
    self.m_size = box:getContentSize()
    print("w,h",self.m_size.width,self.m_size.height)
    local move3 = cc.MoveBy:create(2000/speed, cc.p(0, 2000))
    local move3back = move3:reverse()
    box:setPosition(cc.p(box_x, 2000))
    self.m_paneltop:addChild(box, 2)

    local removeFunc = function ( ... )
        box:removeFromParent()
        self.m_boxlist[index] = nil
    end

    local callBackFunc = cc.CallFunc:create(removeFunc)
    local sequence = cc.Sequence:create(move3back, callBackFunc)

    box:runAction(sequence)
end

function GameScene:moveup(speed)
    self.m_meteor:setGravity(cc.p(0,-speed*2))
end

function GameScene:onPause()
    local GamePause = import(".GamePause",MODULE_PATH)
    local pauseNode = GamePause:create(self)
    pauseNode:setPosition(display.cx, display.cy)
    self:addChild(pauseNode,100)

    for k,l_box in pairs(self.m_boxlist) do
        l_box:pause()
    end 

    cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.m_scheduler)
    cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.m_scheduler2)
    cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.m_scheduler3)
end

function GameScene:onResume()
    for k,l_box in pairs(self.m_boxlist) do
        l_box:resume()
    end 
    self.m_scheduler = dd.scheduler:scheduleScriptFunc(handler(self, self.updateBox), 1, false)
    self.m_scheduler2= dd.scheduler:scheduleScriptFunc(handler(self, self.checkCollision), 0.01, false)
    self.m_scheduler3= dd.scheduler:scheduleScriptFunc(handler(self, self.starRising), 0.1, false)
end


function GameScene:addTouch()
    local listener = cc.EventListenerTouchOneByOne:create()
    listener:registerScriptHandler(handler(self, self.onTouchBegin), cc.Handler.EVENT_TOUCH_BEGAN)
    listener:registerScriptHandler(handler(self, self.onTouchMoved), cc.Handler.EVENT_TOUCH_MOVED)
    listener:registerScriptHandler(handler(self, self.onTouchEnd), cc.Handler.EVENT_TOUCH_ENDED)
    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self.m_star)
    self.m_listener = listener
end

function GameScene:onTouchBegin(touch, event)
    local speed = 500
    if self.m_direction == 1 then
        self.moveleft = cc.MoveBy:create(1000/speed, cc.p(-1000,0))
        self.m_star:runAction(self.moveleft)
            if self.moveright ~= nil then
                self.m_star:stopAction(self.moveright)
            end
        self.m_direction = 2
        else if self.m_direction == 2 then
            self.moveright = cc.MoveBy:create(1000/speed, cc.p(1000,0))
            self.m_star:runAction(self.moveright)
                if self.moveleft ~= nil then
                    self.m_star:stopAction(self.moveleft)
                end
            self.m_direction = 1
        end
    end
    return true
end

function GameScene:onTouchEnd(touch, event)

end

function GameScene:onTouchMoved(touch, event)
end

function GameScene:onCleanup()
    cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.m_scheduler)
    cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.m_scheduler2)
    cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.m_scheduler3)

end

function GameScene:gameover()
    print("游戏结束")
    cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.m_scheduler)
    cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.m_scheduler2)
    cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.m_scheduler3)

    for k,l_box in pairs(self.m_boxlist) do
        l_box:stopAllActions()
    end

    local meteor2 = cc.ParticleFlower:create()
    meteor2:setTexture(cc.Director:getInstance():getTextureCache():addImage("ball_white.png"))
    meteor2:setPosition(12.5, 12.5)
    meteor2:setSpeed(150)
    meteor2:setRadialAccel(0)--设置加速度变化  
    meteor2:setDuration(0.1)--设置持续时间-1为永久
    meteor2:setStartSize(20)
    meteor2:setEndSize(50)
    meteor2:setGravity(cc.p(0,0))--设置引力值
    meteor2:setAngle(360)--设置角度
    meteor2:setLife(0.5)
    meteor2:setEmissionRate(500)--发射频率

    self.m_meteor1:removeFromParent()
    self.m_star:setOpacity(0)
    self.m_star:addChild(meteor2)
    self.m_star:stopAllActions()

    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:removeEventListener(self.m_listener)

    local gamefailed = import(".GameFailed",MODULE_PATH)
    local failedNode = gamefailed:create(self)
    failedNode:setPosition(display.cx, display.cy)
    self:addChild(failedNode)
end

function GameScene:getHeight()
    return self.height
end

function GameScene:getHeightest()
    if self.height>=self.heightest then
        self.heightest=self.height
    end
    return self.heightest 
end

return GameScene