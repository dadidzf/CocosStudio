local Balls = class("Balls", function ( ... )
    return cc.Node:create()
end)

function Balls:ctor(levelIndex)
    self.m_levelIndex = levelIndex
    self.m_ballList = {}

    self:addBalls()
end

function Balls:addBalls()
    local roundCfg = dd.CsvConf:getRoundCfg()[self.m_levelIndex] 
    for _, ballConf in ipairs(dd.YWStrUtil:parse(roundCfg.ball_setting)) do
        local pos = cc.p(ballConf[1][1], ballConf[1][2])
        local speed = cc.p(ballConf[2][1], ballConf[2][2])
        self:addBall(speed, pos)
    end
end

function Balls:addBall(velocity, pos, picName)
    local vel = velocity or cc.p(300, 300)  
    local pic = picName or "ball.png"
    pos = pos or cc.p(0, 0)

    local ball = display.newSprite(pic)
        :move(pos)
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

function Balls:slowDown()
    for _, ball in ipairs(self.m_ballList) do
        local body = ball:getPhysicsBody()
        local curVelVector = body:getVelocity()
        ball.m_slowDownSpeed = curVelVector
        body:setVelocity(cc.p(0, 0))
    end
end

function Balls:recoverSpeed()
    for _, ball in ipairs(self.m_ballList) do
        local body = ball:getPhysicsBody()
        body:setVelocity(ball.m_slowDownSpeed)
    end
end

function Balls:getBallPosList()
    local retPosList = {}
    for _, ball in ipairs(self.m_ballList) do
        table.insert(retPosList, cc.p(ball:getPositionX(), ball:getPositionY()))
    end

    print("Balls:getBallPosList")
    dump(retPosList)
    return retPosList
end

return Balls