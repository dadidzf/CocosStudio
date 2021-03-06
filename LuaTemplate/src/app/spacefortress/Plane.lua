local Plane = class("Plane", cc.Node)
local MODULE_PATH = ...

function Plane:ctor(radius, angleSpeed, shootAngleSpeed)
    self.m_radius = radius
    self:enableNodeEvents()
    self:createPlane(radius)
    self.m_angleSpeed = angleSpeed or 210
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
    self.m_plane = display.newSprite("#spacefortress_plane.png")
        :move(0, radius)
        :addTo(self)

    self.m_plane:setAnchorPoint(cc.p(0.5, 1))
    local planeSize = self.m_plane:getContentSize()
end

function Plane:removeTriangleShadowPlane()
    if self.m_shadow1 then
        self.m_shadow1:removeFromParent()
        self.m_shadow1 = nil
    end

    if self.m_shadow2 then
        self.m_shadow2:removeFromParent()
        self.m_shadow2 = nil
    end
end

function Plane:showTriangleShadowPlane()
    if self.m_shadow1 and self.m_shadow2 then
        return
    end

    self:removeTriangleShadowPlane()
    local shadow1 = display.newSprite("#spacefortress_plane.png")
        :setOpacity(150)
        :setAnchorPoint(cc.p(0.5, 1))
        :setRotation(120)
        :move(math.sqrt(3)*self.m_radius/2 + 30, -1.5*self.m_radius + 52)
        :addTo(self.m_plane)

    shadow1.m_diffAngle = 120
    self.m_shadow1 = shadow1
    self.m_plane.m_shadow1 = shadow1

    local shadow2 = display.newSprite("#spacefortress_plane.png")
        :setOpacity(150)
        :setAnchorPoint(cc.p(0.5, 1))
        :setRotation(-120)
        :move(-math.sqrt(3)*self.m_radius/2 + 30, -1.5*self.m_radius + 52)
        :addTo(self.m_plane)

    shadow2.m_diffAngle = -120
    self.m_shadow2 = shadow2
    self.m_plane.m_shadow2 = shadow2
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
    if self.m_lastShootSoundHandler then
        AudioEngine.getInstance():stopEffect(self.m_lastShootSoundHandler)
    end

    if self.m_bulletType == "SINGLE_LASER" or
        self.m_bulletType == "TRIANGLE_LASER" then
        --dd.PlaySound("laser.mp3")
        self.m_lastShootSoundHandler = dd.PlaySound("laser.mp3")
    else
        self.m_lastShootSoundHandler = dd.PlaySound("shoot.mp3")
    end

    if self.m_bulletType == "TRIANGLE_LASER" 
        or self.m_bulletType == "TRIANGLE_BULLET" then
        self:showTriangleShadowPlane()
    else
        self:removeTriangleShadowPlane()
    end

    self.m_bulletManager:createBullet(self.m_bulletType)
end


function Plane:destory()
    self:removeTriangleShadowPlane()
    self:stopShoot()
    self.m_plane:stopAllActions()
    self.m_plane:runAction(cc.FadeOut:create(1.0))
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