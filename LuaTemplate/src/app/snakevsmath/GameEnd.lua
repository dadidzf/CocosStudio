local GameEnd = class("GameEnd", cc.load("mvc").ViewBase)
local MODULE_PATH = ...

GameEnd.RESOURCE_FILENAME = "jiesu.csb"
GameEnd.RESOURCE_BINDING = {
    ["Button_1"] = {varname = "m_btnRestart", events = {{ event = "click", method = "onRestart" }}},
    ["Button_2"] = {varname = "m_btnRank", events = {{ event = "click", method = "onRank" }}},
    ["lishizuigaofen"] = {varname = "m_labelHighScore"},
    ["dangqiandefen"] = {varname = "m_labelCurScore"}
}
local _gameEndCount = 0

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
    self:showMask(nil, 180)

    cc.load("sdk").GameCenter.submitScoreToLeaderboard(1, score)

    if score > 10000 then
        cc.load("sdk").GameCenter.unlockAchievement(1)
    end

    if score > 100000 then
        cc.load("sdk").GameCenter.unlockAchievement(2)
    end

    if score > 1000000 then
        cc.load("sdk").GameCenter.unlockAchievement(3)
    end

    if score > 10000000 then
        cc.load("sdk").GameCenter.unlockAchievement(4)
    end

    if score > 100000000 then
        cc.load("sdk").GameCenter.unlockAchievement(5)
    end

    self:runAction(cc.Sequence:create(
        cc.DelayTime:create(1.5),
        cc.CallFunc:create(function ( ... )
            if cc.load("sdk").Tools.getGamePlayCount() > 0 or _gameEndCount > 2 then
                cc.load("sdk").Admob.getInstance():showInterstitial()
            end
        end)
        ))

    local btnBack = ccui.ImageView:create("fanhui.png", ccui.TextureResType.plistType)
        :move(-display.width/2 + 60, display.height/2 - 60)
        :addTo(self)
        :setTouchEnabled(true)
        :onClick(function ( ... )
            self.m_game:onHome()
        end)
end

function GameEnd:onRestart()
    dd.PlaySound("button.wav")
    AudioEngine.getInstance():stopMusic()
    self.m_game:onRestart()  
end

function GameEnd:onRank()
    cc.load("sdk").GameCenter.openGameCenterLeaderboardsUI(1)
end

return GameEnd