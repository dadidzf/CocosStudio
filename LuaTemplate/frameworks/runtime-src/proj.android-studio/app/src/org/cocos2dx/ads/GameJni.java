package org.cocos2dx.ads;

import org.cocos2dx.lua.AppActivity;

public class GameJni {
    public static void showFullAd() {
        AppActivity.getInstance().runOnUiThread(new Runnable() {
            public void run() {
                AppActivity.getInstance().getAds().showFullAd();
            }
        });
    }

    public static void showBanner(final float posY, final float anchorY) {
        AppActivity.getInstance().runOnUiThread(new Runnable() {
            public void run() {
                AppActivity.getInstance().getAds().showBanner(posY, anchorY);
            }
        });
    }

    public static void removeBanner() {
        AppActivity.getInstance().runOnUiThread(new Runnable() {
            public void run() {
                AppActivity.getInstance().getAds().removeBanner();
            }
        });
    }

    public static void initAds(final String bannerId, final String interstitialId){
        AppActivity.getInstance().runOnUiThread(new Runnable() {
            public void run() {
                AppActivity.getInstance().getAds().initAds(bannerId, interstitialId);
            }
        });
    }
}
