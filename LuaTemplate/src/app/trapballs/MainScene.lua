local MainScene = class("MainScene", cc.load("mvc").ViewBase)
local test

function MainScene:onCreate()
	local disY = 64
	local inc = 1
	local fntSize = 48

	dump(cc.load("sdk").CsvUtil.parseFile("csv/ball.csv"))

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
			cc.load("sdk").GameCenter.openGameCenterLeaderboardsUI(1)
		end)

	inc = inc + 1
	ccui.Text:create("Submit score", "", fntSize)
		:move(display.cx, display.height - 100 - disY*inc)
		:addTo(self)
		:setTouchEnabled(true)
		:onClick(function ()
			cc.load("sdk").GameCenter.submitScoreToLeaderboard(1, 1000)
		end)

	inc = inc + 1
	ccui.Text:create("Show Achievement", "", fntSize)
		:move(display.cx, display.height - 100 - disY*inc)
		:addTo(self)
		:setTouchEnabled(true)
		:onClick(function ()
			cc.load("sdk").GameCenter.openAchievementUI()
		end)

	inc = inc + 1
	ccui.Text:create("Unlock Achievement", "", fntSize)
		:move(display.cx, display.height - 100 - disY*inc)
		:addTo(self)
		:setTouchEnabled(true)
		:onClick(function ()
			cc.load("sdk").GameCenter.unlockAchievement(1)
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

	inc = inc + 1
	ccui.Text:create("Vib...", "", fntSize)
		:move(display.cx, display.height - 100 - disY*inc)
		:addTo(self)
		:setTouchEnabled(true)
		:onClick(function (sender)
			cc.load("sdk").Tools.vibrate(50)
		end)

	inc = inc + 1
	ccui.Text:create("purchase", "", fntSize)
		:move(display.cx, display.height - 100 - disY*inc)
		:addTo(self)
		:setTouchEnabled(true)
		:onClick(function (sender)
			cc.load("sdk").Billing.purchase(dd.appCommon.skuKeys[1], function (result)
				print("Billing Purchase Result ~ ", result)
			end)
		end)

	inc = inc + 1
	if device.platform == "android" then
		ccui.Text:create("consume", "", fntSize)
			:move(display.cx, display.height - 100 - disY*inc)
			:addTo(self)
			:setTouchEnabled(true)
			:onClick(function (sender)
				cc.load("sdk").Billing.consume(dd.appCommon.skuKeys[1], function (result)
					print("Billing Consume Result ~ ", result)
				end)
			end)
	elseif device.platform == "ios" then
		ccui.Text:create("restore", "", fntSize)
			:move(display.cx, display.height - 100 - disY*inc)
			:addTo(self)
			:setTouchEnabled(true)
			:onClick(function (sender)
				cc.load("sdk").Billing.restore(function (result)
					print("Restore Ok  - ", result)
				end)
			end)
	end
end

return MainScene
