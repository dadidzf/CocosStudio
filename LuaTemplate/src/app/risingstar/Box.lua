local Box = class("Box", function ()
    return cc.Sprite:create()
end)

function Box:ctor(picName)
    local pic = picName or "button_purple.png"
    self:initWithFile(pic)
end

return Box