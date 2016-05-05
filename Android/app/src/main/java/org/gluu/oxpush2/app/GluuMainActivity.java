/*
 *  oxPush2 is available under the MIT License (2008). See http://opensource.org/licenses/MIT for full text.
 *
 *  Copyright (c) 2014, Gluu
 */

package org.gluu.oxpush2.app;

import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.os.Bundle;
import android.support.v4.app.FragmentTransaction;
import android.support.v4.content.LocalBroadcastManager;
import android.support.v4.view.ViewPager;
import android.support.v7.app.AppCompatActivity;
import android.text.format.Time;
import android.util.Log;
import android.view.Menu;
import android.view.MenuInflater;
import android.view.MenuItem;
import android.widget.Toast;

import com.google.gson.Gson;
import com.mostcho.pincodeview.PinCodeView;

import org.gluu.oxpush2.app.CustomGluuAlertView.CustomGluuAlert;
import org.gluu.oxpush2.app.listener.OxPush2RequestListener;
import org.gluu.oxpush2.app.listener.PushNotificationRegistrationListener;
import org.gluu.oxpush2.app.model.LogInfo;
import org.gluu.oxpush2.model.OxPush2Request;
import org.gluu.oxpush2.net.CommunicationService;
import org.gluu.oxpush2.push.PushNotificationManager;
import org.gluu.oxpush2.store.AndroidKeyDataStore;
import org.gluu.oxpush2.u2f.v2.SoftwareDevice;
import org.gluu.oxpush2.u2f.v2.exception.U2FException;
import org.gluu.oxpush2.u2f.v2.model.TokenEntry;
import org.gluu.oxpush2.u2f.v2.model.TokenResponse;
import org.gluu.oxpush2.u2f.v2.store.DataStore;
import org.gluu.oxpush2.device.DeviceUuidManager;
import org.gluu.oxpush2.util.Utils;
import org.json.JSONException;

import java.io.IOException;
import java.io.UnsupportedEncodingException;

/**
 * Main activity
 *
 * Created by Yuriy Movchan on 12/28/2015.
 */
public class GluuMainActivity extends AppCompatActivity implements OxPush2RequestListener, PushNotificationRegistrationListener, KeyHandleInfoFragment.OnDeleteKeyHandleListener, PinCodeView.IPinCodeViewListener {

    private static final String TAG = "main-activity";

    public static final String QR_CODE_PUSH_NOTIFICATION_MESSAGE = GluuMainActivity.class.getPackage().getName() + ".QR_CODE_PUSH_NOTIFICATION_MESSAGE";
    public static final int MESSAGE_NOTIFICATION_ID = 444555;

    private SoftwareDevice u2f;
    private AndroidKeyDataStore dataStore;
    private static Context context;

    private Boolean isShowClearMenu = false;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        // Get the view from gluu_activity_main_main.xml
        setContentView(R.layout.gluu_activity_main);

        // Locate the viewpager in gluu_activity_main.xmln.xml
        ViewPager viewPager = (ViewPager) findViewById(R.id.pager);
        // Set the ViewPagerAdapter into ViewPager
        viewPager.setAdapter(new ViewPagerAdapter(getSupportFragmentManager(), this));

        viewPager.addOnPageChangeListener(new ViewPager.OnPageChangeListener() {
            @Override
            public void onPageScrolled(int position, float positionOffset, int positionOffsetPixels) {

            }

            @Override
            public void onPageSelected(int position) {
                isShowClearMenu = position == 1 ? true : false;
                reloadLogs();
                invalidateOptionsMenu();
            }

            @Override
            public void onPageScrollStateChanged(int state) {

            }
        });

        // Init network layer
        CommunicationService.init();

        // Init device UUID service
        DeviceUuidManager deviceUuidFactory = new DeviceUuidManager();
        deviceUuidFactory.init(this);

