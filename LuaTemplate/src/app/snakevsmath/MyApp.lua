local MyApp = class("MyApp", cc.load("mvc").AppBase)

cc.FileUtils:getInstance():addSearchPath("res/snakevsmath")

cc.load("sdk").Tools.setMultiLanguageSupported(true)

import(".Constant")
dd.GameData = import(".GameData"):create()

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

return MyApp
