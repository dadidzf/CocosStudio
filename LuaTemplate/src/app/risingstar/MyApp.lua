local MyApp = class("MyApp", cc.load("mvc").AppBase)

cc.FileUtils:getInstance():addSearchPath("res/risingstar")


dd.PlaySound = function( fileName )
    AudioEngine.getInstance():playEffect("sounds/" .. fileName)
end

function MyApp:onCreate()
    math.randomseed(os.time())

    cc.load("sdk").Billing.init(dd.android.googleRSAKey, function (result)
        print("Billing init result ~ ", result) 
    end)
end

return MyApp
