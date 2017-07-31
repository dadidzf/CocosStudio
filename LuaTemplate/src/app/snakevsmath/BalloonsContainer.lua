local BalloonsContainer = class("BalloonsContainer", cc.Node)
local Balloon = import(".Balloon")

function BalloonsContainer:ctor()
    self.m_balloonsList = {}
    self.m_posXList = {53, 159, 265, 371, 477, 583}
    self.m_levelCreateProb = {0.05, 0.1, 0.2}

    self.m_symbolList = {"+", "-", "x", "/", "bomb", "diamond"}
    self.m_symbolGenarator = self:getSymbolGenarator()

    self.m_scheduler = dd.scheduler:scheduleScriptFunc(handler(self, self.createBalloons), 0.01, false)
end

function BalloonsContainer:getSymbolGenarator()
    local levelSymbolProb = {
        {100, 100, 10, 10, 20, 5},
        {100, 200, 10, 20, 30, 5},
        {100, 300, 10, 30, 40, 5}
    }
    local levelSymbolProbIncreaseList = {}
    for index, levelProbList in ipairs(levelSymbolProb) do
        local increaseTb = {}
        local totalNum = 0
        for _, probNum in ipairs(levelProbList) do
            totalNum = totalNum + probNum
            table.insert(increaseTb, totalNum)
        end
        levelSymbolProbIncreaseList[index] = increaseTb
    end

    dump(levelSymbolProbIncreaseList)
    return function ( ... )
        local curLevelProbIncreaseList = levelSymbolProbIncreaseList[dd.GameData:getCurLevel()]
        local totalProbNum = curLevelProbIncreaseList[#curLevelProbIncreaseList]
        local randNum = math.random(totalProbNum)

        for index, probNum in ipairs(curLevelProbIncreaseList) do
            if randNum <= probNum then
                return self.m_symbolList[index]
            end
        end
    end
end

function BalloonsContainer:createBalloons()
    local level = dd.GameData:getCurLevel()
    if math.random() < self.m_levelCreateProb[level] then
        self:addBalloon()
    end
end

function BalloonsContainer:addBalloon()
    self.m_posXIndex = self.m_posXIndex or 1
    local xCount= #self.m_posXList
    self.m_posXIndex = self.m_posXIndex + math.random(xCount - 1)
    if self.m_posXIndex > xCount then
        self.m_posXIndex = self.m_posXIndex - xCount
    end

    local randX = self.m_posXList[self.m_posXIndex] - 320 --+ (math.random() - 0.5)*50 
    local balloon = Balloon:create(math.random(1, 9), self.m_symbolGenarator())
        :move(randX, 640)
        :addTo(self)

    local index = #self.m_balloonsList + 1
    self.m_balloonsList[index] = balloon
    local moveAction = cc.MoveBy:create(3.0, cc.p(0, -1280)), 2
    
    if math.random() < 0.2 then
        moveAction = cc.EaseInOut:create(moveAction, 2)
    end

    balloon:runAction(cc.Sequence:create(
        moveAction, 
        cc.CallFunc:create(function ( ... )
            balloon:removeFromParent()
            self.m_balloonsList[index] = nil
        end)
        ))
end

function BalloonsContainer:getBalloonsList()
    return self.m_balloonsList
end

return BalloonsContainer 