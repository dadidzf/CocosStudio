local Effect = class("Effect", cc.Node)
local Gear = import(".Gear")
local _scheduler = cc.Director:getInstance():getScheduler()

function Effect:ctor(index, param)
    local createFunctions = 
    {
        self.createParticleCircle,
        self.createSquareDot,
        self.createCircleDot,
        self.createGearPair,
        self.createProgressCircle,
        self.createProgressBar
    }

    local i = index or math.random(#createFunctions)
    self.m_updateFunction = createFunctions[i](self, param)
end

function Effect:createGearPair()
    local rLen = 54
    local gearA = Gear:create("gear.png")
            :move(0, 0)
            :addTo(self)

    local gearB = Gear:create("gear.png")
            :addTo(self)

    gearB:pairWithTarget(gearA, rLen, 90)

    return function (ratio)
        gearB:setAngle(-ratio*360 + 90)
    end
end

function Effect:createProgressCircle()
    local progressSprite = cc.Sprite:create("potentiometerProgress.png")
    local progress = cc.ProgressTimer:create(progressSprite)
            :setType(cc.PROGRESS_TIMER_TYPE_RADIAL)
            :setPosition(cc.p(0, 0))
            :addTo(self)


    return function (ratio)
        progress:setPercentage(ratio*100)
    end
end

function Effect:createProgressBar(range)
    local progressSprite = cc.Sprite:create("sliderProgress.png")
    local spriteSize = progressSprite:getContentSize()

    local progress = cc.ProgressTimer:create(progressSprite)
            :setType(cc.PROGRESS_TIMER_TYPE_BAR)
            :setPosition(cc.p(0, 0))
            :addTo(self)
            :setMidpoint(cc.p(0, 0))
            :setBarChangeRate(cc.p(1, 0))

    local drawNode = cc.DrawNode:create()
            :move(0, 0)
            :addTo(self)

    if range then
        drawNode:drawTriangle(
            cc.p(spriteSize.width/2, spriteSize.height/2),
            cc.p(spriteSize.width/2 - 10, spriteSize.height/2 + 10),
            cc.p(spriteSize.width/2 + 10, spriteSize.height/2 + 10),
            cc.c4f(0.65, 0.65, 0.65, 1)
            )

        local plus = ccui.Text:create(string.format("+" .. range), "", 16)
            :setAnchorPoint(cc.p(0.5, 0))
            :move(spriteSize.width/2, spriteSize.height/2 + 10)
            :addTo(drawNode)
            :setColor(cc.WHITE)

        drawNode:drawTriangle(
            cc.p(spriteSize.width*((1 - range)/(1 + range) - 0.5), -spriteSize.height/2),
            cc.p(spriteSize.width*((1 - range)/(1 + range) - 0.5) - 10, -spriteSize.height/2 - 10),
            cc.p(spriteSize.width*((1 - range)/(1 + range) - 0.5) + 10, -spriteSize.height/2 - 10),
            cc.c4f(0.65, 0.65, 0.65, 1)
            )

        local minus = ccui.Text:create(string.format("-" .. range), "", 16)
            :setAnchorPoint(cc.p(0.5, 1))
            :move(spriteSize.width*((1 - range)/(1 + range) - 0.5), -spriteSize.height/2 - 10)
            :addTo(drawNode)
            :setColor(cc.WHITE)

        local origin = cc.p(spriteSize.width*((1 - range)/(1 + range) - 0.5), -spriteSize.height/2)
        local dest = cc.p(spriteSize.width/2, spriteSize.height/2)
        drawNode:drawRect(origin, dest, cc.c4f(1, 1, 0, 0.5))

        origin = cc.p(-spriteSize.width/2, -spriteSize.height/2)
        dest = cc.p(spriteSize.width*(1/(1 + range) - 0.5), spriteSize.height/2)
        drawNode:drawRect(origin, dest, cc.c4f(0, 0, 1, 0.5))

        local minus = ccui.Text:create("1.0", "", 16)
            :move(spriteSize.width*(1/(1 + range) - 0.5), 0)
            :addTo(drawNode)
            :setColor(cc.WHITE)
    else
        local origin = cc.p(-spriteSize.width/2, -spriteSize.height/2)
        local dest = cc.p(spriteSize.width/2, spriteSize.height/2)
        drawNode:drawRect(origin, dest, cc.c4f(0, 0, 1, 0.5))
    end

    return function (ratio)
        progress:setPercentage(ratio*100)
    end
end

cc.RED = cc.c3b(255,0,0)
cc.GREEN = cc.c3b(0,255,0)
cc.BLUE = cc.c3b(0,0,255)
cc.BLACK = cc.c3b(0,0,0)
cc.WHITE = cc.c3b(255,255,255)
cc.YELLOW = cc.c3b(255,255,0)

local colorTb = 
{
    cc.c4f(1, 0, 1, 1),
    cc.c4f(0, 1, 1, 1),
    cc.c4f(1, 0, 0, 1),
    cc.c4f(1, 1, 1, 1),
    cc.c4f(0, 1, 0, 1),
    cc.c4f(1, 1, 0, 1),
    cc.c4f(0, 0, 1, 1)
}

function Effect:createCircleDot()
    local drawNode = cc.DrawNode:create()
            :move(0, 0)
            :addTo(self)
    local len = 150
    local dotsCount = 0

    return function (ratio)
        dotsCount = dotsCount + 1
        if dotsCount >= 60 then
            drawNode:clear()
            dotsCount = 0
        end

        drawNode:drawPoint(
            cc.p(math.cos(-ratio*math.pi*2 + math.pi/2)*len, math.sin(-ratio*math.pi*2 + math.pi/2)*len),
            6,
            --cc.c4f(math.random(), math.random(), math.random(), 1)
            colorTb[math.random(#colorTb)]
            )
    end
end

function Effect:createParticleCircle()
    local particle = cc.ParticleSystemQuad:create("particle_circle.plist") 
        :addTo(self)
    local len = 150

    return function (ratio)
        particle:setPosition(math.cos(-ratio*math.pi*2 + math.pi/2)*len, math.sin(-ratio*math.pi*2 + math.pi/2)*len)
    end
end

function Effect:createSquareDot()
    local drawNode = cc.DrawNode:create()
            :move(0, 0)
            :addTo(self)
    local len = 150
    local dotsCount = 0

    return function (ratio)
        local degree = -ratio*360 + 90
        local pt = cc.pRotate(cc.p(1, 0), cc.pForAngle(math.rad(degree)))
        local mul = 1 / math.cos(math.rad(45 - math.abs((degree % 90) - 45)))
        pt = cc.pMul(pt, mul)

        dotsCount = dotsCount + 1
        if dotsCount >= 60 then
            dotsCount = 0
            drawNode:clear()
        end
        
        drawNode:drawPoint(
            cc.p(pt.x*len, pt.y*len),
            6,
            colorTb[math.random(#colorTb)]
            --cc.c4f(math.random(), math.random(), math.random(), 1)
            )
    end
end

function Effect:updateProgress(ratio)
    self.m_updateFunction(ratio)
end
    
return Effect