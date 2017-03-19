
local MainScene = class("MainScene", cc.load("mvc").ViewBase)

function MainScene:onCreate()
    -- add background image
    display.newSprite("HelloWorld.png")
        :move(display.center)
        :addTo(self)

    -- add HelloWorld label
    cc.Label:createWithSystemFont("Hello World", "Arial", 40)
        :move(display.cx, display.cy + 200)
        :addTo(self)
	

	ccui.ImageView:create("HelloWorld.png")
		:move(display.cx, display.cy - 200)
		:addTo(self)
		:setTouchEnabled(true)
		:onClick(function ()
			cc.load("sdk").MyAds.showAds()
		end)
end

return MainScene
