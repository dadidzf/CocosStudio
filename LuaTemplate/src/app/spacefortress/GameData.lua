local GameData = class("GameData")
local _userDefault = cc.UserDefault:getInstance()

function GameData:isSoundEnable()
    if nil == self.m_isSoundEnable then
        self.m_isSoundEnable = _userDefault:getBoolForKey("isSoundEnable", true)
    end

    return self.m_isSoundEnable
end

function GameData:setSoundEnable(val)
    self.m_isSoundEnable = val
    _userDefault:setBoolForKey("isSoundEnable", val)
end

function GameData:isMusicEnable()
    if nil == self.m_isMusicEnable then
        self.m_isMusicEnable = _userDefault:getBoolForKey("isMusicEnable", true)
    end

    return self.m_isMusicEnable
end

function GameData:setMusicEnable(val)
    self.m_isMusicEnable = val
    _userDefault:setBoolForKey("isMusicEnable", val)
end

function GameData:getBestScore()
    if nil == self.m_bestScore then
        self.m_bestScore = _userDefault:getIntegerForKey("bestScore", 0)
    end

    return self.m_bestScore
end

function GameData:refreshBestScore(score)
    if score > self.m_bestScore then
        self.m_bestScore = score
        _userDefault:setIntegerForKey("bestScore", score)
    end
end

return GameData
