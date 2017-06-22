local MyApp = class("MyApp", cc.load("mvc").AppBase)

cc.FileUtils:getInstance():addSearchPath("res/onesecond")

function MyApp:onCreate()
    math.randomseed(os.time())

    cc.load("sdk").Billing.init(dd.android.googleRSAKey, function (result)
        print("Billing init result ~ ", result) 
        cc.load("sdk").Billing.setIsBillingEnabled(result)

        if result then
            local isPurchased = cc.load("sdk").Billing.isItemPurchased(dd.appCommon.skuKeys[1])
            if device.platform == "android" and isPurchased then
                cc.load("sdk").Admob.getInstance():setAdsRemoved(true)
                cc.UserDefault:getInstance():setBoolForKey("noads", true)
            end
        end
    end)
end

return MyApp
