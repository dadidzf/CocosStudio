cc.FileUtils:getInstance():setPopupNotify(false)

require "config"
require "cocos.init"

math.randomseed(os.time())

local function initBeforeGame()
	local gameConf  = require("cjson").decode(cc.FileUtils:getInstance():getStringFromFile("src/GameConfig.json"))
	for k, v in pairs(gameConf) do
		dd[k] = v
	end
	--dd.serverConfig.serverHost = "http://127.0.0.1:5000/"
	if device.platform == "ios" then
		dd.appCommon = dd.ios
	elseif device.platform == "android" then
		dd.appCommon = dd.android
	end

	cc.load("sdk").MyAds.init()
end

local function main()
	initBeforeGame()
    require("app.MyApp"):create():run()
end

cc.exports.__G__TRACKBACK__ = function (msg)
    local msg = debug.traceback(msg, 3)
    print(msg)

    if not display.getRunningScene() then
    	return
    end
    
    local MAX_INT = 0x7fffffff
  	local maskLayer = ccui.Layout:create()
  		:setBackGroundColorType(LAYOUT_COLOR_SOLID)
  		:setBackGroundColor(cc.BLACK)
  		:setBackGroundColorOpacity(150)
  		:setTouchEnabled(true)
  		:setSwallowTouches(true)
  		:setGlobalZOrder(MAX_INT)
  		:setContentSize(display.size)
  		:addTo(display.getRunningScene())

	cc.Label:createWithSystemFont(msg, "", 32)
		:setAnchorPoint(cc.p(0, 1))
		:move(0, display.height)
		:setWidth(display.width)
		:addTo(maskLayer)

	local closeBtn = ccui.Button:create("sdk_close_btn.png")
		:setAnchorPoint(cc.p(1, 0))
		:move(display.width, 0)
		:addTo(maskLayer)
		:setTouchEnabled(true)
		:setGlobalZOrder(MAX_INT)
		:onClick(function ()
			maskLayer:removeFromParent()
		end)
end

local status, msg = xpcall(main, __G__TRACKBACK__)
if not status then
    print(msg)
end
