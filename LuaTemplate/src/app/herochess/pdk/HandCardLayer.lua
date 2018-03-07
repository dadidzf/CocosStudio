local HandCardLayer = class("HandCardLayer", cc.Node)
local CardSprite = import(".CardSprite")
local logic = import(".logic")

local _CARD_X_DISTANCE_RATIO = 0.5

function HandCardLayer:ctor(selectCardscallBack)
    self:initTouch()
    self.m_cardSprites = {}
    local cardContentSize = CardSprite:create(0x1):getContentSize()
    self.m_cardWidth = cardContentSize.width
    self.m_cardHeight = cardContentSize.height
    self.m_xDistance = self.m_cardWidth*_CARD_X_DISTANCE_RATIO

    self.m_selectCardsCallBack = selectCardscallBack
end

function HandCardLayer:initCards(handCards)
    logic.sort_for_display(handCards)
    local cardsCount = #handCards
    local totalWidth = (cardsCount - 1)*self.m_xDistance + self.m_cardWidth
    self.m_beginXPos = -totalWidth/2
    self.m_endXPos = totalWidth/2

    for i, card in ipairs(handCards) do
        local cardSprite = CardSprite:create(card)
            :move(self.m_beginXPos + (i - 1)*self.m_xDistance + self.m_cardWidth/2, self.m_cardHeight/2)
            :setLocalZOrder(i)
            :addTo(self)

        cardSprite:recordPosition()
        self.m_cardSprites[i] = cardSprite
    end
end

function HandCardLayer:onSendCard(handCards)
end

function HandCardLayer:resortCards()
    local cardsCount = #self.m_cardSprites
    local totalWidth = (cardsCount - 1)*self.m_xDistance + self.m_cardWidth
    self.m_beginXPos = -totalWidth/2
    self.m_endXPos = totalWidth/2

    for i, cardSprite in ipairs(self.m_cardSprites) do
        cardSprite:move(self.m_beginXPos + (i - 1)*self.m_xDistance + self.m_cardWidth/2, self.m_cardHeight/2)
        cardSprite:recordPosition()
    end
end

function HandCardLayer:initTouch()
    local listener = cc.EventListenerTouchOneByOne:create()
    listener:registerScriptHandler(handler(self, self.onTouchBegin), cc.Handler.EVENT_TOUCH_BEGAN)
    listener:registerScriptHandler(handler(self, self.onTouchMoved), cc.Handler.EVENT_TOUCH_MOVED)
    listener:registerScriptHandler(handler(self, self.onTouchEnded), cc.Handler.EVENT_TOUCH_ENDED)
    listener:registerScriptHandler(handler(self, self.onTouchEnded), cc.Handler.EVENT_TOUCH_CANCELLED)
    listener:setSwallowTouches(true)

    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self)
end

function HandCardLayer:onOutCard(outCards)
    local outSet = {}
    for _, card in ipairs(outCards) do
        outSet[card] = true
    end

    local cardCounts = #self.m_cardSprites 
    local remainCardSprites = {}
    for _, cardSprite in ipairs(self.m_cardSprites) do
        if outSet[cardSprite:getCard()] then
            cardSprite:removeFromParent() 
        else
            table.insert(remainCardSprites, cardSprite)
            cardSprite:setLocalZOrder(#remainCardSprites)
        end
    end

    self.m_cardSprites = remainCardSprites
    self:resortCards()
end

function HandCardLayer:getHandCards()
    local handCards = {}
    for _, cardSprite in ipairs(self.m_cardSprites) do
        table.insert(handCards, cardSprite:getCard())
    end

    return handCards
end

function HandCardLayer:getStandCards()
    local outCards = {}
    for _, cardSprite in ipairs(self.m_cardSprites) do
        if cardSprite:isStandOut() then
            table.insert(outCards, cardSprite:getCard())
        end
    end

    return outCards
end

function HandCardLayer:getCardSpriteByPosX(x)
    local index = 0
    local cardCounts = #self.m_cardSprites
    if x >= (self.m_xDistance*(cardCounts - 1) + self.m_beginXPos) and 
        x <= self.m_endXPos then
        index = #self.m_cardSprites
    else
        index = math.modf((x - self.m_beginXPos)/self.m_xDistance) + 1
    end

    return self.m_cardSprites[index]
end

function HandCardLayer:onTouchBegin(touch, event)
    local pos = self:convertToNodeSpace(touch:getLocation())
    if pos.x >= self.m_beginXPos and pos.x <= self.m_endXPos and 
        pos.y >= 0 and pos.y <= self.m_cardHeight then

        local cardSprite = self:getCardSpriteByPosX(pos.x)
        cardSprite:setSelected(true)
        return true
    end 

    return false
end

function HandCardLayer:onTouchMoved(touch, event)
    local pos = self:convertToNodeSpace(touch:getLocation())
    local cardSprite = self:getCardSpriteByPosX(pos.x)
    if cardSprite then
        cardSprite:setSelected(true)
    end
end

function HandCardLayer:onTouchEnded(touch, event)
    for index, cardSprite in ipairs(self.m_cardSprites) do
        if cardSprite:isSelected() then
            cardSprite:setSelected(false) 
            if cardSprite:isStandOut() then
                cardSprite:standIn()
            else
                cardSprite:standOut()
            end
        end
    end

    if self.m_selectCardsCallBack then
        self.m_selectCardsCallBack()
    end
end

return HandCardLayer