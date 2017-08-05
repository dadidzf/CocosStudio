local Body = class("Body", function ( ... )
    return cc.Sprite:create()
end)

function Body:ctor(isHead)
    if isHead then
        self:initWithSpriteFrameName(string.format("tou%d.png", dd.GameData:getHeadIndex()))
    else
        self:initWithSpriteFrameName("balloon1.png")
        self:setScale(0.7)
        local size = self:getContentSize()
        self.m_labelNum = cc.Label:createWithBMFont(string.format("fnt/snake_white_32_%d.fnt", 1), "")
            :setScale(1.3)
            :setOpacity(210)
            :move(size.width/2, size.height*0.65)
            :addTo(self)
    end
end

function Body:setNumber(num)
    self.m_labelNum:setBMFontFilePath(string.format("fnt/snake_white_32_%d.fnt", num%10 + 1))
    self.m_labelNum:setString(tostring(num))
    self:setSpriteFrame(string.format("balloon%d.png", num%10 + 1))
end

function Body:setDirection(rad)
    local angle = 90 - rad*180/math.pi
    self:setRotation(angle)
end

return Body