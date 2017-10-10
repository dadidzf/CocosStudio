local GameNode = class("GameNode", cc.Node)
local Plane = import(".Plane")
local MODULE_PATH = ...

function GameNode:ctor(gameScene)
    self.m_scene = gameScene

    self:enableNodeEvents()
    self:initUI()
    self:addTouch()
    self:addPhysicListener()
    self:createSyncPosScheduler()

    self:createPlane()
    self:createEnermyManger()
    self:createEnermyTrack()
end

function GameNode:initUI()
    local bg = display.newSprite("#gameBg.png")
        :move(0, 0)
        :addTo(self)

    local rotateLight = display.newSprite("#rotateLight.png")
        :move(0, 0)
        :addTo(self, 1)

    rotateLight:runAction(cc.RepeatForever:create(cc.RotateBy:create(10, 360)))
end

function GameNode:createPlane()
    local planetCircle = self:createPlanetCircle()
    self.m_plane = Plane:create(planetCircle:getContentSize().width/2)
        :move(0, 0)
        :addTo(self, 3)

    self.m_planetCircle = planetCircle
end

function GameNode:getPlane()
    return self.m_plane
end

function GameNode:createEnermyManger()
    self.m_enermyManger = import(".EnermyManager", MODULE_PATH):create()
        :move(0, 0)
        :addTo(self, 4)

    self.m_enermyManger:start()
end

function GameNode:createEnermyTrack()
    local trackSize = display.newSprite("#enermyTrack.png"):getContentSize()
    local trackWidth = trackSize.width

    self.m_trackList = {}
    for i = 1, 8 do
        local radius = 250 + i*i*30 + math.random(50) - 25
        local track = display.newSprite("#enermyTrack.png")
            :move(0, 0)
            :setScale(radius/800)
            :addTo(self)
        table.insert(self.m_trackList, track)

        if math.random() > 0.3 then
            local track = display.newSprite("#enermyTrack.png")
                :move(0, 0)
                :setScale((radius + i*5 + math.random(10) + 10)/800)
                :addTo(self)
            table.insert(self.m_trackList, track)
        end
    end
end

function GameNode:createPlanetCircle()
    local planetCircleSprite = display.newSprite("#planetCircle.png")
    local planetCircle = cc.ProgressTimer:create(planetCircleSprite)
            :setType(cc.PROGRESS_TIMER_TYPE_RADIAL)
            :setPosition(cc.p(0, 0))
            :addTo(self, 2)

    local size = planetCircle:getContentSize()

    local edgeBody = cc.PhysicsBody:createCircle(size.width/2, cc.PhysicsMaterial(1, 1, 0), cc.p(0, 0))
    edgeBody:setCategoryBitmask(dd.Constant.CATEGORY.FORTRESS)
    edgeBody:setContactTestBitmask(dd.Constant.CATEGORY.ENERMY)
    edgeBody:setDynamic(false)
    
    planetCircle:setPhysicsBody(edgeBody)

    planetCircle:setPercentage(0)

    local seq =  cc.Sequence:create(
        cc.ProgressTo:create(dd.Constant.BULLET_CFG.SUPER_BULLET_CREATE_TIME, 100),
        cc.CallFunc:create(function ( ... )
            planetCircle:setReverseDirection(not planetCircle:isReverseDirection())
            self:createSuperBullet()
        end),
        cc.ProgressTo:create(dd.Constant.BULLET_CFG.SUPER_BULLET_COLD_TIME, 0),
        cc.CallFunc:create(function ( ... )
            planetCircle:setReverseDirection(not planetCircle:isReverseDirection())
            self:coldSuperBullet()
        end)
        )
    planetCircle:runAction(cc.RepeatForever:create(seq))
    
    return planetCircle
end

function GameNode:createSuperBullet()
    print("GameNode:createSuperBullet")
    self.m_plane:setBulletType(dd.Constant.BULLET_TYPE[math.random(2, 4)])
end

function GameNode:coldSuperBullet()
    print("GameNode:coldSuperBullet")
    self.m_plane:setBulletType("SINGLE_BULLET")
end

function GameNode:createSyncPosScheduler()
    self.m_syncPosScheduler = dd.scheduler:scheduleScriptFunc(handler(self, self.syncPosUpdate), 0.01, false)
end

