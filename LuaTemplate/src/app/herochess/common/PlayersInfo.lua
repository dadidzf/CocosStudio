local PlayersInfo = class("PlayersInfo")

function PlayersInfo:ctor()
    self.m_accountMapPlayerInfoList = {}
    self.m_accountMapHeadImgPath = {}

    self.m_headImgsDir = dd.WritablePath..'HeadImgs/'

    if not dd.fileUtils:isDirectoryExist(self.m_headImgsDir) then
        dd.fileUtils:createDirectory(self.m_headImgsDir)
    end
end

function PlayersInfo:initMyInfo(info)
    self.m_myInfo = info
    self:addPlayerInfo(info)
end

function PlayersInfo:addPlayerInfo(info)
    self.m_accountMapPlayerInfoList[info.account] = info
    if string.sub(info.headimgurl, 1, 6) == "system" then
        self.m_accountMapHeadImgPath[account] = info.headimgurl
    end
end

function PlayersInfo:downloadHeadImg(info, callBack)
    local headFileName = self.m_headImgsDir ..  dd.YWPlatform:getStringMD5(info.headimgurl) .. ".jpg"
    if not dd.fileUtils:isFileExist(headFileName) then
        cc.load("http").Downloader.downloadFile(
            info.headimgurl,
            headFileName,
            function (result)
                if result then
                    print("down load headimg succes", info.headimgurl) 
                    self.m_accountMapHeadImgPath[info.account] = headFileName

                    callBack(headFileName)
                end
            end
        )
    else
        self.m_accountMapHeadImgPath[info.account] = headFileName
        callBack(headFileName)
    end
end

function PlayersInfo:getMyInfo()
    return clone(self.m_myInfo)
end

function PlayersInfo:getInfoByAccount(account, callBack)
    if self.m_accountMapPlayerInfoList[account] then
        callBack(clone(self.m_accountMapPlayerInfoList[account]))
    else
        dd.NetworkClient:sendBlockMsg("system.get_user_info", {account = account}, function (info)
            self:addPlayerInfo(info)
            callBack(clone(self.m_accountMapPlayerInfoList[account]))
        end)
    end
end

function PlayersInfo:getHeadImgPath(playerInfo, callBack)
    local account = playerInfo.account
    if self.m_accountMapHeadImgPath[account] then
        callBack(self.m_accountMapHeadImgPath[account])
    else
        self:downloadHeadImg(playerInfo, callBack)
    end
end

return PlayersInfo