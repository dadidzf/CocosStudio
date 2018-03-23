//
//  WXApiManager.m
//  SDKSample
//
//  Created by Jeason on 16/07/2015.
//
//

#import "WXApiManager.h"

@implementation WXApiManager

#pragma mark - LifeCycle
+(instancetype)sharedManager {
    static dispatch_once_t onceToken;
    static WXApiManager *instance;
    dispatch_once(&onceToken, ^{
        instance = [[WXApiManager alloc] init];
    });
    return instance;
}

#pragma mark - WXApiDelegate
- (void)onResp:(BaseResp *)resp {
    NSLog(@"onResp:(BaseResp *)resp");
    if ([resp isKindOfClass:[SendAuthResp class]]) {
        NSLog(@"1");
        if (_delegate
            && [_delegate respondsToSelector:@selector(managerDidRecvAuthResponse:)]) {
            NSLog(@"2");
            SendAuthResp *authResp = (SendAuthResp *)resp;
            [_delegate managerDidRecvAuthResponse:authResp];
        }
    }
}

- (void)onReq:(BaseReq *)req {
}

@end
