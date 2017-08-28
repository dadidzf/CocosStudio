local Plate = class("Plate", function ()
    return cc.Sprite:create()
end)

function Plate:ctor(picName)
    local pic = picName or "btn_backtomenu.png"
    self:initWithFile(pic)
end

return Plate