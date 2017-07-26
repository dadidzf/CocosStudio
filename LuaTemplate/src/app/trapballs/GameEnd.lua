local GameEnd = class("GameEnd", cc.load("mvc").ViewBase)
local MODULE_PATH = ...

GameEnd.RESOURCE_FILENAME = "Node_gamepass.csb"
GameEnd.RESOURCE_BINDING = {
    ["Button_chart"] = {varname = "m_btnRank", events = {{ event = "click", method = "onRank" }}},
    ["Button_share"] = {varname = "m_btnShare", events = {{ event = "click", method = "onShare" }}},
    ["Button_restart"] = {varname = "m_btnRePlay", events = {{ event = "click", method = "onReplay" }}},
    ["Button_backtomenu"] = {varname = "m_btnMenu", events = {{ event = "click", method = "onMenu" }}},
    ["Button_next"] = {varname = "m_btnNext", events = {{ event = "click", method = "onNext" }}},

    ["Panel_1.BitmapFontLabel_spacenumber"] = {varname = "m_labelFillRate"},
    ["Panel_1.Image_space"] = {varname = "m_imgFillRate"},
    ["Panel_1.BitmapFontLabel_x1"] = {varname = "m_imgFillRateMulSimbol"},
    ["Panel_1.BitmapFontLabel_baifenbi"] = {varname = "m_imgFillRatePercentSimbol"},
    ["Panel_1.BitmapFontLabel_spacescore"] = {varname = "m_labelFillRateScore"},

    ["Panel_1.BitmapFontLabel_lifenumber"] = {varname = "m_labelLives"},
    ["Panel_1.Image_life"] = {varname = "m_imgLife"},
    ["Panel_1.BitmapFontLabel_x2"] = {varname = "m_imgLifeMulSimbol"},
    ["Panel_1.BitmapFontLabel_lifescore"] = {varname = "m_labelLivesScore"},


    ["Panel_1.BitmapFontLabel_stepnumber"] = {varname = "m_labelSteps"},
    ["Panel_1.BitmapFontLabel_step"] = {varname = "m_imgStep"},
    ["Panel_1.BitmapFontLabel_x3"] = {varname = "m_imgStepMulSimbol"},
    ["Panel_1.BitmapFontLabel_stepscore"] = {varname = "m_labelStepsScore"},

    ["Panel_1.BitmapFontLabel_allscore"] = {varname = "m_labelTotalScore"},
    ["Panel_1.BitmapFontLabel_score"] = {varname = "m_imgTotalScore"},


    ["Panel_1.Image_top"] = {varname = "m_imgTop"},
    ["Panel_1.BitmapFontLabel_x4"] = {varname = "m_imgTopMulSimbol"},
    ["Panel_1.BitmapFontLabel_jia"] = {varname = "m_imgTopAddSimbol"},
    ["Panel_1.BitmapFontLabel_topzuanshi"] = {varname = "m_labelDiamondReward"},
    ["Panel_1.BitmapFontLabel_topnumber"] = {varname = "m_labelTopCollision"},
    ["Panel_1.Image_4"] = {varname = "m_imgDiamonds"},

    ["BitmapFontLabel_roundnumber"] = {varname = "m_labelRoundNum"},
    ["BitmapFontLabel_highscorenumber"] = {varname = "m_labelHighScore"},
    ["Image_highscore"] = {varname = "m_imgHighScoreIcon"},

    ["BitmapFontLabel_zuanshi"] = {varname = "m_labelTotalDiamonds"}
}

function GameEnd:ctor(gameScene, levelIndex, param)
    self.super.ctor(self)

    self.m_labelTotalDiamonds:setString(tostring(dd.GameData:getDiamonds()))
    self.m_levelIndex = levelIndex
    self.m_gameScene = gameScene
    dd.GameData:levelPass(levelIndex)

    self:getResourceNode():setVisible(false)

    local resName = cc.load("sdk").Tools.getLanguageDependSpriteFrameName("stageclear.png")
    local gameSuccessImg = display.newSprite("#"..resName)
        :move(0, display.height*0.15) 
        :addTo(self)

    local mask = self:getMask()
    mask:setOpacity(0)
    mask:runAction(cc.FadeIn:create(1.0))

    self:particle()
    gameSuccessImg:setScale(2.0)
    gameSuccessImg:runAction(cc.Sequence:create(
        cc.ScaleTo:create(1.0, 1.0),
        cc.DelayTime:create(0.5),
        cc.FadeOut:create(0.5),
        cc.CallFunc:create(function ( ... )
            self:getResourceNode():setVisible(true)
            self:updateScorePanel(param)
        end)
        ))

    self:rewardDiamondsAction()
