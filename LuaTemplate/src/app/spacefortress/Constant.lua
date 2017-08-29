local Constant = {}

Constant.CATEGORY = {
    FORTRESS = 0x1,
    BULLET = 0x2,
    ENERMY = 0x4,
    LASER = 0x8
}

Constant.BULLET_TYPE = {
    "SINGLE_BULLET",
    "DOUBLE_BULLET",
    "THREE_BULLET",
    "SINGLE_LASER",
}

Constant.BULLET_CFG = {
    SINGLE_BULLET = {
        frequency = 0.2,
        bulletList = {
            {speed = 1000, distance = display.height, color = cc.YELLOW, direction = 0, xPos = 0}
        }
    },

    DOUBLE_BULLET = {
        frequency = 0.2,
        bulletList = {
            {speed = 1000, distance = display.height, color = cc.YELLOW, direction = 0, xPos = -10},
            {speed = 1000, distance = display.height, color = cc.YELLOW, direction = 0, xPos = 10},
        }
    },

    THREE_BULLET = {
        frequency = 0.2,
        bulletList = {
            {speed = 1000, distance = 300, color = cc.YELLOW, direction = 30, xPos = 0},
            {speed = 1000, distance = 600, color = cc.YELLOW, direction = 0, xPos = 0},
            {speed = 1000, distance = 300, color = cc.YELLOW, direction = -30, xPos = 0}
        }
    },

    SINGLE_LASER = {
        frequency = 0.2,
        bulletList = {
            {color = cc.RED, direction = 0, width = 10, xPos = 0, lifecycle = 0.1}
        }
    }
}


return Constant

