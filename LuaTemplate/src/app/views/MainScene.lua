
local MainScene = class("MainScene", cc.load("mvc").ViewBase)

function MainScene:onCreate()
    -- add background image
    display.newSprite("HelloWorld.png")
        :move(display.center)
        :addTo(self)

    -- add HelloWorld label
    cc.Label:createWithSystemFont("Hello World", "Arial", 40)
        :move(display.cx, display.cy + 200)
        :addTo(self)
	
	self:downloaderTest() 
end

local index = 0 
function MainScene:downloaderTest()
	local button = ccui.Button:create("sdk_close_btn.png")
		:move(cc.pAdd(display.center, cc.p(0, -200)))
		:addTo(self)

	index = index + 1
	local callBack = function ( ... )
		local downloader = require("packages.http.Downloader")
		local filePath = device.writablePath .. "christmas" .. tostring(index) .. ".jpg"
		print("Start download -- ", filePath)
		local taskId = downloader.downloadFile(
			"https://www.yongwuart.com/christmas.jpg", 
			filePath,
			function (result, data)
				print("download ended -- ", result, data)
			end
			)

		downloader.setProgressCallBack(taskId, function (bytesRec, totalBytesRec, totalBytesExpected)
			print("download progress -- ", totalBytesRec*100/totalBytesExpected)
		end)
	end

	button:onClick(callBack)
end

return MainScene
