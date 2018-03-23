@class RootViewController;

@interface SendMsgToWeChatViewController: NSObject{
}

@property(nonatomic, retain) RootViewController* viewController;
@property int functionId;

+ (SendMsgToWeChatViewController*) getInstance;
- (void)setRootViewController:(RootViewController*) viewCtrl;

@end


