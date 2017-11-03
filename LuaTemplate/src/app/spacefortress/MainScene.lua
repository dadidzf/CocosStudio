local MainScene = class("MainScene", cc.load("mvc").ViewBase)
local GameScene = import(".GameScene")

local MODULE_PATH = ...

local isFirstTime = true

MainScene.RESOURCE_FILENAME = "MainScene.csb"
MainScene.RESOURCE_BINDING = {
    ["Image_1"] = {varname = "m_btnPlay", events = {{ event = "click", method = "onPlay"}}},
    ["Image_2"] = {varname = "m_btnRate", events = {{ event = "click", method = "onRate"}}},
    ["Image_3"] = {varname = "m_btnShare", events = {{ event = "click", method = "onShare"}}},
    ["Image_4"] = {varname = "m_btnRank", events = {{ event = "click", method = "onRank"}}},
    ["spacefortress_yingwenbiaoti_2.spacefortress_diqiu_3"] = {varname = "m_planet"},
    ["BitmapFontLabel_1"] = {varname = "m_labelScore"},
    ["BitmapFontLabel_2"] = {varname = "m_labelBestScore"},
    ["spacefortress_yingwenbiaoti_2"] = {varname = "m_imgLogo"},
    ["spacefortress_fengshudi_4"] = {varname = "m_imgScoreBg"},
    ["spacefortress_fengshudi_5"] = {varname = "m_imgBestScoreBg"},

    ["spacefortress_di_1.shinningNode"] = {varname = "m_shinningNode"}

}

function MainScene:ctor()
    self.super.ctor(self)
    self:enableNodeEvents()
    
    local resourceNode = self:getResourceNode()
    resourceNode:setContentSize(display.size)
    ccui.Helper:doLayout(resourceNode)

    local btnList = {self.m_btnPlay, self.m_btnRate, self.m_btnShare, self.m_btnRank}
    for _, btn in ipairs(btnList) do
        cc.load("sdk").Tools.btnScaleAction(btn)
    end

    self.m_labelScore:setString("0")
    self.m_bestStr = self.m_labelBestScore:getString()
    self.m_labelBestScore:setString(self.m_bestStr..tostring(dd.GameData:getBestScore()))

    self:showLight()
    self.m_lightSheduler = dd.scheduler:scheduleScriptFunc(handler(self, self.showLight), 3.0, false)

    self:initAction()

    local particle = cc.ParticleSystemQuad:create("particle/particle_stars.plist") 
        :move(display.width/2, display.height/2)
        :addTo(self.m_shinningNode, 1)

    if isFirstTime then
        dd.PlaySound("myvoice.mp3")
        dd.PlaySound("robot.wav")
        isFirstTime = false
    end
end

function MainScene:initAction()
    self.m_planet:runAction(cc.RepeatForever:create(
        cc.RotateBy:create(3, 360)
        ))


    local getAction = function (delayTime)
        return cc.Sequence:create(
            cc.DelayTime:create(delayTime),
            cc.ScaleTo:create(0.2, 1.2),
            cc.ScaleTo:create(0.1, 0.9),
            cc.ScaleTo:create(0.1, 1.1),
            cc.ScaleTo:create(0.1, 1.0)
            )         
    end 

    local btnList = {self.m_btnRate, self.m_btnRank, self.m_btnShare}

    for index, btn in ipairs(btnList) do
        btn:setScale(0)
        btn:runAction(getAction(0.2 + (index - 1)*0.2))
    end

    self.m_labelScore:setOpacity(0)
    self.m_labelBestScore:setOpacity(0)
    self.m_imgScoreBg:setOpacity(0)
    self.m_imgBestScoreBg:setOpacity(0)

    local getActionOpacity = function (delayTime)
        return cc.Sequence:create(
            cc.DelayTime:create(delayTime),
            cc.FadeIn:create(0.5))
    end
    self.m_imgScoreBg:runAction(getActionOpacity(0.5))
    self.m_labelScore:runAction(getActionOpacity(1.0))

    self.m_imgBestScoreBg:runAction(getActionOpacity(0.8))
    self.m_labelBestScore:runAction(getActionOpacity(1.3))
end

function MainScene:setCurScore(curScore)
    curScore = curScore or 0
    dd.GameData:refreshBestScore(curScore)
    self.m_labelScore:setString(tostring(curScore))
    self.m_labelBestScore:setString(self.m_bestStr..tostring(dd.GameData:getBestScore()))
end

function MainScene:onCreate()
    cc.load("sdk").Admob.getInstance():removeBanner()
end

function MainScene:onPlay()
    dd.PlayBtnSound()
    local gameScene = GameScene:create()
    gameScene:showWithScene("FADE", 0.5)

    cc.load("sdk").Admob.getInstance():showBanner()
end

function MainScene:onRank()
    dd.PlayBtnSound()
    cc.load("sdk").GameCenter.openGameCenterLeaderboardsUI(1)
end

function MainScene:onRate()
    dd.PlayBtnSound()
    cc.load("sdk").Tools.rate()
end

function MainScene:onShare()
    dd.PlayBtnSound()
    cc.load("sdk").Tools.share(dd.GetTips(dd.Constant.SHARE_TIPS), 
        cc.FileUtils:getInstance():fullPathForFilename("512.png"))
end

function MainScene:showLight()
    local animation = cc.Animation:create()
    for i = 1, 7 do
        animation:addSpriteFrameWithFile(string.format("EffSource/home_eff_shan_%d.png", i))
    end
    animation:setDelayPerUnit(0.3)
    local action = cc.Animate:create(animation)

    local sprite = cc.Sprite:create()
        :move(display.width*math.random(), display.height*math.random())
        :addTo(self.m_shinningNode)

    sprite:runAction(cc.Sequence:create(
        action,
        cc.CallFunc:create(function ( ... )
            sprite:removeFromParent()
        end)
        ))
end

function MainScene:onCleanup()
    if self.m_lightSheduler then
        dd.scheduler:unscheduleScriptEntry(self.m_lightSheduler)
        self.m_lightSheduler = nil
    end
end

return MainScene
