package org.cocos2dx.lua;

import android.app.AlertDialog;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.os.Bundle;
import android.os.Vibrator;
import android.text.TextUtils;
import android.util.Log;

import com.google.android.gms.games.Games;

import org.cocos2dx.ads.Ads;
import org.cocos2dx.billing.util.IabBroadcastReceiver;
import org.cocos2dx.billing.util.IabHelper;
import org.cocos2dx.billing.util.IabResult;
import org.cocos2dx.billing.util.Inventory;
import org.cocos2dx.billing.util.Purchase;
import org.cocos2dx.lib.Cocos2dxLuaJavaBridge;

import java.util.ArrayList;
import java.util.List;


public class AppActivity extends BaseGameActivity implements IabBroadcastReceiver.IabBroadcastListener {
    Ads mAds;

    static AppActivity me;
    static Context currentContext;

    // Leader board, Rank
    static boolean gpgAvailable;

    /*
     * In-app Billing
     */
    static boolean s_isBillingInited = false;
    // Debug tag, for logging
    static final String TAG = "Billing";

    // Common success failed Result
    static final String FAILED_RESULT = "failed";
    static final String SUCCESS_RESULT = "success";

    // (arbitrary) request code for the purchase flow
    static final int RC_REQUEST = 10001;

    // Billing init lua function call back id
    static int s_billingInitLuaFunctionId = 0;
    static int s_billingPurchaseLuaFunctionId = 0;
    static int s_billingConsumeFunctionId = 0;

    // query result
    static Inventory s_queryResult;

    // The helper object
    IabHelper mHelper;

    // Provides purchase notification while this app is running
    IabBroadcastReceiver mBroadcastReceiver;

    public static AppActivity getInstance()
    {
        return  me;
    }

    /*
     *     As a back up in case we will use it in the future
     *
import com.google.android.gms.common.ConnectionResult;
import com.google.android.gms.common.GoogleApiAvailability;
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
    */

    protected void onCreate(Bundle paramBundle)
    {
        currentContext = this;
        me = this;
        mAds = new Ads(this);
        gpgAvailable = false;
        //checkPlayServices();

        super.onCreate(paramBundle);
    }

    @Override
    public void onResume() {
        mAds.onResume();
        super.onResume();
    }

    @Override
    public void onPause() {
        mAds.onPause();
        super.onPause();
    }

    @Override
    public void onDestroy() {
        mAds.onDestroy();
        super.onDestroy();

        // very important:
        if (mBroadcastReceiver != null) {
            unregisterReceiver(mBroadcastReceiver);
        }

        // very important:
        Log.d(TAG, "Destroying helper.");
        if (mHelper != null) {
            mHelper.disposeWhenFinished();
            mHelper = null;
        }
    }

    public Ads getAds()
    {
       return mAds;
    }

    @Override
    public void receivedBroadcast() {
        // Received a broadcast notification that the inventory of items has changed
        Log.d(TAG, "Received broadcast notification. Querying inventory.");
        try {
            mHelper.queryInventoryAsync(mGotInventoryListener);
        } catch (IabHelper.IabAsyncInProgressException e) {
            complain("Error querying inventory. Another async operation in progress.");
        }
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        Log.d(TAG, "onActivityResult(" + requestCode + "," + resultCode + "," + data);
        if (mHelper == null) return;

        // Pass on the activity result to the helper for handling
        if (!mHelper.handleActivityResult(requestCode, resultCode, data)) {
            // not handled, so handle it ourselves (here's where you'd
            // perform any handling of activity results not related to in-app
            // billing...
            super.onActivityResult(requestCode, resultCode, data);
        }
        else {
            Log.d(TAG, "onActivityResult handled by IABUtil.");
        }
    }

    /*
     *  Google play game center !
     */
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

    /*
     * Vibrate ~~~
     * @paramLong - millisecond
     */
    public void vibrate(long paramLong)
    {
        ((Vibrator)currentContext.getSystemService("vibrator")).vibrate(paramLong);
    }

    /*
     * In-app billings
     */
    public boolean isBillingAvailable()
    {
        return  s_isBillingInited;
    }

