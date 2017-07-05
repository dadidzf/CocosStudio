local GameEnd = class("GameEnd", cc.load("mvc").ViewBase)
local MODULE_PATH = ...

GameEnd.RESOURCE_FILENAME = "Node_gamepass.csb"
GameEnd.RESOURCE_BINDING = {
    -- ["Button_help"] = {varname = "m_btnPlay", events = {{ event = "click", method = "onHelp" }}},
    -- ["Button_resume"] = {varname = "m_btnShare", events = {{ event = "click", method = "onResume" }}},
    -- ["Button_menu"] = {varname = "m_btnShop", events = {{ event = "click", method = "onMenu" }}},
    -- ["CheckBox_sound"] = {varname = "m_btnShop"}
}

function GameEnd:ctor()
    self.super.ctor(self)
end

function GameEnd:onCreate()
    self:showMask()
end

return GameEnd