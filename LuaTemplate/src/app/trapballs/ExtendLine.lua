local ExtendLine = class("ExtendLine", function ( ... )
    return cc.DrawNode:create()
end)

function ExtendLine:ctor(pointManger, isHorizontal, spriteFrame, dropPos, speed, endsBallRadius)
    self:enableNodeEvents()

    self.m_pointsMgr = pointManger
    self.m_dropPos = dropPos
    self.m_spriteFrame = spriteFrame
    self.m_endsBallRadius = endsBallRadius or 8
    self.m_isHorizontal = isHorizontal
    self.m_speed = speed or 300

    self.m_icon = cc.Sprite:createWithSpriteFrame(spriteFrame)
        :move(0, 0)
        :setOpacity(80)
        :addTo(self)

    self.m_positivePt = nil
    self.m_negativePt = nil

    self.m_extendVirtualColor = cc.c4f(0, 0, 0, 0.2)
end

function ExtendLine:getDropPos()
    return self.m_dropPos
end

function ExtendLine:onCleanup()
    self:stopExtend()
end

function ExtendLine:isHorizontal()
    return self.m_isHorizontal
end

function ExtendLine:getOffsets()
    return {self.m_postiveCollisionPt, self.m_negativeCollisionPt}
end

function ExtendLine:startExtend()
    self.m_icon:removeFromParent()
    
    self.m_lineWidth = dd.Constants.LINE_WIDTH_IN_PIXEL
    self.m_startTime = socket.gettime()
    self:clear()

    self.m_scheduler = dd.scheduler:scheduleScriptFunc(handler(self, self.updatePhysicBody), 0, false)
end

