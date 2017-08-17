#import "GoogleMobileAds/GoogleMobileAds.h"
#import "GoogleMobileAds/GADBannerViewDelegate.h"

@class RootViewController;

@interface AdmobController : NSObject <GADBannerViewDelegate, GADRewardBasedVideoAdDelegate,
GADInterstitialDelegate> {
}

@property(nonatomic, retain) RootViewController* viewController;
@property(nonatomic, strong) GADBannerView *bannerView;
@property(nonatomic, strong) GADInterstitial *interstitial;
@property(nonatomic, strong) GADRewardBasedVideoAd *rewardVideo;
@property(nonatomic, assign) NSString* interstitialAdsId;
@property(nonatomic, assign) NSString* rewardVideoAdsId;
@property int rewardVideoFunctionId;

+ (AdmobController*) getInstance;
- (void)setRootViewController:(RootViewController*) viewCtrl;

@end

