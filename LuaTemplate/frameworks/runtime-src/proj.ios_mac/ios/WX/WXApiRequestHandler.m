#import "WXApi.h"
#import "WXApiRequestHandler.h"
#import "WXApiManager.h"
#import "SendMessageToWXReq+requestWithTextOrMediaMessage.h"

@implementation WXApiRequestHandler

#pragma mark - Public Methods

+ (BOOL)sendAuthRequestScope:(NSString *)scope
                       State:(NSString *)state
                      OpenID:(NSString *)openID
            InViewController:(UIViewController *)viewController {
    SendAuthReq* req = [[SendAuthReq alloc] init];
    req.scope = scope; // @"post_timeline,sns"
    req.state = state;
    req.openID = openID;
    
    //return [WXApi sendReq:req];
    return [WXApi sendAuthReq:req
               viewController:viewController
                     delegate:[WXApiManager sharedManager]];
}

@end
