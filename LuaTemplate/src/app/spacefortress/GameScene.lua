local GameScene = class("GameScene", cc.load("mvc").ViewBase)
local GameNode = import(".GameNode")
local MODULE_PATH = ...

function GameScene:onCreate()
    self:showGameNode()

    ccui.Text:create("Back", "", 64)
        :setAnchorPoint(cc.p(0, 1))
        :move(0, display.height)
        :addTo(self, 1)
        :setTouchEnabled(true)
        :onClick(function ()
            local mainScene = import(".MainScene", MODULE_PATH):create()
            mainScene:showWithScene()
        end)
        
    ccui.Text:create("Bullet", "", 64)
        :setAnchorPoint(cc.p(1, 1))
        :move(display.width, display.height)
        :addTo(self, 1)
        :setTouchEnabled(true)
        :onClick(function ()
            self.m_gameNode:getPlane():changeBulletTest()
        end)
end

function GameScene:showGameNode()
    local gameNodeContainer = cc.Node:create()
        :move(display.cx, display.cy)
        :addTo(self)

    self.m_gameNode = GameNode:create()
        :move(0, 0)
        :addTo(gameNodeContainer)
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
