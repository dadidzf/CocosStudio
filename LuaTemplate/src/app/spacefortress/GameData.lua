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

return GameData
