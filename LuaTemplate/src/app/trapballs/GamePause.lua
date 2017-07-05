local GamePause = class("GamePause", cc.load("mvc").ViewBase)
local MODULE_PATH = ...

GamePause.RESOURCE_FILENAME = "Node_stop.csb"
GamePause.RESOURCE_BINDING = {
    ["Button_help"] = {varname = "m_btnPlay", events = {{ event = "click", method = "onHelp" }}},
    ["Button_resume"] = {varname = "m_btnShare", events = {{ event = "click", method = "onResume" }}},
    ["Button_menu"] = {varname = "m_btnShop", events = {{ event = "click", method = "onMenu" }}},
    ["CheckBox_sound"] = {varname = "m_btnShop"}
}

function GamePause:ctor()
    self.super.ctor(self)
end

function GamePause:onCreate()
    self:showMask()
    self:getMask():onClick(function ()
        self:removeFromParent()
    end)
end

function GamePause:onHelp()
    print("GamePause:onHelp")
end

function GamePause:onResume()
    self:removeFromParent()
end

function GamePause:onMenu()
    local MainScene = import(".MainScene", MODULE_PATH)
    local mainScene = MainScene:create()
    mainScene:showWithScene()
end

return GamePause