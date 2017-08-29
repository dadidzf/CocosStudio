local Plane = class("Plane", cc.Node)
local MODULE_PATH = ...

function Plane:ctor(radius, angleSpeed, shootAngleSpeed)
    self:enableNodeEvents()
    self:createPlane(radius)
    self.m_angleSpeed = angleSpeed or 180
    self.m_shootAngleSpeed = shootAngleSpeed or 30
    self:startAction(true, self.m_angleSpeed)

    self.m_bulletManager = import(".BulletManager", MODULE_PATH):create(self.m_plane)
        :move(0, 0)
        :addTo(self)
        
    self.m_bulletType = dd.Constant.BULLET_TYPE[1]
end

function Plane:getBulletManager()
    return self.m_bulletManager
end

function Plane:createPlane(radius)
    self.m_plane = display.newSprite("#plane.png")
        :move(0, radius + 25)
        :addTo(self)

    self.m_plane:setAnchorPoint(cc.p(0.5, 1))
    local planeSize = self.m_plane:getContentSize()
end

function Plane:startAction(isClockWise, angleSpeed)
    self.m_isClockWise = isClockWise
    local rotateAction = dd.CircleBy:create(1, cc.p(0, 0), isClockWise and angleSpeed or -angleSpeed, true)
    self.m_repeatRotateAction = cc.RepeatForever:create(rotateAction)
    self.m_plane:runAction(self.m_repeatRotateAction)
end

function Plane:removeRepeatRotateAction()
    if self.m_repeatRotateAction then
        self.m_plane:stopAction(self.m_repeatRotateAction)
        self.m_repeatRotateAction = nil
    end
end

function Plane:setBulletType(bulletType)
    self.m_bulletType = bulletType 
end

function Plane:touchBegin()
    self:removeRepeatRotateAction()
    self:startAction(self.m_isClockWise, self.m_shootAngleSpeed)

    self:startShoot()
end

function Plane:touchEnd()
    self:removeRepeatRotateAction()
    self:startAction(not self.m_isClockWise, self.m_angleSpeed)
    
    self:stopShoot()
end

function Plane:getPlanePos()
    return cc.p(self.m_plane:getPositionX(), self.m_plane:getPositionY())
end

function Plane:startShoot()
    self:shoot()
    local freq = dd.Constant.BULLET_CFG[self.m_bulletType].frequency
    self.m_shootScheduler = dd.scheduler:scheduleScriptFunc(handler(self, self.shoot), freq, false)
end

local _bulletTypeIndex = 1

function Plane:changeBulletTest()
    local _bulletList = dd.Constant.BULLET_TYPE 
    _bulletTypeIndex = _bulletTypeIndex + 1
    if _bulletTypeIndex > #_bulletList then
        _bulletTypeIndex = 1
    end

    self.m_bulletType = _bulletList[_bulletTypeIndex]
end

function Plane:shoot()
    local planeSize = self.m_plane:getContentSize()
    self.m_bulletManager:createBullet(self.m_bulletType)
end

function Plane:removeBullet(index)
    self.m_bulletList[index] = nil
end

function Plane:stopShoot()
    if self.m_shootScheduler then
        dd.scheduler:unscheduleScriptEntry(self.m_shootScheduler)
        self.m_shootScheduler = nil
    end
end

function Plane:onCleanup()
    self:stopShoot()
end

return Plane