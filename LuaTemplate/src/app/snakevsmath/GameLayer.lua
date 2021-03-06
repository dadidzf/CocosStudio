local GameLayer = class("GameLayer", cc.Layer)

local MODULE_PATH = ...
local Snake = import(".Snake")
local BalloonsContainer = import(".BalloonsContainer")
local GamePause = import(".GamePause")

function GameLayer:ctor(scene)
    print("GameLayer:ctor")
    
    self:enableNodeEvents()

    self.m_scene = scene
    local snake = Snake:create(handler(self, self.onSnakeMove))
        :move(display.cx, display.cy)
        :addTo(self, 1)
    self.m_snake = snake
    self.m_balloonsContainer = BalloonsContainer:create() 
        :move(display.cx, display.cy)
        :addTo(self)

    self:addTouch()
    self:createPauseBtn()
    self:createDiamonds()
    self:createTips()

    self.m_schedulerCollision = dd.scheduler:scheduleScriptFunc(handler(self, self.updateCollision), 0.01, false)
    self.m_isGameEnd = false
    self.m_isAlreadyBegin = false
end

function GameLayer:createTips()
    local tipsTb = {
        en = "Long Press To Make The Snake Move Left !",
        cn = "长按让蛇往左边移动 !" 
    }

    self.m_tipsLabel = cc.Label:createWithBMFont("fnt/snake_white_48.fnt", dd.GetTips(tipsTb))
        :move(display.cx, display.height*0.15)
        :setScale(0.5)
        :addTo(self, 100)

    self.m_gameFinger1 = ccui.ImageView:create("finger1.png")
        :move(display.cx, display.height*0.28)
        :addTo(self)
        :setScale(0.8)

    self.m_gameFinger = ccui.ImageView:create("finger.png")
        :move(display.cx, display.height*0.28)
        :setScale(0.6)
        :addTo(self)

    self.m_gameFinger:setVisible(false)
    self.m_gameFinger1:runAction(
        cc.RepeatForever:create(
            cc.Sequence:create(
                cc.ScaleTo:create(1.0, 0.6),
                cc.CallFunc:create(function ()
                    self.m_gameFinger1:setVisible(false)
                    self.m_gameFinger:setVisible(true)
                end),
                cc.DelayTime:create(1.0),
                cc.CallFunc:create(function ()
                    self.m_gameFinger1:setVisible(true)
                    self.m_gameFinger:setVisible(false)
                end),
                cc.ScaleTo:create(1.0, 0.8),
                nil
                )
            )
        )
end

function GameLayer:removeTips()
    self.m_tipsLabel:removeFromParent()
    self.m_tipsLabel = nil

    self.m_gameFinger:removeFromParent()
    self.m_gameFinger = nil

    self.m_gameFinger1:removeFromParent()
    self.m_gameFinger1 = nil
end

function GameLayer:createPauseBtn()
    local button = ccui.Layout:create()
        :setAnchorPoint(cc.p(0.5, 0.5))
        :addTo(self)
        
    local size = 60
    button:setContentSize(cc.size(size, size))
    button:setTouchEnabled(true)
    button:move(size, display.height - size)

    button:onClick(function ( ... )
        dd.PlaySound("button.wav")
        local gamePause = GamePause:create(self)
            :move(display.width/2, display.height/2)
            :addTo(self, 1)
    end)

    dd.BtnScaleAction(button)

    local pauseBtn = ccui.ImageView:create("zanting.png", ccui.TextureResType.plistType) 
        :move(size/2, size/2)
        :addTo(button)

    self.m_pauseBtn = button
end

function GameLayer:createDiamonds()
    self.m_diamondImg = display.newSprite("#diamondNum.png")
        :move(display.width - 150, display.height - 60)
        :addTo(self, 1)

    self.m_diamondLabel = cc.Label:createWithBMFont("fnt/snake_white_48.fnt", "")
        :setAnchorPoint(cc.p(0, 0.5))
        :move(display.width - 120, display.height - 60)
        :addTo(self, 1)
    self:refreshDiamonds()
