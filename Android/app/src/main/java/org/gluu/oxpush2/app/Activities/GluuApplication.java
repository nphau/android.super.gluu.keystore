package org.gluu.oxpush2.app.Activities;

import android.app.Application;

/**
 * Created by nazaryavornytskyy on 5/9/16.
 */
public class GluuApplication extends Application {
    private static boolean isAppInForeground;

    public static boolean isIsAppInForeground() {
        return isAppInForeground;
    }

    public static void applicationResumed() {
        isAppInForeground = true;
    }

    public static void applicationPaused() {
        isAppInForeground = false;
    }

}
