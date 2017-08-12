local MainScene = class("MainScene", cc.load("mvc").ViewBase)
local GameScene = import(".GameScene")

MainScene.RESOURCE_FILENAME = "menu.csb"
MainScene.RESOURCE_BINDING = {
    ["Button_play"] = {varname = "m_btnPlay", events = {{ event = "click", method = "onPlay" }}},
    ["Button_exit"] = {varname = "m_btnExit", events = {{ event = "click", method = "onExit" }}},
    ["BitmapFontLabel_0"] = {varname = "m_title"},
    ["BitmapFontLabel_1"] = {varname = "m_txtPlay"},
    ["BitmapFontLabel_2"] = {varname = "m_txtExit"}
}

local Star = import(".Star")

function MainScene:onCreate()

    local resourceNode = self:getResourceNode()
    resourceNode:setContentSize(display.size)
    ccui.Helper:doLayout(resourceNode)

    self.m_txtPlay:setOpacity(0)
    self.m_txtExit:setOpacity(0)
    self.m_title:setOpacity(0)
    local action1 = cc.FadeIn:create(1)
    local action2 = cc.FadeIn:create(1)
    local action3 = cc.FadeIn:create(1)
    self.m_txtPlay:runAction(action1)
    self.m_txtExit:runAction(action2)
    self.m_title:runAction(action3)

    local star = Star:create(nil)
    star:setPosition(cc.p(display.cx - 200, 580))
    
    local move1 = cc.MoveBy:create(4, cc.p(400, 0))
    local move2 = cc.MoveBy:create(4, cc.p(-400, 0))

    local move_ease_inout1 = cc.EaseInOut:create(move1, 2)
    local move_ease_inout2 = cc.EaseInOut:create(move2, 2)

    local act = cc.Sequence:create(move_ease_inout1, move_ease_inout2)
    self.m_act = cc.RepeatForever:create(act)
    star:runAction(self.m_act)

    self:addChild(star, 1)

    local meteor = cc.ParticleMeteor:create()
    meteor:setTexture(cc.Director:getInstance():getTextureCache():addImage("ball_white.png"))
    meteor:setPosition(12.5, 12.5)
    meteor:setSpeed(100)
    meteor:setDuration(-1)--设置持续时间-1为永久
    meteor:setStartSize(20)
    meteor:setEndSize(50)
    meteor:setGravity(cc.p(0,-1000))--设置引力值
    meteor:setAngle(1)--设置角度
    meteor:setLife(0.25)
    meteor:setEmissionRate(120)--发射频率
    star:addChild(meteor)
end

function MainScene:onPlay()
	print("......")
    local gameScene = GameScene:create()
    dd.PlaySound("buttonclick.mp3")
    -- print("gameScene - ", gameScene)
    -- local scene = display.newScene("gameScene")
    -- scene:addChild(gameScene)
    -- local tr = cc.TransitionJumpZoom:create(1.0, scene)
    -- cc.Director:getInstance():pushScene(tr)
    gameScene:showWithScene("FADE",1.5)

end


return MainScene