local MyApp = class("MyApp", cc.load("mvc").AppBase)

cc.FileUtils:getInstance():addSearchPath(string.format("res/%s", DD_WORKING_GAME_NAME))

dd.Constant = import(".Constant")
dd.GameData = import(".GameData").new()

dd.PlaySound = function (fileName)
    if dd.GameData:isSoundEnable() then
        return AudioEngine.getInstance():playEffect("sounds/" .. fileName)
    end
end

dd.PlayBtnSound = function ()
    dd.PlaySound("button.wav")
end

dd.GetTips = function (tipsTb)
    if  tipsTb[device.language] then
        return tipsTb[device.language]
    else
        return tipsTb["en"]
    end 
end

function MyApp:onCreate()
    math.randomseed(os.time())
    cc.load("sdk").Admob.getInstance():removeBanner()

    cc.load("sdk").Billing.init(dd.android.googleRSAKey, function (result)
        print("Billing init result ~ ", result) 
    end)
end

return MyApp
