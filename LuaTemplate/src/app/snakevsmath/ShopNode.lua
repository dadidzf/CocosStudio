local ShopNode = class("ShopNode", cc.load("mvc").ViewBase)

ShopNode.RESOURCE_FILENAME = "ShopNode.csb"
ShopNode.RESOURCE_BINDING = {
    ["di"] = {varname = "m_bg1", events = {{ event = "click", method = "onSelect1" }}},
    ["di_0"] = {varname = "m_bg2", events = {{ event = "click", method = "onSelect2" }}},
    ["di_1"] = {varname = "m_bg3", events = {{ event = "click", method = "onSelect3" }}},
    ["di_2"] = {varname = "m_bg4", events = {{ event = "click", method = "onSelect4" }}}
}

function ShopNode:ctor(owner, index, priceTb)
    self.super.ctor(self)

    self.m_owner = owner
    index = index - 1

    local unLockedList = {} 
    local indexList = {}
    for i = 1, 4 do
        unLockedList[i] = dd.GameData:isHeadIndexUnlocked(index*4 + i)
        indexList[i] = index*4 + i
    end

    self.m_diList = {self.m_bg1, self.m_bg2, self.m_bg3, self.m_bg4}
    self.m_headList = {}

    for i, bg in ipairs(self.m_diList) do
        if priceTb[i] then
            bg:setSwallowTouches(false)
            local box = bg:getChildByName("kuang")
            local balloon = bg:getChildByName("qiqiu")
            local price = bg:getChildByName("price")
            local bgSize = bg:getContentSize()

            balloon:setVisible(not unLockedList[i])
            price:setString(tostring(priceTb[i]))
            price:setVisible(not unLockedList[i])
            box:setVisible(false)

            local headName = string.format("t%d.png", indexList[i])
            local head = display.newSprite("#"..headName)
                :move(bgSize.width/2, bgSize.height/2)
                :addTo(bg)
            if not unLockedList[i] then
                head:setOpacity(0)
            end

            self.m_headList[i] = head
        else
            bg:setVisible(false)
        end
    end

    self.m_indexList = indexList
    self.m_priceTb = priceTb
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
    if not self.m_owner:isAlreadyMoved() then
        dd.PlaySound("button.wav")

        if dd.GameData:isHeadIndexUnlocked(self.m_indexList[index]) then
            dd.GameData:setHeadIndex(self.m_indexList[index])
            self.m_owner:updateSelectedIndex()
        else
            local diamonds = dd.GameData:getDiamonds()
            if diamonds >= self.m_priceTb[index] then
                local callBackFunc = function (val)
                    if val then
                        dd.GameData:refreshDiamonds(diamonds - self.m_priceTb[index])
                        dd.GameData:setHeadIndex(self.m_indexList[index])
                        dd.GameData:setHeadIndexUnlocked(self.m_indexList[index])
                        self.m_owner:updateSelectedIndex()
                    end
                end
                self.m_owner:showConfirmView(self.m_priceTb[index], callBackFunc)
            else
                self.m_owner:showLackDiamondsTips()
            end
        end
    end
end

function ShopNode:setSelected(index, isSelected)
    local bg = self.m_diList[index] 
    local box = bg:getChildByName("kuang")
    local balloon = bg:getChildByName("qiqiu")
    local price = bg:getChildByName("price")

    if isSelected then
        box:setVisible(true)
        balloon:setVisible(false)
        price:setVisible(false)
        self.m_headList[index]:setOpacity(255)
    else
        box:setVisible(false)
    end
end

function ShopNode:getContentSize()
    return cc.size(300, 160)
end

return ShopNode