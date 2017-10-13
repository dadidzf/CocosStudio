local Constant = {}

Constant.SHARE_TIPS = 
{
    en = "Overwatch in the space, the super arc light game ! play with me now !",
    cn = [[简单的几何学你懂吗？快来玩"太空守望"，跟我一起成为太空中的守望先锋吧 ！]],
}

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
    },

    SUPER_BULLET_CREATE_TIME = 10,
    SUPER_BULLET_COLD_TIME = 5
}

Constant.ENERMY_CFG = {
    LEVEL_TIME = 60,
    LEVEL_SPEED = {
        50, 55, 60, 65, 70, 75
    },
    LEVEL_FREQUENCY = {
        1, 0.95, 0.9, 0.85, 0.8, 0.75
    },
    ROTATE_PROB = 0.2,
    ROTATE_SPEED_MIN = 90,
    ROTATE_SPEED_MAX = 360,
    CIRCLE_RADIUS_MAX = 0.5,
    CIRCLE_RADIUS_MIN = 0.3,
    CIRCLE_ANGLE_SPEED_MIN = 60,
    CIRCLE_ANGLE_SPEED_MAX = 90,
    CIRCLE_ANGLE_MAX = 1080,
    CIRCLE_ANGLE_MIN = 360
}

return Constant

