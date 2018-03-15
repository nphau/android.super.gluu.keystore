/*
 *  oxPush2 is available under the MIT License (2008). See http://opensource.org/licenses/MIT for full text.
 *
 *  Copyright (c) 2014, Gluu
 */

package org.gluu.super_gluu.app;

import android.annotation.SuppressLint;
import android.app.Activity;
import android.app.NotificationManager;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.content.SharedPreferences;
import android.content.pm.ActivityInfo;
import android.content.pm.PackageManager;
import android.content.res.Configuration;
import android.media.Ringtone;
import android.media.RingtoneManager;
import android.net.Uri;
import android.os.Bundle;
import android.os.Vibrator;
import android.support.design.widget.NavigationView;
import android.support.v4.app.ActivityCompat;
import android.support.v4.app.Fragment;
import android.support.v4.app.FragmentManager;
import android.support.v4.app.FragmentManager.OnBackStackChangedListener;
import android.support.v4.app.FragmentTransaction;
import android.support.v4.content.LocalBroadcastManager;
import android.support.v4.view.GravityCompat;
import android.support.v4.widget.DrawerLayout;
import android.support.v7.app.ActionBarDrawerToggle;
import android.support.v7.app.AppCompatActivity;
import android.support.v7.widget.Toolbar;
import android.util.Log;
import android.view.MenuItem;
import android.view.View;
import android.view.ViewGroup;
import android.view.inputmethod.InputMethodManager;
import android.widget.Toast;

import com.google.android.gms.ads.AdRequest;
import com.google.android.gms.ads.AdView;
import com.google.android.gms.ads.MobileAds;
import com.google.gson.Gson;

import org.gluu.super_gluu.app.activities.GluuApplication;
import org.gluu.super_gluu.app.activities.MainActivity;
import org.gluu.super_gluu.app.customGluuAlertView.CustomGluuAlert;
import org.gluu.super_gluu.app.fragments.KeysFragment.KeyFragmentListFragment;
import org.gluu.super_gluu.app.fragments.KeysFragment.KeyHandleInfoFragment;
import org.gluu.super_gluu.app.fragments.LicenseFragment.LicenseFragment;
import org.gluu.super_gluu.app.fragments.LogsFragment.LogsFragment;
import org.gluu.super_gluu.app.fragments.PinCodeFragment.PinCodeFragment;
import org.gluu.super_gluu.app.fragments.PinCodeFragment.PinCodeSettingFragment;
import org.gluu.super_gluu.app.fragments.SettingsFragment.SettingsFragment;
import org.gluu.super_gluu.app.fragments.SettingsFragment.SettingsPinCode;
import org.gluu.super_gluu.app.listener.OxPush2RequestListener;
import org.gluu.super_gluu.app.model.LogInfo;
import org.gluu.super_gluu.app.purchase.InAppPurchaseService;
import org.gluu.super_gluu.app.services.FingerPrintManager;
import org.gluu.super_gluu.app.settings.Settings;
import org.gluu.super_gluu.device.DeviceUuidManager;
import org.gluu.super_gluu.model.OxPush2Request;
import org.gluu.super_gluu.net.CommunicationService;
import org.gluu.super_gluu.store.AndroidKeyDataStore;
import org.gluu.super_gluu.u2f.v2.SoftwareDevice;
import org.gluu.super_gluu.u2f.v2.exception.U2FException;
import org.gluu.super_gluu.u2f.v2.model.TokenEntry;
import org.gluu.super_gluu.u2f.v2.model.TokenResponse;
import org.gluu.super_gluu.u2f.v2.store.DataStore;
import org.gluu.super_gluu.util.Utils;
import org.json.JSONException;

import java.io.IOException;
import java.util.List;

import SuperGluu.app.BuildConfig;
import SuperGluu.app.R;

/**
 * Main activity
 *
 * Created by Yuriy Movchan on 12/28/2015.
 */
