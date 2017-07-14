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
    local jsonStr = cc.FileUtils:getInstance():getStringFromFile(string.format("levels/level%d.json", levelIndex))
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

    self:createObstacles(levelIndex)
end

function GameNode:onBallCreateOk(ballList)
    self.m_scene:getNewGuideCtl():controlBalls(ballList)
end

function GameNode:createObstacles(levelIndex)
    self.m_obstacleGears = {}
    self.m_obstaclePowers = {}

    local obstaclesCfg = dd.YWStrUtil:parse(dd.CsvConf:getRoundCfg()[levelIndex].obstacle)
    for _, obstacleCfg in ipairs(obstaclesCfg) do
        local id = obstacleCfg[1]
        if id == dd.Constants.OBSTACLE.GEAR then
            self:createObstacleGear(obstacleCfg)
        elseif id == dd.Constants.OBSTACLE.POWER then
            self:createObstaclePower(obstacleCfg)
        end
    end
end

function GameNode:checkObstacles()
    local destoryObstacleInRemovedPolygons = function(obstacleList)
        for _, nodeObstacle in pairs(obstacleList) do
            local pos = cc.p(nodeObstacle:getPositionX(), nodeObstacle:getPositionY()) 
            if not self.m_pointsMgr:isPtInOneValidPolygon(pos) then
                obstacleList[nodeObstacle:getTag()] = nil
                local body = cc.PhysicsBody:create()
                nodeObstacle:setPhysicsBody(body)
                nodeObstacle:stopAllActions()
                nodeObstacle:runAction(cc.Sequence:create(
                    cc.Blink:create(0.5, 2),
                    cc.CallFunc:create(function ()
                        nodeObstacle:removeFromParent()
                    end)
                    ))
            end
        end
    end

    destoryObstacleInRemovedPolygons(self.m_obstacleGears)
    destoryObstacleInRemovedPolygons(self.m_obstaclePowers)
end

function GameNode:createObstacleGear(conf)
    local pos1 = cc.p(conf[2][1], conf[2][2])
    local pos2 = cc.p(conf[3][1], conf[3][2])
    local speed = conf[4][1] 

    local ObstacleGear = import(".ObstacleGear", MODULE_PATH)
    local index = #self.m_obstacleGears + 1
    local obstacleGear = ObstacleGear:create(pos1, pos2, speed) 
        :addTo(self, 3)
        :setTag(index)

    self.m_obstacleGears[index] = obstacleGear
end

function GameNode:createObstaclePower(conf)
    local pos = cc.p(conf[2][1], conf[2][2])
    local speed = {x = conf[3][1], y = conf[3][2]}
    if speed.y == nil then
        local speedLen = speed.x
        local angle = math.random(1, 4)*math.pi/2 + math.rad(math.random(10, 80))
        speed = cc.p(speedLen*math.sin(angle), speedLen*math.cos(angle))
    end

    local ObstaclePower = import(".ObstaclePower", MODULE_PATH) 
    local index = #self.m_obstaclePowers + 1
    local obstaclePower = ObstaclePower:create(pos, speed)
        :addTo(self, 3)
        :setTag(index)

    self.m_obstaclePowers[index] = obstaclePower
end

