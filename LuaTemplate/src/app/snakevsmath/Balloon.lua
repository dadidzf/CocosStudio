local Balloon = class("Balloon", function ( ... )
    return cc.Sprite:create()
end)

function Balloon:ctor(num, symbol)
    self.m_num = num
    self.m_symbol = symbol

    if symbol == "bomb" then
        self:initWithSpriteFrameName("zhadan.png")
    elseif symbol == "diamond" then
        self:initWithSpriteFrameName("diamondInGame.png")
    else
        self:initWithSpriteFrameName(string.format("balloon%d.png", num + 1))
        local size = self:getContentSize()
        self.m_labelNum = cc.Label:createWithBMFont("fnt/white_48.fnt", "")
            :move(size.width/2, size.height*0.65)
            :addTo(self)
        self.m_labelNum:setString(symbol .. tostring(num))
    end
end

function Balloon:dealSnakeNumber(snakeNum)
    local ret = 0 
    if self.m_symbol == "+" then
        ret = snakeNum + self.m_num
    elseif self.m_symbol == "-" then
        ret =  snakeNum - self.m_num
    elseif self.m_symbol == "x" then
        ret = snakeNum * self.m_num
    elseif self.m_symbol == "/" then
        ret =  snakeNum/self.m_num
    elseif self.m_symbol == "bomb" then
        return "dead"
    elseif self.m_symbol == "diamond" then
        return "diamond"
    end

    ret = math.floor(ret)
    return ret
end

return Balloon


