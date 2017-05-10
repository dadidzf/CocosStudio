local GameCenter = {}

local _jniClass = "org/cocos2dx/lua/GameJni"

function GameCenter.openGameCenterLeaderboardsUI(leadboardIndex)
    print("GameCenter.openGameCenterLeaderboardsUI", leadboardIndex)
    local leaderboardIdStr = dd.appCommon.leaderboard[leadboardIndex]
    if leaderboardIdStr then
        if device.platform == "ios" then 
            local args = {
                id = leaderboardIdStr
            }
            getLuaBridge().callStaticMethod("GameCenterDelegate", "openGameCenterLeaderboardsUILua", args)    
        elseif device.platform == "android" then
            getLuaBridge().callStaticMethod(_jniClass, "openLeaderboardUI", {leaderboardIdStr})
        else
            error("not support for platform")
        end
    else
        error("Leaderboard index not exist !")
        return
    end
end

function GameCenter.openAchievementUI()
    print("GameCenter.openAchievementUI")
    if device.platform == "ios" then 
        getLuaBridge().callStaticMethod("GameCenterDelegate", "openAchievementUILua")    
    elseif device.platform == "android" then
        getLuaBridge().callStaticMethod(_jniClass, "showAchievements", {})
    else
        error("not support for platform")
    end
end

function GameCenter.submitScoreToLeaderboard(leadboardIndex, submitScore)
    print("GameCenter.submitScoreToLeaderboard", leadboardIndex, submitScore)
    local leaderboardIdStr = dd.appCommon.leaderboard[leadboardIndex]
    if leaderboardIdStr then
        if device.platform == "ios" then 
            local args = {
                id = leaderboardIdStr,
                score = submitScore
            }
            getLuaBridge().callStaticMethod("GameCenterDelegate", "submitScoreToLeaderboardLua", args)    
        elseif device.platform == "android" then
            getLuaBridge().callStaticMethod(_jniClass, "submitScoreToLeaderboard", 
                {leaderboardIdStr, submitScore}, "(Ljava/lang/String;I)V")
        else
            error("not support for platform")
        end
    else
        error("Leaderboard index not exist !")
        return
    end
end

function GameCenter.unlockAchievement(achievementIndex)
    print("GameCenter.unlockAchievement", achievementIndex)
    local achievementIdStr = dd.appCommon.achievement[achievementIndex]
    if achievementIdStr then
        if device.platform == "ios" then 
            local args = {
                id = achievementIdStr
            }
            getLuaBridge().callStaticMethod("GameCenterDelegate", "unlockAchievementLua", args)    
        elseif device.platform == "android" then
            getLuaBridge().callStaticMethod(_jniClass, "updateAchievement", {achievementIdStr})
        else
            error("not support for platform")
        end
    else
        error("Achievement index not exist !")
        return
    end
end

return GameCenter