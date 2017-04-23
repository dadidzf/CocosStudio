
local MainScene = class("MainScene", cc.load("mvc").ViewBase)
local test

function MainScene:onCreate()
	local disY = 80
	local inc = 1
	local fntSize = 64

	ccui.Text:create("Show My Own Ads", "", fntSize)
		:move(display.cx, display.height - 100)
		:addTo(self)
		:setTouchEnabled(true)
		:onClick(function ()
			cc.load("sdk").MyAds.showAds()
		end)
	
	local choice = 0
	ccui.Text:create("Show Banner", "", fntSize)
		:move(display.cx, display.height - 100 - disY*inc)
		:addTo(self)
		:setTouchEnabled(true)
		:onClick(function ()
			if choice == 0 then 	
  				cc.load("sdk").Admob.getInstance():showBanner(0, 0)
  			elseif choice == 1 then
  				cc.load("sdk").Admob.getInstance():showBanner(0.5, 0.5)
  			elseif choice == 2 then
  				cc.load("sdk").Admob.getInstance():showBanner(1, 1)
  			end
  			choice = (choice + 1) % 3
		end)

	inc = inc + 1
	ccui.Text:create("Hide Banner", "", fntSize)
		:move(display.cx, display.height - 100 - disY*inc)
		:addTo(self)
		:setTouchEnabled(true)
		:onClick(function ()
  			cc.load("sdk").Admob.getInstance():removeBanner()
		end)

	inc = inc + 1
	ccui.Text:create("Show Full Ads", "", fntSize)
		:move(display.cx, display.height - 100 - disY*inc)
		:addTo(self)
		:setTouchEnabled(true)
		:onClick(function ()
  			cc.load("sdk").Admob.getInstance():showInterstitial()
		end)

	inc = inc + 1
	ccui.Text:create("Show Rank", "", fntSize)
		:move(display.cx, display.height - 100 - disY*inc)
		:addTo(self)
		:setTouchEnabled(true)
		:onClick(function ()
		end)

	inc = inc + 1
	ccui.Text:create("Show Achievement", "", fntSize)
		:move(display.cx, display.height - 100 - disY*inc)
		:addTo(self)
		:setTouchEnabled(true)
		:onClick(function ()
		end)

	inc = inc + 1
	ccui.Text:create("Remove Ads", "", fntSize)
		:move(display.cx, display.height - 100 - disY*inc)
		:addTo(self)
		:setTouchEnabled(true)
		:onClick(function ()
		end)

	inc = inc + 1
	ccui.Text:create("Share Game", "", fntSize)
		:move(display.cx, display.height - 100 - disY*inc)
		:addTo(self)
		:setTouchEnabled(true)
		:onClick(function ()
			cc.load("sdk").Tools.share("Share Test", cc.FileUtils:getInstance():fullPathForFilename("sdk_close_btn.png"))
		end)

	inc = inc + 1
	ccui.Text:create("Rate Game", "", fntSize)
		:move(display.cx, display.height - 100 - disY*inc)
		:addTo(self)
		:setTouchEnabled(true)
		:onClick(function (sender)
			cc.load("sdk").Tools.rate()
		end)
end

function MainScene:onEnterTransitionFinish()
	--test()
end

test = function()
    local bgLayer = display.newLayer(cc.BLACK, display.width, display.height)
        :addTo(display.getRunningScene(), 10)

    local function makeBtn(title)
        local GAP = 6
        local bgColor = cc.c4b(0,0,255,255)
        local btn = ccui.Button:create():setTitleText(title):setTitleFontSize(16):setZoomScale(-0.1)
        local size = btn:getContentSize()
        display.newLayer(bgColor, size.width + GAP * 4, size.height + GAP * 2):move(-GAP * 2, -GAP):addTo(btn, -1, 0)
        return btn
    end

    local camera8 = cc.Camera:create()
    camera8:setDepth(8)
    camera8:setCameraFlag(cc.CameraFlag.USER8)
    bgLayer:addChild(camera8)

    local camera7 = cc.Camera:create()
    camera7:setDepth(7)
    camera7:setCameraFlag(cc.CameraFlag.USER7)
    bgLayer:addChild(camera7)

    local renderTexture = cc.RenderTexture:create(200, 200)
        :setAnchorPoint(0.5, 0.5)
        :move(display.width/2, display.height/2 + 100)
        :clear(100, 100, 100, 100)
        :addTo(bgLayer)

    makeBtn("Camera7 Button visit RenderTexture")
        :move(display.width/2, display.height/2 - 50)
        :addTo(bgLayer)
        :setCameraMask(cc.CameraFlag.USER7)
        :addClickEventListener(function()
            renderTexture:clear(100, 100, 100, 100)
            local text = ccui.Text:create("Text created by \nCamera7 button", "", 16)
                :move(100, 150)
                :setColor(cc.GREEN)

            if cc.Camera:getVisitingCamera() then
                text:setCameraMask(cc.Camera:getVisitingCamera():getCameraFlag())
            end

            renderTexture:begin()
            text:visit()
            renderTexture:endToLua()
        end)

    makeBtn("Camera8 Button visit RenderTexture")
        :move(display.width/2, display.height/2 - 100)
        :addTo(bgLayer)
        :setCameraMask(cc.CameraFlag.USER8)
        :addClickEventListener(function()
            renderTexture:clear(100, 100, 100, 100)
            local text = ccui.Text:create("Text created by \nCamera8 button", "", 16)
                :move(100, 100)
                :setColor(cc.BLUE)
            renderTexture:begin()
            text:visit()
            renderTexture:endToLua()
        end)

    makeBtn("CameraDefault Button visit RenderTexture")
        :move(display.width/2, display.height/2 - 150)
        :addTo(bgLayer)
        :addClickEventListener(function()
            renderTexture:clear(100, 100, 100, 100)
            local text = ccui.Text:create("Text created by \nCameraDefault button", "", 16)
                :move(100, 50)
                :setColor(cc.RED)
            renderTexture:begin()
            text:visit()
            renderTexture:endToLua()
        end)
end

return MainScene
