local Splash = class("MainScene", cc.load("mvc").ViewBase)
local MainScene = import(".MainScene", ...)

local resourceList = {
    {"gui.plist", "gui.png"}
}

function Splash:ctor()
    local loadingBg = display.newSprite("splash.png")
        :addTo(self)
        :move(display.cx, display.cy)

    if display.height > 960 then
        loadingBg:setScale(display.height/960)
    end

    self:loadingBegin()
end

function Splash:loadingBegin()
    local textureCache = cc.Director:getInstance():getTextureCache()
    local frameCache = cc.SpriteFrameCache:getInstance()

    local len = table.nums(resourceList)
    local index = 1
    local scheduleId
    local loadingFunc

    local setFunc = function()
        index = index + 1
        scheduleId = dd.scheduler:scheduleScriptFunc(loadingFunc, 1.0, false)
    end

    loadingFunc = function()
        if index > 1 then
            frameCache:addSpriteFrames(resourceList[index - 1][2])
        end
        
        if scheduleId then 
            dd.scheduler:unscheduleScriptEntry(scheduleId)
            scheduleId = nil
        end

        if index <= len then
            textureCache:addImageAsync(resourceList[index][2], setFunc)
        else
            self:loadingEnd()
        end
    end
    loadingFunc()
end

function Splash:loadingEnd()
    local mainScene = MainScene:create()
    mainScene:showWithScene()
end


return Splash
