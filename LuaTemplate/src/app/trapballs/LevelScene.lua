local LevelScene = class("LevelScene", cc.load("mvc").ViewBase)
local GameScene = import(".GameScene")
local MODULE_PATH = ...

LevelScene.RESOURCE_FILENAME = "selectlevel.csb"
LevelScene.RESOURCE_BINDING = {
    ["Image_back.Button_back"] = {varname = "m_btnBack", events = {{ event = "click", method = "onBack" }}},
    ["ListView_level"] = {varname = "m_listView"},
    ["BitmapFontLabel_zuanshi"] = {varname = "m_lableDiamonds"}
}

function LevelScene:onCreate()
    local resourceNode = self:getResourceNode()
    resourceNode:setContentSize(display.size)
    ccui.Helper:doLayout(resourceNode)

    self.m_lableDiamonds:setString(tostring(dd.GameData:getDiamonds()))

    self:initListView()
end

function LevelScene:initListView()
    local roundCfg = dd.CsvConf:getRoundCfg() 
    local NodeLevel = import(".NodeLevel", MODULE_PATH)
    
    for index, cfg in ipairs(roundCfg) do
        local oneLevel = NodeLevel:create(index, cfg)
        local size = oneLevel:getContentSize()
        local layout = ccui.Layout:create()
        layout:setContentSize(size)
        layout:addChild(oneLevel)
        oneLevel:setPosition(size.width/2, size.height/2)

        self.m_listView:pushBackCustomItem(layout)
    end

    self.m_listView:setScrollBarEnabled(false)
    local jumpIndex = dd.GameData:getCurLevel()
    -- if jumpIndex >= #roundCfg - 2 then
    --     jumpIndex = jumpIndex - 1
    -- end
    self.m_listView:jumpToPercentVertical((2*jumpIndex - 2)*50/#roundCfg)
    self.m_listView:setScale(dd.Constants.LEVEL_LIST_SCALE)
end

function LevelScene:onBack()
    dd.PlaySound("buttonclick.mp3")
    local MainScene = import(".MainScene", MODULE_PATH)
    local mainScene = MainScene:create()
    mainScene:showWithScene()
end

return LevelScene
