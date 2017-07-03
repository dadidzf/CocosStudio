local MyApp = class("MyApp", cc.load("mvc").AppBase)

cc.FileUtils:getInstance():addSearchPath("res/trapballs")

import(".Constant")
dd.CsvConf = import(".CsvConf").new()

function MyApp:onCreate()
    math.randomseed(os.time())

    cc.load("sdk").Billing.init(dd.android.googleRSAKey, function (result)
        print("Billing init result ~ ", result) 
    end)
end

return MyApp
