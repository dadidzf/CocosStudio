local Billing = {}

local _jniClass = "org/cocos2dx/lua/GameJni"

local _iosPurchaseCallBackFunc = nil

-- the billingKey is only for android
function Billing.init(billingKey, callBack)
    if device.platform == "ios" then
        local callBackFunc = function (...)
            if _iosPurchaseCallBackFunc then
                _iosPurchaseCallBackFunc(...)
                _iosPurchaseCallBackFunc = nil
            end
        end

        local args = {
            functionId = callBackFunc
        }

        getLuaBridge().callStaticMethod("ToolsController", "registerBillingCallBackFunc", args)    
    elseif device.platform == "android" then
        getLuaBridge().callStaticMethod(_jniClass, "initBillings", {billingKey, callBack})
    end
end

function Billing.restore(callBack)
    if callBack then
        _iosPurchaseCallBackFunc = callBack
    end

    getLuaBridge().callStaticMethod("ToolsController", "restore")    
end

function Billing.purchase(skuKey, callBack)
    if device.platform == "ios" then
        local args = {
            productId = skuKey
        }
        if callBack then
            _iosPurchaseCallBackFunc = callBack
        end

        getLuaBridge().callStaticMethod("ToolsController", "purchase", args)    
    elseif device.platform == "android" then
        getLuaBridge().callStaticMethod(_jniClass, "purchase", {skuKey, callBack})
    end
end

function Billing.subscript(oldKey, skuKey, callBack)
    if device.platform == "ios" then
    elseif device.platform == "android" then
        getLuaBridge().callStaticMethod(_jniClass, "subscript", {oldKey, skuKey, callBack})
    end
end

function Billing.consume(skuKey, callBack)
    if device.platform == "ios" then
    elseif device.platform == "android" then
        getLuaBridge().callStaticMethod(_jniClass, "consume", {skuKey, callBack})
    end
end

function Billing.isItemPurchased(skuKey)
    if device.platform == "ios" then
    elseif device.platform == "android" then
        local isOk, ret = getLuaBridge().callStaticMethod(_jniClass, "isItemPurchased", {skuKey})
        return ret
    end
end

function Billing.isSubscriptionAutoRenewEnabled(skuKey)
    if device.platform == "ios" then
    elseif device.platform == "android" then
        local isOk, ret = getLuaBridge().callStaticMethod(_jniClass, "isSubscriptionAutoRenewEnabled", {skuKey})
        return ret
    end
end

return Billing
