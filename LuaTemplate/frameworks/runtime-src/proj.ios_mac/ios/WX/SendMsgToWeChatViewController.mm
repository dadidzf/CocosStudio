#import "SendMsgToWeChatViewController.h"
#import "WXApiManager.h"
#import "WXApiRequestHandler.h"
#import "../Constant.h"
#import "cocos2d.h"
#import "scripting/lua-bindings/manual/platform/ios/CCLuaObjcBridge.h"
#import "../RootViewController.h"

@implementation SendMsgToWeChatViewController

static SendMsgToWeChatViewController* _instance = nil;

+ (SendMsgToWeChatViewController*) getInstance
{
    if (_instance == nil)
    {
        _instance = [SendMsgToWeChatViewController alloc];
    }
    
    _instance.functionId = 0;
    [WXApiManager sharedManager].delegate = _instance;
    return _instance;
}


/*
 * Lua interface
 */
+ (void)registerCallBackFunc:(NSDictionary *)dict
{
    [_instance initCallBackFunc:[[dict objectForKey:@"functionId"] intValue]];
}

+ (void) sendAuthRequestLua:(NSDictionary *)dict
{
    [_instance sendAuthRequest:[dict objectForKey:@"kAuthState"]];
}

/*
 *
 */
- (void)initCallBackFunc:(int) functionId
{
    _functionId = functionId;
}

- (void)setRootViewController:(RootViewController*) viewCtrl
{
    _viewController = viewCtrl;
}

- (void)sendAuthRequest:(NSString*)kAuthState
{
    [WXApiRequestHandler sendAuthRequestScope: kAuthScope
                                        State: kAuthState
                                        OpenID: kAuthOpenID
                             InViewController:_viewController];
}

#pragma mark - WXApiManagerDelegate
- (void)managerDidRecvAuthResponse:(SendAuthResp *)response {
    NSLog(@"managerDidRecvAuthResponse");
    if (_functionId != 0)
    {
        cocos2d::LuaObjcBridge::pushLuaFunctionById(_functionId);
        cocos2d::LuaObjcBridge::getStack()->pushBoolean(response.errCode == 0);
        cocos2d::LuaObjcBridge::getStack()->pushString([response.state UTF8String]);
        cocos2d::LuaObjcBridge::getStack()->pushString([response.code UTF8String]);
        cocos2d::LuaObjcBridge::getStack()->executeFunction(3);
    }
}

@end
