local ShopConfirm = class("ShopConfirm", cc.load("mvc").ViewBase)

ShopConfirm.RESOURCE_FILENAME = "goumaiquedi.csb"
ShopConfirm.RESOURCE_BINDING = {
    ["Image_2"] = {varname = "m_btnCancel", events = {{ event = "click", method = "onCancel" }}},
    ["Image_4"] = {varname = "m_btnOk", events = {{ event = "click", method = "onOk" }}},
    ["BitmapFontLabel_2"] = {varname = "m_labelDiamonds"}
}

function ShopConfirm:ctor(price, callBack)
    self.super.ctor(self)
    print("ShopConfirm:ctor", price, callBack)
    self.m_callBack = callBack
    self.m_labelDiamonds:setString(tostring(price))
    
    self:showMask(nil, 0)
end

function ShopConfirm:onOk()
    self:onClose(true)
end

function ShopConfirm:onCancel()
    self:onClose(false)
end

function ShopConfirm:onClose(val)
    self.m_callBack(val)
    self:removeFromParent()
end

return ShopConfirm