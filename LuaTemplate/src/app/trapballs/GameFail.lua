local GameFail = class("GameFail", cc.load("mvc").ViewBase)
local MODULE_PATH = ...

GameFail.RESOURCE_FILENAME = "Node_gamefailed.csb"
GameFail.RESOURCE_BINDING = {
    ["Button_restart"] = {varname = "m_btnPlay", events = {{ event = "click", method = "onRestart" }}},
    ["Button_backtomenu"] = {varname = "m_btnShare", events = {{ event = "click", method = "onMenu" }}},
}

function GameFail:ctor(gameScene)
    self.super.ctor(self)
    self.m_gameScene = gameScene
end

function GameFail:onCreate()
    self:showMask()
end

function GameFail:onRestart()
    self.m_gameScene:resetGame()
    self:removeFromParent()
end

function GameFail:onMenu()
    local MainScene = import(".MainScene", MODULE_PATH)
    local mainScene = MainScene:create()
    mainScene:showWithScene()
end

return GameFail