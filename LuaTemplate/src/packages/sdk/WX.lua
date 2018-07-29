local WX = class("WX")
local cjson = require("cjson")

--[[
    WX for IOS
--]]
local _iosCallBackFunc = nil

local WXIos = class("WXIos", WX)

function WXIos:ctor()
    self.super.ctor(self)

    local callBackFunc = function (...)
        if _iosCallBackFunc then
            _iosCallBackFunc(...)
            _iosCallBackFunc = nil
        end
    end

    local args = {
        functionId = callBackFunc
    }

    getLuaBridge().callStaticMethod("SendMsgToWeChatViewController", "registerCallBackFunc", args)    
end

function WXIos:auth(callBack)
    self.super.auth(self) 
    local kAuthState = "dzf"..os.time()
    if callBack then
        _iosCallBackFunc = function (isSuccess, state, code) 
            if isSuccess and state == kAuthState then
                callBack(isSuccess, code)
            else
                callBack(false)
            end
        end
    end

    local args = {
        kAuthState = kAuthState
    }

    getLuaBridge().callStaticMethod("SendMsgToWeChatViewController", "sendAuthRequestLua", args)    
end

function WXIos:sendImageContent(filePath, thumbPath, scene)
    local args = {
        path = filePath,
        thumbPath = thumbPath,
        scene = scene
    }

    getLuaBridge().callStaticMethod("SendMsgToWeChatViewController", "sendImageContentLua", args)
end

function WXIos:sendLinkContent(linkURL, title, description, imgPath, scene)
    local args = {
        linkURL = linkURL,
        title = title,
        imgPath = imgPath,
        description = description,
        scene = scene
    }

    getLuaBridge().callStaticMethod("SendMsgToWeChatViewController", "sendLinkContentLua", args)
end

function WXIos:bizpay(fee)
    assert(type(fee) == "number")
    cc.load("http").Downloader.downloadData(
        "https://www.yongwuart.com/flask/herochess/wxpay/unifyorder/" .. tostring(math.floor(fee)), 
            function (result, data)
                print(result, data)
                if result then
                    getLuaBridge().callStaticMethod("SendMsgToWeChatViewController", "bizpayLua", cjson.decode(data))
                end
            end
    )
end

--[[
    WX for Androida
--]]
local WXAndroid = class("WXAndroid", WX)

function WXAndroid:ctor()
    self.super.ctor(self)
    self.m_jniClass = "org/cocos2dx/lua/GameJni"
end

--[[
    WX Base
--]]
local _instance = nil

function WX.getInstance()
    if _instance == nil then
        if device.platform == "ios" then
            _instance = WXIos.new()
        elseif device.platform == "android" then
            _instance = WXAndroid.new()
        else
            print("WX not support for ", device.platform)
            _instance = WX.new()
            return _instance
        end
    end

    return _instance
end

function WX:ctor()
end

function WX:auth()
end

return WX