local GamePause = class("GamePause", cc.load("mvc").ViewBase)
local MainScene = import(".MainScene")
local GameScene = import(".GameScene")
GamePause.RESOURCE_FILENAME = "Node_pause.csb"
GamePause.RESOURCE_BINDING = {
    ["Button_menu"] = {varname = "m_btnmenu", events = {{ event = "click", method = "backtomenu" }}},
    ["CheckBox_sound"] = {varname = "m_cksound", events = {{ event = "click", method = "onsound" }}},
    ["Button_resume"] = {varname = "m_btnresume", events = {{ event = "click", method = "onresume" }}},
    ["Button_help"] = {varname = "m_btnhelp", events = {{ event = "click", method = "onhelp" }}}
}

function GamePause:ctor(gameScene)
    self.super.ctor(self)
    self.m_gameScene = gameScene
end

function GamePause:onCreate()
    self:setOpacity(0)
    self:setCascadeOpacityEnabled(true)
    local action = cc.FadeIn:create(0.1)
    self:runAction(action)
    self:showMask()
    -- self:getMask():onClick(function ()
    --     if self.m_imgHelp then
    --         self.m_imgHelp:removeFromParent()
    --         self.m_imgHelp = nil
    --     else
    --         local action2 = cc.FadeOut:create(0.5)
    --         self:runAction(cc.Sequence:create(action2,cc.CallFunc:create(function ( ... )
    --             self:removeFromParent()
    --         end)))
    --     end
    -- end)
end

function GamePause:backtomenu()
    local mainScene = MainScene:create()
    mainScene:showWithScene("FADE",1.0)
end

function GamePause:onresume()
    local action = cc.FadeOut:create(0.1)
        self:runAction(cc.Sequence:create(action2,cc.CallFunc:create(function ( ... )
            self:removeFromParent()
        end)))
    self.m_gameScene:onResume()
end


return GamePause