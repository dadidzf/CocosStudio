local BalloonsContainer = class("BalloonsContainer", cc.Node)
local Balloon = import(".Balloon")

function BalloonsContainer:ctor()
    self:enableNodeEvents()

    self.m_balloonsList = {}
    self.m_posXList = {53, 159, 265, 371, 477, 583}
    self.m_linePosXList = {106, 212, 318, 424, 530}
    self.m_levelCreateProb = {0.4, 0.5, 0.6, 0.7, 0.7}

    self.m_symbolList = {"+", "-", "×", "/", "bomb", "diamond", "wall"}
    self.m_symbolGenarator = self:getSymbolGenarator()

    self.m_colLastWallList = {}
end

function BalloonsContainer:start()
    self.m_scheduler = dd.scheduler:scheduleScriptFunc(handler(self, self.createBalloons), 0.5, false)
end

function BalloonsContainer:removeSheduler()
    if self.m_scheduler then
        dd.scheduler:unscheduleScriptEntry(self.m_scheduler)
        self.m_scheduler = nil
    end
end

function BalloonsContainer:getSymbolGenarator()
    local levelSymbolProb = {
        {100, 10, 1, 5, 1, 5, 5},
        {100, 100, 10, 30, 50, 5, 50},
        {100, 200, 10, 50, 100, 5, 60},
        {100, 300, 10, 100, 200, 5, 70},
        {100, 300, 5, 200, 300, 5, 70},
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
    for i = 1, 6 do
        if math.random() > 0.5 then 
            local randX = self.m_posXList[i] - 320 --+ (math.random() - 0.5)*50 
            local symbol = self.m_symbolGenarator()
            local posY = 640
            local balloon = Balloon:create(math.random(1, 9), symbol)
                :addTo(self)
            local balloonSize = balloon:getContentSize()

            if symbol == "wall" then
                local index = i%5 + 1
                randX = self.m_linePosXList[index] - 320
                local lastWall = self.m_colLastWallList[index] 

                if not tolua.isnull(lastWall) then
                    local lastPosY = lastWall:getPositionY()
                    if (posY - lastPosY) < balloonSize.height then
                        posY = lastPosY + balloonSize.height
                    end
                end

                self.m_colLastWallList[index] = balloon
            end

            balloon:move(randX, posY)

            local index = #self.m_balloonsList + 1
            self.m_balloonsList[index] = balloon
            local moveAction = cc.MoveBy:create(10.0, cc.p(0, -2560)), 2
            
            local filterList = {["+"] = true, ["-"] = true, ["wall"] = true}
            if math.random() < 0.5 and not filterList[symbol] then
                if dd.GameData:getCurLevel() > 2 then
                    moveAction = cc.MoveBy:create(4.0, cc.p(0, -1280)), 2
                end
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
    end
end

function BalloonsContainer:onGameEnd()
    self:removeSheduler()
    for _, balloon in pairs(self.m_balloonsList) do
        balloon:pause()
    end
end

function BalloonsContainer:removeBalloon(index)
    self.m_balloonsList[index] = nil
end

function BalloonsContainer:getBalloonsList()
    return self.m_balloonsList
end

function BalloonsContainer:onCleanup()
    self:removeSheduler()
end

return BalloonsContainer 