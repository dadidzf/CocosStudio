
local ViewBase = class("ViewBase", cc.Node)

function ViewBase:ctor(app, name)
    self:enableNodeEvents()
    self.app_ = app
    self.name_ = name

    -- check CSB resource file
    local res = rawget(self.class, "RESOURCE_FILENAME")
    if res then
        self:createResourceNode(res)
    end

    local binding = rawget(self.class, "RESOURCE_BINDING")
    if res and binding then
        self:createResourceBinding(binding)
    end

    if self.onCreate then self:onCreate() end
end

function ViewBase:getApp()
    return self.app_
end

function ViewBase:getName()
    return self.name_
end

function ViewBase:getResourceNode()
    return self.resourceNode_
end

function ViewBase:createResourceNode(resourceFilename)
    if self.resourceNode_ then
        self.resourceNode_:removeSelf()
        self.resourceNode_ = nil
    end
    self.resourceNode_ = cc.CSLoader:createNode(cc.load("sdk").Tools.getLanguageDependPathForRes(resourceFilename))
    assert(self.resourceNode_, string.format("ViewBase:createResourceNode() - load resouce node from file \"%s\" failed", resourceFilename))
    self:addChild(self.resourceNode_)
end

function ViewBase:createResourceBinding(binding)
    assert(self.resourceNode_, "ViewBase:createResoueceBinding() - not load resource node")
    cc.load("sdk").BindingUtil.binding(self, self.resourceNode_, binding)
end

function ViewBase:showWithScene(transition, time, more)
    self:setVisible(true)
    local scene = display.newScene(self.name_)
    scene:addChild(self)
    display.runScene(scene, transition, time, more)
    return self
end

function ViewBase:showMask(color, opacity)
    color = color or cc.BLACK
    opacity = opacity or 180
    if self.m_maskLayer then
        self.m_maskLayer:removeFromParent()
    end
    
    self.m_maskLayer = ccui.Layout:create()
        :setBackGroundColorType(LAYOUT_COLOR_SOLID)
        :setBackGroundColor(color)
        :setBackGroundColor(cc.c3b(0, 0, 0))
        :setBackGroundColorOpacity(opacity)
        :setTouchEnabled(true)
        :setSwallowTouches(true)
        :setContentSize(display.size)
        :setAnchorPoint(cc.p(0.5, 0.5))
        :addTo(self, -1)
end

function ViewBase:getMask()
    return self.m_maskLayer
end

return ViewBase
