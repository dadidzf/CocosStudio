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

function EnermyManager:createEnermy()
    local enermy = display.newSprite("yunshi01.png")  
        :move(0, display.width/2)
        :addTo(self)

    enermy:runAction(cc.Sequence:create(
        dd.CircleBy:create(5.0, cc.p(0, 0), 360),
        cc.CallFunc:create(function ( ... )
            enermy:removeFromParent()
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