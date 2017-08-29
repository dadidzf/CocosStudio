local BulletManger = class("BulletManger", cc.Node)

function BulletManger:ctor(plane)
    self.m_plane = plane
    self.m_bulletList = {}
end

function BulletManger:createBullet(bulletType)
    local plane = self.m_plane
    self.m_curPos = cc.p(plane:getPositionX(), plane:getPositionY())
    self.m_curRotation = plane:getRotation()

    if bulletType == "SINGLE_BULLET" or
        bulletType == "DOUBLE_BULLET" or
        bulletType == "THREE_BULLET" then
        self:createMultiBullet(dd.Constant.BULLET_CFG[bulletType].bulletList)
    elseif bulletType == "SINGLE_LASER" then
        self:createMultiLaser(dd.Constant.BULLET_CFG[bulletType].bulletList) 
    end
end

function BulletManger:createMultiBullet(bulletCfg)
    for _, singleCfg in ipairs(bulletCfg) do
        self:createSingleBullet(singleCfg.speed, singleCfg.distance, singleCfg.color, singleCfg.direction, singleCfg.xPos)
    end
end

function BulletManger:createSingleBullet(speed, distance, color, direction, xPos)
    speed = speed or 1000
    distance = distance or display.height
    direction = direction or 0
    color = color or cc.YELLOW
    xPos = xPos or 0
    
    local time = distance/speed
    local dirInRadian = math.pi*direction/180

    -- ContainerNode
    local containerNode = cc.Node:create()
        :move(self.m_curPos)
        :addTo(self)
        :setRotation(self.m_curRotation)

    local index = #self.m_bulletList + 1
    self.m_bulletList[index] = containerNode

    -- Head
    local bulletHead = display.newSprite("bullet1.png")
        :move(xPos, 0)
        :addTo(containerNode)
    local bulletHeadSize = bulletHead:getContentSize()
    bulletHead.m_index = index

    local edgeBody = cc.PhysicsBody:createBox(bulletHeadSize, cc.PhysicsMaterial(1, 1, 0), cc.p(0, 0))
    edgeBody:setCategoryBitmask(dd.Constant.CATEGORY.BULLET)
    edgeBody:setContactTestBitmask(dd.Constant.CATEGORY.ENERMY)
    edgeBody:setDynamic(false)
    bulletHead:setPhysicsBody(edgeBody)

    -- streak
    local streak = cc.MotionStreak:create(0.8, bulletHeadSize.width/2, bulletHeadSize.width/2, cc.YELLOW, "bullet3.png")
        :move(xPos, 0)
        :addTo(containerNode)

    local moveByAction = cc.MoveBy:create(time, cc.p(distance*math.sin(dirInRadian), distance*math.cos(dirInRadian)))
    bulletHead:runAction(moveByAction)

    streak:runAction(cc.Sequence:create(moveByAction:clone(), cc.CallFunc:create(function ( ... )
        self.m_bulletList[index] = nil
        containerNode:removeFromParent()
    end)))
end

function BulletManger:createMultiLaser(laserCfg)
    for _, singleCfg in ipairs(laserCfg) do
        self:createSingleLaser(singleCfg.color, singleCfg.direction, singleCfg.width, singleCfg.xPos, singleCfg.lifecycle)
    end
end

function BulletManger:createSingleLaser(color, direction, width, xPos, lifecycle)
    print("BulletManger:createSingleLaser")
    color = color or cc.RED 
    direction = direction or 0
    xPos = xPos or 0
    width = width or 0

    local planeSize = self.m_plane:getContentSize()
    local drawNode = cc.DrawNode:create()  
        :addTo(self.m_plane)
        :move(planeSize.width/2, planeSize.height)

    local index = #self.m_bulletList + 1
    self.m_bulletList[index] = drawNode
    drawNode.m_index = index
    
    drawNode:drawSolidRect(cc.p(xPos - width/2, 0),
        cc.p(xPos + width/2, display.height), cc.c4f(color.r/255, color.g/255, color.b/255, 1))

    local edgeBody = cc.PhysicsBody:createBox(cc.size(width, display.height), 
        cc.PhysicsMaterial(1, 1, 0), cc.p(xPos, display.height/2))

    edgeBody:setCategoryBitmask(dd.Constant.CATEGORY.LASER)
    edgeBody:setContactTestBitmask(dd.Constant.CATEGORY.ENERMY)
    edgeBody:setDynamic(false)
    drawNode:setPhysicsBody(edgeBody)

    drawNode:runAction(cc.Sequence:create(
        cc.DelayTime:create(lifecycle),
        cc.CallFunc:create(function ( ... )
            self.m_bulletList[index] = nil
            drawNode:removeFromParent()
        end)
        ))
end

function BulletManger:removeBullet(bullet)
    local containerNode = self.m_bulletList[bullet.m_index]
    self.m_bulletList[bullet.m_index] = nil
    containerNode:removeFromParent()
end

return BulletManger