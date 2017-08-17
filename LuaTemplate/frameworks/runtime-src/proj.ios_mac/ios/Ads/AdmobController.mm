/****************************************************************************
    By dzf 20170415 
 ****************************************************************************/

#import "AdmobController.h"
#import "RootViewController.h"
#import "cocos2d.h"
#import "scripting/lua-bindings/manual/platform/ios/CCLuaObjcBridge.h"

@implementation AdmobController

static AdmobController* _instance = nil;

+ (AdmobController*) getInstance
{
    if (_instance == nil)
    {
        _instance = [AdmobController alloc];
    }
    
    return _instance;
}

- (void)setRootViewController:(RootViewController*) viewCtrl
{
    _viewController = viewCtrl;
}

/**
 Lua interface
 **/
+ (void)initBannerLua:(NSDictionary *)dict
{
    [[AdmobController getInstance] setBannerPosY:[[dict objectForKey:@"posY"] floatValue]
                                      andAnchorY:[[dict objectForKey:@"anchorY"] floatValue]];
    [[AdmobController getInstance] showBanner];
}

+ (void)showInterstitialLua {
    [[AdmobController getInstance] showInterstitialAd];
}

+ (void)showRewardVideoLua {
    [[AdmobController getInstance] showRewardVideo];
}

+ (void)removeBannerLua
{
    [[AdmobController getInstance] removeBanner];
}

+ (void)initAdsLua:(NSDictionary *)dict
{
    [[AdmobController getInstance] createBannerAds:[dict objectForKey:@"bannerAdsId"]];
    [[AdmobController getInstance] setInterstitialAdsId:[dict objectForKey:@"interstitialAdsId"]];
    [[AdmobController getInstance] createAndLoadInterstitial];
    NSString* rewardVideoId = [dict objectForKey:@"rewardVideoId"];
    
    if ([rewardVideoId isEqualToString:@""])
    {
    }
    else
    {
        [[AdmobController getInstance] createRewardVideoAds:rewardVideoId
                                         withCallBackFuncId:[[dict objectForKey:@"functionId"] intValue]];
    }
}

/**
 Interstitial ads
 **/
- (void)setInterstitialAdsId:(NSString*) adsId
{
    _interstitialAdsId = adsId;
}

- (void)createAndLoadInterstitial
{
    _interstitial = [[GADInterstitial alloc] initWithAdUnitID:_interstitialAdsId];
    _interstitial.delegate = self;
    [_interstitial loadRequest:[GADRequest request]];
}

- (void)interstitialDidDismissScreen:(GADInterstitial *)interstitial {
    [self createAndLoadInterstitial];
}

- (void)showInterstitialAd{
    if ([_interstitial isReady]) {
        [_interstitial presentFromRootViewController:_viewController];
    }
}

/**
 Banner Ads
 **/

- (void)createBannerAds:(NSString*)adsId
{
    _bannerView = [[GADBannerView alloc] initWithAdSize:kGADAdSizeSmartBannerPortrait];
    _bannerView.adUnitID = adsId;
    _bannerView.rootViewController = _viewController;
 
    GADRequest *request = [GADRequest request];
    // Requests test ads on devices you specify. Your test device ID is printed to the console when
    // an ad request is made. GADBannerView automatically returns test ads when running on a
    // simulator.
    // request.testDevices = @[@"55f779818cb4c3f08e89b0d39a20f181"];  // Eric's iPod Touch
    
    [_bannerView loadRequest:request];
    [_bannerView setAutoloadEnabled:true];
    [_viewController.view addSubview:_bannerView];
    [_bannerView setDelegate:self];
    [self setBannerPosY:0 andAnchorY:0];
    [_bannerView setHidden:TRUE];
}

- (void)adViewDidReceiveAd:(GADBannerView *)view {
    _bannerView.alpha = 0;
    [UIView animateWithDuration:1.0 animations:^{
        _bannerView.alpha = 1;
    }];
}

