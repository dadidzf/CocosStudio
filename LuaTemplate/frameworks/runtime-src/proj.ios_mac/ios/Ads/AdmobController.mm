/****************************************************************************
    By dzf 20170415 
 ****************************************************************************/

#import "AdmobController.h"
#import "RootViewController.h"

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
+ (void)initInterstitialLua:(NSDictionary *)dict
{
    [[AdmobController getInstance] setInterstitialAdsId:[dict objectForKey:@"interstitialAdsId"]];
    [[AdmobController getInstance] createAndLoadInterstitial];
}

+ (void)initBannerLua:(NSDictionary *)dict
{
    [[AdmobController getInstance] createBannerAds:[dict objectForKey:@"bannerAdsId"]];
    [[AdmobController getInstance] setBannerPosY:[[dict objectForKey:@"posY"] floatValue]
                                      andAnchorY:[[dict objectForKey:@"anchorY"] floatValue]];
}

+ (void)showInterstitialLua
{
    [[AdmobController getInstance] showInterstitialAd];
}

+ (void)removeBannerLua
{
    [[AdmobController getInstance] removeBanner];
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
    if (_bannerView == nil)
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
    }
    else
    {
        [_bannerView setHidden:FALSE];
    }
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

- (void)removeBanner
{
    if (_bannerView != nil)
    {
        [_bannerView setHidden:YES];
    }
}

@end
