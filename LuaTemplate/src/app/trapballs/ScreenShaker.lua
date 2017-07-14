local ScreenShaker = class("ScreenShaker")
local scheduler = dd.scheduler

function ScreenShaker:ctor(target, time)
    self.init_x = 0       --[[初始位置x]]
    self.init_y = 0       --[[初始位置y]]
    self.diff_x = 0       --[[偏移量x]]
    self.diff_y = 0       --[[偏移量y]]
    self.diff_max = 8     --[[最大偏移量]]
    self.interval = 0.01  --[[震动频率]]
    self.totalTime = 0    --[[震动时间]]
    self.time = 0         --[[计时器]]

    self.target = target
    self.init_x = target:getPositionX()
    self.init_y = target:getPositionY()
    self.totalTime = time
end

function ScreenShaker:run()
    self.scheduler = scheduler:scheduleScriptFunc(
        function (ft)
            self:shake(ft)
        end, 
        self.interval,
        false
        )
end

function ScreenShaker:shake(ft)
    if self.time >= self.totalTime then
        self:stop()
        return
    end

    self.time = self.time + ft
    self.diff_x = math.random(-self.diff_max, self.diff_max)*math.random()
    self.diff_y = math.random(-self.diff_max, self.diff_max)*math.random()
    self.target:setPosition(cc.p(self.init_x + self.diff_x, self.init_y + self.diff_y))
end

function ScreenShaker:stop()
    self.time = 0
    scheduler:unscheduleScriptEntry(self.scheduler)
    self.target:setPosition(cc.p(self.init_x, self.init_y))
end

return ScreenShaker