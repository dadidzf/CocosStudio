local MainScene = class("MainScene", cc.load("mvc").ViewBase)
local GameScene = import(".GameScene")

function MainScene:onCreate()
	display.loadSpriteFrames("gui.plist", "gui.png")

	ccui.Text:create("Play", "", 128)
		:move(display.cx, display.cy)
		:addTo(self)
		:setTouchEnabled(true)
		:onClick(function ()
	        local gameScene = GameScene:create()
	        gameScene:showWithScene()
		end)
end

return MainScene
