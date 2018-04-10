package org.gluu.super_gluu.app;

import android.arch.lifecycle.Lifecycle;
import android.arch.lifecycle.LifecycleObserver;
import android.arch.lifecycle.OnLifecycleEvent;
import android.arch.lifecycle.ProcessLifecycleOwner;
import android.support.multidex.MultiDexApplication;

/**
 * Created by nazaryavornytskyy on 5/9/16.
 */
public class GluuApplication extends MultiDexApplication implements LifecycleObserver {

    private static GluuApplication sInstance;

    private static boolean isAppInForeground;
    private static boolean wentThroughLauncherActivity = false;
    public static boolean isTrustAllCertificates = false;

    @Override
    public void onCreate() {
        super.onCreate();
        ProcessLifecycleOwner.get().getLifecycle().addObserver(this);
    }

    public static boolean isIsAppInForeground() {
        return isAppInForeground;
    }

    @OnLifecycleEvent(Lifecycle.Event.ON_START)
    void onAppForegrounded() {
        isAppInForeground = true;
    }

    @OnLifecycleEvent(Lifecycle.Event.ON_STOP)
    void onAppBackgrounded() {
        isAppInForeground = false;
        wentThroughLauncherActivity = false;
    }

    public GluuApplication() {
        sInstance = this;
    }

    public static GluuApplication get() {
        return sInstance;
    }

    public static void setWentThroughLauncherActivity(boolean wentThroughLauncherActivity) {
        GluuApplication.wentThroughLauncherActivity = wentThroughLauncherActivity;
    }

    public static boolean didAppGoThroughLauncherActivity() {
        return wentThroughLauncherActivity;
    }
}
