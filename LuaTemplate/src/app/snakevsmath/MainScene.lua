local MainScene = class("MainScene", cc.load("mvc").ViewBase)
local Start = import(".Start")
local GameLayer = import(".GameLayer")

function MainScene:onCreate()
    self:createStartlayer()

    local spriteFrameCache = cc.SpriteFrameCache:getInstance()
    spriteFrameCache:addSpriteFrames("gui.plist", "gui.png")

    local backGround = display.newSprite("#background.png")
        :setAnchorPoint(cc.p(0, 0))
        :move(0, 0)
        :setScaleY(1.2)
        :addTo(self, -1)
end

function MainScene:startGame()
    self.m_gameLayer = GameLayer:create(self)
        :addTo(self)
    self:removeStartLayer()
        
    cc.load("sdk").Admob.getInstance():showBanner()
end

function MainScene:removeStartLayer()
    self.m_start:removeFromParent()
    self.m_start = nil
end

function MainScene:createStartlayer()
    self.m_start = Start:create(self)
        :move(0, 0)
        :addTo(self, 100)
end

function MainScene:backHome()
    self.m_gameLayer:removeFromParent()
    self.m_gameLayer = nil
    self:createStartlayer()

    cc.load("sdk").Admob.getInstance():removeBanner()
end

return MainScene
