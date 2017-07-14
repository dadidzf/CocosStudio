local GameScene = class("GameScene", cc.load("mvc").ViewBase)
local GameNode = import(".GameNode")
local MODULE_PATH = ...

GameScene.RESOURCE_FILENAME = "game.csb"
GameScene.RESOURCE_BINDING = {
    ["Image_stop.Button_stop"] = {varname = "m_btnPause", events = {{ event = "click", method = "onPause" }}},
    ["BitmapFontLabel_roundnumber"] = {varname = "m_labelRoundNum"},
    ["BitmapFontLabel_stepnuber"] = {varname = "m_labelStepNum"},
    ["BitmapFontLabel_topnumber"] = {varname = "m_labelTopCollisionNum"},
    ["Image_horizontal"] = {varname = "m_picHorizontal"},
    ["Image_certical"] = {varname = "m_picVertical"},

    ["Image_daoju1"] = {varname = "m_prop1"},
    ["Image_daoju2"] = {varname = "m_prop2"},
    ["Image_daoju3"] = {varname = "m_prop3"},

    ["Image_life1"] = {varname = "m_imgLife1"},
    ["Image_life2"] = {varname = "m_imgLife2"},
    ["Image_life3"] = {varname = "m_imgLife3"},

    ["Image_circlehalfblack"] = {varname = "m_imgCircleBlack"},
    ["Image_circlewhite"] = {varname = "m_imgCircleWhite"},
    ["Image_circlehalfwhite"] = {varname = "m_imgCircleGray"}
}

function GameScene:ctor(levelIndex)
    self.super.ctor(self)
    self.m_levelIndex = levelIndex
    self.m_newGuideCtl = import(".NewGuideController", MODULE_PATH):create(self, levelIndex)
    
    local resourceNode = self:getResourceNode()
    resourceNode:setContentSize(display.size)
    ccui.Helper:doLayout(resourceNode)
    
    print("GameScene:ctor", levelIndex)
    self.m_labelRoundNum:setString(tostring(levelIndex))

    self.m_imgLifeList = {self.m_imgLife1, self.m_imgLife2, self.m_imgLife3}
    self.m_imgCircleGray:setVisible(false)
    self.m_imgCircleWhite:setVisible(false)
    self.m_imgCircleBlack:setVisible(false)

    self:showRandBg()
    self:showGameNode()

    self:initGameData(levelIndex)
    self:initGameProgress()
    self:showProps()
    self:applyGamedataDisplay()

    self.m_picVertical:setOpacity(0)
    self.m_picHorizontal:setOpacity(0)
end

function GameScene:onBallCreateOk()
    self.m_picVertical:runAction(cc.FadeIn:create(0.5))
    self.m_picHorizontal:runAction(cc.FadeIn:create(0.5))
    self:getParent():getPhysicsWorld():setAutoStep(true)
end

function GameScene:getNewGuideCtl()
    return self.m_newGuideCtl
end

function GameScene:resetGame()
    self:getParent():getPhysicsWorld():setAutoStep(false)
    self.m_newGuideCtl:reset(self, self.m_levelIndex)
    self:showRandBg()
    self:showGameNode()
    self:initGameData(self.m_levelIndex)
    self:resetGameProgress()
    self:applyGamedataDisplay()

    self.m_isGameEnd = false
end

function GameScene:onNext()
    self.m_levelIndex = self.m_levelIndex + 1
    self.m_labelRoundNum:setString(tostring(self.m_levelIndex))
    self:resetGame()
end

function GameScene:initGameData(levelIndex)
    self.m_lives = 3
    self.m_topCollisionCount = 0

    local roundCfg = dd.CsvConf:getRoundCfg()[levelIndex]
    self.m_steps = roundCfg.steps
    self.m_gameTarget = roundCfg.fill_target
    self.m_gameCurCut = 0
    self.m_totalArea = math.abs(self.m_node:getValidPolygonArea())
    self.m_curArea = self.m_totalArea
end

function GameScene:gameSuccess()
    self.m_labelStepNum:stopAllActions()
    local GameEnd = import(".GameEnd", MODULE_PATH)
    local params = {}

    dd.PlaySound("gameSuccess.mp3", 80)
    params.fill = math.floor(self.m_gameCurCut*10)/10
    params.lives = self.m_lives
    params.steps = self.m_steps
    params.topCollision = self.m_topCollisionCount

    local gameEnd = GameEnd:create(self, self.m_levelIndex, params)
        :move(display.cx, display.cy)
        :addTo(self, 10)

    self.m_isGameEnd = true
end

function GameScene:gameFail()
    self.m_labelStepNum:stopAllActions()
    local GameFail = import(".GameFail", MODULE_PATH)
    local gameFail = GameFail:create(self) 
    self:addChild(gameFail, 2)
    gameFail:setPosition(display.cx, display.cy)
    dd.PlaySound("gameFail.mp3")
    
    self.m_isGameEnd = true
end

