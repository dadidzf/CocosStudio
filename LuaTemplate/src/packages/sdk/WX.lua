local WX = class("WX")

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