end

function GameLayer:refreshDiamonds()
    local curDiamonds = dd.GameData:getDiamonds()
    self.m_diamondLabel:setString(tostring(curDiamonds))
end

function GameLayer:onHome()
    self.m_scene:backHome()
end

function GameLayer:onRestart()
    self.m_scene:onRestart()
end

function GameLayer:onSnakeMove(diffY)
end

function GameLayer:updateCollision()
    local balloonsList = self.m_balloonsContainer:getBalloonsList()
    for index, balloon in pairs(balloonsList) do
        local balloonPos = cc.p(balloon:getPositionX(), balloon:getPositionY())
        local headPos = self.m_snake:getHeadPos()

        local symbol = balloon:getSymbol()
        if symbol == "wall" then
            self.m_snake:updatePosWithWall(balloon)
        else
            if cc.pGetLength(cc.pSub(balloonPos, headPos)) < 50 then
                local snakeNum = self.m_snake:getNumber()
                local ret = balloon:dealSnakeNumber(snakeNum)
 
                if type(ret) == "number" then
                    snakeNum = ret
                    balloonsList[index] = nil
                    if snakeNum < 0 then
                        self:gameEnd(0, false)
                        self.m_snake:setNumber(0)
                    else
                        if symbol == "+" or symbol == "×" then
                            dd.PlaySound("score.mp3")
                        else
                            dd.PlaySound("lose.wav")
                        end

                        self.m_snake:setNumber(snakeNum)
                        self:updateLevel(snakeNum)
                    end

                    balloon:runAction(cc.Sequence:create(
                        cc.FadeOut:create(0.2),
                        cc.DelayTime:create(0.3),
                        cc.CallFunc:create(function ( ... )
                            balloon:removeFromParent()
                        end)
                        ))
                elseif ret == "diamond" then
                    dd.PlaySound("diamond.mp3")
                    balloon:stopAllActions() 
                    self.m_balloonsContainer:removeBalloon(index)
                    balloon:runAction(cc.Sequence:create(
                        cc.Blink:create(1, 2),
                        cc.MoveTo:create(1, cc.p(self.m_diamondImg:getPositionX() - display.width/2, 
                            self.m_diamondImg:getPositionY() - display.height*0.5)),
                        cc.FadeOut:create(0.5),
                        cc.CallFunc:create(function ( ... )
                            local curDiamonds = dd.GameData:getDiamonds()
                            dd.GameData:refreshDiamonds(curDiamonds + 1)
                            balloon:removeFromParent()
                            self:refreshDiamonds()
                        end
                        )
                        ))
                elseif ret == "bomb" then
                    local snakeNum = self.m_snake:getNumber()
                    self:gameEnd(snakeNum, true)
                    balloon:removeFromParent()
                end

                break
            end
        end
    end
end

function GameLayer:updateLevel(snakeNum)
    local curLevel = dd.GameData:getCurLevel()
    if snakeNum > 100 and curLevel == 1 then
         dd.GameData:setLevel(2)
    elseif snakeNum > 1000000 and curLevel == 2 then
         dd.GameData:setLevel(3)
    elseif snakeNum > 10000000 and curLevel == 3 then
         dd.GameData:setLevel(4)
    elseif snakeNum > 100000000 and curLevel == 4 then
         dd.GameData:setLevel(5)
    end
end

