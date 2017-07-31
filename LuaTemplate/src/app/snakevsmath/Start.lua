local Start = class("Start", cc.load("mvc").ViewBase)
local MODULE_PATH = ...

Start.RESOURCE_FILENAME = "Start.csb"
Start.RESOURCE_BINDING = {
    -- ["Button_help"] = {varname = "m_btnPlay", events = {{ event = "click", method = "onHelp" }}},
    -- ["Button_resume"] = {varname = "m_btnShare", events = {{ event = "click", method = "onResume" }}},
    -- ["Button_menu"] = {varname = "m_btnShop", events = {{ event = "click", method = "onMenu" }}},
    -- ["CheckBox_sound"] = {varname = "m_checkBoxSound"}
}

function Start:ctor()
    self.super.ctor(self)
    
    local resourceNode = self:getResourceNode()
    resourceNode:setContentSize(display.size)
    ccui.Helper:doLayout(resourceNode)
end

return Start