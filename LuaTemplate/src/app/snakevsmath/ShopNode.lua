local ShopNode = class("ShopNode", cc.load("mvc").ViewBase)

ShopNode.RESOURCE_FILENAME = "ShopNode.csb"
ShopNode.RESOURCE_BINDING = {
    ["di"] = {varname = "m_bg1", events = {{ event = "click", method = "onSelect1" }}},
    ["di_0"] = {varname = "m_bg2", events = {{ event = "click", method = "onSelect2" }}},
    ["di_1"] = {varname = "m_bg3", events = {{ event = "click", method = "onSelect3" }}},
    ["di_2"] = {varname = "m_bg4", events = {{ event = "click", method = "onSelect4" }}},
}

function ShopNode:ctor(index, priceTb)
    self.super.ctor(self)

    local visibleBg = self.m_bg1
    visibleBg:onTouch(function (event)
        if event.name == "began" then
            self.m_alreadyMoved = false
        elseif event.name == "moved" then
            local beginPos = visibleBg:getTouchBeganPosition()
            local movePos = visibleBg:getTouchMovePosition()
            if cc.pGetLength(cc.pSub(movePos, beginPos)) > 6 then
                self.m_alreadyMoved = true
            end
        end
    end)

    self.m_diList = {self.m_bg1, self.m_bg2, self.m_bg3, self.m_bg4}

    for _, bg in ipairs(self.m_diList) do
        bg:setSwallowTouches(false)
        bg:getChildByName("kuang"):setVisible(false)
    end
end

function ShopNode:onSelect1()
    self:onSelect(1)
end

function ShopNode:onSelect2()
    self:onSelect(2)
end

function ShopNode:onSelect3()
    self:onSelect(3)
end

function ShopNode:onSelect4()
    self:onSelect(4)
end

function ShopNode:onSelect(index)
    if not self.m_alreadyMoved then
        dd.PlaySound("button.wav")
    end
end

function ShopNode:getContentSize()
    return cc.size(300, 160)
end

return ShopNode