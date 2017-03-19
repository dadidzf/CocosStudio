
cc.FileUtils:getInstance():setPopupNotify(false)

require "config"
require "cocos.init"

math.randomseed(os.time())

local function main()
	local GameConfig = require("cjson").decode(cc.FileUtils:getInstance():getStringFromFile("GameConfig.json"))
	dd.serverConfig = GameConfig.serverConfig
	dd.isSelfAdsEnabled = GameConfig.isSelfAdsEnabled
	dd.appName = GameConfig.appName

	if dd.isSelfAdsEnabled then
		cc.load("sdk").MyAds.init()
	end

    require("app.MyApp"):create():run()
end

local status, msg = xpcall(main, __G__TRACKBACK__)
if not status then
    print(msg)
end
