package org.gluu.super_gluu.app.Activities;

import android.app.Application;
import android.util.Log;

/**
 * Created by nazaryavornytskyy on 5/9/16.
 */
public class GluuApplication extends Application {
    private static boolean isAppInForeground;
    public static boolean isTrustAllCertificates =false;

    public static boolean isIsAppInForeground() {
        return isAppInForeground;
    }

    public static void applicationResumed() {
        isAppInForeground = true;
        Log.d(String.valueOf(GluuApplication.class), "APP RESUMED");
    }

    public static void applicationPaused() {
        isAppInForeground = false;
        Log.d(String.valueOf(GluuApplication.class), "APP PAUSED");
    }
}
