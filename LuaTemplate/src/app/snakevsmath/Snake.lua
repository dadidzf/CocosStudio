local Snake = class("Snake", cc.Node)
local Body = import(".Body")

local _baseStepDistance = 10
local _distanceOfBodies = 40
local _bodyMapSteps = _distanceOfBodies/_baseStepDistance

function Snake:ctor(moveCallBack)
    self:enableNodeEvents()
    self.m_bodies = {}
    self.m_pathList = {}
    self.m_direction = 30
    self.m_moveCallBack = moveCallBack
    self.m_number = 0
    self.m_snakeYpos = -display.height*0.1

    local head = Body:create(true)
        :move(cc.p(0, self.m_snakeYpos))
        :addTo(self)

    self.m_headSize = head:getContentSize()

    table.insert(self.m_bodies, head)
    table.insert(self.m_pathList, cc.p(0, 0))

    self:setMoveSpeed(500)
    self:applyNumber()
end

function Snake:getHeadPos()
    local head = self.m_bodies[1]
    return cc.p(head:getPositionX(), head:getPositionY())
end

function Snake:getNumber()
    return self.m_number
end

function Snake:setNumber(num)
    self.m_number = num
    self:applyNumber()
end

function Snake:applyNumber()
    if self.m_number >= 0 then
        local num = self.m_number

        local numBytesCount = string.len(tostring(num))
        local len = #self.m_bodies - 1
        if numBytesCount > len then
            for i = 1, numBytesCount - len do
                self:grow()
            end
        elseif numBytesCount < len then
            for i = 1, len - numBytesCount do
                self:decrease()
            end 
        end 

        local index = #self.m_bodies
        repeat 
            self.m_bodies[index]:setNumber(num%10)
            num = math.floor(num/10)
            index = index - 1
        until(num == 0)
    end 
end

function Snake:setDirection(direction)
    self.m_direction = direction
end

function Snake:getDirection()
    return self.m_direction
end

function Snake:setMoveSpeed(speed)
    print("Snake:setMoveSpeed", speed)
    
    self:removeScheduler()
    self.m_speed = speed
    local updateTime = _baseStepDistance/self.m_speed

    self.m_scheduler = dd.scheduler:scheduleScriptFunc(handler(self, self.step), updateTime, false)
end

function Snake:removeScheduler()
    if self.m_scheduler then
        dd.scheduler:unscheduleScriptEntry(self.m_scheduler)
        self.m_scheduler = nil
    end
end

function Snake:grow()
    self:insertPathesToTail()
    local tailPos = self.m_pathList[#self.m_pathList]

    local newBody = Body:create()
        :move(tailPos)
        :addTo(self)

    local rad = cc.pToAngleSelf(cc.pSub(self.m_pathList[#self.m_pathList - 1], tailPos))
    newBody:setDirection(rad)
    table.insert(self.m_bodies, newBody)
end

function Snake:decrease()
    local tail = self.m_bodies[#self.m_bodies]
    self.m_bodies[#self.m_bodies] = nil
    tail:removeFromParent()

    for i = 1, _bodyMapSteps do
        table.remove(self.m_pathList)
    end    
end

function Snake:step()
    self:updatePathForOneStep()
    self:updateBodiesPos()
end

function Snake:updateBodiesPos()
    local index = 1
    for i = 1, #self.m_pathList, _bodyMapSteps do
        local body = self.m_bodies[index]
        index = index + 1
        body:setPosition(self.m_pathList[i])
        if i == 1 then
            body:setDirection(math.rad(self.m_direction))
        else
            local pos = self.m_pathList[i]
            local pos1 = self.m_pathList[i - 1]
            local rad = cc.pToAngleSelf(cc.pSub(pos1, pos))
            body:setDirection(rad)
        end
    end
end

function Snake:updatePathForOneStep()
    local rad = math.rad(self.m_direction)
    local diffX = _baseStepDistance*math.cos(rad) 
    local diffY = _baseStepDistance*math.sin(rad)

    local headPos = self.m_pathList[1]
    local nextPos = cc.p(headPos.x + diffX, headPos.y + diffY)

    local headSize = self.m_headSize
    if nextPos.x <= -display.width/2 + headSize.width then
        self.m_direction = 90
        nextPos.x = -display.width/2 + headSize.width
        local dx = headPos.x - nextPos.x
        nextPos.y = math.sqrt(_baseStepDistance*_baseStepDistance - dx*dx) + self.m_snakeYpos
    elseif nextPos.x > display.width/2 - headSize.width then
        self.m_direction = 90
        nextPos.x = display.width/2 - headSize.width
        local dx = nextPos.x - headPos.x
        nextPos.y = math.sqrt(_baseStepDistance*_baseStepDistance - dx*dx) + self.m_snakeYpos
    end

    table.insert(self.m_pathList, 1, nextPos)
    table.remove(self.m_pathList, #self.m_pathList)

    diffY = nextPos.y - self.m_snakeYpos
    for _, pos in ipairs(self.m_pathList) do
        pos.y = pos.y - diffY
    end

    self.m_moveCallBack(diffY)
end

function Snake:updatePosWithWall(wall)
    local wallPos = cc.p(wall:getPositionX(), wall:getPositionY())
    local wallSize = wall:getContentSize()

    local headPos = self.m_pathList[1]
    local headSize = self.m_headSize

    local nextPos = {}
    if math.abs(headPos.x - wallPos.x) < headSize.width/2 and 
        (headPos.y < wallPos.y + wallSize.height/2) and (headPos.y > wallPos.y - wallSize.height/2) then
        
        if headPos.x >= wallPos.x then
            nextPos.x = wallPos.x + headSize.width/2
        elseif headPos.x < wallPos.x then
            nextPos.x = wallPos.x - headSize.width/2
        end

        local dx = nextPos.x - headPos.x
        print("xxxxxxxxxxxxxxxx", nextPos.x, headPos.x, _baseStepDistance, self.m_snakeYpos, dx)
        nextPos.y = math.sqrt(math.abs(_baseStepDistance*_baseStepDistance - dx*dx)) + self.m_snakeYpos
        print("Snake:updatePosWithWall ----------------------", nextPos.x, nextPos.y)
    else
        return
    end

    self.m_direction = 90
    table.insert(self.m_pathList, 1, nextPos)
    table.remove(self.m_pathList, #self.m_pathList)
    
    local diffY = nextPos.y - self.m_snakeYpos
    for _, pos in ipairs(self.m_pathList) do
        pos.y = pos.y - diffY
    end

    self:updateBodiesPos()
    self.m_moveCallBack(diffY)
end

function Snake:insertPathesToTail()
    local tailDirection = self:getTailDirection()
    local diffX = _baseStepDistance*math.cos(tailDirection) 
    local diffY = _baseStepDistance*math.sin(tailDirection)
    local tailPos = clone(self.m_pathList[#self.m_pathList])

    for i = 1, _bodyMapSteps do
        tailPos.x = tailPos.x - diffX
        tailPos.y = tailPos.y - diffY
        table.insert(self.m_pathList, clone(tailPos))
    end
end

function Snake:getTailDirection()
    local pathCount = #self.m_pathList 

    if pathCount == 1 then
        return math.rad(self.m_direction)
    else
        local tail1Pos = self.m_pathList[pathCount]
        local tail2Pos = self.m_pathList[pathCount - 1]
        local rad = cc.pToAngleSelf(cc.pSub(tail2Pos, tail1Pos))
        return rad
    end
end

function Snake:onGameEnd()
    self:removeScheduler()
end

function Snake:onCleanup()
    self:removeScheduler()
end

return Snake