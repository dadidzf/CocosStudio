local GameEndLayer = class("GameEndLayer", cc.Node)
local StringMgr = import(".StringMgr")
local MODULE_PATH = ...

function GameEndLayer:ctor(score)
    self:enableNodeEvents()

    -- show Achievement
    cc.load("sdk").GameCenter.submitScoreToLeaderboard(1, score)
    if score >= 50 then
        cc.load("sdk").GameCenter.unlockAchievement(5)
    end
    if score >= 40 then
        cc.load("sdk").GameCenter.unlockAchievement(4)
    end
    if score >= 30 then
        cc.load("sdk").GameCenter.unlockAchievement(3)
    end
    if score >= 20 then
        cc.load("sdk").GameCenter.unlockAchievement(2)
    end
    if score >= 10 then
        cc.load("sdk").GameCenter.unlockAchievement(1)
    end
    
    -- Store high score
    local highScore = cc.UserDefault:getInstance():getIntegerForKey("highScore", 0)
    if highScore < score then
        cc.UserDefault:getInstance():setIntegerForKey("highScore", score)
        highScore = score
    end

    -- background layer
    local particle = nil
    local maskLayer = ccui.Layout:create()
        :setBackGroundColorType(LAYOUT_COLOR_SOLID)
        --:setBackGroundColor(cc.BLACK)
        :setBackGroundColor(cc.c3b(192, 192, 192))
        :setBackGroundColorOpacity(0)
        :setTouchEnabled(true)
        :setSwallowTouches(true)
        :setContentSize(display.size)
        :addTo(self, -2)
        :onTouch(function (event)
            local target = event.target
            if event.name == "began" then
                if particle then return end
                
                particle = cc.ParticleSystemQuad:create("particle_texture.plist") 
                    :addTo(self)
                    :move(self:convertToNodeSpace(target:getTouchBeganPosition()))
            elseif event.name == "moved" then
                if not particle then return end
                particle:move(self:convertToNodeSpace(target:getTouchMovePosition()))
            elseif event.name == "ended" or event.name == "cancelled" then
                if particle then
                    particle:removeFromParent()
                    particle = nil
                end
            end
        end)

    -- Game Over label
    local gameOverLabel = ccui.Text:create(StringMgr.gameOver, "", 96)
        :move(display.cx, display.height*0.72)
        :addTo(self)
        :setColor(cc.WHITE)

    -- High score bg, high score label
    local scoreBg = cc.Sprite:create("gameEndScoreBg.png")
        :addTo(self, -1)
        :setAnchorPoint(cc.p(0.5, 0))
        :move(display.cx, display.height)

    scoreBg:runAction(cc.Sequence:create(
        cc.MoveTo:create(0.7, cc.p(display.cx, display.height*0.40)),
        cc.MoveBy:create(0.1, cc.p(0, display.height*0.05)),
        cc.MoveBy:create(0.2, cc.p(0, -display.height*0.05)),
        nil
        ))

    local scoreLabel = cc.Label:createWithBMFont("score.fnt", tostring(score)) 
        :move(125, 160)
    scoreBg:addChild(scoreLabel)
    local highSocreLabel = ccui.Text:create(tostring(highScore), "", 36)
        :addTo(scoreBg)
        :move(168, 80)
        :setColor(cc.BLACK)
    
    -- retrun, rate, share, rank Buttons
    local returnBtn = ccui.ImageView:create("return.png")
        :move(display.width*0.5, display.height*0.3)
        :setTouchEnabled(true)
        :addTo(self)
        :onClick(function ()
            self:backHome()
        end)

    local shareBtn = ccui.ImageView:create("sharebtn.png")
        :move(display.width*0.2, display.height*0.15)
        :addTo(self)
        :setTouchEnabled(true)
    shareBtn:onClick(function ( ... )
        cc.load("sdk").Tools.share(string.format("I have got %d points in 1 Second !", score), 
            cc.FileUtils:getInstance():fullPathForFilename("512.png"))
    end)

    local rank = ccui.ImageView:create("rankbtn.png")
        :move(display.width*0.5, display.height*0.15)
        :addTo(self)
        :setTouchEnabled(true)
    rank:onClick(function ( ... )
        cc.load("sdk").GameCenter.openGameCenterLeaderboardsUI(1)
    end)

    local rateBtn = ccui.ImageView:create("rate.png")
        :move(display.width*0.8, display.height*0.15)
        :addTo(self)
        :setTouchEnabled(true)
    rateBtn:onClick(function ( ... )
        cc.load("sdk").Tools.rate()
    end)

    local btnAction = cc.RepeatForever:create(cc.Sequence:create(
            cc.ScaleTo:create(1, 1.1),
            cc.ScaleTo:create(1, 0.9),
            nil
        ))
    shareBtn:runAction(btnAction)
    rank:runAction(btnAction:clone())
    rateBtn:runAction(btnAction:clone())
end

local _sGameEndsCount = 0
function GameEndLayer:onEnter()
    _sGameEndsCount = _sGameEndsCount + 1
    if _sGameEndsCount % 2 == 0 then
        cc.load("sdk").Admob.getInstance():showInterstitial()
    end
end

function GameEndLayer:backHome()
    local MainScene = import(".MainScene", MODULE_PATH)
    local mainScene = MainScene:create()
    mainScene:showWithScene()
end

return GameEndLayer