package org.gluu.super_gluu.app.services;

import android.content.SharedPreferences;
import android.preference.PreferenceManager;
import android.util.Log;

import com.google.firebase.iid.FirebaseInstanceId;
import com.google.firebase.iid.FirebaseInstanceIdService;

import static android.content.ContentValues.TAG;

/**
 * Created by nazaryavornytskyy on 4/3/17.
 */

public class SuperGluuFirebaseInstanceIDService extends FirebaseInstanceIdService {

    @Override
    public void onTokenRefresh() {
        // Get updated InstanceID token.
        //current one - dOK_b8uLrGU:APA91bHYetC63cTA618ThHEOGZA22iW8j69MyJzEL26PJ4-3d7_AaPRuwnGcoodsokjo2DdQR4cWTNFeX0-jARj7YlXaKmDTdl-ZrfYEl65qQlqSFEwz1mRwtw2SKLLiGRFw204cY09p
        String refreshedToken = FirebaseInstanceId.getInstance().getToken();
        Log.d(TAG, "Refreshed token: " + refreshedToken);
        savePushRegistrationId(refreshedToken);

        // If you want to send messages to this application instance or
        // manage this apps subscriptions on the server side, send the
        // Instance ID token to your app server.
//        sendRegistrationToServer(refreshedToken);
    }

    private void savePushRegistrationId(String pushNotificationToken){
        SharedPreferences preferences = PreferenceManager.getDefaultSharedPreferences(this);
        SharedPreferences.Editor editor = preferences.edit();
        editor.putString("pushNotificationToken", pushNotificationToken);
        editor.commit();
    }

    public String getPushRegistrationId(){
        SharedPreferences preferences = PreferenceManager.getDefaultSharedPreferences(this);
        return preferences.getString("pushNotificationToken", "");
    }

}
