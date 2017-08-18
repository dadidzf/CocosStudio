package org.cocos2dx.ads;

import android.content.Context;
import android.widget.Toast;

import com.google.android.gms.ads.reward.RewardItem;
import com.google.android.gms.ads.reward.RewardedVideoAdListener;

public class RewardVideoListener implements RewardedVideoAdListener
{
  private Context mContext;
  public RewardVideoListener(Context paramContext)
  {
    this.mContext = paramContext;
  }

  // Required to reward the user.
  @Override
  public void onRewarded(RewardItem reward) {
//    Toast.makeText(this.mContext, "onRewarded! currency: " + reward.getType() + "  amount: " +
//            reward.getAmount(), Toast.LENGTH_SHORT).show();
    // Reward the user.
  }

  // The following listener methods are optional.
  @Override
  public void onRewardedVideoAdLeftApplication() {
//    Toast.makeText(this.mContext, "onRewardedVideoAdLeftApplication",
//            Toast.LENGTH_SHORT).show();
  }

  @Override
  public void onRewardedVideoAdClosed() {
//    Toast.makeText(this.mContext, "onRewardedVideoAdClosed", Toast.LENGTH_SHORT).show();
  }

  @Override
  public void onRewardedVideoAdFailedToLoad(int errorCode) {
//    Toast.makeText(this.mContext, "onRewardedVideoAdFailedToLoad", Toast.LENGTH_SHORT).show();
  }

  @Override
  public void onRewardedVideoAdLoaded() {
//    Toast.makeText(this.mContext, "onRewardedVideoAdLoaded", Toast.LENGTH_SHORT).show();
  }

  @Override
  public void onRewardedVideoAdOpened() {
//    Toast.makeText(this.mContext, "onRewardedVideoAdOpened", Toast.LENGTH_SHORT).show();
  }

  @Override
  public void onRewardedVideoStarted() {
//    Toast.makeText(this.mContext, "onRewardedVideoStarted", Toast.LENGTH_SHORT).show();
  }
}
