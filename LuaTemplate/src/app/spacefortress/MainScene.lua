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

function MainScene:onRank()
    cc.load("sdk").GameCenter.openGameCenterLeaderboardsUI(1)
end

function MainScene:onRate()
    dd.PlayBtnSound()
    cc.load("sdk").Tools.rate()
end

function MainScene:onShare()
    dd.PlayBtnSound()
    cc.load("sdk").Tools.share(dd.GetTips(dd.Constants.SHARE_TIPS), 
        cc.FileUtils:getInstance():fullPathForFilename("512.png"))
end

function MainScene:onSound()
end

function MainScene:onMusic()
end

return MainScene
