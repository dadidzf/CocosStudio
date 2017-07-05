local GameScene = class("GameScene", cc.load("mvc").ViewBase)
local GameNode = import(".GameNode")
local MODULE_PATH = ...

GameScene.RESOURCE_FILENAME = "game.csb"
GameScene.RESOURCE_BINDING = {
    ["Image_stop.Button_stop"] = {varname = "m_btnPause", events = {{ event = "click", method = "onPause" }}},
    ["BitmapFontLabel_roundnumber"] = {varname = "m_labelRoundNum"},
    ["BitmapFontLabel_stepnuber"] = {varname = "m_labelStepNum"},
    ["BitmapFontLabel_topnumber"] = {varname = "m_labelTopCollisionNum"},
    ["Image_horizontal"] = {varname = "m_picHorizontal"},
    ["Image_certical"] = {varname = "m_picVertical"},

    ["Image_daoju1"] = {varname = "m_prop1"},
    ["Image_daoju2"] = {varname = "m_prop2"},
    ["Image_daoju3"] = {varname = "m_prop3"},
}

function GameScene:ctor(levelIndex)
    self.super.ctor(self)
    print("GameScene:ctor", levelIndex)
    self.m_labelRoundNum:setString(tostring(levelIndex))

    self:showRandBg()
    self:showProps()
end

function GameScene:showRandBg()
    local resourceNode = self:getResourceNode()
    for _, v in pairs(dd.CsvConf:getColorCfg()) do
        resourceNode:getChildByName(v.image_di):setVisible(false)
    end

    local randomShow = dd.CsvConf:getRandomBgAndBtn()
    resourceNode:getChildByName(randomShow.image_di):setVisible(true)

    local color = dd.YWStrUtil:parse(randomShow.box_color)
    --self.m_boxColor = cc.c4f(color[1]/255, color[2]/255, color[3]/255, 1)
end

function GameScene:showProps()
    self.m_propList = {self.m_prop1, self.m_prop2, self.m_prop3}

    for _, prop in ipairs(self.m_propList) do
        prop:setVisible(false)
    end
end

function GameScene:onPause()
    local GamePause = import(".GamePause", MODULE_PATH)
    local pauseNode = GamePause:create()
    pauseNode:setPosition(display.cx, display.cy)
    self:addChild(pauseNode, 2)
end

function GameScene:onCreate()
    local resourceNode = self:getResourceNode()
    resourceNode:setContentSize(display.size)
    ccui.Helper:doLayout(resourceNode)
    
    self.m_node = GameNode:create(self)
        :move(display.cx, display.cy)
        :addTo(self)

    self.m_node:setScale(dd.Constants.NODE_SCALE)
end

function GameScene:getValidSpriteFrame(location)
    local pos = self.m_picHorizontal:convertToNodeSpace(location)
    local size = self.m_picHorizontal:getContentSize()
    local rect = cc.rect(0, 0, size.width, size.height)

    if cc.rectContainsPoint(rect, pos) then
        return self.m_picHorizontal:getVirtualRenderer():getSprite():getSpriteFrame(), true, 
            self.m_picHorizontal:convertToWorldSpace(cc.p(size.width/2, size.height/2))
    end

    pos = self.m_picVertical:convertToNodeSpace(location)
    if cc.rectContainsPoint(rect, pos) then
        return self.m_picVertical:getVirtualRenderer():getSprite():getSpriteFrame(), false, 
            self.m_picVertical:convertToWorldSpace(cc.p(size.width/2, size.height/2))
    end
end

function GameScene:showWithScene(transition, time, more)
    self:setVisible(true)
    local scene = display.newScene(self.name_, {physics = true})
    scene:addChild(self)
    display.runScene(scene, transition, time, more)

    local physicWorld = scene:getPhysicsWorld()
    --physicWorld:setDebugDrawMask(cc.PhysicsWorld.DEBUGDRAW_ALL)
    physicWorld:setGravity(cc.p(0, 0))
    return self
end

return GameScene 
