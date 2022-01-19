package org.gluu.super_gluu.app.services;

import android.content.Context;
import android.content.SharedPreferences;
import android.preference.PreferenceManager;
import android.util.Log;

import static android.content.ContentValues.TAG;

import com.google.firebase.installations.FirebaseInstallations;

/**
 * Created by nazaryavornytskyy on 4/3/17.
 */

public class AppFirebaseInstanceIDService {

    public void onTokenRefresh(Context context) {
        // Get updated InstanceID token.
        FirebaseInstallations.getInstance().getToken(/* forceRefresh */true)
                .addOnCompleteListener(task -> {
                    if (task.isSuccessful() && task.getResult() != null) {
                        String token = task.getResult().getToken();
                        Log.d(TAG, "Installation auth token: " + token);
                        savePushRegistrationId(token, context);
                    } else {
                        Log.e(TAG, "Unable to get Installation auth token");
                    }
                });
    }

    private void savePushRegistrationId(String pushNotificationToken, Context context){
        SharedPreferences preferences = PreferenceManager.getDefaultSharedPreferences(context);
        SharedPreferences.Editor editor = preferences.edit();
        editor.putString("pushNotificationToken", pushNotificationToken);
        editor.commit();
    }

    public String getPushRegistrationId(Context context){
        SharedPreferences preferences = PreferenceManager.getDefaultSharedPreferences(context);
        return preferences.getString("pushNotificationToken", "");
    }

}
