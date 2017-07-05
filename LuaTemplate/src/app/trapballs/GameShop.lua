local GameShop = class("GameShop", cc.load("mvc").ViewBase)
local MODULE_PATH = ...

GameShop.RESOURCE_FILENAME = "Node_buy.csb"
GameShop.RESOURCE_BINDING = {
    ["Button_1"] = {varname = "m_btn099", events = {{ event = "click", method = "on099" }}},
    ["Button_2"] = {varname = "m_btn029", events = {{ event = "click", method = "on299" }}},
    ["Button_3"] = {varname = "m_btn099", events = {{ event = "click", method = "on999" }}},
    ["Button_4"] = {varname = "m_btn299", events = {{ event = "click", method = "on2999" }}},
    ["Button_close"] = {varname = "m_btnClose", events = {{ event = "click", method = "onClose" }}},
}

function GameShop:ctor()
    self.super.ctor(self)
end

function GameShop:onCreate()
    self:showMask()
    self:getMask():onClick(function ()
        self:removeFromParent()
    end)
end

function GameShop:on099()
    print("GameShop:on099")
end

function GameShop:on299()
    print("GameShop:on299")
end

function GameShop:on999()
    print("GameShop:on999")
end

function GameShop:on2999()
    print("GameShop:on2999")
end

function GameShop:onClose()
    print("GameShop:onClose")
    self:removeFromParent()
end

return GameShop