end

function GameEnd:particle()
    for i = 1, 6 do
        local particle = cc.ParticleSystemQuad:create(string.format("particle/particle_texture (%d).plist", i)) 
            :move(0, 0)
            :addTo(self, 10)

        --particle:move(display.width*(2 - ((i - 1)%3 + 1))/2, display.height*0.25)

        particle:pause()
        particle:setVisible(false)
        particle:runAction(cc.Sequence:create(
            cc.DelayTime:create(i*0.3),
            cc.CallFunc:create(function ( ... )
                particle:setVisible(true)
                particle:start()
            end),
            cc.MoveTo:create(0.5, cc.p(0, display.height*0.25))
            ))
    end
end
function GameEnd:rewardDiamondsAction()
    local rewardDiamonds = display.newSprite("#money.png")
        :setAnchorPoint(cc.p(0, 0.5))
        :move(0, 10)
        :addTo(self)

    local rewardDiamondsSize = rewardDiamonds:getContentSize()
    local addLable = cc.Label:createWithBMFont("fnt/white_32.fnt", "+"..tostring(dd.Constants.LEVEL_PASS_DIAMONDS_REWARD))
        :setAnchorPoint(cc.p(1, 0.5))
        :move(-10, rewardDiamondsSize.height/2)
        :addTo(rewardDiamonds)

    rewardDiamonds:runAction(cc.Sequence:create(
        cc.Blink:create(2, 2),
        cc.MoveTo:create(1.0, cc.p(display.width/2 - rewardDiamondsSize.width, 
            display.height/2 - rewardDiamondsSize.height)),
        cc.CallFunc:create(function ( ... )
            rewardDiamonds:removeFromParent()
            self:addDiamonds(dd.Constants.LEVEL_PASS_DIAMONDS_REWARD)
        end)
        ))
end

