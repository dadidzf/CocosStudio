local MyApp = class("MyApp", cc.load("mvc").AppBase)

cc.FileUtils:getInstance():addSearchPath("res/snakevsmath")

cc.load("sdk").Tools.setMultiLanguageSupported(true)

import(".Constant")
dd.GameData = import(".GameData"):create()

dd.PlaySound = function (fileName)
    --if dd.GameData:isSoundEnable() then
        AudioEngine.getInstance():playEffect("sounds/" .. fileName)
    --end
end

function MyApp:onCreate()
    math.randomseed(os.time())

    if dd.GameData:isAdsRemoved() then
        cc.load("sdk").Admob.getInstance():setAdsRemoved(true)
    end

    cc.load("sdk").Billing.init(dd.android.googleRSAKey, function (result)
        print("Billing init result ~ ", result) 
        cc.load("sdk").Billing.setIsBillingEnabled(result)

        if result then
            local isPurchased = cc.load("sdk").Billing.isItemPurchased(dd.appCommon.skuKeys[1])
            if device.platform == "android" and isPurchased then
                cc.load("sdk").Admob.getInstance():setAdsRemoved(true)
                dd.GameData:setAdsRemoved(true)
            end
        end
    end)
end

return MyApp