public class GluuMainActivity extends AppCompatActivity implements OxPush2RequestListener, KeyHandleInfoFragment.OnDeleteKeyHandleListener, PinCodeFragment.PinCodeViewListener, ApproveDenyFragment.OnDeleteLogInfoListener, LicenseFragment.OnMainActivityListener {

    private static final String TAG = "main-activity";

    /**
     * Id to identify a camera permission request.
     */
    private static final int REQUEST_CAMERA = 0;

    public static final String QR_CODE_PUSH_NOTIFICATION_MESSAGE = GluuMainActivity.class.getPackage().getName() + ".QR_CODE_PUSH_NOTIFICATION_MESSAGE";
    public static final String QR_CODE_PUSH_NOTIFICATION = "QR_CODE_PUSH_NOTIFICATION";
    public static final int MESSAGE_NOTIFICATION_ID = 444555;

    private DrawerLayout drawer;
    private Toolbar toolbar;
    private ActionBarDrawerToggle toggle;
    DrawerLayout.DrawerListener drawerListener;


    private SoftwareDevice u2f;
    private AndroidKeyDataStore dataStore;
    private static Context context;

    private Boolean isOXRequestProtected = false;
    private OxPush2Request oxPush2RequestProtected;

    private FragmentManager fragmentManager;

    private Settings settings = new Settings();

    private BroadcastReceiver mPushMessageReceiver = new BroadcastReceiver() {
        @Override
        public void onReceive(Context context, Intent intent) {
            //Pop backstack to get back to home screen
            if(fragmentManager.getBackStackEntryCount() > 0) {
                for (int i = 0; i < fragmentManager.getBackStackEntryCount(); i++) {
                    fragmentManager.popBackStack();
                }
            }

            setTitle(getString(R.string.home));

            // Get extra data included in the Intent
            String message = intent.getStringExtra(GluuMainActivity.QR_CODE_PUSH_NOTIFICATION_MESSAGE);
            final OxPush2Request oxPush2Request = new Gson().fromJson(message, OxPush2Request.class);
            onQrRequest(oxPush2Request);
            //play sound and vibrate
            try {
                Uri notification = RingtoneManager.getDefaultUri(RingtoneManager.TYPE_NOTIFICATION);
                Ringtone r = RingtoneManager.getRingtone(context, notification);
                r.play();
            } catch (Exception e) {
                e.printStackTrace();
            }
            ((Vibrator)getApplication().getSystemService(Context.VIBRATOR_SERVICE)).vibrate(800);
        }
    };

    //For purchases
    private InAppPurchaseService inAppPurchaseService = new InAppPurchaseService();

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        // Get the view from gluu_activity_main_main.xml
        setContentView(R.layout.gluu_activity_main);
        context = getApplicationContext();

        fragmentManager = getSupportFragmentManager();
        initNavDrawer();

        LocalBroadcastManager.getInstance(this).registerReceiver(mPushMessageReceiver,
                new IntentFilter(GluuMainActivity.QR_CODE_PUSH_NOTIFICATION));

        // Init network layer
        CommunicationService.init();

        // Init device UUID service
        DeviceUuidManager deviceUuidFactory = new DeviceUuidManager();
        deviceUuidFactory.init(this);

        this.dataStore = new AndroidKeyDataStore(context);
        this.u2f = new SoftwareDevice(this, dataStore);

        checkUserCameraPermission();

