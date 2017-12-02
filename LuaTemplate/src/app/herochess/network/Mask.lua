local Mask = class("Mask", cc.Node)

function Mask:ctor()
    self:enableNodeEvents()
    display.getRunningScene():addChild(self, dd.SceneLayerOrder.netMask)
    self:addMaskLayer()

    -- 延迟2秒再显示，提升用户体验
    self.schedulerId_ = dd.scheduler:scheduleScriptFunc(handler(self, self.onTimeOut), 2, false)
end

function Mask:addMaskLayer()
    self.m_maskLayer = ccui.Layout:create()
        :setBackGroundColorType(LAYOUT_COLOR_NONE)
        :setBackGroundColorOpacity(0)
        :setTouchEnabled(true)
        :setSwallowTouches(true)
        :setContentSize(display.size)
        :addTo(self)
end

function Mask:removeMaskLayer()
    if self.m_maskLayer then
        self.m_maskLayer:removeFromParent()
        self.m_maskLayer = nil
    end
end

function Mask:removeSheduler()
    if self.schedulerId_ then
        dd.scheduler:unscheduleScriptEntry(self.schedulerId_)
        self.schedulerId_ = nil
    end
end

function Mask:onTimeOut()
    self:removeSheduler()

    display.newLayer(cc.c4b(0, 0, 0, 150), display.width, display.height):addTo(self)
    ccui.Text:create("Connecting Server...", "", 48):addTo(self):move(display.cx, display.cy)

    -- 总共超时20秒，重登录吧
    self.schedulerId_ = dd.scheduler:scheduleScriptFunc(handler(self, self.onTimeOut2), 18, false)
end

function Mask:onTimeOut2()
    self:removeSheduler()
    --dd.eventDispatcher:dispatchEvent(cc.EventCustom:new(dd.EVENT_NETWORK_TIMEOUT))
end

function Mask:onCleanup()
    self:removeMaskLayer()
    self:removeSheduler()
end

return Mask