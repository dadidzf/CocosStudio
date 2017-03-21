cc.FileUtils:getInstance():setPopupNotify(false)

require "config"
require "cocos.init"
require "GameConfig"

math.randomseed(os.time())

local function main()
	if dd.isSelfAdsEnabled then
		cc.load("sdk").MyAds.init()
	end

    require("app.MyApp"):create():run()
end

local status, msg = xpcall(main, __G__TRACKBACK__)
if not status then
    print(msg)
end
