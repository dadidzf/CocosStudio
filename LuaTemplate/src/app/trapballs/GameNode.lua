local GameNode = class("GameNode", cc.Node)

local Balls = import(".Balls")
local ExtendLine = import(".ExtendLine")
local EdgeSegments = import(".EdgeSegments")
local PointsManager = import(".PointsManager")

function GameNode:ctor()
    self.m_pointsMgr = PointsManager:create()
    local jsonStr = cc.FileUtils:getInstance():getStringFromFile("level1.json")
    self.m_pointsMgr:load(jsonStr)

    self.m_edgeSegments = EdgeSegments:create(self.m_pointsMgr)
        :addTo(self)

    self.m_balls = Balls:create()
        :addTo(self)

    self:addTouch()
    self:addPhysicListener()
end

-- Physic Contact
function GameNode:addPhysicListener()
    local contactListener = cc.EventListenerPhysicsContact:create()
    contactListener:registerScriptHandler(handler(self, self.onContactBegin), cc.Handler.EVENT_PHYSICS_CONTACT_BEGIN)

    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(contactListener, self)
end

function GameNode:onContactBegin(contact)
    local shapeA = contact:getShapeA()
    local shapeB = contact:getShapeB()
    local nodeA = shapeA:getBody():getNode()
    local nodeB = shapeB:getBody():getNode()

    if not (nodeA and nodeB) then
        return
    end

    local shapeACategory = shapeA:getCategoryBitmask()
    local shapeBCategory = shapeB:getCategoryBitmask()
    local cateGoryAdd = shapeACategory + shapeBCategory

    -- segment with extend line ends
    if cateGoryAdd == dd.Constants.CATEGORY.EDGE_SEGMENT + dd.Constants.CATEGORY.EXTENDLINE_BOTH_ENDS then
        self:dealExtendlineCollision(shapeA, shapeB)
        return false
    end

    -- segment with ball
    if cateGoryAdd == dd.Constants.CATEGORY.EDGE_SEGMENT + dd.Constants.CATEGORY.BALL then
        return true
    end

    -- ball with extend line ends
    if cateGoryAdd == dd.Constants.CATEGORY.EXTENDLINE_BOTH_ENDS + dd.Constants.CATEGORY.BALL then
        self:dealExtendlineCollision(shapeA, shapeB)
        return true
    end

    -- ball with extend line
    if cateGoryAdd == dd.Constants.CATEGORY.EXTENDLINE + dd.Constants.CATEGORY.BALL then
        print("Game Over !")
        return false
    end
end

function GameNode:dealExtendlineCollision(shapeA, shapeB)
    local shape
    local shapeACategory = shapeA:getCategoryBitmask()
    if shapeACategory == dd.Constants.CATEGORY.EXTENDLINE_BOTH_ENDS then
        shape = shapeA
    else
        shape = shapeB
    end
        
    self.m_extendLine:collision(shape)
    if not self.m_extendLine:isExtend() then
        local pts = self.m_extendLine:getOffsets()
        local pos = cc.p(self.m_extendLine:getPositionX(), self.m_extendLine:getPositionY())
        self.m_pointsMgr:addLine(cc.pAdd(pts[1], pos), cc.pAdd(pts[2], pos))
        self.m_extendLine:removeFromParent()
        self.m_extendLine = nil

        local scheduler
        local segment = self.m_edgeSegments
        local callBack = function ()
            if not tolua.isnull(segment) then
                segment:updatePhysicBody()
            end
            dd.scheduler:unscheduleScriptEntry(scheduler)
        end

        scheduler = dd.scheduler:scheduleScriptFunc(callBack, 0, false)
    end
end

-- Touch
function GameNode:addTouch()
    local listener = cc.EventListenerTouchOneByOne:create()
    listener:registerScriptHandler(handler(self, self.onTouchBegin), cc.Handler.EVENT_TOUCH_BEGAN)
    listener:registerScriptHandler(handler(self, self.onTouchMoved), cc.Handler.EVENT_TOUCH_MOVED)
    listener:registerScriptHandler(handler(self, self.onTouchEnd), cc.Handler.EVENT_TOUCH_ENDED)
    listener:registerScriptHandler(handler(self, self.onTouchEnd), cc.Handler.EVENT_TOUCH_CANCELLED)

    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self)
end

function GameNode:onTouchBegin(touch, event)
    local pt = self:convertToNodeSpace(touch:getLocation())
    self.m_extendLine = ExtendLine:create(pt.x < 0, 300)
        :addTo(self)

    self:updateExtendLinePos(touch)
    return true
end

function GameNode:onTouchMoved(touch, event)
    self:updateExtendLinePos(touch)
end

function GameNode:onTouchEnd(touch, event)
    self:updateExtendLinePos(touch)
    self.m_extendLine:startExtend()
end

function GameNode:updateExtendLinePos(touch)
    local pt = self:convertToNodeSpace(touch:getLocation())
    pt.y = pt.y + 100

    self.m_extendLine:setPosition(pt.x, pt.y)
end

return GameNode