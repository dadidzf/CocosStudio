local MainScene = class("MainScene", cc.load("mvc").ViewBase)
local InputRoomNumber = import ".common.InputRoomNumber"
local PdkScene = import ".pdk.PdkScene"
local PlayersInfo = import ".common.PlayersInfo"

MainScene.RESOURCE_FILENAME = "MainScene.csb"
MainScene.RESOURCE_BINDING = {
	["button_create_room"] = {varname = "m_btnCreateRoom", events = {{ event = "click", method = "onCreateRoom" }}},
	["button_join_room"] = {varname = "m_btnJoinRoom", events = {{ event = "click", method = "onJoinRoom" }}},
	["herochess_other_uimg_bg_5"] = {varname = "m_imgBgHead"}
}

function MainScene:onCreate()
    local resourceNode = self:getResourceNode()
    resourceNode:setContentSize(display.size)
    ccui.Helper:doLayout(resourceNode)

    self.m_myInfo = dd.PlayersInfo:getMyInfo()
    dd.PlayersInfo:getHeadImgPath(self.m_myInfo, function (headFile)
    	print("xxx -", headFile)
    	if not tolua.isnull(self.m_imgBgHead) then
    		local bgSize = self.m_imgBgHead:getContentSize()
			local headImg = ccui.ImageView:create(headFile)	
				:move(bgSize.width/2, bgSize.height/2)
				:addTo(self.m_imgBgHead, -1)
			cc.load("sdk").Tools.scaleSpriteToBox(headImg, bgSize)
		end
    end)
end

function MainScene:onCreateRoom()
	dd.NetworkClient:sendBlockMsg("room.create_room", {game_id = 1}, function ( ... )
		local pdkScene = PdkScene:create(...)
		pdkScene:showWithScene()
	end)
end

function MainScene:onJoinRoom()
	local inputNode = InputRoomNumber:create(function (roomNumber)
		if roomNumber then
			dd.NetworkClient:sendBlockMsg("room.join_room", {room_id = roomNumber}, function ( ... )
				local pdkScene = PdkScene:create(...)
				pdkScene:showWithScene()
			end)
		end
	end)

	inputNode:move(display.cx, display.cy)
	self:addChild(inputNode, 1)
end

return MainScene
