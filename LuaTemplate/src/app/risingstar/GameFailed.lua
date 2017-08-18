local GameFailed = class("GameFailed", cc.load("mvc").ViewBase)
local MainScene = import(".MainScene")
local GameScene = import(".GameScene")

GameFailed.RESOURCE_FILENAME = "Node_failed.csb"
GameFailed.RESOURCE_BINDING = {
    ["Button_restart"] = {varname = "m_btnrestart", events = {{ event = "click", method = "onRestart" }}},
    ["Button_backtomenu"] = {varname = "m_btnTomenu", events = {{ event = "click", method = "onMenu" }}},
    ["BitmapFontLabel_3"] = {varname = "m_height"},
    ["BitmapFontLabel_4"] = {varname = "m_heighest"}
}

function GameFailed:ctor(gameScene)
    self.m_gameScene = gameScene
    self.super.ctor(self)
end

function GameFailed:onCreate()
    self:setOpacity(0)
    self:setCascadeOpacityEnabled(true)
    local action = cc.FadeIn:create(0.5)
    self:runAction(action)
    self:showMask()

    local height = self.m_gameScene:getHeight()
    local heightest = dd.GameData:getHighScore()
    
    if heightest < height then
        heightest = height
        dd.GameData:refreshHighScore(heightest)
    end

    self.m_height:setString(tostring(height))
    self.m_heighest:setString(tostring(heightest))

end

function GameFailed:onRestart()
    local gameScene = GameScene:create()
    dd.PlaySound("buttonclick.mp3")
    gameScene:showWithScene()
end

function GameFailed:onMenu()
    local mainScene = MainScene:create()
    dd.PlaySound("buttonclick.mp3")
    mainScene:showWithScene("FADE",1.5)
end

return GameFailed