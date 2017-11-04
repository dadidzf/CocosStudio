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

    self.m_lightSheduler = dd.scheduler:scheduleScriptFunc(handler(self, self.showLight), 1.0, false)
end

function GameNode:initUI()
    local bg = display.newSprite("#spacefortress_gameBg.png")
        :move(0, -2)
        :addTo(self)

    local rotateLight = display.newSprite("#spacefortress_rotateLight.png")
        :move(0, -1)
        :addTo(self, 10)

    rotateLight:runAction(cc.RepeatForever:create(cc.RotateBy:create(10, 360)))
end

function GameNode:createPlane()
    local planetCircle = self:createPlanetCircle()
    self.m_plane = Plane:create(planetCircle:getContentSize().width/2 + 25)
        :move(0, 0)
        :addTo(self, 3)

    self.m_planetCircle = planetCircle
    self:circleAction()
end

function GameNode:getPlane()
    return self.m_plane
end

function GameNode:createEnermyManger()
    self.m_enermyManger = import(".EnermyManager", MODULE_PATH):create()
        :move(0, 0)
        :addTo(self, 4)

    self.m_enermyManger:start()
    self.m_enermyManger:runAction(cc.Sequence:create(
        cc.DelayTime:create(60),
        cc.CallFunc:create(function ( ... )
            print("GameNode:createEnermyManger - level up 2 !")
            self.m_enermyManger:setLevel(2)
            dd.PlaySound("warning.mp3")
        end),
        cc.DelayTime:create(60),
        cc.CallFunc:create(function ( ... )
            print("GameNode:createEnermyManger - level up 3 !")
            self.m_enermyManger:setLevel(3)
            dd.PlaySound("warning.mp3")
        end)
        ))
end

function GameNode:createEnermyTrack()
    local trackSize = display.newSprite("#spacefortress_enermyTrack.png"):getContentSize()
    local trackWidth = trackSize.width

    self.m_trackList = {}
    local tracksCount = 16
    if device.platform == "android" then
        tracksCount = 7
    end

    for i = 1, tracksCount do
        local radius = 300 + i*i*30 + math.random(50) - 25
        local track = display.newSprite("#spacefortress_enermyTrack.png")
            :move(0, 0)
            :setScale(radius/trackWidth)
            :addTo(self)
        table.insert(self.m_trackList, track)

        local trackSize = track:getContentSize()
        if math.random() > 0.3 then
            local trackBrother = display.newSprite("#spacefortress_enermyTrack.png")
                :move(trackSize.width/2, trackSize.height/2)
                :setScale((trackSize.width + 30) / trackSize.width)
                :addTo(track)
        end
    end
end

function GameNode:createPlanetCircle()
    local planetCircleSprite = display.newSprite("#spacefortress_yuan001.png")
    local planetCircle = cc.ProgressTimer:create(planetCircleSprite)
            :setType(cc.PROGRESS_TIMER_TYPE_RADIAL)
            :setPosition(cc.p(0, 0))
            :addTo(self, 2)

    local size = planetCircle:getContentSize()

    local edgeBody = cc.PhysicsBody:createCircle(size.width/2 - 50, cc.PhysicsMaterial(1, 1, 0), cc.p(0, 0))
    edgeBody:setCategoryBitmask(dd.Constant.CATEGORY.FORTRESS)
    edgeBody:setContactTestBitmask(dd.Constant.CATEGORY.ENERMY + dd.Constant.CATEGORY.BOSS)
    edgeBody:setDynamic(false)
    
    planetCircle:setPhysicsBody(edgeBody)

    planetCircle:setReverseDirection(true)
    planetCircle:setPercentage(100)

    return planetCircle
end

function GameNode:circleAction()
    self.m_planetCircle:runAction(cc.RepeatForever:create(
        cc.Sequence:create(
            cc.DelayTime:create(0.8),
            cc.FadeTo:create(0.8, 50),
            cc.FadeTo:create(0.2, 255)
            )
        ))
end

function GameNode:skillStart(circlePic, coldTime)
    self.m_planetCircle:stopAllActions()
    
    local planetCircleSprite = display.newSprite("#" .. circlePic)
    self.m_planetCircle:setSprite(planetCircleSprite)
    --self.m_planetCircle:getSprite():setSpriteFrame(circlePic)
    self.m_planetCircle:setPercentage(100)

    local seq =  cc.Sequence:create(
        cc.ProgressTo:create(coldTime, 0),
        cc.CallFunc:create(function ( ... )
            self:skillOver()
        end)
        )

    self.m_planetCircle:runAction(seq)
