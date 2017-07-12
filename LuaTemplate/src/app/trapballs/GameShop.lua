local GameShop = class("GameShop", cc.load("mvc").ViewBase)
local MODULE_PATH = ...

GameShop.RESOURCE_FILENAME = "Node_buy.csb"
GameShop.RESOURCE_BINDING = {
    ["Button_1"] = {varname = "m_btn099", events = {{ event = "click", method = "on099" }}},
    ["Button_2"] = {varname = "m_btn029", events = {{ event = "click", method = "on299" }}},
    ["Button_3"] = {varname = "m_btn099", events = {{ event = "click", method = "on999" }}},
    ["Button_4"] = {varname = "m_btn299", events = {{ event = "click", method = "on2999" }}},
    ["Button_close"] = {varname = "m_btnClose", events = {{ event = "click", method = "onClose" }}},

    ["BitmapFontLabel_1"] = {varname = "m_labelDiamonds099"},
    ["BitmapFontLabel_2"] = {varname = "m_labelDiamonds299"},
    ["BitmapFontLabel_3"] = {varname = "m_labelDiamonds999"},
    ["BitmapFontLabel_4"] = {varname = "m_labelDiamonds2999"},
}


function GameShop:ctor(callBack)
    self.super.ctor(self)
    self.m_callBack = callBack

    self:setOpacity(0)
    self:setCascadeOpacityEnabled(true)
    self:runAction(cc.FadeIn:create(0.3))

    self.m_labelDiamonds099:setString(tostring(dd.Constants.MONEY_MAP_DIAMONDS.dollar099))
    self.m_labelDiamonds299:setString(tostring(dd.Constants.MONEY_MAP_DIAMONDS.dollar299))
    self.m_labelDiamonds999:setString(tostring(dd.Constants.MONEY_MAP_DIAMONDS.dollar999))
    self.m_labelDiamonds2999:setString(tostring(dd.Constants.MONEY_MAP_DIAMONDS.dollar2999))
end

function GameShop:onCreate()
    self:showMask()
    self.m_curDiamodns = dd.GameData:getDiamonds() 
end

function GameShop:on099()
    print("GameShop:on099")
    self.m_curDiamodns = self.m_curDiamodns + dd.Constants.MONEY_MAP_DIAMONDS.dollar099
    dd.GameData:refreshDiamonds(self.m_curDiamodns)
    
    self:close(true)
end

function GameShop:on299()
    print("GameShop:on299")
    self.m_curDiamodns = self.m_curDiamodns + dd.Constants.MONEY_MAP_DIAMONDS.dollar299
    dd.GameData:refreshDiamonds(self.m_curDiamodns)

    self:close(true)
end

function GameShop:on999()
    print("GameShop:on999")
    self.m_curDiamodns = self.m_curDiamodns + dd.Constants.MONEY_MAP_DIAMONDS.dollar999
    dd.GameData:refreshDiamonds(self.m_curDiamodns)

    self:close(true)
end

function GameShop:on2999()
    print("GameShop:on2999")
    self.m_curDiamodns = self.m_curDiamodns + dd.Constants.MONEY_MAP_DIAMONDS.dollar2999
    dd.GameData:refreshDiamonds(self.m_curDiamodns)

    self:close(true)
end

function GameShop:onClose()
    print("GameShop:onClose")
    self:close(nil)
end

function GameShop:close(callBackParam)
    self:runAction(cc.Sequence:create(
        cc.FadeOut:create(0.3),
        cc.CallFunc:create(function ( ... )
            self.m_callBack(callBackParam)
            self:removeFromParent()
        end),
        nil
        )
    )
end

return GameShop