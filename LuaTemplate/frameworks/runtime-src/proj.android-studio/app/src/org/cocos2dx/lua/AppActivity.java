package org.cocos2dx.lua;

import android.content.Context;
import android.os.Bundle;
import android.os.Vibrator;

import com.google.android.gms.common.ConnectionResult;
import com.google.android.gms.common.GoogleApiAvailability;
import com.google.android.gms.games.Games;

import org.cocos2dx.ads.Ads;

public class AppActivity extends BaseGameActivity{
    Ads mAds;

    static AppActivity me;
    static Context currentContext;

    static boolean gpgAvailable;


    public static AppActivity getInstance()
    {
        return  me;
    }

    private boolean checkPlayServices() {
        int PLAY_SERVICES_RESOLUTION_REQUEST = 9000;
        GoogleApiAvailability googleAPI = GoogleApiAvailability.getInstance();
        int result = googleAPI.isGooglePlayServicesAvailable(this);
        if(result != ConnectionResult.SUCCESS) {
            if(googleAPI.isUserResolvableError(result)) {
                googleAPI.getErrorDialog(this, result,
                        PLAY_SERVICES_RESOLUTION_REQUEST).show();
            }

            return false;
        }

        return true;
    }

    protected void onCreate(Bundle paramBundle)
    {
        currentContext = this;
        me = this;
        mAds = new Ads(this);
        gpgAvailable = false;
        //checkPlayServices();

        super.onCreate(paramBundle);
    }

    public Ads getAds()
    {
       return mAds;
    }

    @Override
    public void onSignInSucceeded(){
        gpgAvailable = true;
    }

    @Override
    public void onSignInFailed(){
        gpgAvailable = false;
    }

    public void openLeaderboardUI(String leadboardId)
    {
        if (gpgAvailable) {
            startActivityForResult(Games.Leaderboards.getLeaderboardIntent(
                    getGameHelper().getApiClient(), leadboardId), 2);
        }
    }

    public void submitScoreToLeaderboard(String leaderboardId, int score)
    {
        if(gpgAvailable) {
            Games.Leaderboards.submitScore(getGameHelper().getApiClient(), leaderboardId, score);
        }
    }

    public void showAchievements() {
        if(gpgAvailable) {
            startActivityForResult(Games.Achievements.getAchievementsIntent(getGameHelper().getApiClient()), 5);
        }
    }

    public void updateAchievement(String achievementId){
        if(gpgAvailable){
            Games.Achievements.unlock(getGameHelper().getApiClient(), achievementId);
        }
    }

    public void vibrate(long paramLong)
    {
        ((Vibrator)currentContext.getSystemService("vibrator")).vibrate(paramLong);
    }
}
