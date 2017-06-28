cc.FileUtils:getInstance():setPopupNotify(false)

require "socket"
require "config"
require "cocos.init"

local function initBeforeGame()
    local gameConf  = require("cjson").decode(cc.FileUtils:getInstance():getStringFromFile(
		string.format("src/app/%s/%s_config.json", DD_WORKING_GAME_NAME, DD_WORKING_GAME_NAME)))
	for k, v in pairs(gameConf) do
		dd[k] = v
	end
	--dd.serverConfig.serverHost = "http://192.168.0.100:5000/"
	if device.platform == "ios" then
		dd.appCommon = dd.ios
	elseif device.platform == "android" then
		dd.appCommon = dd.android
	end

    dd.scheduler = cc.Director:getInstance():getScheduler()

    if not cc.load("sdk").Tools.verifyPackage() then
        print("verifyPackage Error !")
        while(true) do
        end
    end

    cc.load("sdk").MyAds.init()
end

local function main()
	initBeforeGame()
    local workingDir = "app." .. DD_WORKING_GAME_NAME
    require(workingDir .. ".MyApp"):create({viewsRoot = workingDir}):run()
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

cc.exports.getLuaBridge = function ()
    if device.platform == "ios" then
        return require("cocos.cocos2d.luaoc")
    elseif device.platform == "android" then
        return require("cocos.cocos2d.luaj")
    else
        error("not support platform")
    end
end


local status, msg = xpcall(main, __G__TRACKBACK__)
if not status then
    print(msg)
end
