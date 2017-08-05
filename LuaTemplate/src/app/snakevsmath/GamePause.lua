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
end

function GamePause:onResume()
    cc.Director:getInstance():resume()

    self:removeFromParent()
end

function GamePause:onHome()
    cc.Director:getInstance():resume()
    
    self.m_game:onHome()
end

function GamePause:onSound()
end

return GamePause