    public void initBillings(String publicKey, int callBackLuaFunctionId)
    {
        Log.d(TAG, "Public key - " + publicKey);
        /* base64EncodedPublicKey should be YOUR APPLICATION'S PUBLIC KEY
         * (that you got from the Google Play developer console). This is not your
         * developer public key, it's the *app-specific* public key.
         *
         * Instead of just storing the entire literal string here embedded in the
         * program,  construct the key at runtime from pieces or
         * use bit manipulation (for example, XOR with some other string) to hide
         * the actual key.  The key itself is not secret information, but we don't
         * want to make it easy for an attacker to replace the public key with one
         * of their own and then fake messages from the server.
         */
        String base64EncodedPublicKey = publicKey;
        s_billingInitLuaFunctionId = callBackLuaFunctionId;

        // Create the helper, passing it our context and the public key to verify signatures with
        Log.d(TAG, "Creating IAB helper.");
        mHelper = new IabHelper(this, base64EncodedPublicKey);

        // enable debug logging (for a production application, you should set this to false).
        mHelper.enableDebugLogging(true);

        // Start setup. This is asynchronous and the specified listener
        // will be called once setup completes.
        Log.d(TAG, "Starting setup.");
        mHelper.startSetup(new IabHelper.OnIabSetupFinishedListener() {
            public void onIabSetupFinished(IabResult result) {
                Log.d(TAG, "Setup finished.");

                if (!result.isSuccess()) {
                    // Oh noes, there was a problem.
                    complain("Problem setting up in-app billing: " + result);
                    sendResult(s_billingInitLuaFunctionId, FAILED_RESULT);
                    return;
                }

                // Have we been disposed of in the meantime? If so, quit.
                if (mHelper == null) {
                    sendResult(s_billingInitLuaFunctionId, FAILED_RESULT);
                    return;
                }

                // Important: Dynamically register for broadcast messages about updated purchases.
                // We register the receiver here instead of as a <receiver> in the Manifest
                // because we always call getPurchases() at startup, so therefore we can ignore
                // any broadcasts sent while the app isn't running.
                // Note: registering this listener in an Activity is a bad idea, but is done here
                // because this is a SAMPLE. Regardless, the receiver must be registered after
                // IabHelper is setup, but before first call to getPurchases().
                mBroadcastReceiver = new IabBroadcastReceiver(me);
                IntentFilter broadcastFilter = new IntentFilter(IabBroadcastReceiver.ACTION);
                registerReceiver(mBroadcastReceiver, broadcastFilter);

                // IAB is fully set up. Now, let's get an inventory of stuff we own.
                Log.d(TAG, "Setup successful. Querying inventory.");
                try {
                    mHelper.queryInventoryAsync(mGotInventoryListener);
                } catch (IabHelper.IabAsyncInProgressException e) {
                    complain("Error querying inventory. Another async operation in progress.");
                    sendResult(s_billingInitLuaFunctionId, FAILED_RESULT);
                }
            }
        });
    }

    public void purchase(String skuKey, int luaFunctionId)
    {
        if (s_isBillingInited == false) return;
        Log.d(TAG, "Launching purchase flow" + skuKey + " " + luaFunctionId);

        /* TODO: for security, generate your payload here for verification. See the comments on
         *        verifyDeveloperPayload() for more info. Since this is a SAMPLE, we just use
         *        an empty string, but on a production app you should carefully generate this. */
        String payload = "";
        s_billingPurchaseLuaFunctionId = luaFunctionId;
        try {
            mHelper.launchPurchaseFlow(this, skuKey, RC_REQUEST,
                    mPurchaseFinishedListener, payload);
        } catch (IabHelper.IabAsyncInProgressException e) {
            complain("Error launching purchase flow. Another async operation in progress.");
            sendResult(s_billingPurchaseLuaFunctionId, FAILED_RESULT);
        }
    }

    public void subscript(String oldKey, String skuKey, int luaFunctionId)
    {
        if (s_isBillingInited == false) return;
        Log.d(TAG, "Launching purchase flow for gas subscription.");
        String payload = "";
        s_billingPurchaseLuaFunctionId = luaFunctionId;

        List<String> oldSkus = null;
        if (!TextUtils.isEmpty(oldKey)
                && !oldKey.equals(skuKey)) {
            // The user currently has a valid subscription, any purchase action is going to
            // replace that subscription
            oldSkus = new ArrayList<String>();
            oldSkus.add(oldKey);
        }

        try {
            mHelper.launchPurchaseFlow(this, skuKey, IabHelper.ITEM_TYPE_SUBS,
                    oldSkus, RC_REQUEST, mPurchaseFinishedListener, payload);
        } catch (IabHelper.IabAsyncInProgressException e) {
            complain("Error launching purchase flow. Another async operation in progress.");
            sendResult(s_billingPurchaseLuaFunctionId, FAILED_RESULT);
        }
    }

    public void consume(String skuKey, int luaFunctionId)
    {
        if (s_isBillingInited == false) return;
        s_billingConsumeFunctionId = luaFunctionId;
        try {
            mHelper.consumeAsync(s_queryResult.getPurchase(skuKey), mConsumeFinishedListener);
        } catch (IabHelper.IabAsyncInProgressException e) {
            complain("Error consuming gas. Another async operation in progress.");
            sendResult(s_billingConsumeFunctionId, FAILED_RESULT);
        }
    }

    private void sendResult(final int luaFunctionId, final String result) {
        Log.d(TAG, "sendResult " + result + " " + luaFunctionId);
         me.runOnGLThread(new Runnable() {
             @Override
             public void run() {
                 Log.d(TAG, "sendResult ---  " + result + " " + luaFunctionId);
                 Cocos2dxLuaJavaBridge.callLuaFunctionWithString(luaFunctionId, result);
                 //LuaJavaBridge.releaseLuaFunction(luaFunctionId);
             }
         });
    }

    public void sendResultSuccess(final int luaFunctionId)
    {
        sendResult(luaFunctionId, SUCCESS_RESULT);
    }

    public void sendResultFailed(final int luaFunctionId)
    {
        sendResult(luaFunctionId, FAILED_RESULT);
    }

