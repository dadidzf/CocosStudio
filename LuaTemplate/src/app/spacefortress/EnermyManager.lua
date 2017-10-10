local EnermyManager = class("EnermyManager", cc.Node)

function EnermyManager:ctor()
    self:enableNodeEvents()

    self.m_enermyList = {}
    self.m_curLevel = 1
end

function EnermyManager:start()
    self:removeEnermySheduler()
    local frequency = dd.Constant.ENERMY_CFG.LEVEL_FREQUENCY[self.m_curLevel]
    self.m_enermySheduler = dd.scheduler:scheduleScriptFunc(handler(self, self.createEnermy), frequency, false)
end

function EnermyManager:setLevel(level)
    self.m_curLevel = level
    self:start()
end

function EnermyManager:removeEnermySheduler()
    if self.m_enermySheduler then
        dd.scheduler:unscheduleScriptEntry(self.m_enermySheduler)
        self.m_enermySheduler = nil
    end
end

local _enermyFrameTb = {
    "yunshi01.png",
    "yunshi02.png"
}

function EnermyManager:getEnermyFrameName()
    return _enermyFrameTb[math.random(1, #_enermyFrameTb)]
end

function EnermyManager:getRandomFloat(min, max)
    return math.random()*(max - min) + min
end


function EnermyManager:createEnermy()
    local distance = cc.pGetLength(cc.p(display.width/2, display.height/2))
    local randomRad = math.random()*math.pi*2
    local randomPos = cc.p(distance*math.sin(randomRad), distance*math.cos(randomRad))
    local enermy = display.newSprite(self:getEnermyFrameName())  
        :move(randomPos)
        :addTo(self)

    local levelSpeed = dd.Constant.ENERMY_CFG.LEVEL_SPEED[self.m_curLevel]
    local circleRadius = self:getRandomFloat(dd.Constant.ENERMY_CFG.CIRCLE_RADIUS_MIN, 
        dd.Constant.ENERMY_CFG.CIRCLE_RADIUS_MAX)
    local circleAngleSpeed = self:getRandomFloat(dd.Constant.ENERMY_CFG.CIRCLE_ANGLE_SPEED_MIN, 
        dd.Constant.ENERMY_CFG.CIRCLE_ANGLE_SPEED_MAX)
    local circleAngle = self:getRandomFloat(dd.Constant.ENERMY_CFG.CIRCLE_ANGLE_MIN, 
        dd.Constant.ENERMY_CFG.CIRCLE_ANGLE_MAX)

    enermy:runAction(cc.Sequence:create(
        cc.MoveTo:create(distance*(1 - circleRadius)/levelSpeed, cc.pMul(randomPos, (1 - circleRadius))),
        dd.CircleBy:create(circleAngle/circleAngleSpeed, cc.p(0, 0), math.random() > 0.5 and circleAngle or -circleAngle, true),
        cc.MoveTo:create(distance*circleRadius/levelSpeed, cc.p(0, 0)),
        cc.CallFunc:create(function ( ... )
            self:removeEnermy(enermy)
        end)
        ))

    enermy:setRotation(math.random()*360)
    if math.random() < dd.Constant.ENERMY_CFG.ROTATE_PROB then
        local rotateSpeed = self:getRandomFloat(dd.Constant.ENERMY_CFG.ROTATE_SPEED_MIN, 
            dd.Constant.ENERMY_CFG.ROTATE_SPEED_MAX)
        enermy:runAction(cc.RepeatForever:create(
            cc.RotateBy:create(360/rotateSpeed, 360)
            ))
    end

    local enermySize = enermy:getContentSize()
    local edgeBody = cc.PhysicsBody:createBox(enermySize, cc.PhysicsMaterial(1, 1, 0), cc.p(0, 0))
    edgeBody:setCategoryBitmask(dd.Constant.CATEGORY.ENERMY)
    edgeBody:setContactTestBitmask(dd.Constant.CATEGORY.BULLET + dd.Constant.CATEGORY.FORTRESS +
        dd.Constant.CATEGORY.LASER)
    edgeBody:setDynamic(false)
    enermy:setPhysicsBody(edgeBody)

    local index = #self.m_enermyList + 1
    enermy.m_index = index
    self.m_enermyList[index] = enermy
end

function EnermyManager:removeEnermy(enermy)
    self.m_enermyList[enermy.m_index] = nil
    enermy:removeFromParent()
end

function EnermyManager:onCleanup()
    self:removeEnermySheduler()
end

return EnermyManager