        // Init GCM service
        PushNotificationManager pushNotificationManager = new PushNotificationManager(BuildConfig.PROJECT_NUMBER);
        pushNotificationManager.registerIfNeeded(this, this);

        context = getApplicationContext();
        this.dataStore = new AndroidKeyDataStore(context);
        this.u2f = new SoftwareDevice(this, dataStore);
        setIsButtonVisible(dataStore.getLogs().size() != 0);

        getSupportActionBar().setDisplayShowHomeEnabled(true);
        getSupportActionBar().setIcon(R.mipmap.title_image);

//        createMockObjects();

//        // Locate the viewpager in gluu_activity_main_main.xml
//        ViewPager viewPager = (ViewPager) findViewById(R.id.pager);
//
//        // Set the ViewPagerAdapter into ViewPager
//        viewPager.setAdapter(new ViewPagerAdapter(getSupportFragmentManager()));
////        Toolbar toolbar = (Toolbar) findViewById(R.id.toolbar);
////        setSupportActionBar(toolbar);
////
////        MainActivityFragment mainActivityFragment = new MainActivityFragment();
////        getSupportFragmentManager().beginTransaction().replace(R.id.fragment_container, mainActivityFragment).commit();
////
////        FloatingActionButton fab = (FloatingActionButton) findViewById(R.id.fab);
////        fab.setOnClickListener(new View.OnClickListener() {
////            @Override
////            public void onClick(View view) {
////                Snackbar.make(view, getString(R.string.oxpush2_into_text), Snackbar.LENGTH_LONG)
////                        .setAction("Action", null).show();
////            }
////        });