        //temporary turn off rotation
        setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_NOSENSOR);

        //Init InAPP-Purchase service
        initIAPurchaseService();

        setupInitialFragment();
    }

    private void setupInitialFragment() {
        MainActivityFragment mainActivityFragment = new MainActivityFragment();

         //Insert the fragment by replacing any existing fragment
        fragmentManager
                .beginTransaction()
                .replace(R.id.main_frame_layout, mainActivityFragment)
                .commit();

    }

    private void initNavDrawer() {
        toolbar = (Toolbar) findViewById(R.id.nav_drawer_toolbar);
        setSupportActionBar(toolbar);
        setTitle(getString(R.string.home));

        drawer = (DrawerLayout) findViewById(R.id.drawer_layout);

        NavigationView navigationView = (NavigationView) findViewById(R.id.nvView);
        if (navigationView != null) {
            navigationView.setItemIconTintList(null);
        }

        setupDrawerContent(navigationView);

        setupToggleState();
    }

    @Override
    public void onBackPressed() {
        super.onBackPressed();

        if(fragmentManager.getBackStackEntryCount() > 0) {
            Fragment fragment = fragmentManager.findFragmentById(R.id.main_frame_layout);

            if(fragment != null) {

                if(fragment instanceof KeyFragmentListFragment) {
                    setTitle(getString(R.string.keys));
                } else if(fragment instanceof LogsFragment) {
                    setTitle(getString(R.string.logs));
                } else if(fragment instanceof PinCodeFragment || fragment instanceof PinCodeSettingFragment) {
                    setTitle(getString(R.string.pin_code));
                }
            }
        } else {
            setTitle(getString(R.string.home));
        }
    }

    private void initGoogleADS(Boolean isShow){
        AdView adView = (AdView) findViewById(R.id.adView);
        if (!isShow) {
            MobileAds.initialize(getApplicationContext(), "ca-app-pub-3932761366188106~2301594871");
            AdRequest adRequest = new AdRequest.Builder().build();
            if(adView != null) {
                adView.loadAd(adRequest);
            }
        } else {
            if(adView != null) {
                ViewGroup.LayoutParams params = adView.getLayoutParams();
                params.height = 0;
                adView.setLayoutParams(params);
            }
        }
        Intent intent = new Intent("on-ad-free-event");
        // You can also include some extra data.
        intent.putExtra("isAdFree", isShow);
        LocalBroadcastManager.getInstance(this).sendBroadcast(intent);
    }

    private void initIAPurchaseService(){
        inAppPurchaseService.initInAppService(context);
        inAppPurchaseService.setCustomEventListener(new InAppPurchaseService.OnInAppServiceListener() {
            @Override
            public void onSubscribed(Boolean isSubscribed) {
                //Init GoogleMobile AD
                initGoogleADS(isSubscribed);
            }
        });
        inAppPurchaseService.reloadPurchaseService();
    }

    @Override
    protected void onNewIntent(Intent intent) {
        super.onNewIntent(intent);
    }

    @Override
    public void onSaveInstanceState( Bundle outState ) {
        //skip it at all
    }

    private void reloadLogs(){
        Intent intent = new Intent("reload-logs");
        LocalBroadcastManager.getInstance(this).sendBroadcast(intent);
    }

    private void onBackButtonClicked(){
        if (Settings.getIsBackButtonVisibleForLog(getApplicationContext())) {
            Settings.setIsBackButtonVisibleForLog(getApplicationContext(), false);
            invalidateOptionsMenu();
            onBackPressed();
        } else {
            Settings.setIsBackButtonVisibleForLog(getApplicationContext(), false);
            if (settings.getEditingModeLogs()) {
                Intent intent = new Intent("on-delete-logs");
                LocalBroadcastManager.getInstance(getApplicationContext()).sendBroadcast(intent);
                settings.setEditingModeLogs(false);
            } else {
                settings.setEditingModeLogs(true);
            }
            Intent intent = new Intent("editing-mode-logs");
            intent.putExtra("isEditingMode", settings.getEditingModeLogs());
            LocalBroadcastManager.getInstance(getApplicationContext()).sendBroadcast(intent);
            invalidateOptionsMenu();
        }
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

            @Override
            public void onNegativeButton() {
                //Skip here
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

    public void doQrRequest(OxPush2Request oxPush2Request) {
        if (!validateOxPush2Request(oxPush2Request)) {
            return;
        }
        toolbar.setVisibility(View.GONE);

        Settings.setPushDataEmpty(getApplicationContext());
        NotificationManager notificationManager = (NotificationManager) getSystemService(Context.NOTIFICATION_SERVICE);
        if(notificationManager != null) {
            notificationManager.cancel(GluuMainActivity.MESSAGE_NOTIFICATION_ID);
        }
        final ProcessManager processManager = createProcessManager(oxPush2Request);
        ApproveDenyFragment approveDenyFragment = new ApproveDenyFragment();
        approveDenyFragment.setIsUserInfo(false);
        approveDenyFragment.setPush2Request(oxPush2Request);
        approveDenyFragment.setListener(new RequestProcessListener() {
            @Override
            public void onApprove() {
                processManager.onOxPushRequest(false);
                toolbar.setVisibility(View.VISIBLE);
            }

            @Override
            public void onDeny() {
                processManager.onOxPushRequest(true);
                toolbar.setVisibility(View.VISIBLE);
            }
        });
        FragmentTransaction transaction = getSupportFragmentManager().beginTransaction();
        transaction.replace(R.id.main_frame_layout, approveDenyFragment);
        transaction.addToBackStack(null);
        transaction.commitAllowingStateLoss();
    }

    @Override
    public void onQrRequest(final OxPush2Request oxPush2Request) {
        if (!this.isDestroyed()) {
            Boolean isFingerprint = Settings.getFingerprintEnabled(context);
            if (isFingerprint){
                FingerPrintManager fingerPrintManager = new FingerPrintManager(this);
                fingerPrintManager.onFingerPrint(new FingerPrintManager.FingerPrintManagerCallback() {
                    @Override
                    public void fingerprintResult(Boolean isSuccess) {
                        doQrRequest(oxPush2Request);
                    }
                });
            } else if (Settings.getPinCodeEnabled(getApplicationContext())) {
                isOXRequestProtected = true;
                oxPush2RequestProtected = oxPush2Request;
                loadPinCodeFragment();
            } else {
                doQrRequest(oxPush2Request);
            }
        }
    }

    @Override
    public void onAdFreeButtonClick(){
        if (inAppPurchaseService.readyToPurchase) {
            if (!inAppPurchaseService.isSubscribed) {
                inAppPurchaseService.purchase(GluuMainActivity.this);
            } else {
                initGoogleADS(true);
            }
        }
    }

    @Override
    public void onPurchaseRestored() {
        if (inAppPurchaseService.readyToPurchase) {
            if (!inAppPurchaseService.isSubscribed) {
                inAppPurchaseService.restorePurchase();
            } else {
                initGoogleADS(true);
            }
        }
    }

    public void loadPinCodeFragment() {
        PinCodeFragment pinCodeFragment = new PinCodeFragment();
        pinCodeFragment.setIsSettings(false);
        pinCodeFragment.setIsSetNewPinCode(false);

        fragmentManager
                .beginTransaction()
                .replace(R.id.main_frame_layout, pinCodeFragment)
                .addToBackStack(null)
                .commit();
    }

    private ProcessManager createProcessManager(OxPush2Request oxPush2Request){
        ProcessManager processManager = new ProcessManager();
        processManager.setOxPush2Request(oxPush2Request);
        processManager.setDataStore(dataStore);
        processManager.setActivity(this);
        processManager.setOxPush2RequestListener(new OxPush2RequestListener() {
            @Override
            public void onQrRequest(OxPush2Request oxPush2Request) {
                //skip code there
            }

            @Override
            public TokenResponse onSign(String jsonRequest, String origin, Boolean isDeny)
                    throws JSONException, IOException, U2FException {
                return u2f.sign(jsonRequest, origin, isDeny);
            }

            @Override
            public TokenResponse onEnroll(String jsonRequest, OxPush2Request oxPush2Request, Boolean isDeny)
                    throws JSONException, IOException, U2FException {
                return u2f.enroll(jsonRequest, oxPush2Request, isDeny);
            }

            @Override
            public DataStore onGetDataStore() {
                return dataStore;
            }

            @Override
            public void onAdFreeButtonClick(){}

            @Override
            public void onPurchaseRestored() {}
        });

        return processManager;
    }

    @Override
    public TokenResponse onSign(String jsonRequest, String origin, Boolean isDeny)
            throws JSONException, IOException, U2FException {
        return u2f.sign(jsonRequest, origin, isDeny);
    }

    @Override
    public TokenResponse onEnroll(String jsonRequest, OxPush2Request oxPush2Request, Boolean isDeny)
            throws JSONException, IOException, U2FException {
        return u2f.enroll(jsonRequest, oxPush2Request, isDeny);
    }

    @Override
    public DataStore onGetDataStore() {
        return dataStore;
    }

    private boolean validateOxPush2Request(OxPush2Request oxPush2Request) {
        boolean result = true;
        try {
            boolean isOneStep = Utils.isEmpty(oxPush2Request.getUserName());
            boolean isTwoStep = Utils.areAllNotEmpty(oxPush2Request.getUserName(), oxPush2Request.getIssuer(), oxPush2Request.getApp(),
                    oxPush2Request.getState(), oxPush2Request.getMethod());
            boolean isCredManager = Utils.areAllNotEmpty(oxPush2Request.getUserName(), oxPush2Request.getIssuer(), oxPush2Request.getApp(), oxPush2Request.getMethod());

            if (BuildConfig.DEBUG) Log.d(TAG, "isOneStep: " + isOneStep + " isTwoStep: " + isTwoStep);

            if (isOneStep || isTwoStep) {
                // Valid authentication method should be used
                if (isTwoStep && !(Utils.equals(oxPush2Request.getMethod(), "authenticate") || Utils.equals(oxPush2Request.getMethod(), "enroll"))) {
                    result = false;
                }
            } else {
                // All fields must be not empty
                result = isCredManager;
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
    public void onDeleteKeyHandle(TokenEntry key) {
        dataStore.deleteKeyHandle(key);
    }

    public static String getResourceString(int resourceID){
        return context.getString(resourceID);
    }

    @Override
    public void onNewPinCode(String pinCode) {

    }

    @Override
    public void onCorrectPinCode(boolean isPinCodeCorrect) {
        if (isPinCodeCorrect){
            if (isOXRequestProtected){
                //Hide keyboard
                InputMethodManager inputMethodManager = (InputMethodManager) getSystemService(Activity.INPUT_METHOD_SERVICE);
                if(inputMethodManager != null) {
                    inputMethodManager.toggleSoftInput(InputMethodManager.SHOW_IMPLICIT, 0);
                }
                onBackPressed();
                doQrRequest(oxPush2RequestProtected);
                isOXRequestProtected = false;
            } else {
                showAlertView(getString(R.string.new_pin_added));
            }
        } else {
            //to change pin code, first need check if user knows current one
            Intent intent = new Intent(GluuMainActivity.this, MainActivity.class);
            startActivity(intent);
            finish();
        }
    }

    private void showAlertView(String message){
        CustomGluuAlert gluuAlert = new CustomGluuAlert(this);
        gluuAlert.setMessage(message);
        gluuAlert.show();
    }

    @Override
    public void onDeleteLogInfo(OxPush2Request oxPush2Request) {
        dataStore.deleteLogs(oxPush2Request);
        onBackButtonClicked();
    }

    @Override
    public void onDeleteLogInfo(List<LogInfo> logInfo) {
        dataStore.deleteLogs(logInfo);
        settings.setEditingModeLogs(false);
        reloadLogs();
    }

    //OnMainActivityListener methods
    @Override
    public void onLicenseAgreement() {

    }

    @Override
    public void onMainActivity() {

    }

    @Override
    public void onShowPinFragment() {

    }

    @Override
    public void onShowKeyInfo(KeyHandleInfoFragment infoFragment) {

    }
    //// OnMainActivityListener End

    public interface GluuAlertCallback{
        void onPositiveButton();
        void onNegativeButton();
    }

    public interface RequestProcessListener{
        void onApprove();
        void onDeny();
    }

    @Override
    protected void onPause() {
        GluuApplication.applicationPaused();
        super.onPause();
    }

    @Override
    protected void onResume() {
        inAppPurchaseService.reloadPurchaseService();
        GluuApplication.applicationResumed();
        super.onResume();
    }

    @SuppressLint("ApplySharedPref")
    @Override
    protected void onDestroy() {
        SharedPreferences preferences = getApplicationContext().getSharedPreferences("PinCodeSettings", Context.MODE_PRIVATE);
        SharedPreferences.Editor editor = preferences.edit();
        editor.putBoolean("isMainActivityDestroyed", true);
        editor.commit();
        Log.d(String.valueOf(GluuApplication.class), "APP DESTROYED");
        inAppPurchaseService.deInitPurchaseService();
        super.onDestroy();
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        if (inAppPurchaseService.isHandleResult(requestCode, resultCode, data))
            super.onActivityResult(requestCode, resultCode, data);
    }

    private void checkUserCameraPermission(){
        Log.i(TAG, "Show camera button pressed. Checking permission.");
        // Check if the Camera permission is already available.
        if (ActivityCompat.checkSelfPermission(this, android.Manifest.permission.CAMERA)
                != PackageManager.PERMISSION_GRANTED) {
            // Camera permission has not been granted.
            requestCameraPermission();

        } else {
            // Camera permissions is already available, show the camera preview.
            Log.i(TAG,
                    "CAMERA permission has already been granted. Displaying camera preview.");
        }
    }

    private void requestCameraPermission() {
        Log.i(TAG, "CAMERA permission has NOT been granted. Requesting permission.");

        if (ActivityCompat.shouldShowRequestPermissionRationale(this,
                android.Manifest.permission.CAMERA)) {
            // Provide an additional rationale to the user if the permission was not granted
            // and the user would benefit from additional context for the use of the permission.
            // For example if the user has previously denied the permission.
            Log.i(TAG,
                    "Displaying camera permission rationale to provide additional context.");
            ActivityCompat.requestPermissions(GluuMainActivity.this,
                    new String[]{android.Manifest.permission.CAMERA},
                    REQUEST_CAMERA);
        } else {
            // Camera permission has not been granted yet. Request it directly.
            ActivityCompat.requestPermissions(this, new String[]{android.Manifest.permission.CAMERA},
                    REQUEST_CAMERA);
        }
    }

    private void setupDrawerContent(NavigationView navigationView) {
        navigationView.setNavigationItemSelectedListener(
                new NavigationView.OnNavigationItemSelectedListener() {
                    @Override
                    public boolean onNavigationItemSelected(MenuItem menuItem) {
                        selectDrawerItem(menuItem);
                        return true;
                    }
                });
    }

    private void setupToggleState() {
        if (toolbar != null) {
            toggle = new ActionBarDrawerToggle(
                    this, drawer, toolbar, R.string.drawer_open, R.string.drawer_close);
            toggle.syncState();
            drawer.addDrawerListener(toggle);

            OnBackStackChangedListener onBackStackChangedListener = new OnBackStackChangedListener() {
                @Override
                public void onBackStackChanged() {
                    if (getSupportFragmentManager().getBackStackEntryCount() > 0) {
                        drawer.setDrawerLockMode(DrawerLayout.LOCK_MODE_LOCKED_CLOSED);

                        if(getSupportActionBar() != null) {
                            getSupportActionBar().setDisplayHomeAsUpEnabled(true); // show back button
                        }
                        toolbar.setNavigationOnClickListener(new View.OnClickListener() {
                            @Override
                            public void onClick(View v) {
                                onBackPressed();
                            }
                        });
                    } else {
                        drawer.setDrawerLockMode(DrawerLayout.LOCK_MODE_UNLOCKED);

                        //show hamburger
                        if(getSupportActionBar() != null) {
                            getSupportActionBar().setDisplayHomeAsUpEnabled(false); // show back button
                        }
                        toggle.syncState();
                        toolbar.setNavigationOnClickListener(new View.OnClickListener() {
                            @Override
                            public void onClick(View v) {
                                drawer.openDrawer(GravityCompat.START);
                            }
                        });
                    }

                }
            };

            getSupportFragmentManager().addOnBackStackChangedListener(onBackStackChangedListener);
        }

    }

    @Override
    protected void onPostCreate(Bundle savedInstanceState) {
        super.onPostCreate(savedInstanceState);
        // Sync the toggle state after onRestoreInstanceState has occurred.
        toggle.syncState();
    }

    @Override
    public void onConfigurationChanged(Configuration newConfig) {
        super.onConfigurationChanged(newConfig);
        // Pass any configuration change to the drawer toggles
        toggle.onConfigurationChanged(newConfig);
    }

    public void selectDrawerItem(MenuItem menuItem) {
        settings.setForLogs(menuItem.getItemId() == R.id.nav_logs);
        settings.setForKeys(menuItem.getItemId() == R.id.nav_keys);
        reloadLogs();

        switch(menuItem.getItemId()) {
            case R.id.nav_keys:
                updateUIAfterNavItemSelected(new KeyFragmentListFragment(), menuItem);
                break;
            case R.id.nav_logs:
                updateUIAfterNavItemSelected(new LogsFragment(), menuItem);
                break;
            case R.id.nav_pin_code:
                updateUIAfterNavItemSelected(new SettingsPinCode(), menuItem);
                break;
            case R.id.nav_touch_id:
                updateUIAfterNavItemSelected(createSettingsFragment(SettingsFragment.Constant.FINGERPRINT_TYPE), menuItem);
                break;
            case R.id.nav_ssl:
                updateUIAfterNavItemSelected(createSettingsFragment(SettingsFragment.Constant.SSL_CONNECTION_TYPE), menuItem);
                break;
            case R.id.nav_user_guide:
                updateUIAfterNavItemSelected(null, menuItem, false);

                Uri uri = Uri.parse(SettingsFragment.Constant.USER_GUIDE_URL);
                Intent intent = new Intent(Intent.ACTION_VIEW, uri);
                startActivity(intent);
                break;
            case R.id.nav_privacy_policy:
                LicenseFragment licenseFragment = new LicenseFragment();
                licenseFragment.setForFirstLoading(false);
                updateUIAfterNavItemSelected(licenseFragment, menuItem);
                break;
            case R.id.nav_version:
                break;
        }

    }

    public void updateUIAfterNavItemSelected(Fragment fragment, MenuItem menuItem) {
        updateUIAfterNavItemSelected(fragment, menuItem, true);
    }

    public void updateUIAfterNavItemSelected(final Fragment fragment, final MenuItem menuItem, final boolean setTitle) {
        // Close the navigation drawer
        drawer.closeDrawers();

        drawerListener = new DrawerLayout.DrawerListener() {
            @Override
            public void onDrawerSlide(View drawerView, float slideOffset) {

            }

            @Override
            public void onDrawerOpened(View drawerView) {

            }

            @Override
            public void onDrawerClosed(View drawerView) {
                if(fragment != null) {
                    // Insert the fragment by replacing any existing fragment
                    fragmentManager
                            .beginTransaction()
                            .replace(R.id.main_frame_layout, fragment)
                            .addToBackStack(null)
                            .commit();
                }

                if(setTitle) {
                    // Set action bar title
                    setTitle(menuItem.getTitle());
                }

                drawer.removeDrawerListener(drawerListener);
            }

            @Override
            public void onDrawerStateChanged(int newState) {

            }
        };

        drawer.addDrawerListener(drawerListener);
    }

    Fragment createSettingsFragment(String settingsId){
        Fragment settingsFragment = new SettingsFragment();
        Bundle bundle = new Bundle();
        bundle.putString(SettingsFragment.Constant.SETTINGS_ID, settingsId);
        settingsFragment.setArguments(bundle);
        return settingsFragment;
    }
    //endregion

}
