local MainScene = class("MainScene", cc.load("mvc").ViewBase)
local Client = import ".network.Client"

function MainScene:onCreate()
	local disY = 80
	local inc = 1
	local fntSize = 64

	dd.NetworkClient:connect("192.168.18.112", 8080)
	ccui.Text:create("Login", "", fntSize)
		:move(display.cx, display.height*0.9)
		:addTo(self)
		:setTouchEnabled(true)
		:onClick(function ()
			print("Login -- ")
			dd.NetworkClient:sendBlockMsg("login.login", {acount = "123456", passwd = "123456"}, function ( ... )
				print("xxxxxxxxxxxxxxxxxx")
				dump({...})
			end)
		end)

	ccui.Text:create("Register", "", fntSize)
		:move(display.cx, display.height*0.65)
		:addTo(self)
		:setTouchEnabled(true)
		:onClick(function ()
			print("Register --")
			dd.NetworkClient:sendQuickMsg("login.login", {acount = "123456", passwd = "123456"})
		end)
	
	ccui.Text:create("CreateRoom", "", fntSize)
		:move(display.cx, display.height*0.4)
		:addTo(self)
		:setTouchEnabled(true)
		:onClick(function ()
			print("CreateRoom -- ")
		end)


	ccui.Text:create("EnterRoom", "", fntSize)
		:move(display.cx, display.height*0.15)
		:addTo(self)
		:setTouchEnabled(true)
		:onClick(function ()
			print("EnterRoom -- ")
		end)
end

return MainScene
