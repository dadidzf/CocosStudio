local MainScene = class("MainScene", cc.load("mvc").ViewBase)
local Client = import ".network.Client"
local InputRoomNumber = import ".common.InputRoomNumber"

MainScene.RESOURCE_FILENAME = "MainScene.csb"
MainScene.RESOURCE_BINDING = {
	["button_create_room"] = {varname = "m_btnCreateRoom", events = {{ event = "click", method = "onCreateRoom" }}},
	["button_join_room"] = {varname = "m_btnJoinRoom", events = {{ event = "click", method = "onJoinRoom" }}},
}

function MainScene:onCreate()
    local resourceNode = self:getResourceNode()
    resourceNode:setContentSize(display.size)
    ccui.Helper:doLayout(resourceNode)

	dd.NetworkClient:register("room.user_enter", function ( ... )
		dump({...})
	end)
end

function MainScene:onCreateRoom()
	dd.NetworkClient:sendBlockMsg("room.create_room", {game_id = 1}, function ( ... )
		dump({...})
	end)
end

function MainScene:onJoinRoom()
	local inputNode = InputRoomNumber:create(function (roomNumber)
		if roomNumber then
			dd.NetworkClient:sendBlockMsg("room.join_room", {room_id = roomNumber}, function ( ... )
				dump({...})
			end)
		end
	end)

	inputNode:move(display.cx, display.cy)
	self:addChild(inputNode, 1)
end

return MainScene
