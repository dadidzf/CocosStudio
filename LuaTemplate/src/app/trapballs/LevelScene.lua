local LevelScene = class("LevelScene", cc.load("mvc").ViewBase)
local GameScene = import(".GameScene")
local MODULE_PATH = ...

LevelScene.RESOURCE_FILENAME = "selectlevel.csb"
LevelScene.RESOURCE_BINDING = {
    ["Image_back.Button_back"] = {varname = "m_btnBack", events = {{ event = "click", method = "onBack" }}},
    ["ListView_level"] = {varname = "m_listView"},
}

function LevelScene:ctor(jumpIndex)
    print("LevelScene:ctor -------------------------- ", jumpIndex)
    self.m_jumpIndex = jumpIndex
    self.super.ctor(self)
end

function LevelScene:onCreate()
    local resourceNode = self:getResourceNode()
    resourceNode:setContentSize(display.size)
    ccui.Helper:doLayout(resourceNode)

    self:initListView()
end

function LevelScene:initListView()
    local roundCfg = dd.CsvConf:getRoundCfg() 
    local NodeLevel = import(".NodeLevel", MODULE_PATH)
    
    local jumpIndex = self.m_jumpIndex or dd.GameData:getCurLevel()
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
