local MainScene = class("MainScene", cc.load("mvc").ViewBase)
local GameScene = import(".GameScene")

local MODULE_PATH = ...

MainScene.RESOURCE_FILENAME = "MainScene.csb"
MainScene.RESOURCE_BINDING = {
    ["Image_1"] = {varname = "m_btnPlay", events = {{ event = "click", method = "onPlay"}}},
    ["Image_2"] = {varname = "m_btnRate", events = {{ event = "click", method = "onRate"}}},
    ["Image_3"] = {varname = "m_btnShare", events = {{ event = "click", method = "onShare"}}},
    ["Image_4"] = {varname = "m_btnRank", events = {{ event = "click", method = "onRank"}}},
    ["spacefortress_diqiu_3"] = {varname = "m_planet"},
    ["BitmapFontLabel_1"] = {varname = "m_labelScore"},
    ["BitmapFontLabel_2"] = {varname = "m_labelBestScore"},
    ["spacefortress_yingwenbiaoti_2"] = {varname = "m_imgLogo"},
    ["spacefortress_fengshudi_4"] = {varname = "m_imgScoreBg"},
    ["spacefortress_fengshudi_5"] = {varname = "m_imgBestScoreBg"}
}

function MainScene:ctor()
    self.super.ctor(self)
    
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
    gameScene:showWithScene()

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

return MainScene
