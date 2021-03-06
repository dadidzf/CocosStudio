local LoadingScene = class("MainScene", cc.load("mvc").ViewBase)
local MainScene = import(".MainScene", ...)

local resourceList = {
    {"di.plist", "di.png"},
    {"di2.plist", "di2.png"},
    {"gui.plist", "gui.png"}
}

function LoadingScene:ctor()
    local loadingBg = display.newSprite("splash.png")
        :addTo(self)
        :move(display.cx, display.cy)

    self:loadingBegin()
end

function LoadingScene:loadingBegin()
    local textureCache = cc.Director:getInstance():getTextureCache()
    local frameCache = cc.SpriteFrameCache:getInstance()

    local len = table.nums(resourceList)
    local index = 1
    local scheduleId
    local loadingFunc

    local setFunc = function()
        index = index + 1
        scheduleId = dd.scheduler:scheduleScriptFunc(loadingFunc, 0.5, false)
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

function LoadingScene:loadingEnd()
    local mainScene = MainScene:create()
    mainScene:showWithScene()
end


return LoadingScene
