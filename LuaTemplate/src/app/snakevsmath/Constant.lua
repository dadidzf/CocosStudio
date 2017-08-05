local Constants = {}

dd.Constants = Constants

Constants.SHARE_TIPS = 
{
    en = "Trap Balls, very funny game, play with me now !",
    cn = "围住小球又名抓蛋蛋，相当考验智力和耐心的游戏，赶紧加入抓蛋蛋的行列，来跟我一较高低吧！",
    getTips = function ()
        if Constants.SHARE_TIPS[device.language] then
            return Constants.SHARE_TIPS[device.language]
        else
            return Constants.SHARE_TIPS.cn
        end 
    end
}

Constants.INIT_DIAMONDS = 100

return Constants

