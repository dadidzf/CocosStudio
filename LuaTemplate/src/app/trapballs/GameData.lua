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

return GameData