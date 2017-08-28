local ChooseFoodScene = class("ChooseFoodScene", cc.load("mvc").ViewBase)

ChooseFoodScene.RESOURCE_FILENAME = "choosefoodscene.csb"
LevelScene.RESOURCE_BINDING = {
    ["Button_back"] = {varname = "m_btnBack", events = {{ event = "click", method = "onBack" }}},
    ["ListView_1"] = {varname = "m_listView1"},
    ["ListView_2"] = {varname = "m_listView2"}
}

function ChooseFoodScene:onCreate()
    local resourceNode = self:getResourceNode()
    resourceNode:setContentSize(display.size)
    ccui.Helper:doLayout(resourceNode)


end

return ChooseFoodScene