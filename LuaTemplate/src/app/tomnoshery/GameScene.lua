local GameScene = class("GameScene", cc.load("mvc").ViewBase)
local Plate = import(".Plate")
local Food = import(".Food")

GameScene.RESOURCE_FILENAME = "gamescene.csb"

function GameScene:onCreate()

    local resourceNode = self:getResourceNode()
    resourceNode:setContentSize(display.size)
    ccui.Helper:doLayout(resourceNode)
    
    local food = Food:create(nil)
    self.m_food = food
    self.m_food2 = food
    food:setPosition(cc.p(320,480))
    self:addChild(food,2)
    self.m_platelist = {}
    self:addTouch()
    self.m_scheduler = dd.scheduler:scheduleScriptFunc(handler(self, self.updatePlate), 1, false)
    self.m_scheduler2 = dd.scheduler:scheduleScriptFunc(handler(self, self.checkCollision), 0.01,false)
end

function GameScene:addTouch()
    local listener = cc.EventListenerTouchOneByOne:create()
    listener:registerScriptHandler(handler(self, self.onTouchBegin), cc.Handler.EVENT_TOUCH_BEGAN)
    listener:registerScriptHandler(handler(self, self.onTouchMoved), cc.Handler.EVENT_TOUCH_MOVED)
    listener:registerScriptHandler(handler(self, self.onTouchEnd), cc.Handler.EVENT_TOUCH_ENDED)
    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self.m_food)
    self.m_listener = listener
end

function GameScene:addPlate(speed)
    local plate = Plate:create(nil)
    self.m_size = plate:getContentSize()
    local index = #self.m_platelist+1
    self.m_platelist[index] = plate
    plate:setPosition(cc.p(620, 220))
    local move1 = cc.MoveBy:create(300/speed, cc.p(-300, 0))
    local move2 = cc.MoveBy:create(300/speed, cc.p(300, 0))
    local rotateAction = dd.CircleBy:create(240*3.14/speed, cc.p(320, 480), -180, false)
    local callbackfunc = cc.CallFunc:create(function (...)
        plate:removeFromParent()
        self.m_platelist[index] = nil
        end)
    local sequence = cc.Sequence:create(move1, rotateAction, move2, callbackfunc)
    plate:runAction(sequence)
    self:addChild(plate,1)
end

function GameScene:updatePlate()
    self:addPlate(200)
end

function GameScene:checkCollision()
    for k,l_plate in pairs(self.m_platelist) do
        local x, y
        x,y = l_plate:getPosition()
        local x2, y2
        x2,y2 = self.m_food2:getPosition()
        if x2 >= x-self.m_size.width/2 and x2 <= x+self.m_size.width/2 and y2 >= y-self.m_size.height/2 and y2 <= y+self.m_size.height/2
            then
            print("xiangzhuangle")
            local food = Food:create(nil)
            l_plate:addChild(food,2)
            food:setPosition(cc.p(self.m_size.width/2,self.m_size.height/2))
            self.m_food2:removeFromParent()
            cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.m_scheduler2)
            break
        end
    end
end

function GameScene:onTouchBegin()
    local move3 = cc.MoveBy:create(1,cc.p(-400,0))
    self.m_food:runAction(move3)
    local food2 = Food:create(nil)
    food2:setPosition(cc.p(320,480))
    self:addChild(food2,2)
    self.m_food2 = self.m_food
    self.m_food = food2
end

return GameScene