local GameEnd = class("GameEnd", cc.load("mvc").ViewBase)
local MODULE_PATH = ...

GameEnd.RESOURCE_FILENAME = "jiesu.csb"
GameEnd.RESOURCE_BINDING = {
    ["Button_1"] = {varname = "m_btnRestart", events = {{ event = "click", method = "onRestart" }}},
    ["Button_2"] = {varname = "m_btnRank", events = {{ event = "click", method = "onRank" }}},
    ["lishizuigaofen"] = {varname = "m_labelHighScore"},
    ["dangqiandefen"] = {varname = "m_labelCurScore"},
    ["Image_1"] = {varname = "m_curScoreBg"},
    ["Image_2"] = {varname = "m_highScoreIcon"},
    ["Image_1_0"] = {varname = "m_highScoreBg"}
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
    self:showMask(nil, 200)

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

    local scheduler
    local showAdsFunc = function ( ... )
        if scheduler then
            dd.scheduler:unscheduleScriptEntry(scheduler)
            scheduler = nil
        end

        if cc.load("sdk").Tools.getGamePlayCount() > 1 or _gameEndCount > 2 then
            cc.load("sdk").Admob.getInstance():showInterstitial()
        end
        _gameEndCount = _gameEndCount + 1
    end
    
    scheduler = dd.scheduler:scheduleScriptFunc(showAdsFunc, 1.5, false)

    local btnBack = ccui.ImageView:create("fanhui.png", ccui.TextureResType.plistType)
        :move(-display.width/2 + 60, display.height/2 - 60)
        :addTo(self)
        :setTouchEnabled(true)
        
    btnBack:onClick(function ( ... )
        self.m_game:onHome()
    end)

    dd.BtnScaleAction(btnBack)
    dd.BtnScaleAction(self.m_btnRank)
    dd.BtnScaleAction(self.m_btnRestart)

    self:showAction()
end

function GameEnd:showAction()
    self.m_btnRestart:setScale(0)
    self.m_btnRank:setScale(0)
    self.m_labelCurScore:setOpacity(0)
    self.m_labelHighScore:setOpacity(0)
    self.m_highScoreIcon:setOpacity(0)

    local curScoreBgPos = cc.p(self.m_curScoreBg:getPositionX(), self.m_curScoreBg:getPositionY())
    local highScoreBgPos = cc.p(self.m_highScoreBg:getPositionX(), self.m_highScoreBg:getPositionY())

    self.m_curScoreBg:move(curScoreBgPos.x + display.width, curScoreBgPos.y)
    self.m_highScoreBg:move(highScoreBgPos.x + display.width, highScoreBgPos.y)

    self.m_curScoreBg:runAction(cc.EaseInOut:create(cc.MoveTo:create(0.5, curScoreBgPos), 2))
    self.m_highScoreBg:runAction(cc.Sequence:create(
        cc.DelayTime:create(0.2),
        cc.EaseInOut:create(cc.MoveTo:create(0.5, highScoreBgPos), 2)
        ))
    self.m_labelCurScore:runAction(cc.Sequence:create(
        cc.DelayTime:create(0.5),
        cc.FadeIn:create(0.5)
        ))

    self.m_labelHighScore:runAction(cc.Sequence:create(
        cc.DelayTime:create(0.7),
        cc.FadeIn:create(0.5)
        ))

    self.m_highScoreIcon:runAction(cc.Sequence:create(
        cc.DelayTime:create(0.7),
        cc.FadeIn:create(0.5)
        ))

    self.m_btnRestart:runAction(cc.Sequence:create(
        cc.DelayTime:create(0.7),
        cc.ScaleTo:create(0.2, 1.2),
        cc.ScaleTo:create(0.15, 0.9),
        cc.ScaleTo:create(0.1, 1.1),
        cc.ScaleTo:create(0.1, 1.0)
        ))

    self.m_btnRank:runAction(cc.Sequence:create(
        cc.DelayTime:create(1.0),
        cc.ScaleTo:create(0.2, 1.2),
        cc.ScaleTo:create(0.15, 0.9),
        cc.ScaleTo:create(0.1, 1.1),
        cc.ScaleTo:create(0.1, 1.0)
        ))
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