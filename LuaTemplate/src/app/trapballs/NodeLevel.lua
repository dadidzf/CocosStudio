local NodeLevel = class("Level", cc.load("mvc").ViewBase)
local GameScene = import(".GameScene")

NodeLevel.RESOURCE_FILENAME = "Node_level.csb"
NodeLevel.RESOURCE_BINDING = {
    ["Image_1"] = {varname = "m_bg1"},
    ["Image_2"] = {varname = "m_bg2"},
    ["Image_3"] = {varname = "m_bg3"},
    ["Image_4"] = {varname = "m_bg4"},
    ["Image_5"] = {varname = "m_bg5"},
    ["Image_6"] = {varname = "m_bg6"},
    ["Image_7"] = {varname = "m_bg7"},
    ["Image_lock"] = {varname = "m_bgLock"},
    ["BitmapFontLabel_ballnumber"] = {varname = "m_labelBallNumber"},
    ["BitmapFontLabel_roundnumber"] = {varname = "m_labelRoundNumber"},
    ["BitmapFontLabel_step1"] = {varname = "m_labelFirstScore"},
    ["BitmapFontLabel_step2"] = {varname = "m_labelSecondScore"},
    ["BitmapFontLabel_step3"] = {varname = "m_labelThirdScore"},
    ["Button_choose"] = {varname = "m_btnSelectLevel", events = {{ event = "click", method = "onSelectLevel" }}}
}

function NodeLevel:ctor(index, cfg)
    self.m_index = index 

    self.super.ctor(self)
    self.m_labelRoundNumber:setString(tostring(index))
    local ballsSetting = dd.YWStrUtil:parse(cfg.ball_setting)
    self.m_labelBallNumber:setString(#ballsSetting)
    self.m_labelBallNumber:setVisible(false)

    self.m_btnSelectLevel:setSwallowTouches(false)

    self.m_bgList = {self.m_bg1, self.m_bg2, self.m_bg3, self.m_bg4, self.m_bg5, self.m_bg6, self.m_bg7}
    for _, bg in ipairs(self.m_bgList) do
        bg:setVisible(false)
    end

    local visibleBg = self.m_bgList[(index - 1)%(#self.m_bgList) + 1]
    visibleBg:setTouchEnabled(true)
    visibleBg:setSwallowTouches(false)
    visibleBg:setVisible(true)
    visibleBg:onTouch(function (event)
        if event.name == "began" then
            self.m_alreadyMoved = false
        elseif event.name == "moved" then
            local beginPos = visibleBg:getTouchBeganPosition()
            local movePos = visibleBg:getTouchMovePosition()
            if cc.pGetLength(cc.pSub(movePos, beginPos)) > 6 then
                self.m_alreadyMoved = true
            end
        end
    end)

    if index > dd.GameData:getCurLevel() then
        self.m_bgLock:setVisible(true)
        self.m_btnSelectLevel:setTouchEnabled(false)
    else
        self.m_bgLock:setVisible(false)
    end

    local topThree = dd.GameData:getLevelTopThree(index)
    self.m_labelFirstScore:setString(tostring(topThree[1]))
    self.m_labelSecondScore:setString(tostring(topThree[2]))
    self.m_labelThirdScore:setString(tostring(topThree[3]))
end

function NodeLevel:onSelectLevel()
    if not self.m_alreadyMoved then
        print("NodeLevel:onSelectLevel", self.m_index)
        local gameScene = GameScene:create(self.m_index)
        gameScene:showWithScene("MOVEINR", 0.3)
        dd.PlaySound("buttonclick.mp3")
    end
end

function NodeLevel:getContentSize()
    return self.m_bg1:getContentSize()
end

return NodeLevel