local NewGuideController = class("NewGuideController")

function NewGuideController:ctor(gameScene, levelIndex)
    self:reset(gameScene, levelIndex)
end

function NewGuideController:reset(gameScene, levelIndex)
    self.m_gameScene = gameScene

    if levelIndex == 1 then
        self.m_showNewGuide = true
    else
        self.m_showNewGuide = false
    end

    self.m_speed = 150
    self:clear()

    self.m_curStep = 0
    self.m_tipsDisplayTime = 6.0
end

function NewGuideController:clear()
    self:removeTips()
    self:removeHands()
    self:removeMask()
    self:removeDestImg()
end

function NewGuideController:controlBalls(ballsList)
    if not self.m_showNewGuide then
        return
    end 

    local ball = ballsList[1]
    self.m_controlBall = ball
    ball:getPhysicsBody():setVelocity(cc.p(0, 0))
    ball:setPosition(cc.p(0, 0))

    self.m_controlBall:runAction(cc.Sequence:create(
        cc.MoveTo:create(150/self.m_speed, cc.p(-150, 0)),
        cc.CallFunc:create(function ()
            self:step1()
        end)
        ))

end

function NewGuideController:step1()
    self.m_curStep = 1
    self:showTips(cc.p(display.cx, display.height*0.7))

    local picVertical = self.m_gameScene:getPicVertical()
    local pos1 = cc.p(picVertical:getPositionX(), picVertical:getPositionY())
    local pos2 = self.m_gameScene:convertToNodeSpace(
        self.m_gameScene:getGameNode():convertToWorldSpace(cc.p(150, 0)))
    self:showHands(pos1, pos2)
end

function NewGuideController:step2()
    self.m_curStep = 2 

    self:showTips(self.m_gameScene:getImgCirclePos()) 
    self.m_gameScene:runAction(cc.Sequence:create(
        cc.DelayTime:create(self.m_tipsDisplayTime),
        cc.CallFunc:create(function ( ... )
            self:removeTips()
            self:step3()
        end)
        ))
end

function NewGuideController:step3()
    local speed = 300
    self.m_controlBall:runAction(cc.Sequence:create(
        cc.MoveTo:create(150/self.m_speed, cc.p(-300, 0)),
        cc.CallFunc:create(function ()
            self.m_curStep = 3
            self:showTips(cc.p(display.cx, display.height*0.7))
            local picHorizontal = self.m_gameScene:getPicHorizontal()
            local pos1 = cc.p(picHorizontal:getPositionX(), picHorizontal:getPositionY())
            local pos2 = self.m_gameScene:convertToNodeSpace(
                self.m_gameScene:getGameNode():convertToWorldSpace(cc.p(0, 0)))
                self:showHands(pos1, pos2)
                end)
        ))
end

function NewGuideController:step4()
    self.m_curStep = 4
    self:showTips(self.m_gameScene:convertToNodeSpace(
        self.m_gameScene:getGameNode():convertToWorldSpace(cc.p(-20, -20))))

    self.m_gameScene:runAction(cc.Sequence:create(
        cc.DelayTime:create(self.m_tipsDisplayTime),
        cc.CallFunc:create(function ( ... )
            self:removeTips()
            self.m_controlLine:resume()
            self.m_gameScene:getParent():getPhysicsWorld():setAutoStep(true)
        end)
        ))
end

function NewGuideController:step5()
    self.m_curStep = 5
    self:showTips(cc.p(display.cx, display.height*0.7))
    self.m_controlBall:getPhysicsBody():setVelocity(cc.p(0, 0))
    self.m_gameScene:runAction(cc.Sequence:create(
        cc.DelayTime:create(self.m_tipsDisplayTime),
        cc.CallFunc:create(function ( ... )
        self.m_controlBall:getPhysicsBody():setVelocity(cc.p(-150, 0))
            self:removeTips()
            self:step6()
        end)
        ))
end

function NewGuideController:step6()
    self.m_curStep = 6
    self:showTips(cc.p(display.cx, display.height*0.7))
    self.m_gameScene:runAction(cc.Sequence:create(
        cc.DelayTime:create(self.m_tipsDisplayTime),
        cc.CallFunc:create(function ( ... )
            self:clear()
        end)
        ))
    
    self.m_showNewGuide = false
end

function NewGuideController:showTips(pos)
    local tipsCsbNameList = {
        "tips/Node_tips1.csb",
        "tips/Node_tips2.csb",
        "tips/Node_tips3.csb",
        "tips/Node_tips5.csb",
        "tips/Node_tips4.csb",
        "tips/Node_tips6.csb"
    }

    self.m_tipsNode = cc.CSLoader:createNode(
        cc.load("sdk").Tools.getLanguageDependPathForRes(tipsCsbNameList[self.m_curStep]))
        :move(pos)

    self.m_tipsNode:setOpacity(0)
    self.m_tipsNode:runAction(cc.FadeIn:create(0.5))

    self.m_gameScene:addChild(self.m_tipsNode, 100)
