local Constants = {}

dd.Constants = Constants

Constants.SHARE_TIPS = 
{
    en = "Snake VS Math ? What will happenned ? Just come to paly with me now !",
    cn = "当贪吃蛇遇上数学会发生什么呢？赶紧来跟我一较高低吧！",
    getTips = function ()
        if Constants.SHARE_TIPS[device.language] then
            return Constants.SHARE_TIPS[device.language]
        else
            return Constants.SHARE_TIPS.cn
        end 
    end
}

Constants.INIT_DIAMONDS = 10

Constants.SANKE_HEAD_PRICE = 
{
    {50, 50, 50, 50},
    {50, 50, 50, 50},
    {50, 50, 50, 50},
    {50, 50, 50, 50},
    {50, 50, 50, 50},
    {50, 50, 50, 50},
    {50, 50, 50, 50},
    {50}
}

return Constants

