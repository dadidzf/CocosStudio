local MyAds = {}
local cjson = require("cjson")

local _adsDownloadDir = device.writablePath .. "Ads/"
local _configJsonName = "config.json"
local _configJsonPath = _adsDownloadDir.._configJsonName
local _configTable = nil
local _downloader = cc.load("http").Downloader
local _fileUtils = cc.FileUtils:getInstance()
local _jniClass = "org/cocos2dx/lua/GameJni"

local _loadNativeConfig
local _checkUpdate
local _getRemoteVersion
local _downloadResources
local _checkDir
local _createAdsImage
local _ignoreUrl

function MyAds.init()
	_checkDir()
	_loadNativeConfig()
	_getRemoteVersion()
end

function MyAds.showAds(layerOrder)
	if _configTable and _configTable.picArr and #_configTable.picArr > 0 then
		if not layerOrder then layerOrder = 0x7fffffff end
		local runningScene = display.getRunningScene()
		assert(runningScene:getChildByTag(layerOrder) == nil, "invalid layerOrder")

		local layer = ccui.Widget:create()
					:setAnchorPoint(cc.p(0, 0))
					:setContentSize(display.size)
					:addTo(runningScene)
					:setTag(layerOrder)
					:setSwallowTouches(true)
					:setTouchEnabled(true)

		layer:onClick(function ()
			display:getRunningScene():getChildByTag(layerOrder):removeFromParent()
		end)

		local picCount = #_configTable.picArr
		local start = math.random(picCount)
		for i = start, picCount + start - 1 do
			local picAttri = _configTable.picArr[i > picCount and (i - picCount) or i]
			local picPath = _adsDownloadDir .. picAttri.picMd5
			if _fileUtils:isFileExist(picPath) then
				local adsImage = _createAdsImage(picPath, picAttri.jumpUrl, layerOrder)
				adsImage:setScale(_configTable.scale)
				adsImage:setPosition(display.cx, display.cy)
				layer:addChild(adsImage)
				break
			end
		end
	end
end

function _createAdsImage(picPath, jumpUrl, layerOrder)
	local adsImage = ccui.ImageView:create(picPath)	
				   :setTouchEnabled(true)
	adsImage:onClick(function ()
		cc.Application:getInstance():openURL(jumpUrl)
	end)

	local closeBtn = ccui.Button:create("sdk_close_btn.png")
	closeBtn:setPosition(cc.p(adsImage:getContentSize().width, adsImage:getContentSize().height))
	closeBtn:setScale(1/_configTable.scale)
	adsImage:addChild(closeBtn)

	closeBtn:onClick(function ()
		display:getRunningScene():getChildByTag(layerOrder):removeFromParent()
	end)

	return adsImage
end

-- check if the dir "Ads" is created for ads resources
function _checkDir()
	if not _fileUtils:isDirectoryExist(_adsDownloadDir) then
		_fileUtils:createDirectory(_adsDownloadDir)
	end
end

function _ignoreUrl(jumpUrl)
	if device.platform == "android" then
		local packageName = string.gsub(jumpUrl, [[https://play%.google%.com/store/apps/details%?id=]], "")
		print("_ignoreUrl - ", packageName)
		local _, isExist = getLuaBridge().callStaticMethod(_jniClass, "checkPackage", {packageName}, "(Ljava/lang/String;)Z")
		if isExist then
			return true
		else
			return false
		end
	end

	return false
end

-- return native config version
function _loadNativeConfig()
	if _fileUtils:isFileExist(_configJsonPath) then
		local configJsonTb = cjson.decode(_fileUtils:getStringFromFile(_configJsonPath))
		if configJsonTb then
			_configTable = {}
			_configTable.version = configJsonTb.version
			_configTable.scale = configJsonTb.scale
			if configJsonTb.picArr then
				_configTable.picArr = {}
				local i = 1
				for _, v in ipairs(configJsonTb.picArr) do
					if not _ignoreUrl(v[2]) then
						_configTable.picArr[i] = {}
						_configTable.picArr[i].picName = v[1]
						_configTable.picArr[i].jumpUrl = v[2]
						_configTable.picArr[i].picMd5 = v[3]
						i = i + 1
					end
				end
			end

			return _configTable.version
		end
	else
		return nil
	end
end

-- compare native version and remote version
function _checkUpdate(remoteVersion)
	local nativeVersion = _configTable and _configTable.version
	if (not nativeVersion) or nativeVersion < remoteVersion then
		_downloader.downloadData(
			dd.serverConfig.serverHost .. dd.serverConfig.adsConfURL .. dd.appCommon.adsRequestAppName, 
			function (result, retData)
				if result then
					print("~Download remote config file success !")
					local fd = assert(io.output(_configJsonPath))
					io.write(retData)
					io.flush()
					io.close()
					_loadNativeConfig()
					_downloadResources()	
				end
			end
		)
	else
		_downloadResources()
	end
end

function _getRemoteVersion()
	_downloader.downloadData(dd.serverConfig.serverHost .. dd.serverConfig.adsVerURL, 
		function (result, retData)
			if result then
				local remoteVersion = tonumber(retData)
				print("~Remote Version is ", remoteVersion)	
				if remoteVersion then
					_checkUpdate(remoteVersion)
				end
			else
				print("~Failed to get Remote Version !")
			end
		end
	)
end

function _downloadResources()
	if _configTable and _configTable.picArr then
		for _, picAttri in ipairs(_configTable.picArr) do
			if not _fileUtils:isFileExist(_adsDownloadDir .. picAttri.picMd5) then
				_downloader.downloadFile(
					dd.serverConfig.serverHost .. dd.serverConfig.adsPicURL .. picAttri.picName,
					_adsDownloadDir .. picAttri.picMd5,
					function (result)
						print(string.format("~Download file %s %s !", picAttri.picName, result and "success" or "failed"))
					end
					)
			end
		end
	end	
end


return MyAds