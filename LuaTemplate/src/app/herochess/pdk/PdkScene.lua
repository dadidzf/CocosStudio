local PdkScene = class("PdkScene", cc.load("mvc").ViewBase)
local HandCardLayer = import(".HandCardLayer")

PdkScene.RESOURCE_FILENAME = "pdk/PdkScene.csb"
PdkScene.RESOURCE_BINDING = {
    ["bg_head_mine"] = {varname = "m_bgHeadMine"},
    ["bg_head_mine.nickname"] = {varname = "m_txtNickNameMine"},
    ["bg_head_mine.img_ready_go"] = {varname = "m_imgReadyGoMine"},

    ["bg_head_left"] = {varname = "m_bgHeadLeft"},
    ["bg_head_left.nickname"] = {varname = "m_txtNickNameLeft"},
    ["bg_head_left.img_ready_go"] = {varname = "m_imgReadyGoLeft"},

    ["bg_head_right"] = {varname = "m_bgHeadRight"},
    ["bg_head_right.nickname"] = {varname = "m_txtNickNameRight"},
    ["bg_head_right.img_ready_go"] = {varname = "m_imgReadyGoRight"},

    ["btn_invite_left"] = {varname = "m_btnInviteLeft", events = {{ event = "click", method = "onInvite" }}},
    ["btn_invite_right"] = {varname = "m_btnInviteRight", events = {{ event = "click", method = "onInvite" }}},
    ["btn_invite_mine"] = {varname = "m_btnInviteMine", events = {{ event = "click", method = "onInvite" }}},

    ["node_mine_out_card.img_pass"] = {varname = "m_imgPassMine"},
    ["node_mine_out_card.node_card"] = {varname = "m_nodeCardMine"},
    ["node_mine_out_card.btn_out_card"] = {varname = "m_btnOutCard", events = {{ event = "click", method = "onOutCard" }}},
    ["node_mine_out_card.btn_ready"] = {varname = "m_btnReady", events = {{ event = "click", method = "onReady" }}},
    ["node_hand_card"] = {varname = "m_nodeHandCardMine"},

    ["node_left_out_card.img_pass"] = {varname = "m_imgPassLeft"},
    ["node_left_out_card.node_card"] = {varname = "m_nodeCardLeft"},

    ["node_right_out_card.img_pass"] = {varname = "m_imgPassRight"},
    ["node_right_out_card.node_card"] = {varname = "m_nodeCardRight"},

    ["bg_title_board.bg_room_info.txt_room_number"] = {varname = "m_txtRoomNumber"},
    ["bg_title_board.bg_room_info.txt_match_round"] = {varname = "m_txtRoomRound"},
}

local _GAME_STATUS = {
    BEFORE_GAME = 1,
    IN_GAME = 2
}

local _LOCAL_SEATS = {
    LEFT = 1,
    MINE = 2,
    RIGHT = 3
}

--[[
    roomInfo = {
        room_id = xxx,
        room_conf = xxx,
        owner_account = xxx,
        player_list = xxx,
        online_list = xxx,
        ready_list = xxx 
    }
--]]

function PdkScene:ctor(roomInfo)
    dump(roomInfo, "PdkScene:ctor")
    self.super.ctor(self)

    self.m_roomInfo = roomInfo
    self.m_myInfo = dd.PlayersInfo:getMyInfo()
    self.m_myAccount = self.m_myInfo.account
    self.m_gameStatus = _GAME_STATUS.BEFORE_GAME

    self:initMsgHandlers()
    self:initUI()
end

function PdkScene:initMsgHandlers()
    dd.NetworkClient:register("room.user_enter", handler(self, self.msgUserEnter))
    dd.NetworkClient:register("room.user_ready", handler(self, self.msgUserReady))
    dd.NetworkClient:register("room.user_exit", handler(self, self.msgUserExit))
end

function PdkScene:updateLocalSeats()
    self.m_accountMapLocalSeat = {}
    self.m_serverSeatMapLocalSeat = {}
    self.m_localSeatMapServerSeat = {}
    self.m_localSeatMapPlayerInfo = {}

    self.m_accountMapLocalSeat[self.m_myAccount] = _LOCAL_SEATS.MINE
    self.m_localSeatMapPlayerInfo[_LOCAL_SEATS.MINE] = self.m_myInfo

    local myServerSeat
    local myLocalSeat = _LOCAL_SEATS.MINE

    for seat, player in pairs(self.m_roomInfo.player_list) do
        if player.account == self.m_myAccount then
            myServerSeat = seat
            break
        end
    end

    if myServerSeat then
        for i = 1, table.nums(_LOCAL_SEATS) do
            local serverSeat = (3 + i - myLocalSeat + myServerSeat - 1) % 3 + 1
            self.m_localSeatMapServerSeat[i] = serverSeat
            self.m_serverSeatMapLocalSeat[serverSeat] = i
        end

        dump(self.m_localSeatMapServerSeat)
        dump(self.m_serverSeatMapLocalSeat)

        local player_list = self.m_roomInfo.player_list
        for serverSeat = 1, 3 do
            local player = player_list[serverSeat]
            if player then
                local localSeat = self.m_serverSeatMapLocalSeat[serverSeat]
                self.m_accountMapLocalSeat[player.account] = localSeat
                dd.PlayersInfo:getInfoByAccount(player.account, function (info)
                    self.m_localSeatMapPlayerInfo[localSeat] = info
                end)
            end
        end
    else
        assert(false)
    end
