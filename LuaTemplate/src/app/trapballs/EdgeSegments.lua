local PointsManager = import(".PointsManager")
local EdgeSegments = class("EdgeSegments", function ()
    return cc.DrawNode:create()
end)

function EdgeSegments:ctor(pointsManager, lineWidth)
    self.m_lineWidth = lineWidth or dd.Constants.EDGE_SEG_WIDTH
    self.m_pointsMgr = pointsManager
    self:updatePhysicBody()
end

function EdgeSegments:updatePhysicBody(color)
    self:clear()
    self:setLineWidth(self.m_lineWidth)
    color = color or cc.c4f(1, 1, 1, 1)

    local linePointsList = self.m_pointsMgr:getLinePointsList()
    local body = cc.PhysicsBody:create()
    self:setPhysicsBody(body)

    for _, ptPair in pairs(linePointsList) do
        local shape = cc.PhysicsShapeEdgeSegment:create(ptPair[1], ptPair[2], cc.PhysicsMaterial(1, 1, 0), 1)
        body:addShape(shape)
        body:setCategoryBitmask(dd.Constants.CATEGORY.EDGE_SEGMENT)
        body:setContactTestBitmask(dd.Constants.CATEGORY.EXTENDLINE)
        body:setCollisionBitmask(dd.Constants.CATEGORY.BALL)
        body:setDynamic(false)

        self:drawLine(ptPair[1], ptPair[2], color)
    end
end


return EdgeSegments