function ExtendLine:updatePhysicBody(t)
    local diffTime = socket.gettime() - self.m_startTime
    local body = cc.PhysicsBody:create()
    self:setPhysicsBody(body)

    local pt1, pt2
    local len = diffTime*self.m_speed/2
    pt1 = cc.p(-len, 0)
    pt2 = cc.p(len, 0)
    local size = cc.size(dd.Constants.LINE_WIDTH_IN_PIXEL*8, dd.Constants.LINE_WIDTH_IN_PIXEL)
    local sizeShow = cc.size(dd.Constants.EDGE_SEG_WIDTH, dd.Constants.EDGE_SEG_WIDTH)

    if not self.m_isHorizontal then
        pt1 = cc.p(0, -len)
        pt2 = cc.p(0, len)
        size = cc.size(dd.Constants.LINE_WIDTH_IN_PIXEL, dd.Constants.LINE_WIDTH_IN_PIXEL*8)
    end

    if self.m_positivePt then
        pt2 = self.m_positivePt
    end
    if self.m_negativePt then
        pt1 = self.m_negativePt
    end

    self:clear()

    local origin, dest = self.m_pointsMgr:getLineRectWithLineWidth(cc.p(0, 0), pt1)
    if not self.m_negativePt then
        self:drawSolidRect(origin, dest, self.m_extendVirtualColor)

        local shapeLine1 = cc.PhysicsShapeEdgeSegment:create(pt1, cc.p(0, 0), cc.PhysicsMaterial(0, 1, 0), dd.Constants.LINE_WIDTH_IN_PIXEL/2)
        shapeLine1:setCategoryBitmask(dd.Constants.CATEGORY.EXTENDLINE)
        shapeLine1:setContactTestBitmask(dd.Constants.CATEGORY.BALL + dd.Constants.CATEGORY.EDGE_SEGMENT)
        shapeLine1:setCollisionBitmask(0)
        body:addShape(shapeLine1)

        local shapeBox = cc.PhysicsShapeEdgeBox:create(size, cc.PhysicsMaterial(0, 1, 0), 0, pt1)
        shapeBox:setCategoryBitmask(dd.Constants.CATEGORY.EXTENDLINE_BOTH_ENDS)
        shapeBox:setContactTestBitmask(dd.Constants.CATEGORY.BALL)
        shapeBox:setCollisionBitmask(dd.Constants.CATEGORY.BALL)
        body:addShape(shapeBox)

        self:drawSolidRect(cc.pSub(pt1, cc.p(sizeShow.width/2, sizeShow.height/2)),
            cc.pAdd(pt1, cc.p(sizeShow.width/2, sizeShow.height/2)), cc.c4f(1, 1, 1, 1))
    else
        self:drawSolidRect(origin, dest, cc.c4f(1, 1, 1, 1))

        local shapeLine1 = cc.PhysicsShapeEdgeSegment:create(pt1, cc.p(0, 0), cc.PhysicsMaterial(0, 1, 0), dd.Constants.LINE_WIDTH_IN_PIXEL/2)
        shapeLine1:setCategoryBitmask(dd.Constants.CATEGORY.EDGE_SEGMENT)
        shapeLine1:setCollisionBitmask(dd.Constants.CATEGORY.BALL)
        body:addShape(shapeLine1)
    end

    local origin, dest = self.m_pointsMgr:getLineRectWithLineWidth(cc.p(0, 0), pt2)
    if not self.m_positivePt then
        self:drawSolidRect(origin, dest, self.m_extendVirtualColor)

        local shapeLine2 = cc.PhysicsShapeEdgeSegment:create(pt2, cc.p(0, 0), cc.PhysicsMaterial(0, 1, 0), dd.Constants.LINE_WIDTH_IN_PIXEL/2)
        shapeLine2:setCategoryBitmask(dd.Constants.CATEGORY.EXTENDLINE)
        shapeLine2:setContactTestBitmask(dd.Constants.CATEGORY.BALL + dd.Constants.CATEGORY.EDGE_SEGMENT)
        shapeLine2:setCollisionBitmask(0)
        body:addShape(shapeLine2)
        
        local shapeBox = cc.PhysicsShapeEdgeBox:create(size, cc.PhysicsMaterial(0, 1, 0), 0, pt2)
        shapeBox:setCategoryBitmask(dd.Constants.CATEGORY.EXTENDLINE_BOTH_ENDS)
        shapeBox:setContactTestBitmask(dd.Constants.CATEGORY.BALL)
        shapeBox:setCollisionBitmask(dd.Constants.CATEGORY.BALL)
        body:addShape(shapeBox)

        self:drawSolidRect(cc.pSub(pt2, cc.p(sizeShow.width/2, sizeShow.height/2)),
            cc.pAdd(pt2, cc.p(sizeShow.width/2, sizeShow.height/2)), cc.c4f(1, 1, 1, 1))
    else
        self:drawSolidRect(origin, dest, cc.c4f(1, 1, 1, 1))

        local shapeLine2 = cc.PhysicsShapeEdgeSegment:create(pt1, cc.p(0, 0), cc.PhysicsMaterial(0, 1, 0), dd.Constants.LINE_WIDTH_IN_PIXEL/2)
        shapeLine2:setCategoryBitmask(dd.Constants.CATEGORY.EDGE_SEGMENT)
        shapeLine2:setCollisionBitmask(dd.Constants.CATEGORY.BALL)
        body:addShape(shapeLine2)
    end
    
    self:drawSolidCircle(cc.p(0, 0), self.m_lineWidth/2, 0, 20, cc.c4f(1, 1, 1, 1))
    
    body:setDynamic(false)
end

function ExtendLine:stopExtend()
    local body = cc.PhysicsBody:create()
    self:setPhysicsBody(body)
    
    if self.m_scheduler then
        dd.scheduler:unscheduleScriptEntry(self.m_scheduler)
        self.m_scheduler = nil
    end
end

function ExtendLine:collision(collisionPt)
    local offset = cc.pSub(collisionPt, cc.p(self:getPositionX(), self:getPositionY()))

    dump(offset, "------------------------ExtendLine:collision") 
    if not self.m_positivePt then
        if offset.x + offset.y >= 0 then
            print("xxx1")
            self.m_positivePt = clone(offset)
            self.m_postiveCollisionPt = collisionPt
        end
    end

    if not self.m_negativePt then
        if offset.x + offset.y <= 0 then
            print("xxx2")
            self.m_negativePt = clone(offset)
            self.m_negativeCollisionPt = collisionPt
        end
    end

    if self.m_positivePt and self.m_negativePt then
        self:stopExtend()
    end
end

function ExtendLine:isExtend()
    return self.m_scheduler
end

return ExtendLine