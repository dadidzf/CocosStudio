local ExtendLine = class("ExtendLine", function ( ... )
    return cc.DrawNode:create()
end)

function ExtendLine:ctor(isVertical, speed, endsBallRadius)
    self:enableNodeEvents()

    self.m_endsBallRadius = endsBallRadius or 6
    self.m_isVertical = isVertical
    self.m_speed = speed
    self:drawPoint(cc.p(0, 0), self.m_endsBallRadius, cc.c4f(0, 0, 1, 1))

    self.m_positivePt = nil
    self.m_negativePt = nil
end

function ExtendLine:onCleanup()
    self:stopExtend()
end

function ExtendLine:getOffsets()
    local posPt, negPt 
    if self.m_isVertical then
        posPt = cc.p(self.m_positivePt.x + self.m_endsBallRadius, 0)
        negPt = cc.p(self.m_negativePt.x - self.m_endsBallRadius, 0)
    else
        posPt = cc.p(0, self.m_positivePt.y + self.m_endsBallRadius) 
        negPt = cc.p(0, self.m_negativePt.y - self.m_endsBallRadius)
    end

    return {posPt, negPt}
end

function ExtendLine:startExtend()
    self.m_lineWidth = 2 
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

    if not self.m_isVertical then
        pt1 = cc.p(0, -len)
        pt2 = cc.p(0, len)
    end

    if self.m_positivePt then
        pt2 = self.m_positivePt
    end
    if self.m_negativePt then
        pt1 = self.m_negativePt
    end

    local shapeLine = cc.PhysicsShapeEdgeSegment:create(pt1, pt2, cc.PhysicsMaterial(1, 1, 0), 1)
    shapeLine:setCategoryBitmask(dd.Constants.CATEGORY.EXTENDLINE)
    shapeLine:setContactTestBitmask(dd.Constants.CATEGORY.BALL)
    shapeLine:setCollisionBitmask(0)
    body:addShape(shapeLine)

    local shapeCircle1 = cc.PhysicsShapeCircle:create(6, cc.PhysicsMaterial(1, 1, 0), pt1)
    shapeCircle1:setCategoryBitmask(dd.Constants.CATEGORY.EXTENDLINE_BOTH_ENDS)
    shapeCircle1:setContactTestBitmask(dd.Constants.CATEGORY.EDGE_SEGMENT + dd.Constants.CATEGORY.BALL)
    shapeCircle1:setCollisionBitmask(dd.Constants.CATEGORY.BALL)
    body:addShape(shapeCircle1)

    local shapeCircle2 = cc.PhysicsShapeCircle:create(6, cc.PhysicsMaterial(1, 1, 0), pt2)
    shapeCircle2:setCategoryBitmask(dd.Constants.CATEGORY.EXTENDLINE_BOTH_ENDS)
    shapeCircle2:setContactTestBitmask(dd.Constants.CATEGORY.EDGE_SEGMENT + dd.Constants.CATEGORY.BALL)
    shapeCircle2:setCollisionBitmask(dd.Constants.CATEGORY.BALL)
    body:addShape(shapeCircle2)
    
    body:setDynamic(false)
end

function ExtendLine:stopExtend()
    if self.m_scheduler then
        dd.scheduler:unscheduleScriptEntry(self.m_scheduler)
        self.m_scheduler = nil
    end
end

function ExtendLine:collision(shape)
    local offset = shape:getOffset()
    if offset.x + offset.y > 0 then
        self.m_positivePt = offset
    else
        self.m_negativePt = offset
    end

    if self.m_positivePt and self.m_negativePt then
        self:stopExtend()
    end
end

function ExtendLine:isExtend()
    return self.m_scheduler
end

return ExtendLine