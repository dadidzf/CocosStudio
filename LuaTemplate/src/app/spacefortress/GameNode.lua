local GameNode = class("GameNode", cc.Node)
local Plane = import(".Plane")
local MODULE_PATH = ...

function GameNode:ctor()
    self:enableNodeEvents()
    self:initUI()
    self:addTouch()
    self:addPhysicListener()
    self:createSyncPosScheduler()

    self:createPlane()
    self:createEnermyManger()
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
end

function GameNode:getPlane()
    return self.m_plane
end

function GameNode:createEnermyManger()
    self.m_enermyManger = import(".EnermyManager", MODULE_PATH):create()
        :move(0, 0)
        :addTo(self, 4)
end

function GameNode:createPlanetCircle()
    local planetCircle = display.newSprite("#planetCircle.png")
        :move(0, 0)
        :addTo(self, 2)

    local size = planetCircle:getContentSize()

    local edgeBody = cc.PhysicsBody:createCircle(size.width/2, cc.PhysicsMaterial(1, 1, 0), cc.p(0, 0))
    edgeBody:setCategoryBitmask(dd.Constant.CATEGORY.FORTRESS)
    edgeBody:setContactTestBitmask(dd.Constant.CATEGORY.ENERMY)
    edgeBody:setDynamic(false)
    
    planetCircle:setPhysicsBody(edgeBody)

    return planetCircle
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
    local planePos = self.m_plane:getPlanePos()
    local diffPos = cc.pMul(planePos, -0.5)
    self:setPosition(diffPos)
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
end

function GameNode:dealBulletWithEnermy(bullet, enermy)
    self.m_plane:getBulletManager():removeBullet(bullet)
    self.m_enermyManger:removeEnermy(enermy)
end

function GameNode:dealEnermyWithFortress(enermy, fortress)
    print("GameNode:dealEnermyWithFortress")
end

function GameNode:onCleanup()
    self:removeSyncPosScheduler()
end

return GameNode
