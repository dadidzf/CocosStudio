local BuyLives = class("BuyLives", cc.load("mvc").ViewBase)
local MODULE_PATH = ...

BuyLives.RESOURCE_FILENAME = "Node_buylife.csb"
BuyLives.RESOURCE_BINDING = {
    ["Button_no"] = {varname = "m_btnNo", events = {{ event = "click", method = "onNo" }}},
    ["Button_yes"] = {varname = "m_btnYes", events = {{ event = "click", method = "onYes" }}},
    ["BitmapFontLabel_allmoney"] = {varname = "m_labelDiamonds"},
    ["BitmapFontLabel_allmoney2"] = {varname = "m_labelDiamonds2"},
    ["BitmapFontLabel_money"] = {varname = "m_labelCostDiamonds"},
    ["BitmapFontLabel_lifenumber"] = {varname = "m_labelGivenLives"},
}

function BuyLives:ctor(callBack)
    self.super.ctor(self)

    self:updateDiamonds()
    self.m_labelCostDiamonds:setString(tostring(dd.Constants.MORE_RESOURCE.MORE_LIVES.diamonds))
    self.m_labelGivenLives:setString(tostring(dd.Constants.MORE_RESOURCE.MORE_LIVES.lives))

    self.m_callBack = callBack
end

function BuyLives:updateDiamonds()
    local totalDiamonds = dd.GameData:getDiamonds()
    local costDiamonds = dd.Constants.MORE_RESOURCE.MORE_LIVES.diamonds
    self.m_labelDiamonds:setString(tostring(totalDiamonds))
    self.m_labelDiamonds2:setString(tostring(totalDiamonds))
    self.m_labelDiamonds:setVisible(totalDiamonds >= costDiamonds)
    self.m_labelDiamonds2:setVisible(totalDiamonds < costDiamonds)

end

function BuyLives:onCreate()
    self:showMask()
end

function BuyLives:onNo()
    self.m_callBack(nil)
    self:removeFromParent()
end

function BuyLives:onYes()
    local totalDiamonds = dd.GameData:getDiamonds()
    local costDiamonds = dd.Constants.MORE_RESOURCE.MORE_LIVES.diamonds
    if totalDiamonds >= costDiamonds then
        dd.GameData:refreshDiamonds(totalDiamonds - costDiamonds)  
        self.m_callBack(dd.Constants.MORE_RESOURCE.MORE_LIVES.lives)
        self:removeFromParent()
    else
        local GameShop = import(".GameShop", MODULE_PATH)
        local gameShop = GameShop:create(function (isSuccess)
            self:setVisible(true)
            self:updateDiamonds()
        end)
        self:setVisible(false)
        gameShop:move(display.cx, display.cy)
        self:getParent():addChild(gameShop, 10)
    end
end

return BuyLives