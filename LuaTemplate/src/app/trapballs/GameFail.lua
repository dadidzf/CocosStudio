local GameFail = class("GameFail", cc.load("mvc").ViewBase)
local MODULE_PATH = ...

GameFail.RESOURCE_FILENAME = "Node_gamefailed.csb"
GameFail.RESOURCE_BINDING = {
    ["Button_restart"] = {varname = "m_btnPlay", events = {{ event = "click", method = "onRestart" }}},
    ["Button_backtomenu"] = {varname = "m_btnShare", events = {{ event = "click", method = "onMenu" }}},
}

function GameFail:ctor(gameScene, levelIndex)
    self.super.ctor(self)
    self.m_levelIndex = levelIndex
    self.m_gameScene = gameScene

    self:getResourceNode():setVisible(false)
    local mask = self:getMask()
    mask:setOpacity(0)
    mask:runAction(cc.FadeIn:create(1.0))
    
    local resName = cc.load("sdk").Tools.getLanguageDependSpriteFrameName("gameover.png")
    local gameOverImg = display.newSprite("#"..resName)
        :move(0, -display.height*0.2) 
        :setOpacity(0)
        :addTo(self)

    gameOverImg:runAction(cc.Sequence:create(
        cc.Spawn:create(
            cc.FadeIn:create(1.0),
            cc.MoveTo:create(1.0, cc.p(0, display.height*0.1))
            ),
        cc.DelayTime:create(0.5),
        cc.FadeOut:create(0.5),
        cc.CallFunc:create(function ( ... )
            self:getResourceNode():setVisible(true)
        end)
        ))

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
    local levelScene = LevelScene:create(self.m_levelIndex)
    levelScene:showWithScene("MOVEINL", 0.3)
end

return GameFail