local GameData = class("GameData")

function GameData:refreshHighScore(height)
    assert(height > self.m_highScore, "Can not be less than 0 !")
    cc.UserDefault:getInstance():setIntegerForKey("highScore", height)

    self.m_highScore = height
end

function GameData:getHighScore()
    if not self.m_highScore then
        self.m_highScore = cc.UserDefault:getInstance():getIntegerForKey("highScore", 0)
    end

    return self.m_highScore
end

return GameData