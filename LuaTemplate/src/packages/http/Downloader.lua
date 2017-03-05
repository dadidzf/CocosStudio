local Downloader = {}

-- use singletom instance to hanlder all downloaders
local _downloader = dd.Downloader:new() 
local _taskId = 0
local _taskIdSet = {}
local _taskIdMapCallback = {}
local _taskIdMapProgressCallBack = {}
local _task

--[[
@ callBack(result) -- it called when the download finished, 'result' can be true or false
--]]
function Downloader.downloadFile(url, absolutePath, callback)
	assert(type(url) == "string", "Downloader.downloadFile, wrong args, \
		make sure you use '.' not ':' to call this function !")
	_taskId = _taskId + 1
	_taskIdMapCallback[_taskId] = callback
	_taskIdSet[_taskId] = true
	_downloader:downloadFile(url, absolutePath, tostring(_taskId))

	return _taskId
end

--[[
@ callBack(result, data) -- it called when the download finished, 'result' can be true or false \
	-- 'data' is a string value
--]]
function Downloader.downloadData(url, callback)
	assert(type(url) == "string", "Downloader.downloadData, wrong args, \
		make sure you use '.' not ':' to call this function !")
	_taskId = _taskId + 1
	_taskIdMapCallback[_taskId] = callback
	_taskIdSet[_taskId] = true
	_downloader:downloadData(url, tostring(_taskId))

	return _taskId
end

--[[
@ progressCallBack(bytesRecevied, totalBytesRecevied, totalBytesExpected) \
	-- it's called when the download is on progress, the meaning of the params are just as it's named
--]]
function Downloader.setProgressCallBack(taskId, progressCallBack)
	assert(type(taskId) == "number", "Downloader.setProgressCallBack, wrong args, \
		make sure you use '.' not ':' to call this function !")
	assert(_taskIdSet[taskId] == true, "Downloader.setProgressCallBack, wrong taskId !")
	assert(progressCallBack ~= nil, " Downloader.setProgressCallBack, progressCallBack is nil!")

	_taskIdMapProgressCallBack[taskId] = progressCallBack
end

function Downloader.taskCallBack(...)
	local args = {...}
	local callBackName = args[1]
	local taskId = tonumber(args[2])
	local resultCallBack = _taskIdMapCallback[taskId] 
	if callBackName == "onProgress" then
		local progressCallBack = _taskIdMapProgressCallBack[_taskId]
		if progressCallBack then progressCallBack(args[3], args[4], args[5]) end
	else
		if callBackName == "onFileSuccess" then
			if resultCallBack then resultCallBack(true) end
		elseif callBackName == "onDataSuccess"  then
			if resultCallBack then resultCallBack(true, args[3]) end
		elseif callBackName == "onTaskFailed" then
			if resultCallBack then resultCallBack(false) end
		end

		_taskIdMapCallback[taskId] = nil
		_taskIdMapProgressCallBack[taskId] = nil
		_taskIdSet[taskId] = nil
	end
end

-- registCallBack is a static method for class dd::Downloader
dd.Downloader:registCallBack(Downloader.taskCallBack)

return Downloader
