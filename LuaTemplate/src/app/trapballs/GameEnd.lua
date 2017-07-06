local GameEnd = class("GameEnd", cc.load("mvc").ViewBase)
local MODULE_PATH = ...

GameEnd.RESOURCE_FILENAME = "Node_gamepass.csb"
GameEnd.RESOURCE_BINDING = {
    ["Button_chart"] = {varname = "m_btnPlay", events = {{ event = "click", method = "onRank" }}},
    ["Button_share"] = {varname = "m_btnShare", events = {{ event = "click", method = "onShare" }}},
    ["Button_restart"] = {varname = "m_btnShop", events = {{ event = "click", method = "onReplay" }}},
    ["Button_backtomenu"] = {varname = "m_btnShare", events = {{ event = "click", method = "onMenu" }}},
    ["Button_next"] = {varname = "m_btnShop", events = {{ event = "click", method = "onNext" }}}
}

function GameEnd:ctor(gameScene, levelIndex)
    self.super.ctor(self)
    self.m_gameScene = gameScene

    dd.GameData:levelPass(levelIndex)
end

function GameEnd:onCreate()
    self:showMask()
end

function GameEnd:onRank()
end

function GameEnd:onShare()
    cc.load("sdk").Tools.share("Trap Balls, very funny game, play with me now !", 
        cc.FileUtils:getInstance():fullPathForFilename("512.png"))
end

function GameEnd:onReplay()
    self.m_gameScene:resetGame()
    self:removeFromParent()
end

function GameEnd:onMenu()
    local MainScene = import(".MainScene", MODULE_PATH)
    local mainScene = MainScene:create()
    mainScene:showWithScene()
end

function GameEnd:onNext()
    self.m_gameScene:onNext()
    self:removeFromParent()
end

return GameEnd