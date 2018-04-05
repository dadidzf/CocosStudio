local MyApp = class("MyApp", cc.load("mvc").AppBase)

cc.FileUtils:getInstance():addSearchPath(string.format("res/%s", DD_WORKING_GAME_NAME))

function MyApp:onCreate()
    math.randomseed(os.time())

    cc.load("sdk").Billing.init(dd.android.googleRSAKey, function (result)
        print("Billing init result ~ ", result) 
    end)
end

function MyApp:run()
    -- if device.platform == "android" then
    --     self.super.run(self, "LoadingScene")
    -- else
    --     self.super.run(self)
    -- end

    self.super.run(self, "LoginScene")
end

dd.NetworkClient = import(".network.Client").new()
dd.CommonClass = {}
dd.WritablePath = cc.FileUtils:getInstance():getWritablePath()

dd.PlayersInfo = import(".common.PlayersInfo").new()

dd.SceneLayerOrder = 
{
    netMask = 1
}

dd.WXScene = {
    WXSceneSession  = 0,
    WXSceneTimeline = 1, 
    WXSceneFavorite = 2
}

dd.WX = cc.load("sdk").WX.getInstance()

return MyApp


