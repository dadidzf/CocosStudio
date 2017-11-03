local EnermyManager = class("EnermyManager", cc.Node)

function EnermyManager:ctor()
    self:enableNodeEvents()

    self.m_enermyList = {}
    self.m_skillList = {}
    self.m_bossList = {}

    self.m_curLevel = 1
end

function EnermyManager:start()
    self:startEnermySheduler()
    self:startSkillSheduler()
    self:startBossSheduler()
end

function EnermyManager:startEnermySheduler()
    self:removeEnermySheduler()
    local frequency = dd.Constant.ENERMY_CFG.LEVEL_FREQUENCY[self.m_curLevel]
    self.m_enermySheduler = dd.scheduler:scheduleScriptFunc(handler(self, self.createEnermy), frequency, false)
end

function EnermyManager:startSkillSheduler()
    self:removeSkillScheduler() 
    local skillFreq = math.random(dd.Constant.SKILL_CFG.PRODUCE_SCHEDULE_MIN, 
        dd.Constant.SKILL_CFG.PRODUCE_SCHEDULE_MAX)
    self.m_skillSheduler = dd.scheduler:scheduleScriptFunc(handler(self, self.createSkill), skillFreq, false)
end

function EnermyManager:startBossSheduler()
    self:removeBossScheduler() 
    local bossFreq = math.random(dd.Constant.BOSS_CFG.PRODUCE_SCHEDULE_MIN, 
        dd.Constant.BOSS_CFG.PRODUCE_SCHEDULE_MAX)
    self.m_bossSheduler = dd.scheduler:scheduleScriptFunc(handler(self, self.createBoss), bossFreq, false)
end

function EnermyManager:setLevel(level)
    self.m_curLevel = level
    self:startEnermySheduler()
    --self:start()
end

function EnermyManager:removeEnermySheduler()
    if self.m_enermySheduler then
        dd.scheduler:unscheduleScriptEntry(self.m_enermySheduler)
        self.m_enermySheduler = nil
    end
end

function EnermyManager:removeSkillScheduler()
    if self.m_skillSheduler then
        dd.scheduler:unscheduleScriptEntry(self.m_skillSheduler)
        self.m_skillSheduler = nil
    end
end

function EnermyManager:removeBossScheduler()
    if self.m_bossSheduler then
        dd.scheduler:unscheduleScriptEntry(self.m_bossSheduler)
        self.m_bossSheduler = nil
    end
end

function EnermyManager:createSkill()
    self:startSkillSheduler()
    
    local distance = cc.pGetLength(cc.p(display.width/2, display.height/2))
    local randomRad = math.random()*math.pi*2
    local randomPos = cc.p(distance*math.sin(randomRad), distance*math.cos(randomRad))
    local skill = display.newSprite("#spacefortress_jineng.png")
        :setScale(dd.Constant.SKILL_CFG.SCALE)
        :move(randomPos)
        :addTo(self)

    local speed = dd.Constant.SKILL_CFG.SPEED 
    local circleRadius = self:getRandomFloat(dd.Constant.SKILL_CFG.CIRCLE_RADIUS_MIN, 
        dd.Constant.SKILL_CFG.CIRCLE_RADIUS_MAX)
    local circleAngleSpeed = dd.Constant.SKILL_CFG.CIRCLE_ANGLE_SPEED
    local circleAngle = dd.Constant.SKILL_CFG.CIRCLE_ANGLE

    skill:runAction(cc.Sequence:create(
        cc.MoveTo:create(distance*(1 - circleRadius)/speed, cc.pMul(randomPos, (1 - circleRadius))),
        dd.CircleBy:create(circleAngle/circleAngleSpeed, cc.p(0, 0), math.random() > 0.5 and circleAngle or -circleAngle, true),
        cc.FadeOut:create(1.0),
        cc.CallFunc:create(function ( ... )
            self:removeSkill(skill)
        end)
        ))

    local skillSize = skill:getContentSize()
    skillSize = cc.size(skillSize.width*dd.Constant.SKILL_CFG.SCALE, skillSize.height*dd.Constant.SKILL_CFG.SCALE)
    local edgeBody = cc.PhysicsBody:createBox(skillSize, cc.PhysicsMaterial(1, 1, 0), cc.p(0, 0))
    edgeBody:setCategoryBitmask(dd.Constant.CATEGORY.SKILL)
    edgeBody:setContactTestBitmask(dd.Constant.CATEGORY.BULLET + dd.Constant.CATEGORY.LASER)
    edgeBody:setDynamic(false)
    skill:setPhysicsBody(edgeBody)

    local index = #self.m_skillList + 1
    skill.m_index = index
    self.m_skillList[index] = skill 
end