function GameScene:updateArea()
    local oldArea = self.m_curArea
    self.m_curArea = math.abs(self.m_node:getValidPolygonArea())

    if oldArea - self.m_curArea > 0.1 then
        dd.PlaySound("reduceArea.mp3")
    end

    self.m_gameCurCut = math.abs(self.m_totalArea - self.m_curArea)*100/self.m_totalArea
    self:applyGamedataDisplay()

    if self.m_gameCurCut >= self.m_gameTarget then
        self:gameSuccess()
    end
end

function GameScene:checkSteps()
    if self.m_isGameEnd then return end
    if self.m_isPurchasing then return end

    if self.m_steps <= 2 then
        self.m_labelStepNum:runAction(cc.RepeatForever:create(
            cc.Sequence:create(
                cc.FadeOut:create(0.5),
                cc.FadeIn:create(0.5)
                )
            ))
    end

    if self.m_steps <= 0 then
        self.m_labelStepNum:stopAllActions()
        local BuySteps = import(".BuySteps", MODULE_PATH)
        self.m_isPurchasing = true
        local buySteps = BuySteps:create(function (givenSteps)
            self.m_isPurchasing = false
            if givenSteps then
                self.m_steps = self.m_steps + givenSteps
                self:updateStepsDisplay()
            else
                self:gameFail()
            end
        end)
        
        buySteps:move(display.cx, display.cy)
        buySteps:addTo(self, 10)
    end
end

function GameScene:costOneStep()
    if self.m_isAlreadyLoseLife then
        self.m_isAlreadyLoseLife = false
        return
    end

    self.m_steps = self.m_steps - 1
    self:updateStepsDisplay()
    
    self:checkSteps()
end

function GameScene:updateStepsDisplay()
    self.m_labelStepNum:runAction(cc.Sequence:create(
        cc.ScaleTo:create(0.3, 1.6),
        cc.CallFunc:create(function ()
            self.m_labelStepNum:setString(tostring(self.m_steps))
        end),
        cc.ScaleTo:create(0.3, 1)
        ))
end

function GameScene:loseLife()
    import(".ScreenShaker", MODULE_PATH):create(self, 0.2):run()
    
    dd.PlaySound("loseLife.mp3")
    self.m_lives = self.m_lives - 1
    self:updateLivesDisplay()
    self.m_isAlreadyLoseLife = true

    if self.m_lives <= 0 then
        local BuyLives = import(".BuyLives", MODULE_PATH)
        self.m_isPurchasing = true
        local buyLives = BuyLives:create(function (givenLives)
            self.m_isPurchasing = false
            if givenLives then
                self.m_lives = self.m_lives + givenLives
                self:getMoreLivesDisplay()
            else
                self:gameFail()
            end
        end)
        
        buyLives:move(display.cx, display.cy)
        buyLives:addTo(self, 10)
    end
end

function GameScene:getMoreLivesDisplay()
    for i = 1, self.m_lives do
        local life = self.m_imgLifeList[i]
        life:setVisible(true)
        life:setOpacity(0)
        life:runAction(cc.Sequence:create(
            cc.DelayTime:create((i - 1)*0.8),
            cc.FadeIn:create(0.3),
            cc.Blink:create(0.5, 2)
            ))
    end
end

function GameScene:updateLivesDisplay()
    self.m_imgLifeList[self.m_lives + 1]:runAction(cc.Sequence:create(
        cc.DelayTime:create(0.5),
        cc.Blink:create(0.5, 2),
        cc.FadeOut:create(0.3),
        cc.CallFunc:create(function ( ... )
            self.m_imgLifeList[self.m_lives + 1]:setOpacity(256)
            self:applyGamedataDisplay()
        end)
        ))
end

function GameScene:oneMoreTopCollision()
    self.m_topCollisionCount = self.m_topCollisionCount + 1
    self.m_labelTopCollisionNum:runAction(cc.Sequence:create(
        cc.ScaleTo:create(0.3, 1.6),
        cc.CallFunc:create(function ()
            self.m_labelTopCollisionNum:setString(tostring(self.m_topCollisionCount))
        end),
        cc.ScaleTo:create(0.3, 1)
        ))
end

function GameScene:applyGamedataDisplay()
    self.m_labelStepNum:setString(tostring(self.m_steps))
    self:showLives()
    self.m_labelTopCollisionNum:setString(tostring(self.m_topCollisionCount))
    self.m_labelStepNum:setString(tostring(self.m_steps))
    self:showGameProgress()
end

function GameScene:resetGameProgress()
    self.m_progressWhite:setColor(self.m_boxColor)
end

