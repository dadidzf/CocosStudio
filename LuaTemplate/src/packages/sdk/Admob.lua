local Admob = class("Admob")

--[[
	Admob for IOS
--]]
local AdmobIos = class("AdmobIos", Admob)

function AdmobIos:ctor()
	self.m_luaoc = require("cocos.cocos2d.luaoc") 
end

-- posY is the ratio of Y in device height, range from 0 to 1
function AdmobIos:showBanner(pos, anchor)
	print("AdmobIos:showBanner")
 	local args = {
    	posY = pos,
    	anchorY = anchor
	}
	self.m_luaoc.callStaticMethod("AdmobController", "initBannerLua", args)
end

function AdmobIos:initAds()
	print("AdmobIos:initAds")
 	local args = {
    	interstitialAdsId = dd.AdsConfig.iosAdmobInterstitialId,
    	bannerAdsId = dd.AdsConfig.iosAdmobBannerId
	}
	self.m_luaoc.callStaticMethod("AdmobController", "initAdsLua", args)
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
	Admob for Androida
--]]
local AdmobAndroid = class("AdmobAndroid", Admob)

function AdmobAndroid:ctor()
	self.m_luaj = require("cocos.cocos2d.luaj")
	self.m_jniClass = "org/cocos2dx/ads/GameJni"
end

function AdmobAndroid:showBanner(posY, anchorY)
	print("AdmobAndroid:showBanner")
	self.m_luaj.callStaticMethod(self.m_jniClass, "showBanner", {posY, anchorY})
end

function AdmobAndroid:showInterstitial()
	print("AdmobAndroid:showInterstitial")
	self.m_luaj.callStaticMethod(self.m_jniClass, "showFullAd", {})
end

function AdmobAndroid:removeBanner()
	print("AdmobAndroid:removeBanner")
	self.m_luaj.callStaticMethod(self.m_jniClass, "removeBanner", {})
end

function AdmobAndroid:initAds()
	print("AdmobAndroid:initAds")
	self.m_luaj.callStaticMethod(self.m_jniClass, "initAds", 
		{dd.AdsConfig.androidAdmobBannerId, dd.AdsConfig.androidAdmobInterstitialId})
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
		
		_instance:initAds()
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

function Admob:initAds()
	
end

return Admob