local _BOSS_FRAME_NAME_LIST = {
    "spacefortress_boss1.png",
    "spacefortress_boss2.png",
    "spacefortress_boss3.png",
    "spacefortress_boss4.png",
    "spacefortress_boss5.png",
    "spacefortress_boss6.png"
}
function EnermyManager:createBoss()
    self:startBossSheduler()
    
    local distance = cc.pGetLength(cc.p(display.width/2, display.height/2))
    local randomRad = math.random()*math.pi*2
    local randomPos = cc.p(distance*math.sin(randomRad), distance*math.cos(randomRad))

    local boss = display.newSprite(string.format("#%s", _BOSS_FRAME_NAME_LIST[math.random(1, 6)]))
        :setScale(dd.Constant.BOSS_CFG.SCALE)
        :move(randomPos)
        :addTo(self)

    local speed = dd.Constant.BOSS_CFG.SPEED 
    local circleRadius = self:getRandomFloat(dd.Constant.BOSS_CFG.CIRCLE_RADIUS_MIN, 
        dd.Constant.BOSS_CFG.CIRCLE_RADIUS_MAX)
    local circleAngleSpeed = dd.Constant.BOSS_CFG.CIRCLE_ANGLE_SPEED
    local circleAngle = dd.Constant.BOSS_CFG.CIRCLE_ANGLE

    boss:runAction(cc.Sequence:create(
        cc.MoveTo:create(distance*(1 - circleRadius)/speed, cc.pMul(randomPos, (1 - circleRadius))),
        dd.CircleBy:create(circleAngle/circleAngleSpeed, cc.p(0, 0), math.random() > 0.5 and circleAngle or -circleAngle, true),
        cc.MoveTo:create(distance*circleRadius/speed, cc.p(0, 0)),
        cc.CallFunc:create(function ( ... )
            self:removeBoss(boss)
        end)
        ))

    local bossSize = boss:getContentSize()
    bossSize = cc.size(bossSize.width*dd.Constant.BOSS_CFG.SCALE*0.5, bossSize.height*dd.Constant.BOSS_CFG.SCALE*0.5)
    local edgeBody = cc.PhysicsBody:createBox(bossSize, cc.PhysicsMaterial(1, 1, 0), cc.p(0, 0))
    edgeBody:setCategoryBitmask(dd.Constant.CATEGORY.BOSS)
    edgeBody:setContactTestBitmask(dd.Constant.CATEGORY.BULLET + dd.Constant.CATEGORY.LASER + dd.Constant.CATEGORY.FORTRESS)
    edgeBody:setDynamic(false)
    boss:setPhysicsBody(edgeBody)

    local index = #self.m_bossList + 1
    boss.m_index = index
    boss.m_hp = math.random(dd.Constant.BOSS_CFG.HP_MIN, dd.Constant.BOSS_CFG.HP_MAX)
    self.m_bossList[index] = boss 

    local bossSize = boss:getContentSize()
    local hpLabel = cc.Label:createWithBMFont("fnt/score.fnt", "0")
        --:setAnchorPoint(cc.p(0.5, 1))
        :setColor(cc.YELLOW)
        :setScale(0.5)
        :move(bossSize.width/2, bossSize.height/2)
        :addTo(boss, 1)

    hpLabel:setVisible(false)

    boss.m_syncHpFunc = function ( ... )
        hpLabel:setString(tostring(boss.m_hp))
    end
end

local _enermyFrameTb = {
    {"spacefortress_yunshi01.png", "spacefortress_yunshi03.png"},
    {"spacefortress_yunshi02.png", "spacefortress_yunshi04.png"}
}

function EnermyManager:getEnermyFrameNamePair()
    return _enermyFrameTb[math.random(1, #_enermyFrameTb)]
end

function EnermyManager:getRandomFloat(min, max)
    return math.random()*(max - min) + min
end

function EnermyManager:createEnermy()
    local distance = cc.pGetLength(cc.p(display.width/2, display.height/2))
    local randomRad = math.random()*math.pi*2
    local randomPos = cc.p(distance*math.sin(randomRad), distance*math.cos(randomRad))
    local frameNames =  self:getEnermyFrameNamePair()
    local enermy = display.newSprite(string.format("#%s", frameNames[1]))
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
        cc.CallFunc:create(function ( ... )
            local animation = cc.Animation:create()
            for i = 1, 2 do
                animation:addSpriteFrame(display.newSpriteFrame(frameNames[i]))
            end

            animation:setDelayPerUnit(0.3)
            animation:setLoops(0xffffffff)
            local action = cc.Animate:create(animation)
            enermy:runAction(action)
        end),
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

function EnermyManager:destoryAll()
    self:removeEnermySheduler()
    self:removeSkillScheduler()
    self:removeBossScheduler()
    
    for _, enermy in pairs(self.m_enermyList) do
        self:destoryEnermy(enermy, 0)
    end

    for _, skill in pairs(self.m_skillList) do
        skill:removeFromParent()
    end

    for _, boss in pairs(self.m_bossList) do
        boss:removeFromParent()
    end

    self.m_bossList = {}
    self.m_skillList = {}
    self.m_enermyList = {}
end

function EnermyManager:destoryBoss(boss, delay)
    local particle = cc.ParticleSystemQuad:create("particle/particle_bomb_boss.plist") 
        :move(boss:getPosition())
        :addTo(self)

    boss:removeFromParent()
end

function EnermyManager:destoryEnermy(enermy, delay)
    local x, y = enermy:getPosition()
    local animation = cc.Animation:create()
    for i = 0, 5 do
        animation:addSpriteFrameWithFile(string.format("EffSource/game_eff_lan_%d.png", i))
    end
    animation:setDelayPerUnit(0.1)

    local action = cc.Animate:create(animation)
    local sprite = cc.Sprite:create()
    sprite:move(x, y)
    sprite:setScale(0.5)
    self:addChild(sprite, 100)
    sprite:runAction(cc.Sequence:create(
        cc.DelayTime:create(delay),
        action, 
        cc.CallFunc:create(
            function ( ... )
                sprite:removeFromParent()
            end
            )
        )
    )

    enermy:removeFromParent()
end

function EnermyManager:removeSkill(skill)
    self.m_skillList[skill.m_index] = nil
    skill:removeFromParent()
end

function EnermyManager:removeBoss(boss)
    self.m_bossList[boss.m_index] = nil
    self:destoryBoss(boss, 0)
end

function EnermyManager:removeEnermy(enermy)
    self.m_enermyList[enermy.m_index] = nil
    self:destoryEnermy(enermy, 0)
end

function EnermyManager:onCleanup()
    self:removeEnermySheduler()
    self:removeSkillScheduler()
end

return EnermyManager