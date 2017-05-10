package org.cocos2dx.lua;

import android.content.Intent;


public class GameJni {

    /*
     *  Admob  Ads
     */
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


    /*
     *  Game Center
     */
    public static void openLeaderboardUI(final String leaderboardId)
    {
        AppActivity.getInstance().runOnUiThread(new Runnable() {
            public void run() {
                AppActivity.getInstance().openLeaderboardUI(leaderboardId);
            }
        });
    }

    public static void submitScoreToLeaderboard(final String leaderboardId, final int score){
        AppActivity.getInstance().runOnUiThread(new Runnable() {
            public void run() {
                AppActivity.getInstance().submitScoreToLeaderboard(leaderboardId, score);
            }
        });
    }

    public static void showAchievements(){
        AppActivity.getInstance().runOnUiThread(new Runnable() {
            public void run() {
                AppActivity.getInstance().showAchievements();
            }
        });
    }

    public static void updateAchievement(final String achievementId){
        AppActivity.getInstance().runOnUiThread(new Runnable() {
            public void run() {
                AppActivity.getInstance().updateAchievement(achievementId);
            }
        });
    }


    /*
     * Game share
     */
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

    public static void vibrate(final int t)
    {
        AppActivity.getInstance().runOnUiThread(new Runnable() {
            public void run() {
                AppActivity.getInstance().vibrate(t);
            }
        });
    }
}
