local Star = class("Star", function ()
    return cc.Sprite:create()
end)

function Star:ctor(picName)
    local pic = picName or "ball_white.png"
    self:initWithFile(pic)
end

return Star