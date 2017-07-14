local GamePause = class("GamePause", cc.load("mvc").ViewBase)
local MODULE_PATH = ...

GamePause.RESOURCE_FILENAME = "Node_stop.csb"
GamePause.RESOURCE_BINDING = {
    ["Button_help"] = {varname = "m_btnPlay", events = {{ event = "click", method = "onHelp" }}},
    ["Button_resume"] = {varname = "m_btnShare", events = {{ event = "click", method = "onResume" }}},
    ["Button_menu"] = {varname = "m_btnShop", events = {{ event = "click", method = "onMenu" }}},
    ["CheckBox_sound"] = {varname = "m_checkBoxSound"}
}

function GamePause:ctor(levelIndex)
    self.super.ctor(self)
    self.m_levelIndex = levelIndex
    self.m_checkBoxSound:setSelected(not dd.GameData:isSoundEnable())
    self.m_checkBoxSound:onEvent(handler(self, self.onSoundOnOff))
end

function GamePause:onCreate()
    self:showMask()
    self:getMask():onClick(function ()
        if self.m_imgHelp then
            self.m_imgHelp:removeFromParent()
            self.m_imgHelp = nil
        else
            self:removeFromParent()
        end
    end)
end

function GamePause:onHelp()
    dd.PlaySound("buttonclick.mp3")
    print("GamePause:onHelp")

    local imgHelp = ccui.ImageView:create("help.png", ccui.TextureResType.plistType)
        :setTouchEnabled(true)
        :setSwallowTouches(true)
        :addTo(self)
    imgHelp:onClick(function ( ... )
        self.m_imgHelp:removeFromParent()
        self.m_imgHelp = nil
    end)

    self.m_imgHelp = imgHelp 
end

function GamePause:onResume()
    dd.PlaySound("buttonclick.mp3")
    self:removeFromParent()
end

function GamePause:onMenu()
    dd.PlaySound("buttonclick.mp3")
    local LevelScene = import(".LevelScene", MODULE_PATH)
    local levelScene = LevelScene:create(self.m_levelIndex)
    levelScene:showWithScene("MOVEINL", 0.3)
end

function GamePause:onSoundOnOff()
    dd.PlaySound("buttonclick.mp3")
    dd.GameData:setSoundEnable(not dd.GameData:isSoundEnable())
end

return GamePause