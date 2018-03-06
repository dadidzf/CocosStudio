local PlayersInfo = class("PlayersInfo")

function PlayersInfo:ctor()
    self.accountMapPlayerInfoList = {}
end

function PlayersInfo:initMyInfo(info)
    dump(info, "......")
    self.m_myInfo = info
    self.accountMapPlayerInfoList[info.account] = info
end

function PlayersInfo:getMyInfo()
    return clone(self.m_myInfo)
end

function PlayersInfo:getInfoByAccount(account, callBack)
    if self.accountMapPlayerInfoList[account] then
        callBack(clone(self.accountMapPlayerInfoList[account]))
    else
        callBack({account = account, exp = 0, golds = 0, nick_name = "To Be Done !"})
    end
end


return PlayersInfo