end

function PdkScene:initUI()
    local resourceNode = self:getResourceNode()
    resourceNode:setContentSize(display.size)
    ccui.Helper:doLayout(resourceNode)

    self:resetDisplay()
    self:updateBeforeGameDisplay()

    self.m_txtRoomNumber:setString("房间号:"..tostring(self.m_roomInfo.room_id))
    print("PdkScene:initUI", self.m_myInfo.nick_name)
    self.m_txtNickNameMine:setString(self.m_myInfo.nick_name)

    self:test()
end

function PdkScene:test()
    local handCard = HandCardLayer:create()
        :addTo(self.m_nodeHandCardMine)
    handCard:initCards(
        {
            0x03, 0x04, 0x05, 0x06, 
            0x11, 0x13, 0x14, 0x15, 
            0x2a, 0x2b, 0x2c, 0x2d, 
            0x31, 0x32, 0x33, 0x34,
        }
    )
end

function PdkScene:resetDisplay()
    self.m_bgHeadLeft:setVisible(false)
    self.m_bgHeadRight:setVisible(false)

    self.m_btnInviteLeft:setVisible(false)
    self.m_btnInviteMine:setVisible(false)
    self.m_btnInviteRight:setVisible(false)

    self.m_imgPassMine:setVisible(false)
    self.m_imgPassRight:setVisible(false)
    self.m_imgPassLeft:setVisible(false)

    self.m_imgReadyGoRight:setVisible(false)
    self.m_imgReadyGoMine:setVisible(false)
    self.m_imgReadyGoLeft:setVisible(false)

    self.m_btnOutCard:setVisible(false)
    self.m_btnReady:setVisible(false)

    self.m_nodeCardRight:removeAllChildren()
    self.m_nodeCardLeft:removeAllChildren()
    self.m_nodeCardMine:removeAllChildren()

    self.m_txtNickNameRight:setString("")
    self.m_txtNickNameLeft:setString("")
    self.m_txtNickNameMine:setString("")
end

function PdkScene:updateBeforeGameDisplay()
    self:updateLocalSeats()

    dump(self.m_localSeatMapServerSeat)
    dump(self.m_roomInfo)
    dump(self.m_localSeatMapPlayerInfo)

    local leftPlayer = self.m_roomInfo.player_list[self.m_localSeatMapServerSeat[_LOCAL_SEATS.LEFT]]
    local rightPlayer = self.m_roomInfo.player_list[self.m_localSeatMapServerSeat[_LOCAL_SEATS.RIGHT]]
    local leftAccount = leftPlayer and leftPlayer.account
    local rightAccount = rightPlayer and rightPlayer.account
    local leftPlayerInfo = self.m_localSeatMapPlayerInfo[_LOCAL_SEATS.LEFT]
    local rightPlayerInfo = self.m_localSeatMapPlayerInfo[_LOCAL_SEATS.RIGHT]

    self.m_bgHeadLeft:setVisible(leftPlayerInfo ~= nil)
    self.m_btnInviteLeft:setVisible(leftPlayerInfo == nil)
    self.m_txtNickNameLeft:setString(leftPlayerInfo and leftPlayerInfo.nick_name)

    self.m_bgHeadRight:setVisible(rightPlayerInfo ~= nil) 
    self.m_btnInviteRight:setVisible(rightPlayerInfo == nil)
    self.m_txtNickNameRight:setString(rightPlayerInfo and rightPlayerInfo.nick_name)

    local ready_list = self.m_roomInfo.ready_list
    self.m_imgReadyGoLeft:setVisible(leftAccount and ready_list[leftAccount])
    self.m_imgReadyGoRight:setVisible(rightAccount and ready_list[rightAccount])

    self.m_imgReadyGoMine:setVisible(ready_list[self.m_myAccount])
    self.m_btnReady:setVisible(not ready_list[self.m_myAccount])

    self.m_btnInviteMine:setVisible(#self.m_roomInfo.player_list < 3)
end

function PdkScene:onInvite()
end

function PdkScene:onMineOutCard()
end

function PdkScene:onReady()
    dd.NetworkClient:sendQuickMsg("room.user_ready", {is_ready = true})
end

function PdkScene:msgUserReady(info)
    print("PdkScene:msgUserReady")
    dump(info)
    self.m_roomInfo = info
    self:updateBeforeGameDisplay()
end

function PdkScene:msgUserExit(info)
    self.m_roomInfo = info
    if self.m_gameStatus == _GAME_STATUS.BEFORE_GAME then
        self:updateBeforeGameDisplay()
    end
end

function PdkScene:msgUserEnter(info)
    self.m_roomInfo = info
    if self.m_gameStatus == _GAME_STATUS.BEFORE_GAME then
        self:updateBeforeGameDisplay()
    end
end

return PdkScene
