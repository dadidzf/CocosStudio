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
    ["Image_1_0"] = {varname = "m_imgLineRight"},
    ["BitmapFontLabel_1"] = {varname = "m_labelDiamonds"}
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

    self.m_checkBoxNoAds:onEvent(handler(self, self.onNoAds))
    self.m_checkBoxSound:onEvent(handler(self, self.onSoundOnOff))
    self.m_checkBoxSound:setSelected(not dd.GameData:isSoundEnable())

    self.m_labelDiamonds:setString(tostring(dd.GameData:getDiamonds()))
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
    dd.PlaySound("buttonclick.mp3")
    local levelScene = LevelScene:create()
    levelScene:showWithScene()
end

function MainScene:onShare()
    dd.PlaySound("buttonclick.mp3")
    cc.load("sdk").Tools.share("Trap Balls, very funny game, play with me now !", 
        cc.FileUtils:getInstance():fullPathForFilename("512.png"))
end

function MainScene:onShop()
    dd.PlaySound("buttonclick.mp3")
    local gameShop = GameShop:create()
    self:addChild(gameShop)
    gameShop:setPosition(display.cx, display.cy)
end

function MainScene:onRate()
    dd.PlaySound("buttonclick.mp3")
    cc.load("sdk").Tools.rate()
end

function MainScene:onNoAds()
    dd.PlaySound("buttonclick.mp3")
end

function MainScene:onSoundOnOff()
    dd.PlaySound("buttonclick.mp3")
    dd.GameData:setSoundEnable(not dd.GameData:isSoundEnable())
end

return MainScene