function GameEnd:addDiamonds(addNum)
    if addNum == 0 then
        return
    end

    local curDiamonds = dd.GameData:getDiamonds()
    dd.GameData:refreshDiamonds(curDiamonds + addNum)
    self.m_labelTotalDiamonds:runAction(cc.Sequence:create(
        cc.ScaleTo:create(0.3, 1.6),
        cc.CallFunc:create(function ()
            self.m_labelTotalDiamonds:setString(tostring(dd.GameData:getDiamonds()))
        end),
        cc.ScaleTo:create(0.3, 1)
        ))
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
    cc.load("sdk").GameCenter.submitScoreToLeaderboard(self.m_levelIndex, self.m_totalScore)

    self.m_diamondsReward = 10*param.topCollision
    self.m_labelDiamondReward:setString(tostring(self.m_diamondsReward))
    self.m_labelStepsScore:setString(tostring(self.m_stepsScore))
    self.m_labelFillRateScore:setString(tostring(self.m_fillScore))
    self.m_labelLivesScore:setString(tostring(self.m_livesScore))
    self.m_labelTotalScore:setString(tostring(self.m_totalScore))
    self.m_imgHighScoreIcon:setVisible(false)
    
    self.m_labelRoundNum:setString(tostring(self.m_levelIndex))
    self.m_isBest = dd.GameData:refreshLevelScore(self.m_levelIndex, self.m_totalScore)
    local topThree = dd.GameData:getLevelTopThree(self.m_levelIndex)
    self.m_labelHighScore:setString(tostring(topThree[1]))


    local displayNodes = {
        self.m_imgFillRate,
        self.m_imgFillRateMulSimbol,
        self.m_labelFillRate,
        self.m_imgFillRatePercentSimbol,
        self.m_labelFillRateScore,

        self.m_imgLife,
        self.m_imgLifeMulSimbol,
        self.m_labelLives,
        self.m_labelLivesScore,

        self.m_imgStep,
        self.m_imgStepMulSimbol,
        self.m_labelSteps,
        self.m_labelStepsScore,

        self.m_imgTotalScore,
        self.m_labelTotalScore,

        self.m_imgTop,
        self.m_imgTopMulSimbol,
        self.m_labelTopCollision,
        self.m_imgTopAddSimbol,
        self.m_labelDiamondReward,
        self.m_imgDiamonds,
    }

    for _, node in ipairs(displayNodes) do
        node:setVisible(false)
    end


    local index = 1
    local scheduleId
    local showNode = function ()
        if index <= #displayNodes then
            displayNodes[index]:setVisible(true)
        else
            dd.scheduler:unscheduleScriptEntry(scheduleId)
            scheduleId = nil
            self:addDiamonds(self.m_diamondsReward)
        end
        index = index + 1
    end

    scheduleId = dd.scheduler:scheduleScriptFunc(showNode, 0.2, false)

    local getScaleAction = function (delayTime)
        local scaleAction = cc.Sequence:create(
            cc.DelayTime:create(delayTime),
            cc.ScaleTo:create(0.2, 1.2),
            cc.ScaleTo:create(0.1, 0.9),
            cc.ScaleTo:create(0.1, 1.1),
            cc.ScaleTo:create(0.1, 1.0),
            nil
            )

        return scaleAction
    end

    local commonDelay = 0.2*#displayNodes
    self.m_btnRank:setScale(0)
    self.m_btnShare:setScale(0)
    self.m_btnMenu:setScale(0)
    self.m_btnNext:setScale(0)
    self.m_btnRePlay:setScale(0)

    self.m_btnRank:runAction(getScaleAction(commonDelay))
    self.m_btnShare:runAction(getScaleAction(commonDelay + 0.1))
    self.m_btnRePlay:runAction(getScaleAction(commonDelay + 0.2))
    self.m_btnMenu:runAction(getScaleAction(commonDelay + 0.3))
    self.m_btnNext:runAction(cc.Sequence:create(
        getScaleAction(commonDelay + 0.4),
        cc.CallFunc:create(function ( ... )
            if dd.GameData:getLevelPlayTimes()%2 == 0 then
                cc.load("sdk").Admob.getInstance():showInterstitial()
            end
        end)
        )
    )

    if self.m_isBest then
        self.m_imgHighScoreIcon:runAction(cc.Sequence:create(
            cc.DelayTime:create(commonDelay + 0.5),
            cc.CallFunc:create(function ( ... )
                self.m_imgHighScoreIcon:setVisible(true)
                self.m_imgHighScoreIcon:setScale(3)
            end),
            cc.ScaleTo:create(0.5, 1.0),
            nil
            ))
    end
end

function GameEnd:enterAction()
end

function GameEnd:onCreate()
    self:showMask()
end

function GameEnd:onRank()
    dd.PlaySound("buttonclick.mp3")
    cc.load("sdk").GameCenter.openGameCenterLeaderboardsUI(self.m_levelIndex)
end

function GameEnd:onShare()
    dd.PlaySound("buttonclick.mp3")
    cc.load("sdk").Tools.share(dd.Constants.SHARE_TIPS.getTips(), 
        cc.FileUtils:getInstance():fullPathForFilename("512.png"))
end

function GameEnd:onReplay()
    dd.PlaySound("buttonclick.mp3")
    self.m_gameScene:resetGame()
    self:removeFromParent()
end

function GameEnd:onMenu()
    dd.PlaySound("buttonclick.mp3")
    local LevelScene = import(".LevelScene", MODULE_PATH)
    local levelScene = LevelScene:create(self.m_levelIndex)
    levelScene:showWithScene("MOVEINL", 0.3)
end

function GameEnd:onNext()
    dd.PlaySound("buttonclick.mp3")
    self.m_gameScene:onNext()
    self:removeFromParent()
end

return GameEnd