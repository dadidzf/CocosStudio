local MainScene = class("MainScene", cc.load("mvc").ViewBase)
local GameScene = import(".GameScene")

MainScene.RESOURCE_FILENAME = "menu.csb"
MainScene.RESOURCE_BINDING = {
    ["Button_play"] = {varname = "m_btnPlay", events = {{ event = "click", method = "onPlay" }}}
    -- ["Login.PanelU.txtUsername"] = { varname = "txtUsername" },
    -- ["Login.PanelP.txtPassword"] = { varname = "txtPassword" },  
}

function MainScene:onCreate()
    self:getResourceNode():setContentSize(display.size)
    ccui.Helper:doLayout(self:getResourceNode())
    -- self:getResourceNode():setAnchorPoint(cc.p(0.5, 0.5))
    -- self:getResourceNode():move(display.cx, display.cy)
end

function MainScene:onPlay()
    local gameScene = GameScene:create()
    gameScene:showWithScene()
end

return MainScene
