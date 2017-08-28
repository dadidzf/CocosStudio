local Food = class("Food", function ()
    return cc.Sprite:create()
end)

function Food:ctor(picName)
    local pic = picName or "1.png"
    self:initWithFile(pic)
end

return Food
