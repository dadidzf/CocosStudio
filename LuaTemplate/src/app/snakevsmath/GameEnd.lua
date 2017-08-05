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
end

function GameEnd:onRestart()
    self.m_game:onHome()
end

return GameEnd