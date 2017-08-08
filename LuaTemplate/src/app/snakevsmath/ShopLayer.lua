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
    cc.load("sdk").Admob.getInstance():showBanner()
end

function ShopLayer:onCreate()
    local resourceNode = self:getResourceNode()
    resourceNode:setContentSize(display.size)
    ccui.Helper:doLayout(resourceNode)

    self.m_lableDiamonds:setString(tostring(dd.GameData:getDiamonds()))

    self:initListView()

    self:showMask(cc.c3b(27, 27, 27), 255)
    self:getMask():move(display.cx, display.cy)
end

function ShopLayer:initListView()
    local shopNode = import(".ShopNode", MODULE_PATH)
    
    for index, priceTb in ipairs(dd.Constants.SANKE_HEAD_PRICE) do 
        local node = shopNode:create(index, priceTb)
        local size = node:getContentSize()

        local layout = ccui.Layout:create()
        layout:setContentSize(size)
        layout:addChild(node)
        node:setPosition(size.width/2, size.height/2)

        self.m_listView:pushBackCustomItem(layout)
    end

    self.m_listView:setScrollBarEnabled(false)
end

function ShopLayer:onBack()
    dd.PlaySound("button.wav")
    cc.load("sdk").Admob.getInstance():removeBanner()
    self:removeFromParent()
end

return ShopLayer
