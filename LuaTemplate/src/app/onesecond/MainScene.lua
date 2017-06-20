local MainScene = class("MainScene", cc.load("mvc").ViewBase)
local StringMgr = import(".StringMgr")
local GameScene = import(".GameScene")

function MainScene:onCreate()
    self:enableNodeEvents()
    local backGround = cc.Sprite:create("background.png")
        :move(display.cx, display.cy)
        :addTo(self, -1)

    local logo = cc.Sprite:create("logo.png")
        :move(display.cx, display.height)
        :setAnchorPoint(cc.p(0.5, 1))
        :addTo(self)

    cc.Label:createWithSystemFont(StringMgr.gameTips, "", 32)
        :move(display.cx, display.height*0.65)
        :addTo(self)

    local highScore = cc.UserDefault:getInstance():getIntegerForKey("highScore", 0)
    cc.Label:createWithSystemFont(string.format("%s : %d", StringMgr.bestScore, highScore), "", 32)
        :move(display.cx, display.height*0.35)
        :addTo(self)

    local startTips = ccui.Text:create(StringMgr.startTips, "", 32)
        :move(display.cx, display.height*0.25)
        :addTo(self)
        :setTouchEnabled(true)
        
    startTips:onClick(function ()
        local gameScene = GameScene:create()
        gameScene:showWithScene()
        end)

    startTips:runAction(cc.RepeatForever:create(cc.Blink:create(2, 1)))

    local restoreLabel = ccui.Text:create("Restore", "", 32)
        :move(display.width - 50, display.height - 50)
        :setRotation(45)
        :addTo(self)
        :setColor(cc.WHITE)
        :setTouchEnabled(true)
    if device.platform ~= "ios" then
        restoreLabel:setVisible(false)
    end

    local noAds = ccui.ImageView:create("NoAds.png")
        :move(display.width*0.2, display.height*0.15)
        :addTo(self)
        :setTouchEnabled(true)
    noAds:onClick(function ( ... )
        cc.load("sdk").Billing.purchase(dd.appCommon.skuKeys[1], function (result)
            print("Billing Purchase Result ~ ", result)
            if result then
                cc.UserDefault:getInstance():setBoolForKey("noads", true)
                cc.load("sdk").Admob.getInstance():setAdsRemoved(true)
            end
        end)
    end)

    local sound = ccui.CheckBox:create("soundOff.png", "soundOn.png")
        :move(display.width/2, display.height*0.15)
        :addTo(self)
    sound:onClick(function ()
        cc.UserDefault:getInstance():setBoolForKey("sound", sound:isSelected())
    end)
    sound:setSelected(cc.UserDefault:getInstance():getBoolForKey("sound", true))

    local rate = ccui.ImageView:create("rate.png")
        :move(display.width*0.8, display.height*0.15)
        :addTo(self)
        :setTouchEnabled(true)
    rate:onClick(function ( ... )
        cc.load("sdk").Tools.rate()
    end)

    local btnAction = cc.RepeatForever:create(cc.Sequence:create(
            cc.ScaleTo:create(1, 1.1),
            cc.ScaleTo:create(1, 0.9),
            nil
        ))
    noAds:runAction(btnAction)
    rate:runAction(btnAction:clone())
    sound:runAction(btnAction:clone())

    local actionRoate = cc.RepeatForever:create(cc.RotateBy:create(6.0, 360))
    sound:runAction(actionRoate:clone())

    self:addTouch()
    self:createRoate()    

    if cc.UserDefault:getInstance():getBoolForKey("noads", false) then
        cc.load("sdk").Admob.getInstance():setAdsRemoved(true)
    else
        cc.load("sdk").Admob.getInstance():showBanner(0, 0)
    end

    AudioEngine.getInstance():preloadEffect("score.mp3")
    AudioEngine.getInstance():preloadEffect("over.mp3")
end

function MainScene:onEnterTransitionFinish()
    if not cc.UserDefault:getInstance():getBoolForKey("noads", false) then
        if cc.load("sdk").Tools.getGamePlayCount() > 5 then
            cc.load("sdk").MyAds.showAds(100)
        end
    end
end

function MainScene:createRoate()
    local progressSprite = cc.Sprite:create("roate.png")
    local progress = cc.ProgressTimer:create(progressSprite)
            :setType(cc.PROGRESS_TIMER_TYPE_RADIAL)
            :setPosition(cc.p(display.cx, display.cy))
            :addTo(self)
            
    progress:runAction(cc.RepeatForever:create(cc.Sequence:create(
        cc.ProgressTo:create(1, 100),
        cc.CallFunc:create(function ()
            progress:setReverseDirection(not progress:isReverseDirection())
        end),
        cc.ProgressTo:create(1, 0), 
        cc.CallFunc:create(function ()
            progress:setReverseDirection(not progress:isReverseDirection())
        end),
        nil
        )))
end

function MainScene:addTouch()
    local listener = cc.EventListenerTouchOneByOne:create()
    listener:registerScriptHandler(handler(self, self.onTouchBegin), cc.Handler.EVENT_TOUCH_BEGAN)
    listener:registerScriptHandler(handler(self, self.onTouchMoved), cc.Handler.EVENT_TOUCH_MOVED)
    listener:registerScriptHandler(handler(self, self.onTouchEnd), cc.Handler.EVENT_TOUCH_ENDED)

    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self)
end

function MainScene:onTouchBegin(touch, event)
    if (touch:getLocation().y > display.height - 50) 
        and (touch:getLocation().x > display.width - 50) 
        and device.platform == "ios" then
            cc.load("sdk").Billing.restore(function (result)
                print("Billing Restore Result ~ ", result)
                if result then
                    cc.UserDefault:getInstance():setBoolForKey("noads", true)
                    cc.load("sdk").Admob.getInstance():setAdsRemoved(true)
                end
            end)
        return false
    end
    
    local gameScene = GameScene:create()
    gameScene:showWithScene()

    return true
end

function MainScene:onTouchMoved(touch, event)
end

function MainScene:onTouchEnd(touch, event)
end

return MainScene