        // Check if we get push notification
        Intent intent = getIntent();
        if (intent.hasExtra(QR_CODE_PUSH_NOTIFICATION_MESSAGE)) {
            String requestJson = intent.getStringExtra(QR_CODE_PUSH_NOTIFICATION_MESSAGE);
            onQrRequest(requestJson);
        }

    }

    private void createMockObjects(){
        TokenEntry tokenEntry = new TokenEntry("keyPairGenerator", "application", "issuer");
        Time now = new Time();
        now.setToNow();
        tokenEntry.setCreatedDate(now.toString());
        tokenEntry.setUserName("nazar2016");
        tokenEntry.setAuthenticationMode("authentication");
        String serverName = tokenEntry.getIssuer();
        String prefixKeyHandle = getApplicationContext().getString(R.string.keyHandleCell);
        String keyHandleTitle = prefixKeyHandle + " " + serverName;
        tokenEntry.setKeyName(keyHandleTitle);
        String keyHandleStr = "keyHandle";
        try {
            tokenEntry.setKeyHandle(keyHandleStr.getBytes("UTF-8"));
        } catch (UnsupportedEncodingException e) {
            e.printStackTrace();
        }
        final boolean oneStep = false;
        String authenticationType = GluuMainActivity.getResourceString(oneStep ? R.string.one_step : R.string.two_step);
        tokenEntry.setAuthenticationType(authenticationType);
        try {
            dataStore.storeTokenEntry(keyHandleStr.getBytes("UTF-8"), tokenEntry);
        } catch (UnsupportedEncodingException e) {
            e.printStackTrace();
        }
        LogInfo log1 = new LogInfo();
        log1.setIssuer("https://ce-release.gluu.org");
        log1.setUserName("nazar2016");
        log1.setLocationIP("10.76.112.97");
        log1.setLocationAddress("Texas, AX");
        log1.setLogState(LogState.LOGIN_SUCCESS);
        LogInfo log2 = new LogInfo();
        log2.setIssuer("https://demo.gluu.org");
        log2.setUserName("nazar2016");
        log2.setLocationIP("10.76.112.97");
        log2.setLocationAddress("Texas, AX");
        log2.setLogState(LogState.LOGIN_FAILED);
        log2.setMessage("All devices are compromised");
        dataStore.deleteLogs();
        dataStore.saveLog(log1);
        dataStore.saveLog(log2);
//        setIsButtonVisible(true);
    }

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        if (isShowClearMenu && dataStore.getLogs().size() > 0 && getIsButtonVisible()) {
            MenuInflater inflater = getMenuInflater();
            inflater.inflate(R.menu.clear_logs_menu, menu);
        }
        return true;
    }

    private void reloadLogs(){
        Intent intent = new Intent("reload-logs");
        LocalBroadcastManager.getInstance(this).sendBroadcast(intent);
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        GluuAlertCallback listener = new GluuAlertCallback(){
            @Override
            public void onPositiveButton() {
                dataStore.deleteLogs();
                reloadLogs();
                invalidateOptionsMenu();
            }
        };
        CustomGluuAlert gluuAlert = new CustomGluuAlert(GluuMainActivity.this);
        gluuAlert.setMessage(getApplicationContext().getString(R.string.clear_logs));
        gluuAlert.setYesTitle(getApplicationContext().getString(R.string.yes));
        gluuAlert.setNoTitle(getApplicationContext().getString(R.string.no));
        gluuAlert.setmListener(listener);
        gluuAlert.show();
        return super.onOptionsItemSelected(item);
    }

    @Override
    public void onQrRequest(String requestJson) {
        if (!validateOxPush2Request(requestJson)) {
            return;
        }

        ApproveDenyFragment approveDenyFragment = new ApproveDenyFragment();
        approveDenyFragment.setIsUserInfo(false);
        OxPush2Request oxPush2Request = new Gson().fromJson(requestJson, OxPush2Request.class);
        approveDenyFragment.setPush2Request(oxPush2Request);
        final ProcessManager processManager = new ProcessManager();
        processManager.setOxPush2Request(oxPush2Request);
        processManager.setDataStore(dataStore);
        processManager.setActivity(this);
        processManager.setOxPush2RequestListener(new OxPush2RequestListener() {
            @Override
            public void onQrRequest(String requestJson) {
                //skip code there
            }

            @Override
            public TokenResponse onSign(String jsonRequest, String origin, Boolean isDeny) throws JSONException, IOException, U2FException {
                return u2f.sign(jsonRequest, origin, isDeny);
            }

            @Override
            public TokenResponse onEnroll(String jsonRequest, OxPush2Request oxPush2Request, Boolean isDeny) throws JSONException, IOException, U2FException {
                return u2f.enroll(jsonRequest, oxPush2Request, isDeny);
            }

            @Override
            public DataStore onGetDataStore() {
                return dataStore;
            }
        });
        approveDenyFragment.setListener(new RequestProcessListener() {
            @Override
            public void onApprove() {
                processManager.onOxPushRequest(false);
            }

            @Override
            public void onDeny() {
                processManager.onOxPushRequest(true);
            }
        });
        FragmentTransaction transaction = getSupportFragmentManager().beginTransaction();
        transaction.replace(R.id.main_root_frame, approveDenyFragment);
        transaction.addToBackStack(null);
        transaction.commit();
//        FragmentTransaction fragmentTransaction = getSupportFragmentManager().beginTransaction();
//        Fragment fragment = ProcessManager.newInstance(requestJson);
//
//        fragmentTransaction.setTransition(FragmentTransaction.TRANSIT_FRAGMENT_OPEN);
//        fragmentTransaction.replace(R.id.fragment_container, fragment);
//        fragmentTransaction.addToBackStack(null);
//        fragmentTransaction.commit();
    }

    @Override
    public TokenResponse onSign(String jsonRequest, String origin, Boolean isDeny) throws JSONException, IOException, U2FException {
        return u2f.sign(jsonRequest, origin, isDeny);
    }

    @Override
    public TokenResponse onEnroll(String jsonRequest, OxPush2Request oxPush2Request, Boolean isDeny) throws JSONException, IOException, U2FException {
        return u2f.enroll(jsonRequest, oxPush2Request, isDeny);
    }

    @Override
    public DataStore onGetDataStore() {
        return dataStore;
    }

    private boolean validateOxPush2Request(String requestJson) {
        boolean result = true;
        try {
            // Try to parse JSON
            OxPush2Request oxPush2Request = new Gson().fromJson(requestJson, OxPush2Request.class);

            boolean isOneStep = Utils.isEmpty(oxPush2Request.getUserName());
            boolean isTwoStep = Utils.areAllNotEmpty(oxPush2Request.getUserName(), oxPush2Request.getIssuer(), oxPush2Request.getApp(),
                    oxPush2Request.getState(), oxPush2Request.getMethod());

            if (BuildConfig.DEBUG) Log.d(TAG, "isOneStep: " + isOneStep + " isTwoStep: " + isTwoStep);

            if (isOneStep || isTwoStep) {
                // Valid authentication method should be used
                if (isTwoStep && !(Utils.equals(oxPush2Request.getMethod(), "authenticate") || Utils.equals(oxPush2Request.getMethod(), "enroll"))) {
                    result = false;
                }
            } else {
                // All fields must be not empty
                result = false;
            }
        } catch (Exception ex) {
            Log.e(TAG, "Failed to parse QR code");
            result = false;
        }

        if (!result) {
            Toast.makeText(getApplicationContext(), R.string.invalid_qr_code, Toast.LENGTH_LONG).show();
        }

        return result;
    }

    @Override
    public void onPushRegistrationSuccess(String registrationId, boolean isNewRegistration) {
    }

    @Override
    public void onPushRegistrationFailure(Exception ex) {
        this.runOnUiThread(new Runnable() {
            @Override
            public void run() {
                Toast.makeText(getApplicationContext(), R.string.failed_subscribe_push_notification, Toast.LENGTH_LONG).show();
            }
        });
    }

    @Override
    public void onDeleteKeyHandle(byte[] keyHandle) {
        dataStore.deleteTokenEntry(keyHandle);
    }

    public static String getResourceString(int resourceID){
        return context.getString(resourceID);
    }

    @Override
    public void onNewPinCode(String pinCode) {
        savePinCode(pinCode);
        Intent intent = new Intent("reset_pin_code-event");
        // You can also include some extra data.
        intent.putExtra("message", "new_pin");
        LocalBroadcastManager.getInstance(this).sendBroadcast(intent);
    }

    @Override
    public void onCorrectPinCode(boolean isPinCodeCorrect) {
        //to change pin code, first need check if user knows current one
        if (isPinCodeCorrect){//resent pin code
            savePinCode("0000");
            Intent intent = new Intent("reset_pin_code-event");
            // You can also include some extra data.
            intent.putExtra("message", "reset");
            LocalBroadcastManager.getInstance(this).sendBroadcast(intent);
        }
    }

    public void savePinCode(String newPinCode){
        SharedPreferences preferences = getApplicationContext().getSharedPreferences("PinCodeSettings", Context.MODE_PRIVATE);
        SharedPreferences.Editor editor = preferences.edit();
        editor.putString("PinCode", newPinCode);
        editor.commit();
    }

    public Boolean getIsButtonVisible(){
        SharedPreferences preferences = getApplicationContext().getSharedPreferences("CleanLogsSettings", Context.MODE_PRIVATE);
        Boolean isVisible = preferences.getBoolean("isCleanButtonVisible", true);
        return isVisible;
    }

    public void setIsButtonVisible(Boolean isVsible){
        SharedPreferences preferences = getApplicationContext().getSharedPreferences("CleanLogsSettings", Context.MODE_PRIVATE);
        SharedPreferences.Editor editor = preferences.edit();
        editor.putBoolean("isCleanButtonVisible", isVsible);
        editor.commit();
    }

    public interface GluuAlertCallback{
        void onPositiveButton();
    }

    public interface RequestProcessListener{
        void onApprove();
        void onDeny();
    }

}
