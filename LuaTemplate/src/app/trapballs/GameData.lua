local GameData = class("GameData")

function GameData:getCurLevel()
    if not self.m_curLevel then
        self.m_curLevel = cc.UserDefault:getInstance():getIntegerForKey("curLevel", 1)
    end
    return self.m_curLevel 
end

function GameData:levelPass(level)
    if level == self.m_curLevel then
        cc.UserDefault:getInstance():setIntegerForKey("curLevel", level + 1)
        self.m_curLevel = level + 1
    end
end

function GameData:getLineLevel()
    if not self.m_lineLevel then
        self.m_lineLevel = cc.UserDefault:getInstance():getIntegerForKey("lineLevel", 1)
    end
    return self.m_lineLevel
end

function GameData:isSoundEnable()
    if nil == self.m_isSoundEnable then
        self.m_isSoundEnable = cc.UserDefault:getInstance():getBoolForKey("isSoundEnable", true)
    end

    print("self.m_isSoundEnable", self.m_isSoundEnable)
    return self.m_isSoundEnable
end

function GameData:setSoundEnable(val)
    self.m_isSoundEnable = val
    cc.UserDefault:getInstance():setBoolForKey("isSoundEnable", val)
end

function GameData:refreshLevelScore(level, score)
    local isBest = false
    local topThree = self:getLevelTopThree(level)
    for index, topScore in ipairs(topThree) do
        if score > topScore then
            table.insert(topThree, index, score) 
            break
        end
    end

    for i = 1, 3 do
        cc.UserDefault:getInstance():setIntegerForKey(string.format("levelScore-%d-%d", level, i), topThree[i])
    end

    if topThree[1] <= score then
        isBest = true
    end 

    return isBest
end

function GameData:getLevelTopThree(level)
    local retTb = {}
    for i = 1, 3 do
        table.insert(retTb, cc.UserDefault:getInstance():getIntegerForKey(string.format("levelScore-%d-%d", level, i), 0))
    end

    return retTb
end

return GameData