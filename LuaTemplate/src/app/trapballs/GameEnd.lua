local GameEnd = class("GameEnd", cc.load("mvc").ViewBase)
local MODULE_PATH = ...

GameEnd.RESOURCE_FILENAME = "Node_gamepass.csb"
GameEnd.RESOURCE_BINDING = {
    ["Button_chart"] = {varname = "m_btnPlay", events = {{ event = "click", method = "onRank" }}},
    ["Button_share"] = {varname = "m_btnShare", events = {{ event = "click", method = "onShare" }}},
    ["Button_restart"] = {varname = "m_btnShop", events = {{ event = "click", method = "onReplay" }}},
    ["Button_backtomenu"] = {varname = "m_btnShare", events = {{ event = "click", method = "onMenu" }}},
    ["Button_next"] = {varname = "m_btnShop", events = {{ event = "click", method = "onNext" }}},

    ["Panel_1.BitmapFontLabel_spacenumber"] = {varname = "m_labelFillRate"},
    ["Panel_1.BitmapFontLabel_lifenumber"] = {varname = "m_labelLives"},
    ["Panel_1.BitmapFontLabel_stepnumber"] = {varname = "m_labelSteps"},
    ["Panel_1.BitmapFontLabel_topnumber"] = {varname = "m_labelTopCollision"},

    ["Panel_1.BitmapFontLabel_topzuanshi"] = {varname = "m_labelDiamondReward"},
    ["Panel_1.BitmapFontLabel_stepscore"] = {varname = "m_labelStepsScore"},
    ["Panel_1.BitmapFontLabel_lifescore"] = {varname = "m_labelLivesScore"},
    ["Panel_1.BitmapFontLabel_spacescore"] = {varname = "m_labelFillRateScore"},
    ["Panel_1.BitmapFontLabel_allscore"] = {varname = "m_labelTotalScore"},

    ["BitmapFontLabel_roundnumber"] = {varname = "m_labelRoundNum"}
}

function GameEnd:ctor(gameScene, levelIndex, param)
    self.super.ctor(self)

    self.m_labelRoundNum:setString(tostring(levelIndex))
    self.m_gameScene = gameScene
    self:updateScorePanel(param)
    dd.GameData:levelPass(levelIndex)
end

function GameEnd:updateScorePanel(param)
    self.m_labelFillRate:setString(tostring(string.format("%.1f", param.fill)))
    self.m_labelLives:setString(tostring(param.lives))
    self.m_labelSteps:setString(tostring(param.steps))
    self.m_labelTopCollision:setString(tostring(param.topCollision))

    self.m_fillScore = 10*param.fill
    self.m_livesScore = 200*param.lives
    self.m_stepsScore = 100*param.steps
    self.m_totalScore = self.m_fillScore + self.m_livesScore + self.m_stepsScore

    self.m_diamondsReward = 10*param.topCollision + 100
    self.m_labelDiamondReward:setString(tostring(self.m_diamondsReward))
    self.m_labelStepsScore:setString(tostring(self.m_stepsScore))
    self.m_labelFillRateScore:setString(tostring(self.m_fillScore))
    self.m_labelLivesScore:setString(tostring(self.m_livesScore))
    self.m_labelTotalScore:setString(tostring(self.m_totalScore))

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