function GameScene:initGameProgress()
    local pos = cc.p(self.m_imgCircleBlack:getPositionX(), self.m_imgCircleBlack:getPositionY())
    local graySprite = cc.Sprite:createWithSpriteFrameName("circle_halfblack.png")
    self.m_progressGray = cc.ProgressTimer:create(graySprite)
            :setType(cc.PROGRESS_TIMER_TYPE_RADIAL)
            :setPosition(pos)
            :setOpacity(180)
            :setReverseDirection(true)
            :addTo(self, 4)
    self.m_progressGray:setPercentage(self.m_gameCurCut)


    local whiteSprite = cc.Sprite:createWithSpriteFrameName("circle_white.png")
    self.m_progressWhite = cc.ProgressTimer:create(whiteSprite)
            :setType(cc.PROGRESS_TIMER_TYPE_RADIAL)
            :setPosition(pos)
            :setColor(self.m_boxColor)
            :addTo(self, 2)

    self.m_progressWhite:setPercentage(100)

    local blackSprite = cc.Sprite:createWithSpriteFrameName("circle_white.png")
    self.m_progressBlack = cc.ProgressTimer:create(blackSprite)
            :setType(cc.PROGRESS_TIMER_TYPE_RADIAL)
            :setColor(cc.BLACK)
            :setOpacity(180)
            :setPosition(pos)
            :addTo(self, 3)

    self.m_progressBlack:setPercentage(100 - self.m_gameTarget)

end

function GameScene:showGameProgress()
    self.m_progressGray:setPercentage(self.m_gameCurCut)
    self.m_progressWhite:setPercentage(100 - self.m_gameCurCut)
    self.m_progressBlack:setPercentage(100 - self.m_gameTarget)
end

function GameScene:showLives()
    for index = 1, 3 do 
        if index <= self.m_lives then
            self.m_imgLifeList[index]:setVisible(true)
            self.m_imgLifeList[index]:setOpacity(255)
        else
            self.m_imgLifeList[index]:setVisible(false)
        end
    end
end

function GameScene:showRandBg()
    local resourceNode = self:getResourceNode()
    for _, v in pairs(dd.CsvConf:getColorCfg()) do
        resourceNode:getChildByName(v.image_di):setVisible(false)
    end

    local randomShow = dd.CsvConf:getRandomBgAndBtn(self.m_levelIndex)
    resourceNode:getChildByName(randomShow.image_di):setVisible(true)
    local color = dd.YWStrUtil:parse(randomShow.box_color)
    self.m_boxColor = cc.c3b(color[1], color[2], color[3])
end

function GameScene:showProps()
    self.m_propList = {self.m_prop1, self.m_prop2, self.m_prop3}

    for _, prop in ipairs(self.m_propList) do
        prop:setVisible(false)
    end
end

function GameScene:onPause()
    dd.PlaySound("buttonclick.mp3")
    local GamePause = import(".GamePause", MODULE_PATH)
    local pauseNode = GamePause:create()
    pauseNode:setPosition(display.cx, display.cy)
    if self.m_levelIndex == 1 then
        self:addChild(pauseNode, 200)
    else
        self:addChild(pauseNode, 2)
    end
end

function GameScene:showGameNode()
    if self.m_node then
        self.m_node:removeFromParent() 
    end

    self.m_node = GameNode:create(self, self.m_boxColor, self.m_levelIndex)
        :move(display.cx, display.cy)
        :addTo(self)

    self.m_node:setScale(dd.Constants.NODE_SCALE)
end

function GameScene:getValidSpriteFrame(location)
    local pos = self.m_picHorizontal:convertToNodeSpace(location)
    local size = self.m_picHorizontal:getContentSize()
    local rect = cc.rect(0, 0, size.width, size.height)

    if cc.rectContainsPoint(rect, pos) and self.m_picHorizontal:getOpacity() >= 200 then
        return self.m_picHorizontal:getVirtualRenderer():getSprite():getSpriteFrame(), true, 
            self.m_picHorizontal:convertToWorldSpace(cc.p(size.width/2, size.height/2))
    end

    pos = self.m_picVertical:convertToNodeSpace(location)
    if cc.rectContainsPoint(rect, pos) and self.m_picVertical:getOpacity() >= 200 then
        return self.m_picVertical:getVirtualRenderer():getSprite():getSpriteFrame(), false, 
            self.m_picVertical:convertToWorldSpace(cc.p(size.width/2, size.height/2))
    end
end

function GameScene:showWithScene(transition, time, more)
    self:setVisible(true)
    local scene = display.newScene(self.name_, {physics = true})
    scene:addChild(self)
    display.runScene(scene, transition, time, more)

    local physicWorld = scene:getPhysicsWorld()
    --physicWorld:setDebugDrawMask(cc.PhysicsWorld.DEBUGDRAW_ALL)
    physicWorld:setGravity(cc.p(0, 0))
    physicWorld:setFixedUpdateRate(60)
    physicWorld:setAutoStep(false)
    
    return self
end

function GameScene:getPicHorizontal()
    return self.m_picHorizontal
end

function GameScene:getPicVertical()
    return self.m_picVertical
end

function GameScene:getGameNode()
    return self.m_node
end

function GameScene:getImgCirclePos()
    return cc.p(self.m_imgCircleBlack:getPositionX(), self.m_imgCircleBlack:getPositionY())
end


return GameScene 