function GameNode:getValidPolygonArea()
    return self.m_pointsMgr:getLeftArea()
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

    if tolua.isnull(nodeA) or tolua.isnull(nodeB) then
        return
    end

    local shapeACategory = shapeA:getCategoryBitmask()
    local shapeBCategory = shapeB:getCategoryBitmask()
    local cateGoryAdd = shapeACategory + shapeBCategory

    -- gear with extendline
    if cateGoryAdd == dd.Constants.CATEGORY.OBSTACLE_GEAR + dd.Constants.CATEGORY.EXTENDLINE or 
        cateGoryAdd == dd.Constants.CATEGORY.OBSTACLE_GEAR + dd.Constants.CATEGORY.EXTENDLINE_BOTH_ENDS then
        self:extendLineDestory()
        return false
    end

    -- power with extendline
    if cateGoryAdd == dd.Constants.CATEGORY.OBSTACLE_POWER + dd.Constants.CATEGORY.EXTENDLINE or 
        cateGoryAdd == dd.Constants.CATEGORY.OBSTACLE_POWER + dd.Constants.CATEGORY.EXTENDLINE_BOTH_ENDS then
        self:extendLineDestory()
        return false
    end

    -- gear with edgeSegment
    if cateGoryAdd == dd.Constants.CATEGORY.OBSTACLE_GEAR + dd.Constants.CATEGORY.EDGE_SEGMENT then
        if iskindof(nodeA, "ObstacleGear") then
            self:obstacleGearDestory(nodeA)
        else
            self:obstacleGearDestory(nodeB)
        end
        return false
    end

    -- power with ball
    if cateGoryAdd == dd.Constants.CATEGORY.BALL + dd.Constants.CATEGORY.OBSTACLE_POWER then
        -- if iskindof(nodeA, "ObstaclePower") then
        --     self.m_balls:speedUp(nodeB)
        -- else
        --     self.m_balls:speedUp(nodeA)
        -- end
        dd.PlaySound("powerBall.mp3")
        return true
    end

    -- ball with ball
    if cateGoryAdd == dd.Constants.CATEGORY.BALL + dd.Constants.CATEGORY.BALL then
        return true
    end

    -- segment with extend line ends
    if cateGoryAdd == dd.Constants.CATEGORY.EDGE_SEGMENT + dd.Constants.CATEGORY.EXTENDLINE then
        local collisionPt = self:getExtendLineSegmentCollisionPt(shapeA, shapeB)
        if collisionPt then
            self:dealExtendlineCollision(collisionPt, dd.Constants.CATEGORY.EXTENDLINE)
        else
            print("Lots of collision onContactBegin ! boring !")
        end
        return false
    end

    -- segment with ball
    if cateGoryAdd == dd.Constants.CATEGORY.EDGE_SEGMENT + dd.Constants.CATEGORY.BALL then
        return true
    end

    -- ball with extend line ends
    if cateGoryAdd == dd.Constants.CATEGORY.EXTENDLINE_BOTH_ENDS + dd.Constants.CATEGORY.BALL then
        local collisionPt = self:getExtendLineBallCollisionPt(shapeA, shapeB)
        if collisionPt then
            self:dealExtendlineCollision(collisionPt, dd.Constants.CATEGORY.BALL)
            self.m_scene:getNewGuideCtl():onTopCollision(collisionPt)
        else
            print("Lots of collision onContactBegin ! boring !")
        end
        return true
    end

    -- ball with extend line
    if cateGoryAdd == dd.Constants.CATEGORY.EXTENDLINE + dd.Constants.CATEGORY.BALL then
        self:extendLineDestory()
        return false
    end
end

function GameNode:oneMoreTopCollision()
    self.m_scene:oneMoreTopCollision()
end

function GameNode:obstacleGearDestory(nodeObstacleGear)
    local tag = nodeObstacleGear:getTag()
    self.m_obstacleGears[tag] = nil
    nodeObstacleGear:stopAllActions()
    nodeObstacleGear:runAction(cc.Sequence:create(
        cc.Blink:create(0.5, 2),
        cc.CallFunc:create(function ()
        nodeObstacleGear:removeFromParent()
        end)
    ))
end

function GameNode:extendLineDestory()
    self.m_extendLine:removeFromParent()
    self.m_extendLine = nil
    self.m_scene:loseLife()
    self.m_scene:checkSteps()
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

    if shapeExtend.willBeRemoved then
        return
    else
        shapeExtend.willBeRemoved = true
    end

    local lineIndex = shapeSegment:getTag()
    local linePtPair = self.m_pointsMgr:getOneLinePointPair(lineIndex)
    local segPtA = linePtPair[1]
    local segPtB = linePtPair[2]
    local isSegHorizontal = segPtA.y == segPtB.y

    local extendPos = cc.p(self.m_extendLine:getPositionX(), self.m_extendLine:getPositionY())
 
    if self.m_extendLine:isHorizontal() and not isSegHorizontal then
        return cc.p(segPtA.x, extendPos.y)
    elseif not self.m_extendLine:isHorizontal() and isSegHorizontal then
        return cc.p(extendPos.x, segPtA.y)
    else
        local segPtAExtendPosLen = cc.pGetLength(cc.pSub(segPtA, extendPos))
        local segPtBExtendPosLen = cc.pGetLength(cc.pSub(segPtB, extendPos))

        if segPtAExtendPosLen < segPtBExtendPosLen then
            return segPtA
        else
            return segPtB
        end
    end