end

function GameNode:skillOver()
    self.m_planetCircle:getSprite():setSpriteFrame(dd.Constant.PLANE_CIRCLE_PIC.YELLOW)
    self.m_planetCircle:setPercentage(100)
    
    self:coldSuperBullet() 
end

function GameNode:createSuperBullet()
    local bulletIndex = math.random(2, table.nums(dd.Constant.BULLET_TYPE))
    local bulletType = dd.Constant.BULLET_TYPE[bulletIndex]
    print("GameNode:createSuperBullet", bulletType)
    dd.PlaySound("fullpower.mp3")

    self.m_plane:setBulletType(bulletType)

    local bulletCfg = dd.Constant.BULLET_CFG[bulletType]
    self:skillStart(bulletCfg.circle, bulletCfg.coldtime)
end

function GameNode:coldSuperBullet()
    print("GameNode:coldSuperBullet")
    self.m_plane:setBulletType("SINGLE_BULLET")
    self:circleAction()
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

function GameNode:recoverPos()
    self:removeSyncPosScheduler()

    self:setPosition(cc.p(0, 0))
    for _, track in pairs(self.m_trackList) do
        track:setPosition(cc.p(0, 0))
    end
end

function GameNode:syncPosUpdate()
    local planePos = self.m_plane:getPlanePos()
    local diffPos = cc.pMul(planePos, -0.5)
    self:setPosition(diffPos)

    local tracks = #self.m_trackList
    for i, track in ipairs(self.m_trackList) do
        local pos = cc.pMul(diffPos, i*0.18)
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

    if cateGoryAdd == dd.Constant.CATEGORY.SKILL + dd.Constant.CATEGORY.BULLET then
        if shapeACategory == dd.Constant.CATEGORY.SKILL then
            self:dealSkillWithBullet(nodeA, nodeB)
        else
            self:dealSkillWithBullet(nodeB, nodeA)
        end

        return false
    end

    if cateGoryAdd == dd.Constant.CATEGORY.SKILL + dd.Constant.CATEGORY.LASER then
        if shapeACategory == dd.Constant.CATEGORY.SKILL then
            self:dealSkillWithLaser(nodeA, nodeB)
        else
            self:dealSkillWithLaser(nodeB, nodeA)
        end

        return false
    end

    if cateGoryAdd == dd.Constant.CATEGORY.BOSS + dd.Constant.CATEGORY.LASER then
        if shapeACategory == dd.Constant.CATEGORY.BOSS then
            self:dealBossWithLaser(nodeA, nodeB)
        else
            self:dealBossWithLaser(nodeB, nodeA)
        end

        return false
    end

    if cateGoryAdd == dd.Constant.CATEGORY.BOSS + dd.Constant.CATEGORY.BULLET then
        if shapeACategory == dd.Constant.CATEGORY.BOSS then
            self:dealBossWithBullet(nodeA, nodeB)
        else
            self:dealBossWithBullet(nodeB, nodeA)
        end

        return false
    end

    if cateGoryAdd == dd.Constant.CATEGORY.BOSS + dd.Constant.CATEGORY.FORTRESS then
        if shapeACategory == dd.Constant.CATEGORY.BOSS then
            self:dealBossWithFortress(nodeA, nodeB)
        else
            self:dealBossWithFortress(nodeB, nodeA)
        end

        return false
    end
end

function GameNode:dealBossWithLaser(boss, laser)
    if boss.m_protected then
        return
    end

    boss.m_hp = boss.m_hp - 1
    if boss.m_hp <= 0 then
        self.m_enermyManger:removeBoss(boss)
        dd.PlaySound("bomb.mp3")
    else
        boss:setColor(cc.RED)
        boss.m_protected = true
        boss:runAction(cc.Sequence:create(
            cc.DelayTime:create(0.3),
            cc.CallFunc:create(function ( ... )
                boss.m_protected = false
                boss:setColor(cc.WHITE)
            end)
            ))
        boss.m_syncHpFunc()
    end

    self.m_scene:increaseScore()
