local Tools = {}

local _jniClass = "org/cocos2dx/lua/GameJni"

local function getLuaBridge()
	if device.platform == "ios" then
		return require("cocos.cocos2d.luaoc")
	elseif device.platform == "android" then
		return require("cocos.cocos2d.luaj")
	else
		error("not support platform")
	end
end

function Tools.rate()
	print("Tools.rate")
	if device.platform == "ios" or device.platform == "android" then
		cc.Application:getInstance():openURL(dd.appCommon.rateUrl)
	else
		error("not support for platform")
	end
end

function Tools.share(shareTitle, picPath)
	print("Tools.share")	
	if device.platform == "ios" then
		local args = {
			url = dd.appCommon.shareUrl,
			title = shareTitle,
			pic = picPath
		}
		getLuaBridge().callStaticMethod("ToolsController", "gameShareLua", args)	
	elseif device.platform == "android" then
		getLuaBridge().callStaticMethod(_jniClass, "gameShare", 
			{shareTitle, dd.appCommon.shareUrl})
	end
end

return Tools