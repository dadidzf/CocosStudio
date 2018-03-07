local PdkScene = class("PdkScene", cc.load("mvc").ViewBase)
local HandCardLayer = import(".HandCardLayer")
local OutCardContainer = import(".OutCardContainer")
local MsgDealLogic = import(".MsgDealLogic")
local logic = import(".logic")

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
    ["node_card"] = {varname = "m_nodeCardMine"},

    ["node_mine_out_card.img_pass"] = {varname = "m_imgPassMine"},
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

PdkScene._GAME_STATUS = {
    BEFORE_GAME = 1,
    IN_GAME = 2
}

PdkScene._LOCAL_SEATS = {
    LEFT = 1,
    MINE = 2,
    RIGHT = 3
}


function PdkScene:ctor(roomInfo)
    self.super.ctor(self)

    self.m_roomInfo = roomInfo
    self.m_myInfo = dd.PlayersInfo:getMyInfo()
    self.m_myAccount = self.m_myInfo.account
    self.m_gameStatus = self._GAME_STATUS.BEFORE_GAME

    self:initMsgHandlers()
    self:initUI()
end

function PdkScene:getGameStatus()
    return self.m_gameStatus
end

function PdkScene:updateRoomInfo(roomInfo)
    self.m_roomInfo = roomInfo
end

function PdkScene:initMsgHandlers()
    self.m_msgDealLogic = MsgDealLogic:create(self)
end

function PdkScene:updateLocalSeats()
    self.m_accountMapLocalSeat = {}
    self.m_serverSeatMapLocalSeat = {}
    self.m_localSeatMapServerSeat = {}
    self.m_localSeatMapPlayerInfo = {}

    self.m_accountMapLocalSeat[self.m_myAccount] = self._LOCAL_SEATS.MINE
    self.m_localSeatMapPlayerInfo[self._LOCAL_SEATS.MINE] = self.m_myInfo

    local myServerSeat
    local myLocalSeat = self._LOCAL_SEATS.MINE

    for seat, player in pairs(self.m_roomInfo.player_list) do
        if player.account == self.m_myAccount then
            myServerSeat = seat
            break
        end
    end

    if myServerSeat then
        for i = 1, table.nums(self._LOCAL_SEATS) do
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

    local leftPlayer = self.m_roomInfo.player_list[self.m_localSeatMapServerSeat[self._LOCAL_SEATS.LEFT]]
    local rightPlayer = self.m_roomInfo.player_list[self.m_localSeatMapServerSeat[self._LOCAL_SEATS.RIGHT]]
    local leftAccount = leftPlayer and leftPlayer.account
    local rightAccount = rightPlayer and rightPlayer.account
    local leftPlayerInfo = self.m_localSeatMapPlayerInfo[self._LOCAL_SEATS.LEFT]
    local rightPlayerInfo = self.m_localSeatMapPlayerInfo[self._LOCAL_SEATS.RIGHT]

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

function PdkScene:updateOutCardBtnStatus()
    if self.m_curLocalSeat == self._LOCAL_SEATS.MINE then
        self.m_btnOutCard:setVisible(true) 
        local handCards = self.m_handHardLayer:getHandCards()
        local standOutCards = self.m_handHardLayer:getStandCards()
        local standOutCardsInfo = logic.get_type(standOutCards, #handCards == #standOutCards)
        if standOutCardsInfo then
            if next(standOutCards) then
                if self.m_lastOutInfo and not logic.is_big(self.m_lastOutInfo, standOutCardsInfo) then
                    self.m_btnOutCard:setEnabled(false)
                else
                    self.m_btnOutCard:setEnabled(true)
                end
            else
                self.m_btnOutCard:setEnabled(false)
            end
        else
            self.m_btnOutCard:setEnabled(false)
        end
    else
        self.m_btnOutCard:setVisible(false)
    end
end

function PdkScene:updateInGameDisplay()
    self:updateOutCardBtnStatus()
end

function PdkScene:onSendCard(handCards)
    self.m_gameStatus = self._GAME_STATUS.IN_GAME
    self.m_handHardLayer = HandCardLayer:create(handler(self, self.updateInGameDisplay))
        :addTo(self.m_nodeHandCardMine)
    self.m_handHardLayer:initCards(handCards)

    self.m_imgReadyGoLeft:setVisible(false)
    self.m_imgReadyGoMine:setVisible(false)
    self.m_imgReadyGoRight:setVisible(false)
end

function PdkScene:udpateLocalSeat(serverSeat)
    self.m_curLocalSeat = self.m_serverSeatMapLocalSeat[serverSeat]
end

function PdkScene:serverSeatToLocal(serverSeat)
    return self.m_serverSeatMapLocalSeat[serverSeat]
end

function PdkScene:onInvite()
end

function PdkScene:onOutCard()
    self:updateOutCardBtnStatus()
    if self.m_btnOutCard:isVisible() and self.m_btnOutCard:isEnabled() then
        dd.NetworkClient:sendQuickMsg("pdk.out_card", {cards = self.m_handHardLayer:getStandCards()})
    end

    if self.m_lastOutInfo == nil then
        for i = 1, 3 do
            self:getPassNodeByLocalSeat(i):setVisible(false)
            self:getCardContainerByLocalSeat(i):removeAllChildren()
        end
    end
end

function PdkScene:localSeatToOutCardContainerType(localSeat)
    return localSeat
end

function PdkScene:getCardContainerByLocalSeat(localSeat)
    local localSeatMapCardContainer = {self.m_nodeCardLeft, self.m_nodeCardMine, self.m_nodeCardRight}
    return localSeatMapCardContainer[localSeat]
end

function PdkScene:getPassNodeByLocalSeat(localSeat)
    local localSeatMapPassNode = {self.m_imgPassLeft, self.m_imgPassMine, self.m_imgPassRight}
    return localSeatMapPassNode[localSeat]
end

function PdkScene:showOutCard(localOutSeat, outCards)
    self:getPassNodeByLocalSeat(localOutSeat):setVisible(false)
    local outContainer = OutCardContainer:create(self:localSeatToOutCardContainerType(localOutSeat))
    self:getCardContainerByLocalSeat(localOutSeat):addChild(outContainer)
    outContainer:showOutCards(outCards)
end

function PdkScene:showPass(localPassSeat)
    self:getCardContainerByLocalSeat(localPassSeat):removeAllChildren()
    self:getPassNodeByLocalSeat(localPassSeat):setVisible(true)
end

function PdkScene:removeHandCards(outCards)
    self.m_handHardLayer:onOutCard(outCards)
end

function PdkScene:checkPass()
    if self.m_curLocalSeat == self._LOCAL_SEATS.MINE then
        if not logic.is_bigger_cards_exist(self.m_lastOutInfo, self.m_handHardLayer:getHandCards()) then
            dd.NetworkClient:sendQuickMsg("pdk.pass", {})
        end
    end
end

function PdkScene:updateLastOutInfo(outCards)
    if outCards then
        self.m_lastOutInfo = logic.get_type(outCards)
    else
        self.m_lastOutInfo = nil
    end
end

function PdkScene:onReady()
    dd.NetworkClient:sendQuickMsg("room.user_ready", {is_ready = true})
end

return PdkScene
