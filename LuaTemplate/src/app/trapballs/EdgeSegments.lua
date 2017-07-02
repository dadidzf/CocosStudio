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
        self:drawTestLabel()
    end
end

function EdgeSegments:drawTestLabel()
    if self.m_testLabelNode then
        self.m_testLabelNode:removeFromParent()
    end
        self.m_testLabelNode = cc.Node:create()
            :addTo(self)

        for ptIndex, pt in pairs(self.m_pointsMgr.m_pointList) do
            ccui.Text:create(string.format("%d", ptIndex), "", 32)
                :move(pt)
                :setColor(cc.RED)
                :addTo(self.m_testLabelNode)
        end


        for _, ptPair in pairs(self.m_pointsMgr:getLinePointsList()) do
            ccui.Text:create(string.format("%d", ptPair[3]), "", 32)
                :move(cc.pMul(cc.pAdd(ptPair[1], ptPair[2]), 0.5))
                :setColor(cc.YELLOW)
                :addTo(self.m_testLabelNode)
        end
end


return EdgeSegments