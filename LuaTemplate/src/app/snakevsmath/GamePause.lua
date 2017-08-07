local GamePause = class("GamePause", cc.load("mvc").ViewBase)
local MODULE_PATH = ...

GamePause.RESOURCE_FILENAME = "zanting.csb"
GamePause.RESOURCE_BINDING = {
    ["jixu"] = {varname = "m_btnResume", events = {{ event = "click", method = "onResume" }}},
    ["zhujiemian"] = {varname = "m_btnHome", events = {{ event = "click", method = "onHome" }}},
    ["yinxiao"] = {varname = "m_checkBoxSound"}
}

function GamePause:ctor(game)
    self.super.ctor(self)
    self.m_game = game
    self:showMask(nil, 100)

    cc.Director:getInstance():pause()

    self.m_checkBoxSound:onEvent(handler(self, self.onSound))
    self.m_checkBoxSound:setSelected(not dd.GameData:isSoundEnable())

    AudioEngine.getInstance():pauseMusic()
end

function GamePause:onResume()
    cc.Director:getInstance():resume()

    self:removeFromParent()
    AudioEngine.getInstance():resumeMusic()
end

function GamePause:onHome()
    cc.Director:getInstance():resume()
    
    self.m_game:onHome()
    AudioEngine.getInstance():stopMusic()
end

function GamePause:onSound()
    dd.GameData:setSoundEnable(not self.m_checkBoxSound:isSelected())
end

return GamePause