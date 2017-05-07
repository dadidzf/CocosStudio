#import "GameCenterHelper.h"
#import "RootViewController.h"
#import "cocos2d.h"

@implementation GameCenterDelegate

- (void) gameCenterViewControllerDidFinish:(GKGameCenterViewController *)gameCenterViewController {
    [self.viewController dismissViewControllerAnimated:YES completion:nil];
}

/*
 * Lua Interface
 */
+ (void)openGameCenterLeaderboardsUILua:(NSDictionary *)dict
{
    [[GameCenterDelegate getInstance] openGameCenterLeaderboardsUI:[dict objectForKey:@"id"]];
}

+ (void)openAchievementUILua
{
    [[GameCenterDelegate getInstance] openAchievementUI];
}

+ (void)submitScoreToLeaderboardLua:(NSDictionary *)dict
{
    [[GameCenterDelegate getInstance] submitScoreToLeaderboard:[dict objectForKey:@"id"]    \
                                    andScore:[[dict objectForKey:@"score"] longLongValue]];
}

+ (void)unlockAchievementLua:(NSDictionary*) dict
{
    [[GameCenterDelegate getInstance] unlockAchievement:[dict objectForKey:@"id"]];
}

/****************************************************************************************/


+ (GameCenterDelegate *) getInstance {
    static GameCenterDelegate *gameCenterDelegate = nil;
    if (gameCenterDelegate == nil) {
        gameCenterDelegate = [[GameCenterDelegate alloc] init];
    }
    return gameCenterDelegate;
}

- (void)setRootViewController:(RootViewController*) viewCtrl
{
    _viewController = viewCtrl;
    [self signInPlayer];
}

- (Boolean) signInPlayer
{
    GKLocalPlayer *player = [GKLocalPlayer localPlayer];
    Boolean signedIn = false;
    player.authenticateHandler = ^(UIViewController *viewController, NSError *error){
        if (viewController != nil)
        {
            if (viewController != nil && player.authenticated == false)
            {
                [[GameCenterDelegate getInstance].viewController presentViewController:viewController animated:YES completion:^{}];
            }
        }
    };
    if (player.isAuthenticated) {
        signedIn = true;
    }
    return signedIn;
}

- (void)openGameCenterLeaderboardsUI:(NSString*) leaderBoardId
{
    NSLog(@"Open Leaderboard UI");
    if (![GKLocalPlayer localPlayer].isAuthenticated)
    {
        if(![self signInPlayer])
        {
            NSLog(@"Cannot open Leaderboard UI. Not logged in.");
            cocos2d::MessageBox("Not logged in !", "Error");
        }
    }
    else
    {
        GKGameCenterViewController* gkController = [[GKGameCenterViewController alloc] init];
        gkController.leaderboardIdentifier = leaderBoardId;
        gkController.leaderboardTimeScope = GKLeaderboardTimeScopeAllTime;
        gkController.gameCenterDelegate = self;
        
        [_viewController presentViewController:gkController animated:YES completion:^{}];
    }
}

- (void) openAchievementUI
{
    NSLog(@"Open Achievements UI");
    if (![GKLocalPlayer localPlayer].isAuthenticated) {
        if(![self signInPlayer])
        {
            NSLog(@"Cannot open Achievements UI. Not logged in.");
            cocos2d::MessageBox("Not logged in !.", "Error");
        }
    } else {
        GKGameCenterViewController* gkController = [[GKGameCenterViewController alloc] init];
        gkController.gameCenterDelegate = self;
        
        [_viewController presentViewController:gkController animated:YES completion:^{}];
    }
}

- (void) submitScoreToLeaderboard:(NSString*) leadboardId andScore:(int64_t) score
{
    GKScore *scoreReporter = [[GKScore alloc] initWithLeaderboardIdentifier:leadboardId];
    scoreReporter.value = score;
    scoreReporter.context = 0;
    
    [GKScore reportScores:@[scoreReporter] withCompletionHandler:^(NSError *error) {
        if (error != nil) {
            NSLog(@"Error at GameSharing::submitScoreToLeaderboard()");
        }
    }];
}

- (void) unlockAchievement:(NSString*) achievementId{
    GKAchievement *achievement = [[GKAchievement alloc] initWithIdentifier:achievementId];
    if (achievement){
        achievement.percentComplete = 100;
        achievement.showsCompletionBanner = true;
        [GKAchievement reportAchievements:@[achievement] withCompletionHandler:^(NSError *error) {
            if (error != nil) {
                NSLog(@"Error at GameSharing::unlockAchievement()");
            }
        }];
    }
}

@end
