local ObstaclePower = class("ObstaclePower", function ( ... )
    return cc.Sprite:create()
end)

function ObstaclePower:ctor(pos1, speedVector)
    self:initWithSpriteFrameName("zhangai_nengliangqiu1.png")
    self:setPosition(pos1)

    local frames = display.newFrames("zhangai_nengliangqiu%d.png", 1, 4, true)
    local animation = display.newAnimation(frames, 0.2)
    local action = cc.Animate:create(animation)
    self:runAction(cc.RepeatForever:create(action))


    local body = cc.PhysicsBody:create()
    self:setPhysicsBody(body)
    local size = self:getContentSize()
    local shape = cc.PhysicsShapeCircle:create(size.width/2, cc.PhysicsMaterial(100000, 1, 0))
    shape:setCategoryBitmask(dd.Constants.CATEGORY.OBSTACLE_POWER)
    shape:setContactTestBitmask(dd.Constants.CATEGORY.EXTENDLINE
        + dd.Constants.CATEGORY.EXTENDLINE_BOTH_ENDS + dd.Constants.CATEGORY.BALL)
    shape:setCollisionBitmask(dd.Constants.CATEGORY.EDGE_SEGMENT + dd.Constants.CATEGORY.OBSTACLE_GEAR
        + dd.Constants.CATEGORY.OBSTACLE_POWER)

    body:addShape(shape)
    body:setVelocity(speedVector)

    local collisionNode = cc.Node:create()
        :move(size.width/2, size.height/2)
        :addTo(self)

    local body = cc.PhysicsBody:create()
    collisionNode:setPhysicsBody(body)
    local shape = cc.PhysicsShapeCircle:create(size.width/2, cc.PhysicsMaterial(0, 1, 0))
    shape:setCategoryBitmask(dd.Constants.CATEGORY.OBSTACLE_POWER)
    shape:setContactTestBitmask(0)
    shape:setCollisionBitmask(dd.Constants.CATEGORY.BALL)

    body:addShape(shape)
    body:setDynamic(false)
end

return ObstaclePower