end

function GameNode:getExtendLineBallCollisionPt(shapeA, shapeB)
    local shapeACategory = shapeA:getCategoryBitmask()
    local extendPos = cc.p(self.m_extendLine:getPositionX(), self.m_extendLine:getPositionY())

    if shapeACategory == dd.Constants.CATEGORY.BALL then
        if shapeB.willBeRemoved then
            return
        else
            shapeB.willBeRemoved = true
        end

        local pt = shapeB:getOffset()
        pt = cc.pMul(pt, 1/self:getScale())
        if math.abs(pt.x) < 1 then pt.x = 0 end
        if math.abs(pt.y) < 1 then pt.y = 0 end
        return cc.pAdd(extendPos, pt)
    else
        if shapeA.willBeRemoved then
            return
        else
            shapeA.willBeRemoved = true
        end

        local pt = shapeA:getOffset()
        if math.abs(pt.x) < 1 then pt.x = 0 end
        if math.abs(pt.y) < 1 then pt.y = 0 end
        pt = cc.pMul(pt, 1/self:getScale())
        return cc.pAdd(extendPos, pt)
    end
end

function GameNode:dealExtendlineCollision(collisionPt, category)
    local startTime = socket.gettime()
    self.m_extendLine:collision(collisionPt, category)

    if not self.m_extendLine:isExtend() then
        local pts = self.m_extendLine:getOffsets()
        self.m_pointsMgr:adjustLine(pts[1], pts[2])
        self.m_pointsMgr:addLine(pts[1], pts[2], self.m_balls:getBallPosList())
        local extendLine = self.m_extendLine

        local scheduler
        local segment = self.m_edgeSegments
        local callBack = function ()
            if not tolua.isnull(segment) then
                segment:updatePhysicBody()
                segment = nil
            end

            if not tolua.isnull(extendLine) then
                extendLine:removeFromParent()
                extendLine = nil
            end

            if not tolua.isnull(self) then
                self.m_scene:updateArea()
                self.m_scene:costOneStep()
                self:drawPolygon()
                self:checkObstacles()
                self.m_extendLine = nil
            end

            dd.scheduler:unscheduleScriptEntry(scheduler)
        end

        scheduler = dd.scheduler:scheduleScriptFunc(callBack, 0.5, false)
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
    if not spriteFrame or not self.m_scene:getNewGuideCtl():checkDirection(isHorizontal) then
        return false
    end

    dropPos = self:convertToNodeSpace(dropPos)
    local pt = self:convertToNodeSpace(touch:getLocation())
    local lineLevelCfg = dd.CsvConf:getLineLevelCfg()
    local speed = lineLevelCfg[dd.GameData:getLineLevel()]
    self.m_extendLine = ExtendLine:create(self.m_pointsMgr, isHorizontal, spriteFrame, dropPos, speed)
        :addTo(self, 4)

    self:updateExtendLinePos(touch)

    self.m_scene:getNewGuideCtl():onIconStartMoved(self.m_extendLine)
    return true
end

function GameNode:onTouchMoved(touch, event)
    self:updateExtendLinePos(touch)
end

function GameNode:onTouchEnd(touch, event)
    self:updateExtendLinePos(touch)

    local pos = cc.p(self.m_extendLine:getPositionX(), self.m_extendLine:getPositionY())
    if self.m_scene:getNewGuideCtl():onIconPlaced(self.m_extendLine) and self.m_pointsMgr:isPtInOneValidPolygon(pos) then
        self.m_extendLine:startExtend()
        dd.PlaySound("dropLine.mp3")
    else
        self.m_extendLine:runAction(
            cc.Sequence:create(
                cc.MoveTo:create(0.3, self.m_extendLine:getDropPos()),
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
    pt.y = pt.y + display.height*0.2
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

            self.m_drawNode:drawTriangle(pt1, pt2, pt3, cc.c4f(1, 1, 1, 0.5))
        end
    end
end

return GameNode