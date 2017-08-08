local GameEnd = class("GameEnd", cc.load("mvc").ViewBase)
local MODULE_PATH = ...

GameEnd.RESOURCE_FILENAME = "jiesu.csb"
GameEnd.RESOURCE_BINDING = {
    ["Button_1"] = {varname = "m_btnRestart", events = {{ event = "click", method = "onRestart" }}},
    ["Button_2"] = {varname = "m_btnRank", events = {{ event = "click", method = "onRank" }}},
    ["lishizuigaofen"] = {varname = "m_labelHighScore"},
    ["dangqiandefen"] = {varname = "m_labelCurScore"}
}

function GameEnd:ctor(game, score)
    self.super.ctor(self)
    
    local highScore = dd.GameData:getHighScore() 
    if highScore < score then
        highScore = score
        dd.GameData:refreshHighScore(highScore)
    end

    self.m_labelHighScore:setString(tostring(highScore)) 
    self.m_labelCurScore:setString(tostring(score))

    self.m_game = game
    self:showMask(nil, 100)

    cc.load("sdk").GameCenter.submitScoreToLeaderboard(1, score)
end

function GameEnd:onRestart()
    dd.PlaySound("button.wav")
    AudioEngine.getInstance():stopMusic()
    self.m_game:onHome()
end

function GameEnd:onRank()
    cc.load("sdk").GameCenter.openGameCenterLeaderboardsUI(1)
end

return GameEnd