function GameLayer:gameEnd(score, isBomb)
    local scheduler
    local showGameEndFunc = function ( ... )
        local gameEnd = import(".GameEnd", MODULE_PATH):create(self, score)
            :move(display.cx, display.cy)
            :addTo(self, 100)

        if scheduler then
            dd.scheduler:unscheduleScriptEntry(scheduler)
        end
    end
    
    self.m_isGameEnd = true
    self.m_snake:onGameEnd(isBomb)
    self.m_balloonsContainer:onGameEnd()
    self:removeAllSchedule()

    if isBomb then
        local shaker = cc.load("sdk").ScreenShake:create(self, 0.2)
        shaker:setDiffMax(12)
        shaker:run()
        scheduler = dd.scheduler:scheduleScriptFunc(showGameEndFunc, 2.2, false)
        self.m_pauseBtn:setTouchEnabled(false)
    else
        scheduler = dd.scheduler:scheduleScriptFunc(showGameEndFunc, 0.5, false)
        dd.PlaySound("failed.mp3")
    end
    
    AudioEngine.getInstance():stopMusic()
end

function GameLayer:addTouch()
    local listener = cc.EventListenerTouchOneByOne:create()
    listener:registerScriptHandler(handler(self, self.onTouchBegin), cc.Handler.EVENT_TOUCH_BEGAN)
    listener:registerScriptHandler(handler(self, self.onTouchMoved), cc.Handler.EVENT_TOUCH_MOVED)
    listener:registerScriptHandler(handler(self, self.onTouchEnd), cc.Handler.EVENT_TOUCH_ENDED)
    listener:registerScriptHandler(handler(self, self.onTouchEnd), cc.Handler.EVENT_TOUCH_CANCELLED)

    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self)
end

function GameLayer:onTouchBegin(touch, event)
    if self.m_isGameEnd then
        return false
    end

    if not self.m_isAlreadyBegin then
        self.m_isAlreadyBegin = true
        self.m_snake:setMoveSpeed(500)
        self.m_balloonsContainer:start()

        if dd.GameData:isSoundEnable() then
            AudioEngine.getInstance():playMusic("sounds/background.mp3", true)
            AudioEngine.getInstance():setMusicVolume(0.5)
        end

        self:removeTips()
    end

    self:unScheduleRecoverDirection()
    self:unScheduleSnakeDirectionChange()
    self.m_scheduler = dd.scheduler:scheduleScriptFunc(handler(self, self.updateSnakeDirection), 0.01, false)

    return true
end

function GameLayer:onTouchMoved(touch, event)

end

function GameLayer:onTouchEnd(touch, event)
    self:unScheduleSnakeDirectionChange()
    self:unScheduleRecoverDirection()
    self.m_recoverScheduler = dd.scheduler:scheduleScriptFunc(handler(self, self.recoverSnakeDirection), 0.01, false)
end

function GameLayer:unScheduleSnakeDirectionChange()
    if self.m_scheduler then
        dd.scheduler:unscheduleScriptEntry(self.m_scheduler)
        self.m_scheduler = nil
    end
end

function GameLayer:unScheduleRecoverDirection()
    if self.m_recoverScheduler then
        dd.scheduler:unscheduleScriptEntry(self.m_recoverScheduler)
        self.m_recoverScheduler = nil
    end
end

function GameLayer:updateSnakeDirection()
    local curDirection = self.m_snake:getDirection()
    if curDirection < 150 then
        self.m_snake:setDirection(curDirection + 3)
    else
        --self:unScheduleSnakeDirectionChange()
    end
end

function GameLayer:recoverSnakeDirection()
    local curDirection = self.m_snake:getDirection()
    if curDirection > 30 then
        self.m_snake:setDirection(curDirection - 3)
    else
        --self:unScheduleRecoverDirection()
    end
end

function GameLayer:removeAllSchedule()
    self:removeCollisionSchedule()
    self:unScheduleRecoverDirection()
    self:unScheduleSnakeDirectionChange()
end

function GameLayer:removeCollisionSchedule()
    if self.m_schedulerCollision then
        dd.scheduler:unscheduleScriptEntry(self.m_schedulerCollision)
    end
end

function GameLayer:onCleanup()
    self:removeAllSchedule()
end

return GameLayer