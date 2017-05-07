#import <GameKit/GameKit.h>
@class RootViewController;


@interface GameCenterDelegate : NSObject<GKGameCenterControllerDelegate>
@property(nonatomic, weak) UIViewController *viewController;
- (void)setRootViewController:(RootViewController*) viewCtrl;
@end

