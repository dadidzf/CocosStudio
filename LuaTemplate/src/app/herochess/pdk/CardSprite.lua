local CardSprite = class("CardSprite", cc.load("mvc").ViewBase)

CardSprite.RESOURCE_FILENAME = "pdk/CardSprite.csb"
CardSprite.RESOURCE_BINDING = {
    ["node_val"] = {varname = "m_nodeVal"},
    ["bg_select"] = {varname = "m_bgSelect"},
    ["node_color.spade"] = {varname = "m_colorSpade"},
    ["node_color.heart"] = {varname = "m_colorHeart"},
    ["node_color.cube"] = {varname = "m_colorCube"},
    ["node_color.diamond"] = {varname = "m_colorDiamond"}
}

local _CARD_STAND_OUT_Y_RATIO = 0.3

function CardSprite:ctor(card)
    self.super.ctor(self)
    local cardColor = math.modf(card/16) + 1
    local cardVal = math.fmod(card, 16)
    self.m_card = card
    self.m_standOutY = _CARD_STAND_OUT_Y_RATIO*self:getContentSize().height

    self:showColor(cardColor)
    self:showVal(cardColor, cardVal)
end

function CardSprite:recordPosition()
    self.m_pos = cc.p(self:getPositionX(), self:getPositionY())
end

function CardSprite:showColor(cardColor)
    local cardColorMapNode = {
        self.m_colorDiamond, self.m_colorCube, self.m_colorHeart, self.m_colorSpade 
    }

    cardColorMapNode[cardColor]:setVisible(true)
end

function CardSprite:showVal(cardColor, cardVal)
    if cardColor == 1 or cardColor == 3 then  -- diamond or heart
        self.m_nodeVal:getChildByName(string.format("red_%d", cardVal)):setVisible(true)
    else
        self.m_nodeVal:getChildByName(string.format("black_%d", cardVal)):setVisible(true)
    end
end

function CardSprite:isStandOut()
    return self.m_isStandOut
end

function CardSprite:standOut()
    self.m_isStandOut = true
    self:runAction(cc.MoveTo:create(0.2, 
        cc.p(self.m_pos.x, self.m_pos.y + self.m_standOutY)))
end

function CardSprite:standIn()
    self.m_isStandOut = false
    self:runAction(cc.MoveTo:create(0.2, self.m_pos))
end

function CardSprite:isSelected()
    return self.m_bgSelect:isVisible()
end

function CardSprite:setSelected(val)
    self.m_bgSelect:setVisible(val)
end

function CardSprite:getContentSize()
    return self.m_bgSelect:getContentSize()
end

function CardSprite:getCard()
    return self.m_card
end

return CardSprite