    public boolean isItemPurchased(String skuKey)
    {
        // Do we have the premium upgrade?
        Purchase purchase = s_queryResult.getPurchase(skuKey);
        boolean isPurchase = (purchase != null && verifyDeveloperPayload(purchase));
        Log.d(TAG, skuKey + " is " + (isPurchase ? "already purchased !" : "not purchased !"));

        return  isPurchase;
    }

    public boolean isSubscriptionAutoRenewEnabled(String skuKey)
    {
        Purchase purchase = s_queryResult.getPurchase(skuKey);
        if (purchase != null && purchase.isAutoRenewing()) {
            return true;
        }
        else
        {
            return false;
        }
    }

    /** Verifies the developer payload of a purchase. */
    boolean verifyDeveloperPayload(Purchase p) {
        String payload = p.getDeveloperPayload();

        /*
         * TODO: verify that the developer payload of the purchase is correct. It will be
         * the same one that you sent when initiating the purchase.
         *
         * WARNING: Locally generating a random string when starting a purchase and
         * verifying it here might seem like a good approach, but this will fail in the
         * case where the user purchases an item on one device and then uses your app on
         * a different device, because on the other device you will not have access to the
         * random string you originally generated.
         *
         * So a good developer payload has these characteristics:
         *
         * 1. If two different users purchase an item, the payload is different between them,
         *    so that one user's purchase can't be replayed to another user.
         *
         * 2. The payload must be such that you can verify it even when the app wasn't the
         *    one who initiated the purchase flow (so that items purchased by the user on
         *    one device work on other devices owned by the user).
         *
         * Using your own server to store and verify developer payloads across app
         * installations is recommended.
         */

        return true;
    }

    // Listener that's called when we finish querying the items and subscriptions we own
    IabHelper.QueryInventoryFinishedListener mGotInventoryListener = new IabHelper.QueryInventoryFinishedListener() {
        public void onQueryInventoryFinished(IabResult result, Inventory inventory) {
            Log.d(TAG, "Query inventory finished.");

            // Have we been disposed of in the meantime? If so, quit.
            if (mHelper == null) {
                sendResult(s_billingInitLuaFunctionId, FAILED_RESULT);
                return;
            }

            // Is it a failure?
            if (result.isFailure()) {
                sendResult(s_billingInitLuaFunctionId, FAILED_RESULT);
                complain("Failed to query inventory: " + result);
                return;
            }

            sendResult(s_billingInitLuaFunctionId, SUCCESS_RESULT);
            Log.d(TAG, "Query inventory was successful.");
            s_queryResult = inventory;
            s_isBillingInited = true;
        }
    };


    // Callback for when a purchase is finished
    IabHelper.OnIabPurchaseFinishedListener mPurchaseFinishedListener = new IabHelper.OnIabPurchaseFinishedListener() {
        public void onIabPurchaseFinished(IabResult result, Purchase purchase) {
            Log.d(TAG, "Purchase finished: " + result + ", purchase: " + purchase);

            // if we were disposed of in the meantime, quit.
            if (mHelper == null) {
                sendResult(s_billingPurchaseLuaFunctionId, FAILED_RESULT);
                return;
            }

            if (result.isFailure()) {
                sendResult(s_billingPurchaseLuaFunctionId, FAILED_RESULT);
                complain("Error purchasing: " + result);
                return;
            }
            if (!verifyDeveloperPayload(purchase)) {
                complain("Error purchasing. Authenticity verification failed.");
                sendResult(s_billingPurchaseLuaFunctionId, FAILED_RESULT);
                return;
            }

            Log.d(TAG, "Purchase successful.");
            s_queryResult.addPurchase(purchase);
            sendResult(s_billingPurchaseLuaFunctionId, purchase.getSku());
        }
    };

    // Called when consumption is complete
    IabHelper.OnConsumeFinishedListener mConsumeFinishedListener = new IabHelper.OnConsumeFinishedListener() {
        public void onConsumeFinished(Purchase purchase, IabResult result) {
            Log.d(TAG, "Consumption finished. Purchase: " + purchase + ", result: " + result);

            // if we were disposed of in the meantime, quit.
            if (mHelper == null) {
                sendResult(s_billingConsumeFunctionId, FAILED_RESULT);
                return;
            }

            if (result.isSuccess()) {
                Log.d(TAG, "Consumption successful. Provisioning.");
                sendResult(s_billingConsumeFunctionId, purchase.getSku());
            }
            else {
                complain("Error while consuming: " + result);
                sendResult(s_billingConsumeFunctionId, FAILED_RESULT);
            }

            Log.d(TAG, "End consumption flow.");
        }
    };

    void complain(String message) {
        Log.e(TAG, "**** TrivialDrive Error: " + message);
        alert("Error: " + message);
    }

    void alert(String message) {
        AlertDialog.Builder bld = new AlertDialog.Builder(this);
        bld.setMessage(message);
        bld.setNeutralButton("OK", null);
        Log.d(TAG, "Showing alert dialog: " + message);
        bld.create().show();
    }
}
