local Constant = {}

Constant.SHARE_TIPS = 
{
    en = "Overwatch in the space, the super arc light game ! play with me now !",
    cn = [[简单的几何学你懂吗？快来玩"太空守望"，跟我一起成为太空中的守望先锋吧 ！]],
}

Constant.GAME_OVER_TIPS = 
{
    en = "Game Over",
    cn = "游戏结束"
}

Constant.CATEGORY = {
    FORTRESS = 0x1,
    BULLET = 0x2,
    ENERMY = 0x4,
    LASER = 0x8,
    SKILL = 0x10,
    BOSS = 0x20
}

Constant.BULLET_TYPE = {
    "SINGLE_BULLET",
    "DOUBLE_BULLET",
    "THREE_BULLET",
    "FIVE_BULLET",
    "SIX_BULLET",
    "TRIANGLE_BULLET",
    "TRIANGLE_LASER",
    "SINGLE_LASER"
}

Constant.COLOR_GROUP = {
    YELLOW = cc.c3b(230, 230, 25),
    RED = cc.c3b(230, 25, 25),
    BLUE = cc.c3b(25, 25, 220),
    GREEN = cc.c3b(25, 230, 25)
}

Constant.PLANE_CIRCLE_PIC = {
    YELLOW = "spacefortress_yuan001.png",
    RED = "spacefortress_yuan002.png",
    GREEN = "spacefortress_yuan003.png",
    BLUE = "spacefortress_yuan004.png"
}

Constant.BULLET_CFG = {
    SINGLE_BULLET = {
        coldtime = 5,
        frequency = 0.2,
        circle = Constant.PLANE_CIRCLE_PIC.YELLOW,
        bulletList = {
            {speed = 1000, distance = display.height, color = Constant.COLOR_GROUP.YELLOW, direction = 0, xPos = 0}
        }
    },

    DOUBLE_BULLET = {
        coldtime = 8,
        frequency = 0.2,
        circle = Constant.PLANE_CIRCLE_PIC.GREEN,
        bulletList = {
            {speed = 1000, distance = display.height, color = Constant.COLOR_GROUP.GREEN, direction = 0, xPos = -10},
            {speed = 1000, distance = display.height, color = Constant.COLOR_GROUP.GREEN, direction = 0, xPos = 10},
        }
    },

    THREE_BULLET = {
        coldtime = 8,
        frequency = 0.2,
        circle = Constant.PLANE_CIRCLE_PIC.BLUE,
        bulletList = {
            {speed = 1000, distance = 300, color = Constant.COLOR_GROUP.BLUE, direction = 30, xPos = 0},
            {speed = 1000, distance = 600, color = Constant.COLOR_GROUP.BLUE, direction = 0, xPos = 0},
            {speed = 1000, distance = 300, color = Constant.COLOR_GROUP.BLUE, direction = -30, xPos = 0}
        }
    },

    FIVE_BULLET = {
        coldtime = 5,
        frequency = 0.3,
        circle = Constant.PLANE_CIRCLE_PIC.BLUE,
        bulletList = {
            {speed = 1000, distance = 200, color = Constant.COLOR_GROUP.BLUE, direction = 60, xPos = 0},
            {speed = 1000, distance = 300, color = Constant.COLOR_GROUP.BLUE, direction = 30, xPos = 0},
            {speed = 1000, distance = 600, color = Constant.COLOR_GROUP.BLUE, direction = 0, xPos = 0},
            {speed = 1000, distance = 300, color = Constant.COLOR_GROUP.BLUE, direction = -30, xPos = 0},
            {speed = 1000, distance = 200, color = Constant.COLOR_GROUP.BLUE, direction = -60, xPos = 0}
        }
    },

    SIX_BULLET = {
        coldtime = 5,
        frequency = 0.3,
        circle = Constant.PLANE_CIRCLE_PIC.RED,
        bulletList = {
            {speed = 1000, distance = 600, color = Constant.COLOR_GROUP.RED, direction = -100, xPos = 0},
            {speed = 1000, distance = 600, color = Constant.COLOR_GROUP.RED, direction = -90, xPos = 0},
            {speed = 1000, distance = 600, color = Constant.COLOR_GROUP.RED, direction = -80, xPos = 0},
            {speed = 1000, distance = 600, color = Constant.COLOR_GROUP.RED, direction = 80, xPos = 0},
            {speed = 1000, distance = 600, color = Constant.COLOR_GROUP.RED, direction = 90, xPos = 0},
            {speed = 1000, distance = 600, color = Constant.COLOR_GROUP.RED, direction = 100, xPos = 0}
        }
    },

    TRIANGLE_BULLET = {
        coldtime = 5,
        frequency = 0.2,
        circle = Constant.PLANE_CIRCLE_PIC.YELLOW,
        bulletList = {
            {speed = 1000, distance = display.height, color = Constant.COLOR_GROUP.YELLOW, direction = 0, xPos = 0}
        }
    },

    TRIANGLE_LASER = {
        coldtime = 5,
        frequency = 0.2,
        circle = Constant.PLANE_CIRCLE_PIC.RED,
        bulletList = {
            {color = Constant.COLOR_GROUP.RED, direction = 0, width = 10, xPos = 0, lifecycle = 0.1}
        }
    },

    SINGLE_LASER = {
        coldtime = 8,
        frequency = 0.2,
        circle = Constant.PLANE_CIRCLE_PIC.RED,
        bulletList = {
            {color = Constant.COLOR_GROUP.RED, direction = 0, width = 10, xPos = 0, lifecycle = 0.1}
        }
    }
}

Constant.SKILL_CFG = {
    SCALE = 0.8,
    PRODUCE_SCHEDULE_MIN = 15,
    PRODUCE_SCHEDULE_MAX = 30,
    SPEED = 60,
    CIRCLE_RADIUS_MIN = 0.3,
    CIRCLE_RADIUS_MAX = 0.5,
    CIRCLE_ANGLE = 360,
    CIRCLE_ANGLE_SPEED = 120
}

Constant.BOSS_CFG = {
    SCALE = 1.0,
    PRODUCE_SCHEDULE_MIN = 30,
    PRODUCE_SCHEDULE_MAX = 60,
    SPEED = 20,
    CIRCLE_RADIUS_MIN = 0.4,
    CIRCLE_RADIUS_MAX = 0.5,
    CIRCLE_ANGLE = 720,
    CIRCLE_ANGLE_SPEED = 30,
    HP_MIN = 10,
    HP_MAX = 30
}

Constant.ENERMY_CFG = {
    LEVEL_TIME = 60,
    LEVEL_SPEED = {
        50, 55, 60
    },
    LEVEL_FREQUENCY = {
        2, 0.95, 0.9
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

