local MsgDealLogic = class("MsgDealLogic")

function MsgDealLogic:ctor(gameScene)
    self.m_gameScene = gameScene

    dd.NetworkClient:register("room.user_enter", handler(self, self.msgUserEnter))
    dd.NetworkClient:register("room.user_ready", handler(self, self.msgUserReady))
    dd.NetworkClient:register("room.user_exit", handler(self, self.msgUserExit))
    dd.NetworkClient:register("pdk.send_card", handler(self, self.msgSendCard))
    dd.NetworkClient:register("pdk.out_card", handler(self, self.msgOutCard))
    dd.NetworkClient:register("pdk.pass", handler(self, self.msgPass))
end

function MsgDealLogic:msgUserReady(roomInfo)
    self.m_gameScene:updateRoomInfo(roomInfo)
    self.m_gameScene:updateBeforeGameDisplay()
end

function MsgDealLogic:msgUserExit(roomInfo)
    self.m_gameScene:updateRoomInfo(roomInfo)
    if self.m_gameScene:getGameStatus() == self.m_gameScene._GAME_STATUS.BEFORE_GAME then
        self.m_gameScene:updateBeforeGameDisplay()
    end
end

function MsgDealLogic:msgUserEnter(roomInfo)
    self.m_gameScene:updateRoomInfo(roomInfo)
    if self.m_gameScene:getGameStatus() == self.m_gameScene._GAME_STATUS.BEFORE_GAME then
        self.m_gameScene:updateBeforeGameDisplay()
    end
end

function MsgDealLogic:msgSendCard(info)
    local handCards = info.cards
    self.m_gameScene:udpateLocalSeat(info.cur_seat)
    self.m_gameScene:onSendCard(handCards)
    self.m_gameScene:updateInGameDisplay()
end

function MsgDealLogic:msgOutCard(info)
    self.m_gameScene:udpateLocalSeat(info.cur_seat)
    self.m_gameScene:updateLastOutInfo(clone(info.out_cards))

    local localOutSeat = self.m_gameScene:serverSeatToLocal(info.out_seat)
    if localOutSeat == self.m_gameScene._LOCAL_SEATS.MINE then
        self.m_gameScene:removeHandCards(clone(info.out_cards))
    end

    self.m_gameScene:checkPass()

    self.m_gameScene:updateInGameDisplay()
    self.m_gameScene:showOutCard(localOutSeat, info.out_cards)
end

function MsgDealLogic:msgPass(info)
    self.m_gameScene:udpateLocalSeat(info.cur_seat)
    local localPassSeat = self.m_gameScene:serverSeatToLocal(info.pass_seat)
    self.m_gameScene:showPass(localPassSeat) 
    if info.new_turn then
        self.m_gameScene:updateLastOutInfo(nil)
    else
        self.m_gameScene:checkPass()
    end
    self.m_gameScene:updateInGameDisplay()
end

return MsgDealLogic