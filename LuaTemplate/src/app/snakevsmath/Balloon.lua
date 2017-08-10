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
    elseif symbol == "wall" then
        self:initWithSpriteFrameName("qiang.png")
    else
        self:initWithSpriteFrameName(string.format("balloon%d.png", num + 1))
        local size = self:getContentSize()
        self.m_labelNum = cc.Label:createWithBMFont(string.format("fnt/snake_white_32_%d.fnt", num + 1), "")
            :move(size.width/2, size.height*0.65)
            :setScale(1.3)
            :setOpacity(210)
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
    elseif self.m_symbol == "×" then
        ret = snakeNum * self.m_num
    elseif self.m_symbol == "/" then
        ret =  snakeNum/self.m_num
    elseif self.m_symbol == "bomb" then
        return "bomb"
    elseif self.m_symbol == "diamond" then
        return "diamond"
    elseif self.m_symbol == "wall" then
        return "wall"
    end

    ret = math.floor(ret)
    return ret
end

function Balloon:getSymbol()
    return self.m_symbol
end

return Balloon


