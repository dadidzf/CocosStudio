local EnermyManager = class("EnermyManager", cc.Node)

function EnermyManager:ctor()
    self:enableNodeEvents()

    self.m_enermyList = {}
    self.m_enermySheduler = dd.scheduler:scheduleScriptFunc(handler(self, self.createEnermy), 1.0, false)
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
    local randomPos = cc.p(self:getRandomFloat(-1, 1)*display.width/2, self:getRandomFloat(-1, 1)*display.height/2)
    local distance = cc.pGetLength(randomPos)
    local enermy = display.newSprite(self:getEnermyFrameName())  
        :move(randomPos)
        :addTo(self)

    enermy:runAction(cc.Sequence:create(
        cc.MoveTo:create(5.0, cc.p(0, 0)),
        cc.CallFunc:create(function ( ... )
            self:removeEnermy(enermy)
        end)
        ))


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