function GameNode:removeSyncPosScheduler()
    if self.m_syncPosScheduler then
        dd.scheduler:unscheduleScriptEntry(self.m_syncPosScheduler)
        self.m_syncPosScheduler = nil
    end
end

function GameNode:syncPosUpdate()
    print(#self.m_trackList)
    local planePos = self.m_plane:getPlanePos()
    local diffPos = cc.pMul(planePos, -0.5)
    self:setPosition(diffPos)

    local tracks = #self.m_trackList
    for i, track in ipairs(self.m_trackList) do
        local pos = cc.pMul(diffPos, i*0.1)
        track:setPosition(pos)
    end
end

function GameNode:addTouch()
    local listener = cc.EventListenerTouchOneByOne:create()
    listener:registerScriptHandler(handler(self, self.onTouchBegin), cc.Handler.EVENT_TOUCH_BEGAN)
    listener:registerScriptHandler(handler(self, self.onTouchMoved), cc.Handler.EVENT_TOUCH_MOVED)
    listener:registerScriptHandler(handler(self, self.onTouchEnd), cc.Handler.EVENT_TOUCH_ENDED)
    listener:registerScriptHandler(handler(self, self.onTouchEnd), cc.Handler.EVENT_TOUCH_CANCELLED)

    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self)
end

function GameNode:onTouchBegin(touch, event)
    if self.m_isAlreadyBegin then
        return false
    end
    
    self.m_isAlreadyBegin = true
    self.m_plane:touchBegin()
    return true
end

function GameNode:onTouchMoved(touch, event)

end

function GameNode:onTouchEnd(touch, event)
    self.m_isAlreadyBegin = false
    self.m_plane:touchEnd()
end

-- Physic Contact
function GameNode:addPhysicListener()
    local contactListener = cc.EventListenerPhysicsContact:create()
    contactListener:registerScriptHandler(handler(self, self.onContactBegin), cc.Handler.EVENT_PHYSICS_CONTACT_BEGIN)

    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(contactListener, self)
end

function GameNode:onContactBegin(contact)
    local shapeA = contact:getShapeA()
    local shapeB = contact:getShapeB()
    local nodeA = shapeA:getBody():getNode()
    local nodeB = shapeB:getBody():getNode()

    if tolua.isnull(nodeA) or tolua.isnull(nodeB) then
        return
    end

    local shapeACategory = shapeA:getCategoryBitmask()
    local shapeBCategory = shapeB:getCategoryBitmask()
    local cateGoryAdd = shapeACategory + shapeBCategory

    if cateGoryAdd == dd.Constant.CATEGORY.BULLET + dd.Constant.CATEGORY.ENERMY then
        if shapeACategory == dd.Constant.CATEGORY.BULLET then
            self:dealBulletWithEnermy(nodeA, nodeB)
        else
            self:dealBulletWithEnermy(nodeB, nodeA)
        end

        return false
    end

    if cateGoryAdd == dd.Constant.CATEGORY.LASER + dd.Constant.CATEGORY.ENERMY then
        if shapeACategory == dd.Constant.CATEGORY.LASER then
            self:dealLaserWithEnermy(nodeA, nodeB)
        else
            self:dealLaserWithEnermy(nodeB, nodeA)
        end

        return false
    end

    if cateGoryAdd == dd.Constant.CATEGORY.ENERMY + dd.Constant.CATEGORY.FORTRESS then
        if shapeACategory == dd.Constant.CATEGORY.ENERMY then
            self:dealEnermyWithFortress(nodeA, nodeB)
        else
            self:dealEnermyWithFortress(nodeB, nodeA)
        end

        return false
    end
end

function GameNode:dealLaserWithEnermy(laser, enermy)
    self.m_enermyManger:removeEnermy(enermy)
    dd.PlaySound("bomb.mp3")
    
    self.m_scene:increaseScore()
end

function GameNode:dealBulletWithEnermy(bullet, enermy)
    self.m_plane:getBulletManager():removeBullet(bullet)
    self.m_enermyManger:removeEnermy(enermy)
    dd.PlaySound("bomb.mp3")

    self.m_scene:increaseScore()
end

function GameNode:dealEnermyWithFortress(enermy, fortress)
    print("GameNode:dealEnermyWithFortress")
end

function GameNode:onCleanup()
    self:removeSyncPosScheduler()
end

return GameNode
