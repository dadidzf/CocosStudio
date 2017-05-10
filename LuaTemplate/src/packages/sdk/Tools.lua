local Tools = {}

local _jniClass = "org/cocos2dx/lua/GameJni"

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

function Tools.vibrate(t) -- ms
	print("Tools.vibrate")
	if device.platform == "ios" then
	elseif device.platform == "android" then
		getLuaBridge().callStaticMethod(_jniClass, "vibrate", {t}, "(I)V")
	end
end

return Tools