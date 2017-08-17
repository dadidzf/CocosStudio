local Admob = class("Admob")

--[[
	Admob for IOS
--]]
local AdmobIos = class("AdmobIos", Admob)

function AdmobIos:ctor()
	self.super.ctor(self)
	self.m_luaoc = require("cocos.cocos2d.luaoc") 
end

-- posY is the ratio of Y in device height, range from 0 to 1
function AdmobIos:showBanner(pos, anchor)
	print("AdmobIos:showBanner")
	
	if self.m_isAdsRemoved then
		return 
	end
 	local args = {
    	posY = pos,
    	anchorY = anchor
	}
	self.m_luaoc.callStaticMethod("AdmobController", "initBannerLua", args)
end

function AdmobIos:initAds(banner, interstitial, rewardVideo)
	print("AdmobIos:initAds")

	if not rewardVideo then
		rewardVideo = ""
	end

	local rewardCallBack = function (willRewardUser)
		if self.m_rewardVideoCallBack then
			self.m_rewardVideoCallBack(willRewardUser)
		end
	end

 	local args = {
    	interstitialAdsId = interstitial,
    	bannerAdsId = banner,
    	rewardVideoId = rewardVideo,
    	functionId = rewardCallBack
	}
	self.m_luaoc.callStaticMethod("AdmobController", "initAdsLua", args)
end

function AdmobIos:removeBanner()
	print("AdmobIos:removeBanner")
	self.m_luaoc.callStaticMethod("AdmobController", "removeBannerLua")
end

function AdmobIos:showInterstitial()
	print("AdmobIos:showInterstitial")
	if self.m_isAdsRemoved then
		return 
	end
	self.m_luaoc.callStaticMethod("AdmobController", "showInterstitialLua")
end

function AdmobIos:showRewardVideo(callBack)
	print("AdmobIos:showRewardVideo")
	self.m_luaoc.callStaticMethod("AdmobController", "showRewardVideoLua")
	self.m_rewardVideoCallBack = callBack
end

--[[
	Admob for Androida
--]]
local AdmobAndroid = class("AdmobAndroid", Admob)

function AdmobAndroid:ctor()
	self.super.ctor(self)
	self.m_luaj = require("cocos.cocos2d.luaj")
	self.m_jniClass = "org/cocos2dx/lua/GameJni"
end

function AdmobAndroid:showBanner(posY, anchorY)
	print("AdmobAndroid:showBanner")
	if self.m_isAdsRemoved then
		return 
	end
	self.m_luaj.callStaticMethod(self.m_jniClass, "showBanner", {posY, anchorY})
end

function AdmobAndroid:showInterstitial()
	print("AdmobAndroid:showInterstitial")
	if self.m_isAdsRemoved then
		return 
	end
	self.m_luaj.callStaticMethod(self.m_jniClass, "showFullAd", {})
end

function AdmobAndroid:removeBanner()
	print("AdmobAndroid:removeBanner")
	self.m_luaj.callStaticMethod(self.m_jniClass, "removeBanner", {})
end

function AdmobAndroid:initAds(banner, interstitial)
	print("AdmobAndroid:initAds")
	self.m_luaj.callStaticMethod(self.m_jniClass, "initAds", 
		{banner, interstitial})
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
			print("Admob not support for ", device.platform)
			_instance = Admob.new()
			return _instance
		end
		
		_instance:initAds(dd.appCommon.admobBannerId, dd.appCommon.admobInterstitialId, dd.appCommon.admobRewardVideoId)
	end

	return _instance
end

function Admob:ctor()
	self.m_isAdsRemoved = false 
	self.m_rewardVideoCallBack = nil  
end

function Admob:setAdsRemoved(val)
	self.m_isAdsRemoved = val
	self:removeBanner()
end

function Admob:showBanner()
end

function Admob:showInterstitial()

end

function Admob:showRewardVideo()	

end

function Admob:removeBanner()
end

function Admob:initAds()
	
end

return Admob