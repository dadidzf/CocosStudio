local GameData = class("GameData")

function GameData:getCurLevel()
    self.m_curLevel = self.m_curLevel or 1
    return self.m_curLevel 
end

function GameData:setLevel(level)
    self.m_curLevel = level
end

function GameData:isSoundEnable()
    if nil == self.m_isSoundEnable then
        self.m_isSoundEnable = cc.UserDefault:getInstance():getBoolForKey("isSoundEnable", true)
    end

    return self.m_isSoundEnable
end

function GameData:setSoundEnable(val)
    self.m_isSoundEnable = val
    cc.UserDefault:getInstance():setBoolForKey("isSoundEnable", val)
end

function GameData:getDiamonds()
    if not self.m_diamonds then
        self.m_diamonds = cc.UserDefault:getInstance():getIntegerForKey("diamonds", dd.Constants.INIT_DIAMONDS)
    end

    return self.m_diamonds
end

function GameData:refreshDiamonds(diamond)
    assert(diamond >= 0, "Can not be less than 0 !")
    cc.UserDefault:getInstance():setIntegerForKey("diamonds", diamond)

    self.m_diamonds = diamond
end

function GameData:getHighScore()
    if not self.m_highScore then
        self.m_highScore = cc.UserDefault:getInstance():getIntegerForKey("highScore", 0)
    end

    return self.m_highScore
end

function GameData:refreshHighScore(score)
    assert(score > self.m_highScore, "Can not be less than 0 !")
    cc.UserDefault:getInstance():setIntegerForKey("highScore", score)

    self.m_highScore = score
end

function GameData:isAdsRemoved()
    if not self.m_isAdsRemoved then
        self.m_isAdsRemoved = cc.UserDefault:getInstance():getBoolForKey("noads", false)
    end

    return self.m_isAdsRemoved
end

function GameData:setAdsRemoved(val)
    self.m_isAdsRemoved = val
    cc.UserDefault:getInstance():setBoolForKey("noads", true)
end

function GameData:getHeadIndex()
    if not self.m_headIndex then
        self.m_headIndex = cc.UserDefault:getInstance():getIntegerForKey("headIndex", 1)
    end

    return self.m_headIndex
end

function GameData:setHeadIndex(index)
    self.m_headIndex = index
    cc.UserDefault:getInstance():setIntegerForKey("headIndex", index)
end

return GameData





