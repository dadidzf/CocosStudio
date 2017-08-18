package org.cocos2dx.lua;

import android.content.Intent;
import android.content.pm.PackageManager;
import android.util.Log;


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

    public static void showRewardVideo() {
        AppActivity.getInstance().runOnUiThread(new Runnable() {
            public void run() {
                AppActivity.getInstance().getAds().showRewardVideoAds();
            }
        });
    }

    public static void initAds(final String bannerId, final String interstitialId, final String rewardVideoId, final int rewardCallBackFuncId){
        AppActivity.getInstance().runOnUiThread(new Runnable() {
            public void run() {
                AppActivity.getInstance().getAds().initAds(bannerId, interstitialId, rewardVideoId, rewardCallBackFuncId);
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

    /*
     * Vibrate
     */
    public static void vibrate(final int t)
    {
        AppActivity.getInstance().runOnUiThread(new Runnable() {
            public void run() {
                AppActivity.getInstance().vibrate(t);
            }
        });
    }


    /*
     * Billing
     */
    public static void initBillings(final String publicKey, final int luaFunctionId)
    {
        AppActivity.getInstance().runOnUiThread(new Runnable() {
            public void run() {
                AppActivity.getInstance().initBillings(publicKey, luaFunctionId);
            }
        });
    }

    public static void purchase(final String skuKey, final int luaFunctionId)
    {
        AppActivity.getInstance().runOnUiThread(new Runnable() {
            public void run() {
                AppActivity.getInstance().purchase(skuKey, luaFunctionId);
            }
        });
    }

    public static void subscript(final String oldKey, final String skuKey, final int luafunctionId)
    {
        AppActivity.getInstance().runOnUiThread(new Runnable() {
            public void run() {
                AppActivity.getInstance().subscript(oldKey, skuKey, luafunctionId);
            }
        });
    }

    public static void consume(final String skuKey, final int luafunctionId)
    {
        AppActivity.getInstance().runOnUiThread(new Runnable() {
            public void run() {
                AppActivity.getInstance().consume(skuKey, luafunctionId);
            }
        });
    }

    public static boolean isItemPurchased(String skuKey)
    {
       return AppActivity.getInstance().isItemPurchased(skuKey);
    }

    public static boolean isSubscriptionAutoRenewEnabled(String skuKey)
    {
        return  AppActivity.getInstance().isSubscriptionAutoRenewEnabled(skuKey);
    }

    // Package check
    public static String getPackageName()
    {
        Log.i("dzf", " get packageName");
        return AppActivity.getInstance().getApplicationInfo().packageName;
    }

    public static boolean checkPackage(String packageName)
    {
        Log.i("dzf", packageName);
        if (packageName == null || "".equals(packageName))
            return false;
        try
        {
            AppActivity.getInstance().getPackageManager().getApplicationInfo(packageName, PackageManager.GET_ACTIVITIES);
            Log.i("dzf", "package exist");
            return true;
        }
        catch (PackageManager.NameNotFoundException e)
        {
            return false;
        }
    }
}
