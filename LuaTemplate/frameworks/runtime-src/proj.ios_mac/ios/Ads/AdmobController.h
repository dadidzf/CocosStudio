#import "GoogleMobileAds/GoogleMobileAds.h"
#import "GoogleMobileAds/GADBannerViewDelegate.h"

@class RootViewController;

@interface AdmobController : NSObject <GADBannerViewDelegate,
GADInterstitialDelegate> {
}

@property(nonatomic, retain) RootViewController* viewController;
@property(nonatomic, strong) GADBannerView *bannerView;
@property(nonatomic, strong) GADInterstitial *interstitial;
@property(nonatomic, assign) NSString* interstitialAdsId;

+ (AdmobController*) getInstance;
- (void)setRootViewController:(RootViewController*) viewCtrl;

@end

