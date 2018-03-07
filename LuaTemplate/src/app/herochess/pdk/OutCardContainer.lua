local OutCardContainer = class("OutCardContainer", cc.Node)
local CardSprite = import(".CardSprite")
local logic = import(".logic")

local _OUT_CARD_SCALE = 0.6
local _MAX_CARDS_IN_ONE_ROW = 8
local _OUT_CARD_X_DISTANCE_RATIO = 0.5
local _CARD_STAND_OUT_Y_RATIO = 0.5

OutCardContainer._OUT_TYPE = {
    LEFT = 1,
    CENTER = 2,
    RIGHT = 3
}

function OutCardContainer:ctor(t)
    self.m_outType = t

    local cardContentSize = CardSprite:create(0x1):getContentSize()
    self.m_cardWidth = cardContentSize.width*_OUT_CARD_SCALE
    self.m_cardHeight = cardContentSize.height*_OUT_CARD_SCALE
    self.m_xDistance = self.m_cardWidth*_OUT_CARD_X_DISTANCE_RATIO
    self.m_outStandY = _CARD_STAND_OUT_Y_RATIO*self.m_cardHeight*-1
end

function OutCardContainer:clear()
    self:removeAllChildren()
end

function OutCardContainer:showOutCards(outCards)
    self:clear()
    logic.sort_for_display(outCards)  

    local node = cc.Node:create() 
        :addTo(self)

    for index, card in ipairs(outCards) do
        local cardSprite = CardSprite:create(card)
            :setScale(_OUT_CARD_SCALE)
            :setLocalZOrder(index)
            :addTo(node)

        local x = self.m_cardWidth/2 + ((index - 1)%8)*self.m_xDistance
        local y = index > 8 and self.m_outStandY or 0
        cardSprite:move(x, y)
    end

    local maxCardOneRow = #outCards > _MAX_CARDS_IN_ONE_ROW and _MAX_CARDS_IN_ONE_ROW or #outCards
    local totalDistance = (maxCardOneRow - 1)*self.m_xDistance + self.m_cardWidth
    if self.m_outType == self._OUT_TYPE.CENTER then
        node:move(-totalDistance/2)
    elseif self.m_outType == self._OUT_TYPE.RIGHT then
        node:move(-totalDistance)
    end
end


return OutCardContainer
