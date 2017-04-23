@class RootViewController;

@interface ToolsController : NSObject{
}

@property(nonatomic, retain) RootViewController* viewController;

+ (ToolsController*) getInstance;
- (void)setRootViewController:(RootViewController*) viewCtrl;

@end

