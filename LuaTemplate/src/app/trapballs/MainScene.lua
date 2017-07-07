local MainScene = class("MainScene", cc.load("mvc").ViewBase)
local LevelScene = import(".LevelScene")
local GameShop = import(".GameShop")

MainScene.RESOURCE_FILENAME = "menu.csb"
MainScene.RESOURCE_BINDING = {
    ["Button_play"] = {varname = "m_btnPlay", events = {{ event = "click", method = "onPlay" }}},
    ["Button_fenxiang"] = {varname = "m_btnShare", events = {{ event = "click", method = "onShare" }}},
    ["Button_shangdian"] = {varname = "m_btnShop", events = {{ event = "click", method = "onShop" }}},
    ["Button_like"] = {varname = "m_btnLike", events = {{ event = "click", method = "onRate" }}},
    ["CheckBox_2"] = {varname = "m_checkBoxNoAds"},
    ["CheckBox_jingyin"] = {varname = "m_checkBoxSound"},

    ["Image_1"] = {varname = "m_imgLineLeft"},
    ["Image_1_0"] = {varname = "m_imgLineRight"}
}

function MainScene:onCreate()
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

    self:updateLinePos()
end

function MainScene:updateLinePos()
    local playBtnSize = self.m_btnPlay:getContentSize()
    local playPos = cc.p(self.m_btnPlay:getPositionX(), self.m_btnPlay:getPositionY())

    local pos1 = cc.p(playPos.x - playBtnSize.width/2 + 1, playPos.y)
    local pos2 = cc.p(playPos.x + playBtnSize.width/2, playPos.y)

    self.m_imgLineLeft:setPosition(pos1)
    self.m_imgLineRight:setPosition(pos2)
end

function MainScene:onPlay()
    local levelScene = LevelScene:create()
    levelScene:showWithScene()
end

function MainScene:onShare()
    cc.load("sdk").Tools.share("Trap Balls, very funny game, play with me now !", 
        cc.FileUtils:getInstance():fullPathForFilename("512.png"))
end

function MainScene:onShop()
    local gameShop = GameShop:create()
    self:addChild(gameShop)
    gameShop:setPosition(display.cx, display.cy)
end

function MainScene:onRate()
    cc.load("sdk").Tools.rate()
end

function MainScene:onNoAds()
end

function MainScene:onSoundOnOff()
end

return MainScene
