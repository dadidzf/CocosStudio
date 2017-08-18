package org.cocos2dx.ads;

import android.app.Activity;
import android.util.DisplayMetrics;
import android.view.View;
import android.widget.RelativeLayout;

import com.google.android.gms.ads.AdRequest;
import com.google.android.gms.ads.AdSize;
import com.google.android.gms.ads.AdView;
import com.google.android.gms.ads.InterstitialAd;
import com.google.android.gms.ads.MobileAds;
import com.google.android.gms.ads.reward.RewardItem;
import com.google.android.gms.ads.reward.RewardedVideoAd;

import org.cocos2dx.lua.AppActivity;

public class Ads{
    private AdView mAdView;
    private InterstitialAd mInterstitial;
    private RewardedVideoAd mRewardVideo;

    private RelativeLayout.LayoutParams mAdviewLayoutParam;
    private Activity mActivity;
    private RelativeLayout mLayout;
    private String mInterstitialId;
    private String mRewardVideoId;

    static int s_rewardVideoCallBackFuncId = 0;

    public Ads(AppActivity activity) {
        mActivity = activity;
    }

    public void initAds(String bannerId, String interstitialId, String rewardVideoId, int rewardVideoCallBackFuncId)
    {
        mInterstitialId = interstitialId;
        mRewardVideoId = rewardVideoId;
        s_rewardVideoCallBackFuncId = rewardVideoCallBackFuncId;

        initBannerAd(bannerId);
        initInterstitialAd();

        if (rewardVideoId.length() > 0)
        {
            initRewardVideo();
        }
    }

    /*
     * Banner Ads
     */
    public void initBannerAd(String bannerId) {
        mAdView = new AdView(mActivity);
        mAdView.setAdUnitId(bannerId);
        mAdView.setAdSize(AdSize.SMART_BANNER);
        mAdView.setAdListener(new ToastAdListener(mActivity) {
            public void onAdFailedToLoad(int paramAnonymousInt) {
                super.onAdFailedToLoad(paramAnonymousInt);
                AdRequest localAdRequest = new AdRequest.Builder().build();
                mAdView.loadAd(localAdRequest);
            }
        });

        mLayout = new RelativeLayout(mActivity);
        RelativeLayout.LayoutParams localLayoutParams = new RelativeLayout.LayoutParams(-1, -1);
        mActivity.addContentView(mLayout, localLayoutParams);
        mAdviewLayoutParam = new RelativeLayout.LayoutParams(-1, -2);
        mAdviewLayoutParam.addRule(RelativeLayout.ALIGN_PARENT_BOTTOM);
        mLayout.addView(mAdView, mAdviewLayoutParam);

        AdRequest localAdRequest = new AdRequest.Builder().build();
        mAdView.loadAd(localAdRequest);
        //mAdView.setVisibility(View.INVISIBLE);
    }

    public void showBanner(float posY, float anchorY) {
        DisplayMetrics metric = new DisplayMetrics();
        mActivity.getWindowManager().getDefaultDisplay().getRealMetrics(metric);
        int adsHeight = mAdView.getAdSize().getHeightInPixels(mActivity);
        int layoutHeight = metric.heightPixels;
        mAdviewLayoutParam.setMargins(0, 0, 0, (int)(layoutHeight*posY - anchorY*adsHeight));
        mAdView.setLayoutParams(mAdviewLayoutParam);

        mAdView.setVisibility(View.VISIBLE);
    }

    public void removeBanner() {
        mAdView.setVisibility(View.INVISIBLE);
    }

    /*
     * Interstitial Ads
     */
    public void initInterstitialAd() {
        mInterstitial = new InterstitialAd(mActivity);
        mInterstitial.setAdUnitId(mInterstitialId);
        mInterstitial.setAdListener(new ToastAdListener(mActivity) {
            public void onAdClosed() {
                super.onAdClosed();
            }

            public void onAdFailedToLoad(int paramAnonymousInt) {
                super.onAdFailedToLoad(paramAnonymousInt);
                loadInterstitial();
            }

            public void onAdLoaded() {
                super.onAdLoaded();
            }
        });

        loadInterstitial();
    }

    public void loadInterstitial() {
        AdRequest localAdRequest = new AdRequest.Builder().build();
        mInterstitial.loadAd(localAdRequest);
    }


    public void showFullAd() {
        showInterstitial();
        initInterstitialAd();
    }

    public void showInterstitial() {
        if (mInterstitial.isLoaded()) {
            mInterstitial.show();
        }
    }

    /*
     * Reward Video Ads
     */
    public void initRewardVideo(){
        mRewardVideo = MobileAds.getRewardedVideoAdInstance(this.mActivity);
        mRewardVideo.setRewardedVideoAdListener(new RewardVideoListener(mActivity){
            public void onRewarded(RewardItem reward) {
                super.onRewarded(reward);
                // Reward the user.
                ((AppActivity) mActivity).sendResultSuccess(s_rewardVideoCallBackFuncId);
            }

            public void onRewardedVideoAdClosed() {
                super.onRewardedVideoAdClosed();
                loadRewardedVideoAds();
            }
        });

        loadRewardedVideoAds();
    }

    public void loadRewardedVideoAds() {
        mRewardVideo.loadAd(mRewardVideoId, new AdRequest.Builder().build());
    }

    public void showRewardVideoAds()
    {
        if (mRewardVideo.isLoaded()) {
            mRewardVideo.show();
        }
        else
        {
            ((AppActivity) mActivity).sendResultFailed(s_rewardVideoCallBackFuncId);
            loadRewardedVideoAds();
        }
    }

    public void onResume() {
        if (mRewardVideo != null)
        {
            mRewardVideo.resume(mActivity);
        }
    }

    public void onPause() {
        if (mRewardVideo != null)
        {
            mRewardVideo.pause(mActivity);
        }
    }

    public void onDestroy() {
        if (mRewardVideo != null) {
            mRewardVideo.destroy(mActivity);
        }
    }
}
