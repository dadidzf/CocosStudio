local MyAds = {}
local cjson = require("cjson")

local _adsDownloadDir = device.writablePath .. "Ads/"
local _configJsonName = "config.json"
local _configJsonPath = _adsDownloadDir.._configJsonName
local _configTable = nil
local _downloader = cc.load("http").Downloader
local _fileUtils = cc.FileUtils:getInstance()

local loadNativeConfig
local checkUpdate
local getRemoteVersion
local downloadResources
local checkDir

function MyAds.init()
	checkDir()
	getRemoteVersion()
end

function MyAds.showAds()
	
end

-- check if the dir "Ads" is created for ads resources
function checkDir()
	if not _fileUtils:isDirectoryExist(_adsDownloadDir) then
		_fileUtils:createDirectory(_adsDownloadDir)
	end
end

-- return native config version
function loadNativeConfig()
	if _fileUtils:isFileExist(_configJsonPath) then
		_configTable = cjson.decode(_fileUtils:getStringFromFile(_configJsonPath))
		if _configTable then
			return _configTable.version
		end
	else
		return nil
	end
end

-- compare native version and remote version
function checkUpdate(remoteVersion)
	local nativeVersion = loadNativeConfig()
	if (not nativeVersion) or nativeVersion < remoteVersion then
		_downloader.downloadData(
			dd.serverConfig.serverHost .. dd.serverConfig.adsConfURL .. dd.appName, 
			function (result, retData)
				if result then
					print("~Download remote config file success !")
					local fd = assert(io.output(_configJsonPath))
					io.write(retData)
					io.flush()
					io.close()
					_configTable = cjson.decode(_fileUtils:getStringFromFile(_configJsonPath))
					downloadResources()	
				end
			end
		)
	else
		downloadResources()
	end
end

function getRemoteVersion()
	_downloader.downloadData(dd.serverConfig.serverHost .. dd.serverConfig.adsVerURL, 
		function (result, retData)
			if result then
				local remoteVersion = tonumber(retData)
				print("~Remote Version is ", remoteVersion)	
				if remoteVersion then
					checkUpdate(remoteVersion)
				end
			else
				print("~Failed to get Remote Version !")
			end
		end
	)
end

function downloadResources()
	if _configTable and _configTable.picArr then
		for _, picAttri in ipairs(_configTable.picArr) do
			local picName = picAttri[1]
			local jumUrl = picAttri[2] 
			local picMd5 = picAttri[3]

			if not _fileUtils:isFileExist(_adsDownloadDir .. picMd5) then
				_downloader.downloadFile(
					dd.serverConfig.serverHost .. dd.serverConfig.adsPicURL .. picName,
					_adsDownloadDir .. picMd5,
					function (result)
						print(string.format("~Download file %s %s !", picName, result and "success" or "failed"))
					end
					)
			end
		end
	end	
end


return MyAds