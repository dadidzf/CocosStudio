local Start = class("Start", cc.load("mvc").ViewBase)
local MODULE_PATH = ...

Start.RESOURCE_FILENAME = "Start.csb"
Start.RESOURCE_BINDING = {
    ["fenxiang"] = {varname = "m_btnShare", events = {{ event = "click", method = "onShare" }}},
    ["dianzan"] = {varname = "m_btnRate", events = {{ event = "click", method = "onRate" }}},
    ["gouwuche"] = {varname = "m_btnShop", events = {{ event = "click", method = "onShop" }}},
    ["yinxiao"] = {varname = "m_checkBoxSound", events = {{ event = "click", method = "onSound" }}},
    ["quguanggao"] = {varname = "m_btnNoAds", events = {{ event = "click", method = "onNoAds" }}},

    ["Restore"] = {varname = "m_btnRestore", events = {{ event = "click", method = "onRestore" }}},
    ["daqiqiu_3"] = {varname = "m_imgBalloon"},
    ["Sprite_2"] = {varname = "m_imgTitle"},
    ["daqiqiu_3.play"] = {varname = "m_btnPlay", events = {{ event = "click", method = "onPlay" }}}
}

function Start:ctor(scene)
    self.super.ctor(self)
    
    self.m_scene = scene
    local resourceNode = self:getResourceNode()
    resourceNode:setContentSize(display.size)
    ccui.Helper:doLayout(resourceNode)

    if device.platform ~= "ios" then
        self.m_btnRestore:setVisible(false)
    end

    self.m_btnList = {self.m_btnShare, self.m_btnRate, self.m_btnShop, self.m_checkBoxSound, self.m_btnNoAds}

    self:showButtonAction()
end

function Start:showButtonAction()
    local posY = self.m_btnShare:getPositionY()

    for index, btn in ipairs(self.m_btnList) do
        btn:setScale(0.8)
        btn:setPositionY(posY - 150)           
    end

    local getAction = function (delayTime)
        return cc.Sequence:create(
            cc.DelayTime:create(delayTime),
            cc.MoveBy:create(0.2, cc.p(0, 150)),
            cc.ScaleTo:create(0.2, 1.2),
            cc.ScaleTo:create(0.1, 1.0)
            )         
    end 

    for index, btn in ipairs(self.m_btnList) do
        btn:runAction(getAction((index - 1)*0.1))
    end
end

function Start:hideButtonAction()
    local getAction = function (delayTime)
        return cc.Sequence:create(
            cc.DelayTime:create(delayTime),
            cc.ScaleTo:create(0.2, 1.2),
            cc.ScaleTo:create(0.1, 1.0),
            cc.MoveBy:create(0.2, cc.p(0, -150))
            )         
    end 

    local btnCount = #self.m_btnList
    for index = btnCount, 1, -1 do
        local btn = self.m_btnList[index]
        btn:runAction(getAction((btnCount - index + 1)*0.1))
    end
end

function Start:onShare()
end

function Start:onRate()
end

function Start:onShop()
end

function Start:onSound()
end

function Start:onNoAds()
end

function Start:onRestore()
end

function Start:onPlay()
    print("Start:onPlay")

    self:hideButtonAction()
    self.m_imgTitle:runAction(cc.FadeOut:create(0.5))
    self.m_btnRestore:runAction(cc.FadeOut:create(0.5))
    self.m_btnPlay:runAction(cc.Sequence:create(
        cc.FadeOut:create(0.5),
        cc.CallFunc:create(function ( ... )
            self.m_imgBalloon:runAction(cc.EaseIn:create(cc.MoveBy:create(1.0, cc.p(0, display.height)), 3))
        end),
        cc.DelayTime:create(1.0),
        cc.CallFunc:create(function ( ... )
            cc.Director:getInstance():getEventDispatcher():setEnabled(true)
            self.m_scene:startGame()
        end)
        ))
end

return Start