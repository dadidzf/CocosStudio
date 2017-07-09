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
    dd.PlaySound("buttonclick.mp3")
    self.m_gameScene:resetGame()
    self:removeFromParent()
end

function GameFail:onMenu()
    dd.PlaySound("buttonclick.mp3")
    local LevelScene = import(".LevelScene", MODULE_PATH)
    local levelScene = LevelScene:create()
    levelScene:showWithScene()
end

return GameFail