local Balls = class("Balls", function ( ... )
    return cc.Node:create()
end)

local MAX_SPEED = 600

function Balls:ctor(levelIndex)
    self.m_levelIndex = levelIndex
    self.m_ballList = {}

    self:addBalls()
end

function Balls:addBalls()
    local roundCfg = dd.CsvConf:getRoundCfg()[self.m_levelIndex] 
    self.m_particleList = {}
    self:runAction(cc.Sequence:create(
            cc.DelayTime:create(0.4),
            cc.CallFunc:create(function ( ... )
                for _, ballConf in ipairs(dd.YWStrUtil:parse(roundCfg.ball_setting)) do
                    local pos = cc.p(ballConf[1][1], ballConf[1][2])
                    local speed = {x = ballConf[2][1], y = ballConf[2][2]}
                    if speed.y == nil then
                        local speedLen = speed.x
                        local angle = math.random(1, 4)*math.pi/2 + math.rad(math.random(10, 80))
                        speed = cc.p(speedLen*math.sin(angle), speedLen*math.cos(angle))
                    end
                    self:addBall(speed, pos)
                    --speed = cc.pMul(speed, 0.2)

                    local particle = cc.ParticleSystemQuad:create("particle/particle_ballstart.plist") 
                        :move(pos)
                        :addTo(self)

                    table.insert(self.m_particleList, particle)
                end
            end),
            cc.DelayTime:create(1.0),
            cc.CallFunc:create(function ( ... )
                for _, ball in ipairs(self.m_ballList) do
                    ball:setVisible(true)
                    ball:getPhysicsBody():setVelocity(ball.m_retoreMyVel)
                end
                for _, particle in ipairs(self.m_particleList) do
                    particle:removeFromParent()
                end
            end),
            cc.CallFunc:create(function ( ... )
                self:getParent():onBallCreateOk(self.m_ballList)
            end)
            ))

end

function Balls:addBall(velocity, pos, picName)
    local vel = velocity or cc.p(300, 300)  
    local pic = picName or "#ball_white.png"
    pos = pos or cc.p(0, 0)

    local ball = display.newSprite(pic)
        :move(pos)
    self:addChild(ball)
    local ballSize = ball:getContentSize()

    local edgeBody = cc.PhysicsBody:createCircle(ballSize.width/2, cc.PhysicsMaterial(100000, 1, 0), cc.p(0, 0))
    edgeBody:setCategoryBitmask(dd.Constants.CATEGORY.BALL)
    edgeBody:setContactTestBitmask(dd.Constants.CATEGORY.EXTENDLINE_BOTH_ENDS 
        + dd.Constants.CATEGORY.EXTENDLINE + dd.Constants.CATEGORY.OBSTACLE_POWER + dd.Constants.CATEGORY.BALL)
    --edgeBody:setVelocity(vel)
    ball:setPhysicsBody(edgeBody)
    ball:setVisible(false)
    ball.m_retoreMyVel = velocity

    table.insert(self.m_ballList, ball)
end

function Balls:applyVelocity()
    for _, ball in ipairs(self.m_ballList) do
        local body = ball:getPhysicsBody()
        local curVelVector = body:getVelocity()
        local curVel = cc.pGetLength(curVelVector)
        local vel = cc.pMul(curVelVector, ball.m_retoreMyVel/curVel)
        body:setVelocity(vel)
    end
end

function Balls:getBallList()
    return self.m_ballList
end

function Balls:getBallPosList()
    local retPosList = {}
    for _, ball in ipairs(self.m_ballList) do
        table.insert(retPosList, cc.p(ball:getPositionX(), ball:getPositionY()))
    end

    return retPosList
end

function Balls:speedUp(ball)
    local add = 100
    local body = ball:getPhysicsBody()
    local curVel = body:getVelocity()
    local curVelLen = cc.pGetLength(curVel)
    local afterAdd = curVelLen + add
    if afterAdd >= MAX_SPEED then
        afterAdd = MAX_SPEED
    end

    body:setVelocity(cc.pMul(curVel, afterAdd/curVelLen))
end

function Balls:controlSpeed(ball)
    local mul = 1
    local body = ball:getPhysicsBody()
    local curVel = body:getVelocity()
    local curVelLen = cc.pGetLength(curVel)
    if curVelLen >= MAX_SPEED then
        mul = MAX_SPEED/curVelLen
    end

    body:setVelocity(cc.pMul(curVel, mul))
end


return Balls