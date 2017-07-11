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

    cc.load("sdk").Billing.init(dd.android.googleRSAKey, function (result)
        print("Billing init result ~ ", result) 
    end)
end

function MyApp:run()
    if device.platform == "android" then
        self.super.run(self, "LoadingScene")
    else
        self.super.run(self)
    end
end

return MyApp
