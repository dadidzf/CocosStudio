local Start = class("Start", cc.load("mvc").ViewBase)
local MODULE_PATH = ...

Start.RESOURCE_FILENAME = "Start.csb"
Start.RESOURCE_BINDING = {
    ["fenxiang"] = {varname = "m_btnShare", events = {{ event = "click", method = "onShare" }}},
    ["dianzan"] = {varname = "m_btnRate", events = {{ event = "click", method = "onRate" }}},
    ["gouwuche"] = {varname = "m_btnShop", events = {{ event = "click", method = "onShop" }}},
    ["yinxiao"] = {varname = "m_checkBoxSound"},
    ["quguanggao"] = {varname = "m_checkBoxNoAds"},

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

    self.m_checkBoxNoAds:onEvent(handler(self, self.onNoAds))
    self.m_checkBoxSound:onEvent(handler(self, self.onSound))
    self.m_checkBoxSound:setSelected(not dd.GameData:isSoundEnable())
    self.m_checkBoxNoAds:setSelected(dd.GameData:isAdsRemoved())

    if device.platform ~= "ios" then
        self.m_btnRestore:setVisible(false)
    end

    self.m_btnList = {self.m_btnShare, self.m_btnRate, self.m_btnShop, self.m_checkBoxSound, self.m_checkBoxNoAds}

    self:showButtonAction()

    if display.height < 960 then
        self.m_imgBalloon:setScale(display.height*0.9/960)
    end
end

function Start:showButtonAction()
    self.m_imgTitle:setOpacity(0)
    self.m_imgTitle:runAction(cc.FadeIn:create(1.0))
    self.m_btnPlay:setOpacity(0)
    self.m_btnPlay:runAction(cc.FadeIn:create(1.0))
    self.m_btnRestore:setOpacity(0)
    self.m_btnRestore:runAction(cc.FadeIn:create(1.0))

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
    dd.PlaySound("button.wav")
    cc.load("sdk").Tools.share(dd.Constants.SHARE_TIPS.getTips(), 
        cc.FileUtils:getInstance():fullPathForFilename("512.png"))
end

function Start:onRate()
    dd.PlaySound("button.wav")
    cc.load("sdk").Tools.rate()
end

function Start:onShop()
    dd.PlaySound("button.wav")
    local gameShop = import(".ShopLayer", MODULE_PATH):create()
    self:addChild(gameShop)
end

function Start:onSound()
    dd.PlaySound("button.wav")
    dd.GameData:setSoundEnable(not dd.GameData:isSoundEnable())
end

function Start:onNoAds()
    dd.PlaySound("button.wav")
    cc.load("sdk").Billing.purchase(dd.appCommon.skuKeys[1], function (result)
        print("Billing Purchase Result ~ ", result)
        if (result and device.platform == "ios") or 
            (result ~= "failed" and device.platform == "android") then
                cc.load("sdk").Admob.getInstance():setAdsRemoved(true)
                dd.GameData:setAdsRemoved(true)
                self.m_checkBoxNoAds:setSelected(dd.GameData:isAdsRemoved())
        end
    end)

    self.m_checkBoxNoAds:setSelected(dd.GameData:isAdsRemoved())
end

function Start:onRestore()
    dd.PlaySound("button.wav")
    cc.load("sdk").Billing.restore(function (...)
        print("Billing Restore Result ~ ")
        local paramTb = {...}
        dump(paramTb)
        for _, result in ipairs(paramTb) do
            if result == dd.appCommon.skuKeys[1] then
                cc.load("sdk").Admob.getInstance():setAdsRemoved(true)
                dd.GameData:setAdsRemoved(true)
                self.m_checkBoxNoAds:setSelected(dd.GameData:isAdsRemoved())
                break
            end
        end
    end)
end

function Start:onPlay()
    dd.PlaySound("button.wav")
    print("Start:onPlay")

    dd.GameData:setLevel(1)
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