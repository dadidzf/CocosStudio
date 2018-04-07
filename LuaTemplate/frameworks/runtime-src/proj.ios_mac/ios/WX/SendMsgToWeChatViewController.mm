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

+ (void)sendImageContentLua:(NSDictionary *)dict
{
    WXScene scene = [_instance convertIntValueToScene:[[dict objectForKey:@"scene"] intValue]];
    [_instance sendImageContent:[dict objectForKey:@"path"]
                               thumbPath:[dict objectForKey:@"thumbPath"]
                               scene:scene];
}

+ (void) sendLinkContentLua:(NSDictionary*) dict
{
    WXScene scene = [_instance convertIntValueToScene:[[dict objectForKey:@"scene"] intValue]];
    [_instance sendLinkContent:[dict objectForKey:@"linkURL"]
                               title:[dict objectForKey:@"title"]
                               img:[dict objectForKey:@"imgPath"]
                               desc:[dict objectForKey:@"description"]
                               scene:scene];
}

+ (void) bizpayLua:(NSDictionary*) dict
{
    [_instance bizPay:dict];
}

/*
 *
 */
- (WXScene) convertIntValueToScene: (int) intScene
{
    WXScene scene = WXSceneSession;
    switch (intScene) {
        case WXSceneSession:
            scene = WXSceneSession;
            break;
        case WXSceneTimeline:
            scene = WXSceneTimeline;
            break;
        case WXSceneFavorite:
            scene = WXSceneFavorite;
            break;
    }
    
    return scene;
}

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

- (void)sendImageContent:(NSString*) path thumbPath:(NSString*) thumbPath scene:(WXScene) scene
{
    NSData *imageData = [NSData dataWithContentsOfFile:path];
    
    UIImage *thumbImage = [UIImage imageNamed:thumbPath];
    [WXApiRequestHandler sendImageData:imageData
                               TagName:kImageTagName
                            MessageExt:kMessageExt
                                Action:kMessageAction
                            ThumbImage:thumbImage
                               InScene:scene];
}

- (void)sendLinkContent :(NSString*)linkURL
        title:(NSString*) title
        img:(NSString*) imgPath
        desc:(NSString*) description 
        scene:(WXScene) scene
{
    UIImage *thumbImage = [UIImage imageNamed:imgPath];
    [WXApiRequestHandler sendLinkURL:linkURL
                             TagName:kLinkTagName
                               Title:title
                         Description:description
                          ThumbImage:thumbImage
                             InScene:scene];
}

- (void)bizPay :(NSDictionary*) dict
{
    NSString *res = [WXApiRequestHandler jumpToBizPay:dict];
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
