package org.cocos2dx.lua;

import android.content.Intent;

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

    public static void gameShare(final String title, final String url)
    {
        AppActivity.getInstance().runOnUiThread(new Runnable() {
            public void run() {
                Intent localIntent = new Intent("android.intent.action.SEND");
                localIntent.setType("text/plain");
                localIntent.putExtra("android.intent.extra.SUBJECT", "Share to friends now !");
                localIntent.putExtra("android.intent.extra.TEXT", url);
                localIntent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
                AppActivity.getInstance().startActivity(Intent.createChooser(localIntent, title));
            }
        });
    }
}
