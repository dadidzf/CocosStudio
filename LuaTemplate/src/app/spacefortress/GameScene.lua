local GameScene = class("GameScene", cc.load("mvc").ViewBase)
local GameNode = import(".GameNode")
local GamePause = import(".GamePause")
local MODULE_PATH = ...

function GameScene:onCreate()
    self:showGameNode()

    ccui.ImageView:create("spacefortress_zanting.png", ccui.TextureResType.plistType)
        :setAnchorPoint(cc.p(1, 1))
        :move(display.width - 10, display.height - 10)
        :addTo(self, 1)
        :setTouchEnabled(true)
        :onClick(function ()
            dd.PlayBtnSound()
            local gamePause = GamePause:create(self)
                :addTo(self, 100)
        end)

    self.m_scoreLabel = cc.Label:createWithBMFont("fnt/score.fnt", "0")
        :setAnchorPoint(cc.p(0.5, 1))
        :move(display.width/2, display.height)
        :addTo(self, 1)

    if device.model == "iphone X" then
        self.m_scoreLabel:setAnchorPoint(cc.p(0, 1))
        self.m_scoreLabel:move(0, display.height)
    end

    self.m_score = 0

    self.m_startTime = os.time()
    dd.PlayBgMusic()

    self:initKeyBingdings()
end

function GameScene:initKeyBingdings()
    local function onrelease(code, event)
        if code == cc.KeyCode.KEY_BACK then
            dd.PlayBtnSound()
            local gamePause = GamePause:create(self)
                :addTo(self, 100)
        elseif code == cc.KeyCode.KEY_HOME then
        end
    end

    local listener = cc.EventListenerKeyboard:create()
    listener:registerScriptHandler(onrelease, cc.Handler.EVENT_KEYBOARD_RELEASED)

    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self)
end

function GameScene:getScore()
    return self.m_score
end

function GameScene:increaseScore(incNum)
    incNum = incNum or 1
    self.m_score = self.m_score + incNum
    
    self:updateScoreLabel()
end

function GameScene:updateScoreLabel()
    self.m_scoreLabel:setString(tostring(self.m_score))
end

function GameScene:showGameNode()
    local gameNodeContainer = cc.Node:create()
        :move(display.cx, display.cy)
        :addTo(self, 0)

    self.m_gameNode = GameNode:create(self)
        :move(0, 0)
        :addTo(gameNodeContainer)
end

function GameScene:onHome()
    local mainScene = import(".MainScene", MODULE_PATH):create()
    mainScene:showWithScene("FADE", 0.5)
    mainScene:setCurScore(self.m_score)

    AudioEngine.getInstance():stopMusic()
    cc.load("sdk").GameCenter.submitScoreToLeaderboard(1, self.m_score)
end

function GameScene:onGameOver()
    self.m_overLabel = cc.Label:createWithBMFont("fnt/gameOver.fnt", dd.GetTips(dd.Constant.GAME_OVER_TIPS))
        :move(display.width/2, display.height*0.4)
        :setOpacity(0)
        :addTo(self, 1000)


    dd.PlaySound("over.mp3")
    AudioEngine.getInstance():stopMusic()

    self.m_overLabel:runAction(cc.Sequence:create(
        cc.Spawn:create(
            cc.FadeIn:create(1.0),
            cc.MoveTo:create(1.0, cc.p(display.width/2, display.height*0.6))
            ),
        cc.DelayTime:create(1.0),
        cc.FadeOut:create(0.5),
        cc.CallFunc:create(function ( ... )
            local duration = os.time() - self.m_startTime
            print("GameScene:onGameOver", duration)

            if cc.load("sdk").Tools.getGamePlayCount() > 1 and duration > 30 then
                cc.load("sdk").Admob.getInstance():showInterstitial()
            end

            self:onHome()
        end)
        ))
end

function GameScene:showWithScene(transition, time, more)
    local scene = display.newScene(self.name_, {physics = true})
    scene:addChild(self)
    display.runScene(scene, transition, time, more)

    local physicWorld = scene:getPhysicsWorld()
    --physicWorld:setDebugDrawMask(cc.PhysicsWorld.DEBUGDRAW_ALL)
    physicWorld:setGravity(cc.p(0, 0))
    physicWorld:setFixedUpdateRate(60)
    physicWorld:setAutoStep(true)
    
    return self
end

return GameScene