end

function GameNode:showBossEffect(boss, bullet)
    local bulletWorldPos = bullet:convertToWorldSpaceAR(cc.p(0, 0))
    local bulletInBossPos = boss:convertToNodeSpace(bulletWorldPos)

    local x, y = bulletInBossPos.x, bulletInBossPos.y
    local animation = cc.Animation:create()
    for i = 1, 8 do
        animation:addSpriteFrameWithFile(string.format("EffSource/game_eff_xiao%d.png", i))
    end
    animation:setDelayPerUnit(0.1)

    local action = cc.Animate:create(animation)
    local sprite = cc.Sprite:create()
    sprite:move(x, y)
    sprite:setScale(0.5)
    boss:addChild(sprite, 100)
    sprite:runAction(cc.Sequence:create(
        action, 
        cc.CallFunc:create(
            function ( ... )
                sprite:removeFromParent()
            end
            )
        )
    )
end

function GameNode:dealBossWithBullet(boss, bullet)
    boss.m_hp = boss.m_hp - 1
    if boss.m_hp <= 0 then
        self.m_enermyManger:removeBoss(boss)

        self.m_scene:increaseScore()
    else
        boss.m_syncHpFunc()
        self:showBossEffect(boss, bullet)
    end

    dd.PlaySound("bomb.mp3")
    self.m_plane:getBulletManager():removeBullet(bullet)
    self.m_scene:increaseScore()
end

function GameNode:dealBossWithFortress(boss, fortress)
    self:cleanGame()
    self.m_scene:onGameOver()
end

function GameNode:dealSkillWithLaser(skill, laser)
    self.m_enermyManger:removeSkill(skill)
    self:createSuperBullet()
end

function GameNode:dealSkillWithBullet(skill, bullet)
    self.m_enermyManger:removeSkill(skill)
    self.m_plane:getBulletManager():removeBullet(bullet)
    self:createSuperBullet()
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

function GameNode:cleanGame()
    self:recoverPos()
    cc.load("sdk").ScreenShake:create(self, 0.2):run()

    self:getEventDispatcher():removeEventListenersForTarget(self)
    self.m_plane:destory()
    self:removeLightScheduler()
    self.m_planetCircle:getPhysicsBody():setContactTestBitmask(0)
    self.m_planetCircle:stopAllActions()
    self.m_planetCircle:runAction(cc.FadeOut:create(1.0))

    self.m_enermyManger:destoryAll()
    self.m_enermyManger:stopAllActions()

    for _, track in pairs(self.m_trackList) do
        track:runAction(cc.Sequence:create(
            cc.ScaleTo:create(1.5, 0.3),
            cc.CallFunc:create(function ( ... )
                track:removeFromParent()
            end) 
            ))
    end

    self:runAction(cc.Sequence:create(
        cc.DelayTime:create(1.5),
        cc.CallFunc:create(function ( ... )
            local particle = cc.ParticleSystemQuad:create("particle/particle_bomb.plist") 
                :move(0, 0)
                :addTo(self, 1000)
        end)
        ))
end

function GameNode:dealEnermyWithFortress(enermy, fortress)
    print("GameNode:dealEnermyWithFortress")
    self:cleanGame()
    self.m_scene:onGameOver()
end

function GameNode:showLight()
    local animation = cc.Animation:create()
    for i = 1, 7 do
        animation:addSpriteFrameWithFile(string.format("EffSource/home_eff_shan_%d.png", i))
    end
    animation:setDelayPerUnit(0.3)
    local action = cc.Animate:create(animation)

    local sprite = cc.Sprite:create()
        :move(display.width*(math.random() - 0.5), display.height*(math.random() - 0.5))
        :setScale(0.6)
        :setOpacity(180)
        :addTo(self, 0)

    sprite:runAction(cc.Sequence:create(
        action,
        cc.CallFunc:create(function ( ... )
            sprite:removeFromParent()
        end)
        ))
end

function GameNode:removeLightScheduler()
    if self.m_lightSheduler then
        dd.scheduler:unscheduleScriptEntry(self.m_lightSheduler)
        self.m_lightSheduler = nil
    end
end

function GameNode:onCleanup()
    self:removeSyncPosScheduler()
    self:removeLightScheduler()
end

return GameNode
