local MyApp = class("MyApp", cc.load("mvc").AppBase)

cc.FileUtils:getInstance():addSearchPath("res/trapballs")

import(".Constant")
dd.CsvConf = import(".CsvConf").new()
dd.GameData = import(".GameData").new()

dd.PlaySound = function (fileName)
    if dd.GameData:isSoundEnable() then
        AudioEngine.getInstance():playEffect("sounds/" .. fileName)
    end
end

function MyApp:onCreate()
    math.randomseed(os.time())
    
    cc.load("sdk").Admob.getInstance():removeBanner()
    cc.load("sdk").Billing.init(dd.android.googleRSAKey, function (result)
        print("Billing init result ~ ", result) 
        cc.load("sdk").Billing.setIsBillingEnabled(result)

        if result then
            local isPurchased = cc.load("sdk").Billing.isItemPurchased(dd.appCommon.skuKeys[1])
            if device.platform == "android" and isPurchased then
                cc.load("sdk").Admob.getInstance():setAdsRemoved(true)
                dd.GameData:setAdsRemoved(true)
            end

            for i = 2, 5 do 
                local isPurchased = cc.load("sdk").Billing.isItemPurchased(dd.appCommon.skuKeys[i])
                print("-------------- isPurchased - ", isPurchased)
                if isPurchased then
                    print("Item is purchased and not cosumed ! -- ", dd.appCommon.skuKeys[i])
                    cc.load("sdk").Billing.consume(dd.appCommon.skuKeys[i], function (skuKey)
                        print("Billing Consume Result ~ ", skuKey)
                        if skuKey ~= "failed" then
                            self:rewardDiamonds(skuKey)
                        end
                    end)
                end
            end
        end
    end)
end

function MyApp:rewardDiamonds(skuKey)
    print("MyApp:rewardDiamonds", skuKey)
    self.m_curDiamodns = dd.GameData:getDiamonds() 
    local rewardDiamonds = 0
    if skuKey == dd.appCommon.skuKeys[2] then
        rewardDiamonds = dd.Constants.MONEY_MAP_DIAMONDS.dollar099
    elseif skuKey == dd.appCommon.skuKeys[3] then
        rewardDiamonds = dd.Constants.MONEY_MAP_DIAMONDS.dollar299
    elseif skuKey == dd.appCommon.skuKeys[4] then
        rewardDiamonds = dd.Constants.MONEY_MAP_DIAMONDS.dollar999
    elseif skuKey == dd.appCommon.skuKeys[5] then
        rewardDiamonds = dd.Constants.MONEY_MAP_DIAMONDS.dollar2999
    end

    self.m_curDiamodns = self.m_curDiamodns + rewardDiamonds 
    dd.GameData:refreshDiamonds(self.m_curDiamodns)
end

function MyApp:run()
    if device.platform == "android" then
        self.super.run(self, "LoadingScene")
    else
        self.super.run(self)
    end
end

return MyApp
