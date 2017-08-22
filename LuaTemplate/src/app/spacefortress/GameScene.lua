local GameScene = class("GameScene", cc.load("mvc").ViewBase)

function GameScene:onCreate()
    local bg = display.newSprite("#gameBg.png")
        :move(display.cx, display.cy)
        :addTo(self)
end

return GameScene
