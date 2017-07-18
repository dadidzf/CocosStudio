local MainScene = class("MainScene", cc.load("mvc").ViewBase)
local LevelScene = import(".LevelScene")
local GameShop = import(".GameShop")

MainScene.RESOURCE_FILENAME = "menu.csb"
MainScene.RESOURCE_BINDING = {
    ["Button_play"] = {varname = "m_btnPlay", events = {{ event = "click", method = "onPlay" }}},
    ["Button_fenxiang"] = {varname = "m_btnShare", events = {{ event = "click", method = "onShare" }}},
    ["Button_shangdian"] = {varname = "m_btnShop", events = {{ event = "click", method = "onShop" }}},
    ["Pannel_restore"] = {varname = "m_btnRestore", events = {{ event = "click", method = "onRestore" }}},
    ["Button_like"] = {varname = "m_btnLike", events = {{ event = "click", method = "onRate" }}},
    ["CheckBox_2"] = {varname = "m_checkBoxNoAds"},
    ["CheckBox_jingyin"] = {varname = "m_checkBoxSound"},

    ["Image_2"] = {varname = "m_imgGameName"},
    ["Image_1"] = {varname = "m_imgLineLeft"},
    ["Image_1_0"] = {varname = "m_imgLineRight"},

    ["Image_4"] = {varname = "m_imgDiamonds"},
    ["BitmapFontLabel_1"] = {varname = "m_labelDiamonds"}
}

function MainScene:onCreate()
    self:enableNodeEvents()
    local resourceNode = self:getResourceNode()
    resourceNode:setContentSize(display.size)
    ccui.Helper:doLayout(resourceNode)

    for _, v in pairs(dd.CsvConf:getColorCfg()) do
        resourceNode:getChildByName(v.image_di):setVisible(false)
        resourceNode:getChildByName(v.btn_play):setVisible(false)
    end

    local randomShow = dd.CsvConf:getRandomBgAndBtn()
    resourceNode:getChildByName(randomShow.image_di):setVisible(true)
    resourceNode:getChildByName(randomShow.btn_play):setVisible(true)
    self.m_btnPlayColor = resourceNode:getChildByName(randomShow.btn_play)

    self.m_checkBoxNoAds:onEvent(handler(self, self.onNoAds))
    self.m_checkBoxSound:onEvent(handler(self, self.onSoundOnOff))
    self.m_checkBoxSound:setSelected(not dd.GameData:isSoundEnable())
    self.m_checkBoxNoAds:setSelected(dd.GameData:isAdsRemoved())

    self.m_labelDiamonds:setString(tostring(dd.GameData:getDiamonds()))

    self:enterAction()

    if device.platform == "android" then
        self.m_btnRestore:setVisible(false)
    end
end

function MainScene:onEnterTransitionFinish()
    if not dd.GameData:isAdsRemoved() then
        if cc.load("sdk").Tools.getGamePlayCount() > 5 then
            cc.load("sdk").MyAds.showAds(100)
        end
    end
end

function MainScene:enterAction()
    self.m_imgDiamonds:setOpacity(0)
    self.m_labelDiamonds:setOpacity(0)
    self.m_btnLike:setScale(0)
    self.m_btnShop:setScale(0)
    self.m_btnShare:setScale(0)
    self.m_checkBoxSound:setScale(0)
    self.m_checkBoxNoAds:setScale(0)
    self.m_imgLineLeft:setPosition(0, display.cy)
    self.m_imgLineRight:setPosition(display.width, display.cy)
    self.m_imgGameName:setPosition(display.cx, display.cy)
    self.m_btnPlay:setVisible(false)
    self.m_btnPlayColor:setVisible(false)

    self.m_imgGameName:runAction(cc.MoveTo:create(0.5, cc.p(display.cx, display.height*0.75)))

    self.m_imgDiamonds:runAction(cc.Sequence:create(
        cc.DelayTime:create(0.5),
        cc.FadeIn:create(0.3),
        nil
        ))
    self.m_labelDiamonds:runAction(cc.Sequence:create(
        cc.DelayTime:create(0.8),
        cc.FadeIn:create(0.3),
        nil
        ))

    local getScaleAction = function (delayTime)
        local scaleAction = cc.Sequence:create(
            cc.DelayTime:create(delayTime),
            cc.ScaleTo:create(0.2, 1.2),
            cc.ScaleTo:create(0.1, 0.9),
            cc.ScaleTo:create(0.1, 1.1),
            cc.ScaleTo:create(0.1, 1.0),
            nil
            )

        return scaleAction
    end

    local commonDelay = 0.5
    self.m_btnShare:runAction(getScaleAction(commonDelay))
    self.m_btnShop:runAction(getScaleAction(commonDelay + 0.1))
    self.m_btnLike:runAction(getScaleAction(commonDelay + 0.2))
    self.m_checkBoxNoAds:runAction(getScaleAction(commonDelay + 0.3))
    self.m_checkBoxSound:runAction(getScaleAction(commonDelay + 0.4))

    self:updateLinePos()
end

function MainScene:updateLinePos()
    local playBtnSize = self.m_btnPlay:getContentSize()
    local playPos = cc.p(self.m_btnPlay:getPositionX(), self.m_btnPlay:getPositionY())

    local pos1 = cc.p(playPos.x - playBtnSize.width/2 + 1, playPos.y)
    local pos2 = cc.p(playPos.x + playBtnSize.width/2, playPos.y)

    self.m_imgLineLeft:runAction(cc.Sequence:create(
        cc.DelayTime:create(0.2),
        cc.MoveTo:create(0.3, pos1),
        cc.CallFunc:create(function ()
            self.m_btnPlay:setVisible(true)
            self.m_btnPlayColor:setVisible(true)
            self.m_btnPlayColor:setOpacity(0)
            self.m_btnPlayColor:runAction(cc.FadeIn:create(0.5))
        end)
        ))
    self.m_imgLineRight:runAction(cc.Sequence:create(
        cc.DelayTime:create(0.2),
        cc.MoveTo:create(0.3, pos2)
        ))
end

function MainScene:onPlay()
    dd.PlaySound("buttonclick.mp3")
    local levelScene = LevelScene:create()
    levelScene:showWithScene("MOVEINR", 0.3)
end

function MainScene:onShare()
    dd.PlaySound("buttonclick.mp3")
    cc.load("sdk").Tools.share("Trap Balls, very funny game, play with me now !", 
        cc.FileUtils:getInstance():fullPathForFilename("512.png"))
end

function MainScene:onShop()
    dd.PlaySound("buttonclick.mp3")
    local gameShop = GameShop:create(function ()
        self.m_labelDiamonds:setString(tostring(dd.GameData:getDiamonds()))
    end)
    self:addChild(gameShop)
    gameShop:setPosition(display.cx, display.cy)
end

function MainScene:onRate()
    dd.PlaySound("buttonclick.mp3")
    cc.load("sdk").Tools.rate()
end

function MainScene:onNoAds()
    dd.PlaySound("buttonclick.mp3")
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

function MainScene:onSoundOnOff()
    dd.PlaySound("buttonclick.mp3")
    dd.GameData:setSoundEnable(not dd.GameData:isSoundEnable())
end

function MainScene:onRestore()
    print("MainScene:onRestore ---------------")
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

return MainScene