- (void)adView:(GADBannerView *)view didFailToReceiveAdWithError:(GADRequestError *)error {
    [view setHidden:YES];
    NSLog(@"Failed to receive ad %@", [error localizedDescription]);
}

/**
 x, y (0 - 1.0)
 **/
- (void)setBannerPosY:(float)posY andAnchorY:(float)anchorY
{
    CGRect contentFrame = _viewController.view.bounds;
    CGRect bannerFrame = CGRectZero;
#if __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_6_0
    bannerFrame = _bannerView.frame;
#else
    bannerFrame.size = [self.bannerView sizeThatFits:contentFrame.size];
#endif
    bannerFrame.origin.x = (contentFrame.size.width - bannerFrame.size.width) / 2;
    
    bannerFrame.origin.y = contentFrame.size.height*(1 - posY) - (1 - anchorY)*bannerFrame.size.height;
    _bannerView.frame = bannerFrame;
}

- (void)showBanner
{
    [_bannerView setHidden:FALSE];
}


- (void)removeBanner
{
    if (_bannerView != nil)
    {
        [_bannerView setHidden:YES];
    }
}

/**
 Reward Video Ads
 **/
- (void)createRewardVideoAds:(NSString*) adsId withCallBackFuncId:(int) functionId
{
    [GADRewardBasedVideoAd sharedInstance].delegate = self;
    _rewardVideo = [GADRewardBasedVideoAd sharedInstance];
    _rewardVideoAdsId = adsId;
    [self loadRewardVideoAds];
    _rewardVideoFunctionId = functionId;
}

- (void)loadRewardVideoAds
{
    [_rewardVideo loadRequest:[GADRequest request]
            withAdUnitID:_rewardVideoAdsId];
}

- (void)showRewardVideo
{
    if ([_rewardVideo isReady]) {
        [_rewardVideo presentFromRootViewController:_viewController];
    }
    else
    {
        [self rewardResult:FALSE];
        [self loadRewardVideoAds];
    }
}

- (void)rewardBasedVideoAd:(GADRewardBasedVideoAd *)rewardBasedVideoAd
   didRewardUserWithReward:(GADAdReward *)reward
{
    NSString *rewardMessage = [NSString stringWithFormat:@"Reward received with currency %@ , amount %lf", reward.type, [reward.amount doubleValue]];
    NSLog(rewardMessage);
    [self rewardResult:TRUE];
}

- (void)rewardResult:(Boolean) willReward
{
    cocos2d::LuaObjcBridge::pushLuaFunctionById(_rewardVideoFunctionId);
    cocos2d::LuaObjcBridge::getStack()->pushBoolean(willReward ? true : false);
    cocos2d::LuaObjcBridge::getStack()->executeFunction(1);
}

- (void)rewardBasedVideoAdDidReceiveAd:(GADRewardBasedVideoAd *)rewardBasedVideoAd {
    NSLog(@"Reward based video ad is received.");
}

- (void)rewardBasedVideoAdDidOpen:(GADRewardBasedVideoAd *)rewardBasedVideoAd {
    NSLog(@"Opened reward based video ad.");
}

- (void)rewardBasedVideoAdDidStartPlaying:(GADRewardBasedVideoAd *)rewardBasedVideoAd {
    NSLog(@"Reward based video ad started playing.");
}

- (void)rewardBasedVideoAdDidClose:(GADRewardBasedVideoAd *)rewardBasedVideoAd {
    NSLog(@"Reward based video ad is closed.");
    [self loadRewardVideoAds];
}

- (void)rewardBasedVideoAdWillLeaveApplication:(GADRewardBasedVideoAd *)rewardBasedVideoAd {
    NSLog(@"Reward based video ad will leave application.");
}

- (void)rewardBasedVideoAd:(GADRewardBasedVideoAd *)rewardBasedVideoAd
    didFailToLoadWithError:(NSError *)error {
    NSLog(@"Reward based video ad failed to load.");
}

@end
