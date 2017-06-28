local PointsManager = import(".PointsManager")
local EdgeSegments = class("EdgeSegments", function ()
    return cc.DrawNode:create()
end)

function EdgeSegments:ctor(pointsManager)
    self.m_pointsMgr = pointsManager
    self:updatePhysicBody()
end

function EdgeSegments:updatePhysicBody()
    local linePointsList = self.m_pointsMgr:getLinePointsList()
    local body = cc.PhysicsBody:create()
    self:setPhysicsBody(body)

    for _, ptPair in pairs(linePointsList) do
        local shape = cc.PhysicsShapeEdgeSegment:create(ptPair[1], ptPair[2], cc.PhysicsMaterial(1, 1, 0), 1)
        body:addShape(shape)
        body:setCategoryBitmask(dd.Constants.CATEGORY.EDGE_SEGMENT)
        body:setContactTestBitmask(dd.Constants.CATEGORY.BALL + dd.Constants.CATEGORY.EXTENDLINE_BOTH_ENDS)
        body:setCollisionBitmask(dd.Constants.CATEGORY.BALL)
        body:setDynamic(false)
    end
end


return EdgeSegments