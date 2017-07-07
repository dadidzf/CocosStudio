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
    self:onUpdate(handler(self, self.update))
    
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
end

function GameScene:resetGame()
    self:showRandBg()
    self:showGameNode()
    self:initGameData(self.m_levelIndex)
    self:resetGameProgress()
    self:applyGamedataDisplay()
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
    local GameEnd = import(".GameEnd", MODULE_PATH)
    local params = {}

    params.fill = math.floor(self.m_gameCurCut*10)/10
    params.lives = self.m_lives
    params.steps = self.m_steps
    params.topCollision = self.m_topCollisionCount

    local gameEnd = GameEnd:create(self, self.m_levelIndex, params)
        :move(display.cx, display.cy)
        :addTo(self, 10)
end

function GameScene:gameFail()
    local GameFail = import(".GameFail", MODULE_PATH)
    local gameFail = GameFail:create(self) 
    self:addChild(gameFail, 2)
    gameFail:setPosition(display.cx, display.cy)
end

function GameScene:updateArea()
    self.m_curArea = math.abs(self.m_node:getValidPolygonArea())
    print("GameScene:updateArea -------", self.m_curArea, self.m_totalArea)
    self.m_gameCurCut = math.abs(self.m_totalArea - self.m_curArea)*100/self.m_totalArea
    self:applyGamedataDisplay()

    if self.m_gameCurCut >= self.m_gameTarget then
        self:gameSuccess()
    end
end

function GameScene:checkSteps()
    if self.m_steps <= 0 then
        self:gameFail()
    end
end

function GameScene:costOneStep()
    self.m_steps = self.m_steps - 1
    self:applyGamedataDisplay()
end

function GameScene:loseLife()
    self.m_lives = self.m_lives - 1
    self:applyGamedataDisplay()

    if self.m_lives <= 0 then
        self:gameFail()
    end
end

function GameScene:oneMoreTopCollision()
    self.m_topCollisionCount = self.m_topCollisionCount + 1
    self:applyGamedataDisplay()
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
end

function GameScene:showLives()
    for index = 1, 3 do 
        if index <= self.m_lives then
            self.m_imgLifeList[index]:setVisible(true)
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

    local randomShow = dd.CsvConf:getRandomBgAndBtn()
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
    local GamePause = import(".GamePause", MODULE_PATH)
    local pauseNode = GamePause:create()
    pauseNode:setPosition(display.cx, display.cy)
    self:addChild(pauseNode, 2)
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

    if cc.rectContainsPoint(rect, pos) then
        return self.m_picHorizontal:getVirtualRenderer():getSprite():getSpriteFrame(), true, 
            self.m_picHorizontal:convertToWorldSpace(cc.p(size.width/2, size.height/2))
    end

    pos = self.m_picVertical:convertToNodeSpace(location)
    if cc.rectContainsPoint(rect, pos) then
        return self.m_picVertical:getVirtualRenderer():getSprite():getSpriteFrame(), false, 
            self.m_picVertical:convertToWorldSpace(cc.p(size.width/2, size.height/2))
    end
end

function GameScene:update(t)
    -- for i = 1, 3 do 
    --     display:getRunningScene():getPhysicsWorld():step(t/3)
    -- end
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
    --physicWorld:setAutoStep(false)
    
    return self
end

return GameScene 
