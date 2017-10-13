local GamePause = class("GamePause", cc.load("mvc").ViewBase)
local MODULE_PATH = ...

GamePause.RESOURCE_FILENAME = "zanting.csb"
GamePause.RESOURCE_BINDING = {
    ["Image_2"] = {varname = "m_btnResume", events = {{ event = "click", method = "onResume" }}},
    ["Image_1"] = {varname = "m_btnHome", events = {{ event = "click", method = "onHome" }}},
    ["Button_1"] = {varname = "m_btnMusic", events = {{ event = "click", method = "onDisableMusic" }}},
    ["Button_1_0"] = {varname = "m_btnMusicDisable", events = {{ event = "click", method = "onEnableMusic" }}},
    ["Button_2"] = {varname = "m_btnEffect", events = {{ event = "click", method = "onDisableEffect" }}},
    ["Button_2_0"] = {varname = "m_btnEffectDisable", events = {{ event = "click", method = "onEnableEffect" }}},
}

function GamePause:ctor(game)
    self.super.ctor(self)
    self.m_game = game
    self:showMask(nil, 168)
    self:getMask():setPosition(display.width/2, display.height/2)

    local resourceNode = self:getResourceNode()
    resourceNode:setContentSize(display.size)
    ccui.Helper:doLayout(resourceNode)

    cc.Director:getInstance():pause()

    AudioEngine.getInstance():pauseMusic()
    self:updateSoundBtnStats()

    self.m_btnMusic:setPressedActionEnabled(true)
    self.m_btnMusicDisable:setPressedActionEnabled(true)
    self.m_btnEffect:setPressedActionEnabled(true)
    self.m_btnEffectDisable:setPressedActionEnabled(true)

    local btnList = {self.m_btnMusic, self.m_btnMusicDisable, self.m_btnEffect, 
        self.m_btnEffectDisable, self.m_btnResume, self.m_btnHome}
    for _, btn in ipairs(btnList) do
        cc.load("sdk").Tools.btnScaleAction(btn)
    end
end

function GamePause:updateSoundBtnStats()
    self.m_btnMusic:setVisible(dd.GameData:isMusicEnable())
    self.m_btnMusicDisable:setVisible(not dd.GameData:isMusicEnable())
    self.m_btnEffect:setVisible(dd.GameData:isSoundEnable())
    self.m_btnEffectDisable:setVisible(not dd.GameData:isSoundEnable())
end

function GamePause:onDisableMusic()
    dd.PlayBtnSound()
    dd.GameData:setMusicEnable(false)
    self:updateSoundBtnStats()

    AudioEngine.getInstance():stopMusic()
end

function GamePause:onEnableMusic()
    dd.PlayBtnSound()
    dd.GameData:setMusicEnable(true)
    self:updateSoundBtnStats()

    dd.PlayBgMusic()
    AudioEngine.getInstance():pauseMusic()
end

function GamePause:onDisableEffect()
    dd.GameData:setSoundEnable(false)
    self:updateSoundBtnStats()

    dd.PlayBtnSound()
end

function GamePause:onEnableEffect()
    dd.GameData:setSoundEnable(true)
    self:updateSoundBtnStats()
    
    dd.PlayBtnSound()
end

function GamePause:onResume()
    dd.PlayBtnSound()
    dd.PlaySound("button.wav")
    cc.Director:getInstance():resume()

    self:removeFromParent()
    AudioEngine.getInstance():resumeMusic()
end

function GamePause:onHome()
    dd.PlayBtnSound()
    dd.PlaySound("button.wav")
    cc.Director:getInstance():resume()
    
    self.m_game:onHome()
    AudioEngine.getInstance():stopMusic()
end

return GamePause