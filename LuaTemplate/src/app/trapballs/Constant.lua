local Constants = {}
dd.Constants = Constants

Constants.CATEGORY = {
    BALL = 0x1,
    EDGE_SEGMENT = 0x2,
    EXTENDLINE = 0x4,
    EXTENDLINE_BOTH_ENDS = 0x8,

    OBSTACLE_GEAR = 0x10,
    OBSTACLE_POWER = 0x20
}

Constants.OBSTACLE = {
    GEAR = 1,
    POWER = 2 
}

Constants.EDGE_SEG_WIDTH = 10

if display.width <= 640 then
    Constants.NODE_SCALE = display.width/640
    Constants.LEVEL_LIST_SCALE = display.width/640
end
if display.height < 960 then
    Constants.NODE_SCALE = display.height*0.9/960
    Constants.LEVEL_LIST_SCALE = display.height*0.9/960
end

Constants.LINE_WIDTH_IN_PIXEL = Constants.EDGE_SEG_WIDTH/4 



-- 钻石购买，购买生命，购买步数配表
Constants.MORE_RESOURCE = {
    MORE_LIVES = {lives = 3, diamonds = 100},
    MORE_STEPS = {steps = 3, diamonds = 100}
}

Constants.INIT_DIAMONDS = 180

Constants.MONEY_MAP_DIAMONDS = {
    dollar099 = 200,
    dollar299 = 700,
    dollar999 = 3000,
    dollar2999 = 10000
}

Constants.LEVEL_PASS_DIAMONDS_REWARD = 20

return Constants

