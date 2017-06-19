local Gear = class("Gear", function (...)
            return cc.Sprite:create(...) 
        end
    )

local _scheduler = cc.Director:getInstance():getScheduler()

function Gear:pairWithTarget(targetNode, rLen, startAngle)
    self.m_rLen = rLen
    self.m_targetNode = targetNode
    self.m_curAngle = startAngle

    self.m_targetPos = cc.p(targetNode:getPositionX(), targetNode:getPositionY())

    self:place()
end

function Gear:setAngle(angle)
    self.m_curAngle = angle
    self:place()
end

function Gear:place()
    local radian = math.pi*self.m_curAngle/180
    local disVector = cc.p(self.m_rLen*math.cos(radian), self.m_rLen*math.sin(radian))
    self:setPosition(self.m_targetPos.x + disVector.x, self.m_targetPos.y + disVector.y)
    self:setRotation(-self.m_curAngle)
end

return Gear