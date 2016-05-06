/*
 *  oxPush2 is available under the MIT License (2008). See http://opensource.org/licenses/MIT for full text.
 *
 *  Copyright (c) 2014, Gluu
 */

package org.gluu.oxpush2.app;

import android.app.Notification;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.content.Context;
import android.content.Intent;
import android.media.RingtoneManager;
import android.net.Uri;
import android.os.Bundle;
import android.support.v4.app.NotificationCompat;
import android.util.Log;

import com.google.android.gms.gcm.GcmListenerService;

import org.gluu.oxpush2.util.Utils;

/**
 * Handles push messages recieved from server
 *
 * Created by Yuriy Movchan on 02/19/2016.
 */
public class PushNotificationService extends GcmListenerService {

    private static final String TAG = "main-activity";
    private static final String DENY_ACTION = "DENY_ACTION";
    private static final String APPROVE_ACTION = "APPROVE_ACTION";

    @Override
    public void onMessageReceived(String from, Bundle data) {
        String title = data.getString("title");
        String message = data.getString("message");
        if (Utils.isEmpty(title) || Utils.isEmpty(message)) {
            Log.e(TAG, "Get unknown push notification message: " + data.toString());
            return;
        }

//        Intent intent = new Intent(this, GluuMainActivity.class);
//        intent.putExtra(GluuMainActivity.QR_CODE_PUSH_NOTIFICATION_MESSAGE, message);
//        intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);

        sendNotification("Authentication login request");

//        startActivity(intent);
    }

    private void sendNotification(String title) {
        Intent intent = new Intent(this, GluuMainActivity.class);
        intent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP);
        PendingIntent pendingIntent = PendingIntent.getActivity(this, 0, intent,
                PendingIntent.FLAG_ONE_SHOT);

        Uri defaultSoundUri = RingtoneManager.getDefaultUri(RingtoneManager.TYPE_NOTIFICATION);
        //deny intent
        Intent yesReceive = new Intent();
        yesReceive.setAction(DENY_ACTION);
        PendingIntent pendingIntentDeny = PendingIntent.getBroadcast(this, 12345, yesReceive, PendingIntent.FLAG_UPDATE_CURRENT);

        NotificationCompat.Builder notificationBuilder = new NotificationCompat.Builder(this)
                .setSmallIcon(R.drawable.app_icon)
                .setContentTitle("Super Gluu")
                .setContentText(title)
                .setAutoCancel(true)
                .setSound(defaultSoundUri)
                .setContentIntent(pendingIntent)
                .addAction(R.drawable.deny_icon, "Deny", pendingIntentDeny)
                .addAction(R.drawable.approve_icon, "Approve", null);

        NotificationManager notificationManager =
                (NotificationManager) getSystemService(Context.NOTIFICATION_SERVICE);

        notificationManager.notify(GluuMainActivity.MESSAGE_NOTIFICATION_ID, notificationBuilder.build());
    }}
