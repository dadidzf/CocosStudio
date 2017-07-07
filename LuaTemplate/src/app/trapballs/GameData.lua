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

return GameData