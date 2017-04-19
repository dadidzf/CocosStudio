local Admob = class("Admob")

--[[
	Admob for IOS
--]]
local AdmobIos = class("AdmobIos", Admob)

function AdmobIos:ctor()
	self.m_luaoc = require("cocos.cocos2d.luaoc") 
end

-- posY is the ratio of Y in device height, range from 0 to 1
function AdmobIos:showBanner(posY, anchorY)
	print("AdmobIos:showBanner")
 	local args = {
    	bannerAdsId = "ca-app-pub-3940256099942544/2934735716",
    	posY = 0,
    	anchorY = 0
	}
	self.m_luaoc.callStaticMethod("AdmobController", "initBannerLua", args)
end

function AdmobIos:initInterstitial()
	print("AdmobIos:initInterstitial")
 	local args = {
    	interstitialAdsId = "ca-app-pub-3940256099942544/4411468910",
	}
	self.m_luaoc.callStaticMethod("AdmobController", "initInterstitialLua", args)
end

function AdmobIos:removeBanner()
	print("AdmobIos:removeBanner")
	self.m_luaoc.callStaticMethod("AdmobController", "removeBannerLua")
end

function AdmobIos:showInterstitial()
	print("AdmobIos:showInterstitial")
	self.m_luaoc.callStaticMethod("AdmobController", "showInterstitialLua")
end

--[[
	Admob for Android
--]]
local AdmobAndroid = class("AdmobAndroid", Admob)

function AdmobAndroid:ctor()
	self.m_luaj = require("cocos.cocos2d.luaj")
end

function AdmobAndroid:showBanner()
	print("AdmobAndroid:showBanner")
end

function AdmobAndroid:showInterstitial()
	print("AdmobAndroid:showInterstitial")
end

function AdmobAndroid:removeBanner()
	print("AdmobAndroid:removeBanner")
end

function AdmobAndroid:initInterstitial()
	print("AdmobAndroid:initInterstitial")
end

--[[
	Admob Base
--]]
local _instance = nil

function Admob.getInstance()
	if _instance == nil then
		if device.platform == "ios" then
			_instance = AdmobIos.new()
		elseif device.platform == "android" then
			_instance = AdmobAndroid.new()
		else
			assert(false, "Admob not support for ", device.platform)
		end
		
		_instance:initInterstitial()
	end

	return _instance
end

function Admob:ctor()
end

function Admob:showBanner()
end

function Admob:showInterstitial()

end

function Admob:removeBanner()
end

function Admob:initInterstitial()
	
end

return Admob