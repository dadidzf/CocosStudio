local GameData = class("GameData")

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

function GameData:isMusicEnable()
    if nil == self.m_isMusicEnable then
        self.m_isMusicEnable = cc.UserDefault:getInstance():getBoolForKey("isMusicEnable", true)
    end

    return self.m_isMusicEnable
end

function GameData:setMusicEnable(val)
    self.m_isMusicEnable = val
    cc.UserDefault:getInstance():setBoolForKey("isMusicEnable", val)
end

return GameData
