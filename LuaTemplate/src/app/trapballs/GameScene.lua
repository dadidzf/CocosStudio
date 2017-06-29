local GameScene = class("GameScene", cc.load("mvc").ViewBase)
local GameNode = import(".GameNode")
local MODULE_PATH = ...

function GameScene:onCreate()
    ccui.Text:create("Back", "", 64)
        :move(display.cx, display.height - 64)
        :addTo(self)
        :setTouchEnabled(true)
        :onClick(function ()
            local MainScene = import(".MainScene", MODULE_PATH)
            local mainScene = MainScene:create()
            mainScene:showWithScene()
        end)

    self.m_node = GameNode:create()
        :move(display.cx, display.cy)
        :addTo(self)
end

function GameScene:showWithScene(transition, time, more)
    self:setVisible(true)
    local scene = display.newScene(self.name_, {physics = true})
    scene:addChild(self)
    display.runScene(scene, transition, time, more)

    local physicWorld = scene:getPhysicsWorld()
    --physicWorld:setDebugDrawMask(cc.PhysicsWorld.DEBUGDRAW_ALL)
    physicWorld:setGravity(cc.p(0, 0))
    return self
end

return GameScene 
