local MainScene = class("MainScene", cc.load("mvc").ViewBase)
local GameScene = import(".GameScene")

function MainScene:onCreate()
    ccui.Text:create("Play", "", 64)
        :move(display.cx, display.cy)
        :addTo(self)
        :setTouchEnabled(true)
        :onClick(function ()
            local gameScene = GameScene:create()
            gameScene:showWithScene()
        end)
end

return MainScene
