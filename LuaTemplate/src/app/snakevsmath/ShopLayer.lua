local ShopLayer = class("ShopLayer", cc.load("mvc").ViewBase)
local MODULE_PATH = ...

ShopLayer.RESOURCE_FILENAME = "shop.csb"
ShopLayer.RESOURCE_BINDING = {
    ["back"] = {varname = "m_btnBack", events = {{ event = "click", method = "onBack" }}},
    ["listView"] = {varname = "m_listView"},
    ["diamondNum"] = {varname = "m_lableDiamonds"}
}

function ShopLayer:ctor(jumpIndex)
    self.super.ctor(self)
    cc.load("sdk").Admob.getInstance():showBanner(0, 0)

    self:addTouch()
end

function ShopLayer:addTouch()
    local listener = cc.EventListenerTouchOneByOne:create()
    listener:registerScriptHandler(handler(self, self.onTouchBegin), cc.Handler.EVENT_TOUCH_BEGAN)
    listener:registerScriptHandler(handler(self, self.onTouchMoved), cc.Handler.EVENT_TOUCH_MOVED)

    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self)
end

function ShopLayer:onTouchBegin(touch, event)
    self.m_alreadyMoved = false
    self.m_beginPos = touch:getLocation()
    return true
end

function ShopLayer:onTouchMoved(touch, event)
    local pos = touch:getLocation()
    if cc.pGetLength(cc.pSub(self.m_beginPos, pos)) > 6 then
        self.m_alreadyMoved = true
    end
end

function ShopLayer:isAlreadyMoved()
    return self.m_alreadyMoved
end

function ShopLayer:onCreate()
    local resourceNode = self:getResourceNode()
    resourceNode:setContentSize(display.size)
    ccui.Helper:doLayout(resourceNode)

    self.m_lableDiamonds:setString(tostring(dd.GameData:getDiamonds()))

    self:showMask(cc.c3b(27, 27, 27), 255)
    self:getMask():move(display.cx, display.cy)

    self:initListView()
end

function ShopLayer:initListView()
    self.m_nodeList = {}
    local shopNode = import(".ShopNode", MODULE_PATH)
    
    for index, priceTb in ipairs(dd.Constants.SANKE_HEAD_PRICE) do 
        local node = shopNode:create(self, index, priceTb)
        self.m_nodeList[index] = node
        local size = node:getContentSize()

        local layout = ccui.Layout:create()
        layout:setContentSize(size)
        layout:addChild(node)

        --node:setPosition(size.width/2, size.height/2)
        node:move(size.width/2 + size.width, size.height/2)
        node:runAction(cc.Sequence:create(
            cc.DelayTime:create((index - 1)*0.1),
            cc.MoveTo:create(0.2, cc.p(size.width/2, size.height/2))
            ))

        self.m_listView:pushBackCustomItem(layout)
    end

    self.m_listView:setScrollBarEnabled(false)

    self:updateSelectedIndex()
end

function ShopLayer:updateSelectedIndex()
    if self.m_lastSelectedIndex then
        local lastNode = self.m_nodeList[math.floor((self.m_lastSelectedIndex - 1)/4) + 1]
        lastNode:setSelected((self.m_lastSelectedIndex - 1)%4 + 1, false)
    end

    local curSelectedIndex = dd.GameData:getHeadIndex()
    print("ShopLayer:updateSelectedIndex", curSelectedIndex)
    local curNode = self.m_nodeList[math.floor((curSelectedIndex - 1)/4) + 1]
    curNode:setSelected((curSelectedIndex - 1)%4 + 1, true)

    self.m_lastSelectedIndex = curSelectedIndex
    
    self.m_lableDiamonds:setString(tostring(dd.GameData:getDiamonds()))
end

function ShopLayer:onBack()
    dd.PlaySound("button.wav")
    cc.load("sdk").Admob.getInstance():removeBanner()
    self:removeFromParent()
end

return ShopLayer
