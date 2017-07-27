
-- 0 - disable debug info, 1 - less debug info, 2 - verbose debug info
DEBUG = 2

-- use framework, will disable all deprecated API, false - use legacy API
CC_USE_FRAMEWORK = true

-- show FPS on screen
CC_SHOW_FPS = false

-- disable create unexpected global variable
CC_DISABLE_GLOBAL = true

-- for module display
CC_DESIGN_RESOLUTION = {
    width = 640,
    height = 960,
    autoscale = "FIXED_HEIGHT",
    callback = function(framesize)
        local ratio = framesize.height / framesize.width
        local w = CC_DESIGN_RESOLUTION.width
        local h = CC_DESIGN_RESOLUTION.height
        if ratio <= h/w then
            -- iPad 768*1024(1536*2048) is 4:3 screen
            return {autoscale = "FIXED_WIDTH"}
        end
    end
}

-- name of current game, it's also the working directory for current game
DD_WORKING_GAME_NAME = "trapballs"
