local MyApp = class("MyApp", cc.load("mvc").AppBase)

cc.FileUtils:getInstance():addSearchPath("res/snakevsmath")

cc.load("sdk").Tools.setMultiLanguageSupported(true)

import(".Constant")
dd.GameData = import(".GameData"):create()

dd.GetTips = function (tipsTb)
    if  tipsTb[device.language] then
        return tipsTb[device.language]
    else
        return tipsTb["en"]
    end 
end

dd.PlaySound = function (fileName)
    --if dd.GameData:isSoundEnable() then
        AudioEngine.getInstance():playEffect("sounds/" .. fileName)
    --end
end

dd.BtnScaleAction = function (btn)
    btn:addTouchEventListener(function(sender, state)
        local event = {x = 0, y = 0}
        if state == 0 then
            event.name = "began"
            sender:setScale(0.9)
        elseif state == 1 then
            event.name = "moved"
        elseif state == 2 then
            sender:setScale(1.0)
            event.name = "ended"
        else
            sender:setScale(1.0)
            event.name = "cancelled"
        end
        event.target = sender
    end)
    return self
end


function MyApp:onCreate()
    math.randomseed(os.time())

    cc.load("sdk").Admob.getInstance():removeBanner()
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

function MyApp:run()
    if device.platform == "android" then
        self.super.run(self, "Splash")
    else
        self.super.run(self)
    end
end

return MyApp
