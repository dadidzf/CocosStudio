local ObstacleGear = class("ObstacleGear", function ( ... )
    return cc.Sprite:create()
end)

function ObstacleGear:ctor(pos1, pos2, speed)
    self:initWithSpriteFrameName("zhangai_chilun.png")
    self:setPosition(pos1)
    local length = cc.pGetLength(cc.pSub(pos1, pos2))
    local t = length/speed

    self:runAction(cc.RepeatForever:create(
            cc.Sequence:create(
            cc.MoveTo:create(t, pos2),
            cc.MoveTo:create(t, pos1),
            nil
            )
        )
    )

    self:setScaleX(-1)
    self:runAction(cc.RepeatForever:create(
        cc.RotateBy:create(2.0, 360)
        )
    )

    local body = cc.PhysicsBody:create()
    self:setPhysicsBody(body)
    local size = self:getContentSize()
    local shape = cc.PhysicsShapeCircle:create(size.width/2 - 10, cc.PhysicsMaterial(0, 1, 0))
    shape:setCategoryBitmask(dd.Constants.CATEGORY.OBSTACLE_GEAR)
    shape:setContactTestBitmask(dd.Constants.CATEGORY.EXTENDLINE 
        + dd.Constants.CATEGORY.EXTENDLINE_BOTH_ENDS + dd.Constants.CATEGORY.EDGE_SEGMENT)
    shape:setCollisionBitmask(dd.Constants.CATEGORY.BALL + dd.Constants.CATEGORY.OBSTACLE_POWER)

    body:addShape(shape)
    body:setDynamic(false)
end

return ObstacleGear