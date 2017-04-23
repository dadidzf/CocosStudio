package org.cocos2dx.ads;

import android.app.Activity;
import android.graphics.Point;
import android.util.DisplayMetrics;
import android.view.Display;
import android.view.View;
import android.view.WindowManager;
import android.widget.RelativeLayout;

import com.google.android.gms.ads.AdRequest;
import com.google.android.gms.ads.AdSize;
import com.google.android.gms.ads.AdView;
import com.google.android.gms.ads.InterstitialAd;

import org.cocos2dx.lua.AppActivity;

public class Ads {
    AdView mAdView;
    RelativeLayout.LayoutParams mAdviewLayoutParam;
    InterstitialAd mInterstitial;
    Activity mActivity;
    RelativeLayout mLayout;
    String mInterstitialId;

    public Ads(AppActivity activity) {
        mActivity = activity;
    }

    public void initAds(String bannerId, String interstitialId)
    {
        mInterstitialId = interstitialId;
        initBannerAd(bannerId);
        initInterstitialAd();
    }

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
        mAdView.setVisibility(View.INVISIBLE);
    }

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
}
