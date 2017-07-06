local GameNode = class("GameNode", cc.Node)

local MODULE_PATH = ...
local Balls = import(".Balls")
local ExtendLine = import(".ExtendLine")
local EdgeSegments = import(".EdgeSegments")
local PointsManager = import(".PointsManager")

function GameNode:ctor(scene, boxColor, levelIndex)
    dump(boxColor, "GameNode:ctor")
    self.m_scene = scene
    self.m_boxColor = cc.c4f(boxColor.r/255, boxColor.g/255, boxColor.b/255, 1)

    self.m_pointsMgr = PointsManager:create()
    local jsonStr = cc.FileUtils:getInstance():getStringFromFile(string.format("level%d.json", levelIndex))
    self.m_pointsMgr:load(jsonStr)

    self.m_edgeSegments = EdgeSegments:create(self.m_pointsMgr)
        :addTo(self)

    self.m_balls = Balls:create(levelIndex)
        :addTo(self)

    self:addTouch()
    self:addPhysicListener()

    self.m_drawNode = cc.DrawNode:create()
        :addTo(self, -1)
    self:drawPolygon()
end

function GameNode:getValidPolygonArea()
    return self.m_pointsMgr:getAllValidPolygonArea()
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
        self.m_scene:oneMoreTopCollision()
        return true
    end

    -- ball with extend line
    if cateGoryAdd == dd.Constants.CATEGORY.EXTENDLINE + dd.Constants.CATEGORY.BALL then
        self.m_extendLine:removeFromParent()
        self.m_extendLine = nil
        if self.m_scene:loseLife() then
            print("Game Over !")
            local GameFail = import(".GameFail", MODULE_PATH)
            local gameFail = GameFail:create(self.m_scene) 
            self.m_scene:addChild(gameFail, 2)
            gameFail:setPosition(display.cx, display.cy)
        end
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

    local lineIndex = shapeSegment:getTag()
    local linePtPair = self.m_pointsMgr:getOneLinePointPair(lineIndex)
    local segPtA = linePtPair[1]

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
        pt = cc.pMul(pt, 1/self:getScale())
        return cc.pAdd(extendPos, pt)
    else
        local pt = shapeA:getOffset()
        pt = cc.pMul(pt, 1/self:getScale())
        return cc.pAdd(extendPos, pt)
    end
end

function GameNode:dealExtendlineCollision(collisionPt)
    print("GameNode:dealExtendlineCollision")
    dump(collisionPt)
    
    local startTime = socket.gettime()
    self.m_extendLine:collision(collisionPt)

    if not self.m_extendLine:isExtend() then
        local pts = self.m_extendLine:getOffsets()
        self.m_pointsMgr:adjustLine(pts[1], pts[2])
        self.m_balls:slowDown()
        self.m_pointsMgr:addLine(pts[1], pts[2], self.m_balls:getBallPosList())
        self.m_extendLine:removeFromParent()
        self.m_extendLine = nil

        local scheduler
        local segment = self.m_edgeSegments
        self:drawPolygon()
        self.m_scene:updateArea()
        local callBack = function ()
            if not tolua.isnull(segment) then
                segment:updatePhysicBody()
                segment = nil
                return
            end
            if not tolua.isnull(self.m_balls) then
                self.m_balls:recoverSpeed()
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

    local spriteFrame, isHorizontal, dropPos = self.m_scene:getValidSpriteFrame(touch:getLocation())
    if not spriteFrame then
        return false
    end
    
    dropPos = self:convertToNodeSpace(dropPos)
    local pt = self:convertToNodeSpace(touch:getLocation())
    self.m_extendLine = ExtendLine:create(self.m_pointsMgr, isHorizontal, spriteFrame, dropPos)
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
                cc.MoveTo:create(1, self.m_extendLine:getDropPos()),
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
end

function GameNode:updateExtendLinePos(touch)
    local pt = self:convertToNodeSpace(touch:getLocation())
    pt.y = pt.y + 160
    self.m_pointsMgr:adjustPoint(pt)

    self.m_extendLine:setPosition(pt.x, pt.y)
end

function GameNode:drawPolygon()
    self.m_drawNode:clear()

    local validPolygonTriangleLists = self.m_pointsMgr:getAllValidPolygonTriangleList()
    for _, polygonTriangleList in ipairs(validPolygonTriangleLists) do
        for index = 1, #polygonTriangleList/3 do
            local pt1 = polygonTriangleList[(index - 1)*3 + 1]
            local pt2 = polygonTriangleList[(index - 1)*3 + 2]
            local pt3 = polygonTriangleList[(index - 1)*3 + 3]

            self.m_drawNode:drawTriangle(pt1, pt2, pt3, self.m_boxColor)
        end
    end

    local removedPolygonTriangleLists = self.m_pointsMgr:getAllRemovedPolygonTriangleList()
    for _, polygonTriangleList in ipairs(removedPolygonTriangleLists) do
        for index = 1, #polygonTriangleList/3 do
            local pt1 = polygonTriangleList[(index - 1)*3 + 1]
            local pt2 = polygonTriangleList[(index - 1)*3 + 2]
            local pt3 = polygonTriangleList[(index - 1)*3 + 3]

            self.m_drawNode:drawTriangle(pt1, pt2, pt3, cc.c4f(0, 0, 0, 0.15))
        end
    end
end

return GameNode