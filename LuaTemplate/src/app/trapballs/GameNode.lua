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
    if cateGoryAdd == dd.Constants.CATEGORY.EDGE_SEGMENT + dd.Constants.CATEGORY.EXTENDLINE then
        self:dealExtendlineCollision(self:getExtendLineSegmentCollisionPt(shapeA, shapeB))
        return false
    end

    -- segment with ball
    if cateGoryAdd == dd.Constants.CATEGORY.EDGE_SEGMENT + dd.Constants.CATEGORY.BALL then
        return true
    end

    -- ball with extend line ends
    if cateGoryAdd == dd.Constants.CATEGORY.EXTENDLINE_BOTH_ENDS + dd.Constants.CATEGORY.BALL then
        self:dealExtendlineCollision(self:getExtendLineBallCollisionPt(shapeA, shapeB))
        return true
    end

    -- ball with extend line
    if cateGoryAdd == dd.Constants.CATEGORY.EXTENDLINE + dd.Constants.CATEGORY.BALL then
        print("Game Over !")
        return false
    end
end

function GameNode:getExtendLineSegmentCollisionPt(shapeA, shapeB)
    local shapeACategory = shapeA:getCategoryBitmask()
    local shapeExtend, shapeSegment

    if shapeACategory == dd.Constants.CATEGORY.EDGE_SEGMENT then
        shapeExtend = shapeB
        shapeSegment = shapeA
    else
        shapeExtend = shapeA
        shapeSegment = shapeB
    end

    local segPtA = shapeSegment:getPointA()      
    local extendPos = cc.p(self.m_extendLine:getPositionX(), self.m_extendLine:getPositionY())

    if self.m_extendLine:isHorizontal() then
        return cc.p(segPtA.x, extendPos.y)
    else
        return cc.p(extendPos.x, segPtA.y)
    end
end

function GameNode:getExtendLineBallCollisionPt(shapeA, shapeB)
    local shapeACategory = shapeA:getCategoryBitmask()
    local extendPos = cc.p(self.m_extendLine:getPositionX(), self.m_extendLine:getPositionY())

    if shapeACategory == dd.Constants.CATEGORY.BALL then
        local pt = shapeB:getOffset()
        return cc.pAdd(extendPos, pt)
    else
        local pt = shapeA:getOffset()
        return cc.pAdd(extendPos, pt)
    end
end

function GameNode:dealExtendlineCollision(collisionPt)
    local startTime = socket.gettime()

    local extendPos = cc.p(self.m_extendLine:getPositionX(), self.m_extendLine:getPositionY())
    self.m_extendLine:collision(cc.pSub(collisionPt, extendPos))

    if not self.m_extendLine:isExtend() then
        local pts = self.m_extendLine:getOffsets()
        local pos = cc.p(self.m_extendLine:getPositionX(), self.m_extendLine:getPositionY())
        local pt1 = cc.pAdd(pts[1], pos)
        local pt2 = cc.pAdd(pts[2], pos)
        self.m_pointsMgr:adjustLine(pt1, pt2)
        self.m_pointsMgr:addLine(pt1, pt2, self.m_balls:getBallPosList())
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

    print("GameNode:dealExtendlineCollision", socket.gettime() - startTime)
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
    if self.m_extendLine then
        return false
    end
    
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

    if self.m_pointsMgr:isPtInOneValidPolygon(cc.p(self.m_extendLine:getPositionX(), self.m_extendLine:getPositionY())) then
        self.m_extendLine:startExtend()
    else
        self.m_extendLine:runAction(
            cc.Sequence:create(
                cc.MoveTo:create(2, cc.p(0, -300)),
                cc.CallFunc:create(function ( ... )
                    if not tolua.isnull(self.m_extendLine) then
                        self.m_extendLine:removeFromParent()
                    end
                    self.m_extendLine = nil
                end),
                nil
                )
        )  
    end
    self.m_balls:applyVelocity()
end

function GameNode:updateExtendLinePos(touch)
    local pt = self:convertToNodeSpace(touch:getLocation())
    pt.y = pt.y + 200
    self.m_pointsMgr:adjustPoint(pt)

    self.m_extendLine:setPosition(pt.x, pt.y)
end

return GameNode