local Tools = {}

local _jniClass = "org/cocos2dx/lua/GameJni"
local _GamePlayCount = cc.UserDefault:getInstance():getIntegerForKey("gameplaycount", 0)
_GamePlayCount = _GamePlayCount + 1
cc.UserDefault:getInstance():setIntegerForKey("gameplaycount", _GamePlayCount)

function Tools.getGamePlayCount()
	return _GamePlayCount
end

function Tools.verifyPackage()
	if device.platform == "android" then
		local ret, packageName = getLuaBridge().callStaticMethod(_jniClass, "getPackageName", {}, "()Ljava/lang/String;")
		print("Tools.verifyPackage - ", packageName)
		if packageName ~= dd.appCommon.packageName then
			return false
		else
			return true
		end
	else
		return true
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

function Tools.vibrate(t) -- ms
	print("Tools.vibrate")
	if device.platform == "ios" then
	elseif device.platform == "android" then
		getLuaBridge().callStaticMethod(_jniClass, "vibrate", {t}, "(I)V")
	end
end

local _isMultiLanguageSupported = false
function Tools.setMultiLanguageSupported(val)
	_isMultiLanguageSupported = val
end

function Tools.getLanguageDependPathForRes(resName)
	if _isMultiLanguageSupported then
		local name = string.format("%s/%s", device.language, resName)
		if cc.FileUtils:getInstance():isFileExist(name) then
			return name
		else
			return string.format("en/%s", resName)
		end
	else
		return resName
	end
end

return Tools