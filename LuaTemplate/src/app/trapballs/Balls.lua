local Balls = class("Balls", function ( ... )
    return cc.Node:create()
end)

function Balls:ctor()
    self.m_ballList = {}
    self:addBall()
end

function Balls:addBall(velocity, picName)
    local vel = velocity or cc.p(300, 300)  
    local pic = picName or "ball.png"

    local ball = display.newSprite(pic)
    self:addChild(ball)
    local ballSize = ball:getContentSize()

    local edgeBody = cc.PhysicsBody:createCircle(ballSize.width/2, cc.PhysicsMaterial(0,1,0), cc.p(0, 0))
    edgeBody:setCategoryBitmask(dd.Constants.CATEGORY.BALL)
    edgeBody:setContactTestBitmask(dd.Constants.CATEGORY.EXTENDLINE_BOTH_ENDS + dd.Constants.CATEGORY.EXTENDLINE)
    edgeBody:setVelocity(vel)
    ball:setPhysicsBody(edgeBody)
    ball.m_retoreMyVel = cc.pGetLength(vel)

    table.insert(self.m_ballList, ball)
end

function Balls:applyVelocity()
    for _, ball in ipairs(self.m_ballList) do
        local body = ball:getPhysicsBody()
        local curVelVector = body:getVelocity()
        local curVel = cc.pGetLength(curVelVector)
        local vel = cc.pMul(curVelVector, ball.m_retoreMyVel/curVel)
        print("Balls:applyVelocity", vel.x, vel.y)
        body:setVelocity(vel)
    end
end

return Balls