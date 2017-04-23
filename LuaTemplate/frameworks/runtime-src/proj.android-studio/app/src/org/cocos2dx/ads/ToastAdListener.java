package org.cocos2dx.ads;

import android.content.Context;
import com.google.android.gms.ads.AdListener;

public class ToastAdListener
  extends AdListener
{
  private Context mContext;
  public ToastAdListener(Context paramContext)
  {
    this.mContext = paramContext;
  }
  
  public void onAdClosed() {}
  
  public void onAdFailedToLoad(int paramInt)
  {
    switch (paramInt)
    {
    }
    for (;;)
    {
      return;
    }
  }
  
  public void onAdLeftApplication() {}
  
  public void onAdLoaded() {}
  
  public void onAdOpened() {}
}
