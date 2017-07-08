local GamePause = class("GamePause", cc.load("mvc").ViewBase)
local MODULE_PATH = ...

GamePause.RESOURCE_FILENAME = "Node_stop.csb"
GamePause.RESOURCE_BINDING = {
    ["Button_help"] = {varname = "m_btnPlay", events = {{ event = "click", method = "onHelp" }}},
    ["Button_resume"] = {varname = "m_btnShare", events = {{ event = "click", method = "onResume" }}},
    ["Button_menu"] = {varname = "m_btnShop", events = {{ event = "click", method = "onMenu" }}},
    ["CheckBox_sound"] = {varname = "m_checkBoxSound"}
}

function GamePause:ctor()
    self.super.ctor(self)
    self.m_checkBoxSound:setSelected(not dd.GameData:isSoundEnable())
    self.m_checkBoxSound:onEvent(handler(self, self.onSoundOnOff))
end

function GamePause:onCreate()
    self:showMask()
    self:getMask():onClick(function ()
        self:removeFromParent()
    end)
end

function GamePause:onHelp()
    dd.PlaySound("buttonclick.mp3")
    print("GamePause:onHelp")
end

function GamePause:onResume()
    dd.PlaySound("buttonclick.mp3")
    self:removeFromParent()
end

function GamePause:onMenu()
    dd.PlaySound("buttonclick.mp3")
    local MainScene = import(".MainScene", MODULE_PATH)
    local mainScene = MainScene:create()
    mainScene:showWithScene()
end

function GamePause:onSoundOnOff()
    dd.PlaySound("buttonclick.mp3")
    dd.GameData:setSoundEnable(not dd.GameData:isSoundEnable())
end

return GamePause