end

function NewGuideController:removeTips()
    if self.m_tipsNode then
        self.m_tipsNode:removeFromParent()
        self.m_tipsNode = nil
    end
end

function NewGuideController:showHands(pos1, pos2)
    self.m_imgHand = display.newSprite("#hand.png")
        :move(pos1)
        :setAnchorPoint(cc.p(0, 1))
        :setScale(0.6)
        :addTo(self.m_gameScene, 100)
    self.m_imgHand:runAction(cc.RepeatForever:create(
        cc.Sequence:create(
            cc.MoveTo:create(2.0, pos2),
            cc.CallFunc:create(function ()
                self.m_imgHand:move(pos1)
            end),
            nil
            )
    ))

    self.m_destImg = display.newSprite("#teachlevel.png")
        :move(pos2)
        :setVisible(false)
        :addTo(self.m_gameScene, 100)
end

function NewGuideController:removeHands()
    if self.m_imgHand then
        self.m_imgHand:removeFromParent()
        self.m_imgHand = nil
    end
end

function NewGuideController:removeDestImg()
    if self.m_destImg then
        self.m_destImg:removeFromParent()
        self.m_destImg = nil
    end
end

function NewGuideController:checkDirection(isHorizontal)
    if not self.m_showNewGuide then
        return true
    end

    if self.m_curStep == 1 and not isHorizontal then
        return true
    elseif self.m_curStep == 3 and isHorizontal then
        return true
    end

    return false
end

function NewGuideController:onTopCollision(collisionPos)
    if self.m_curStep == 4 then
        self:step5()
    end
end

function NewGuideController:onIconStartMoved(extendLine)
    if not self.m_showNewGuide then
        return
    end 

    self:showMask()
    extendLine.m_icon:setGlobalZOrder(10)
    self.m_destImg:setVisible(true)
    self.m_imgHand:setVisible(false)
end

function NewGuideController:onIconPlaced(extendLine)
    if not self.m_showNewGuide then
        return true
    end 

    local pos = self.m_gameScene:convertToNodeSpace(
        extendLine:convertToWorldSpace(cc.p(0, 0)))

    self:removeMask()
    if cc.rectContainsPoint(self.m_destImg:getBoundingBox(), pos) then
        self:removeDestImg()
        self:removeHands()
        self:removeTips()
        if self.m_curStep == 1 then
            extendLine:setPosition(cc.p(150, 0))
            self:step2()
        end
        
        if self.m_curStep == 3 then
            extendLine:setPosition(cc.p(0, 0))
            self.m_controlBall:getPhysicsBody():setVelocity(cc.p(self.m_speed, 0))
            self.m_gameScene:runAction(cc.Sequence:create(
                cc.DelayTime:create(0.3),
                cc.CallFunc:create(function ( ... )
                    self.m_controlLine = extendLine
                    extendLine:pause()
                    self.m_gameScene:getParent():getPhysicsWorld():setAutoStep(false)
                    self:step4()
                end)
                ))
        end
        return true
    else
        self.m_destImg:setVisible(false)
        self.m_imgHand:setVisible(true)
        return false
    end
end

function NewGuideController:showMask(color, opacity)
    color = color or cc.BLACK
    opacity = opacity or 180
    if self.m_maskLayer then
        self.m_maskLayer:removeFromParent()
    end
    
    self.m_maskLayer = ccui.Layout:create()
        :setBackGroundColorType(LAYOUT_COLOR_SOLID)
        :setBackGroundColor(color)
        :setBackGroundColor(cc.c3b(0, 0, 0))
        :setBackGroundColorOpacity(opacity)
        :setTouchEnabled(true)
        :setSwallowTouches(true)
        :setContentSize(display.size)
        :move(display.cx, display.cy)
        :setAnchorPoint(cc.p(0.5, 0.5))
        :addTo(self.m_gameScene, 99)

    self.m_maskLayer:setOpacity(0)
    self.m_maskLayer:runAction(cc.FadeIn:create(0.3))
end

function NewGuideController:removeMask()
    if self.m_maskLayer then
        local mask = self.m_maskLayer
        self.m_maskLayer:runAction(cc.Sequence:create(
            cc.FadeOut:create(0.3),
            cc.CallFunc:create(function ( ... )
                mask:removeFromParent()
            end)
            ))

        self.m_maskLayer = nil
    end
end


return NewGuideController