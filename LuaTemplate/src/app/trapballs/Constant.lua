local Constants = {}
dd.Constants = Constants

Constants.CATEGORY = {
    BALL = 0x1,
    EDGE_SEGMENT = 0x2,
    EXTENDLINE = 0x4,
    EXTENDLINE_BOTH_ENDS = 0x8
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

Constants.LINE_WIDTH_IN_PIXEL = Constants.EDGE_SEG_WIDTH 

return Constants

