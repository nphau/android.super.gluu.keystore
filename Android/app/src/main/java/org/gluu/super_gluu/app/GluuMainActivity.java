/*
 *  oxPush2 is available under the MIT License (2008). See http://opensource.org/licenses/MIT for full text.
 *
 *  Copyright (c) 2014, Gluu
 */

package org.gluu.super_gluu.app;

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
import android.graphics.drawable.Drawable;
import android.media.Ringtone;
import android.media.RingtoneManager;
import android.net.Uri;
import android.os.Bundle;
import android.os.Vibrator;
import android.support.design.widget.NavigationView;
import android.support.v4.app.ActivityCompat;
import android.support.v4.app.Fragment;
import android.support.v4.app.FragmentManager;
import android.support.v4.app.FragmentTransaction;
import android.support.v4.content.ContextCompat;
import android.support.v4.content.LocalBroadcastManager;
import android.support.v4.view.GravityCompat;
import android.support.v4.widget.DrawerLayout;
import android.support.v7.app.ActionBarDrawerToggle;
import android.support.v7.app.AppCompatActivity;
import android.support.v7.widget.Toolbar;
import android.util.Log;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.view.ViewGroup;
import android.view.inputmethod.InputMethodManager;
import android.widget.Button;
import android.widget.Toast;

import com.google.android.gms.ads.AdRequest;
import com.google.android.gms.ads.AdView;
import com.google.android.gms.ads.MobileAds;
import com.google.gson.Gson;

import org.gluu.super_gluu.app.activities.GluuApplication;
import org.gluu.super_gluu.app.activities.MainActivity;
import org.gluu.super_gluu.app.customGluuAlertView.CustomGluuAlert;
import org.gluu.super_gluu.app.fragments.KeysFragment.KeyHandleInfoFragment;
import org.gluu.super_gluu.app.fragments.LicenseFragment.LicenseFragment;
import org.gluu.super_gluu.app.fragments.PinCodeFragment.PinCodeFragment;
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


    private SoftwareDevice u2f;
    private AndroidKeyDataStore dataStore;
    private static Context context;

    private Boolean isOXRequestProtected = false;
    private OxPush2Request oxPush2RequestProtected;

    FragmentManager fragmentManager;


    private Settings settings = new Settings();

    private BroadcastReceiver mPushMessageReceiver = new BroadcastReceiver() {
        @Override
        public void onReceive(Context context, Intent intent) {
            //Pop backstack to get back to home screen
            if(fragmentManager.getBackStackEntryCount() > 0) {
                fragmentManager.popBackStack();
            }

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

        // Find our drawer view
        drawer = (DrawerLayout) findViewById(R.id.drawer_layout);

        NavigationView navigationView = (NavigationView) findViewById(R.id.nvView);
        if (navigationView != null) {
            navigationView.setItemIconTintList(null);
        }
        setupDrawerContent(navigationView);

        if (toolbar != null) {
            toggle = new ActionBarDrawerToggle(
                    this, drawer, toolbar, R.string.drawer_open, R.string.drawer_close);
            toggle.syncState();
            drawer.addDrawerListener(toggle);
            getSupportFragmentManager().addOnBackStackChangedListener(new FragmentManager.OnBackStackChangedListener() {
                @Override
                public void onBackStackChanged() {
                    if (getSupportFragmentManager().getBackStackEntryCount() > 0) {
                        drawer.setDrawerLockMode(DrawerLayout.LOCK_MODE_LOCKED_CLOSED);
                        getSupportActionBar().setDisplayHomeAsUpEnabled(true); // show back button
                        toolbar.setNavigationOnClickListener(new View.OnClickListener() {
                            @Override
                            public void onClick(View v) {
                                setTitle(getString(R.string.home));
                                onBackPressed();
                            }
                        });
                    } else {
                        drawer.setDrawerLockMode(DrawerLayout.LOCK_MODE_UNLOCKED);
                        //show hamburger
                        getSupportActionBar().setDisplayHomeAsUpEnabled(false);
                        toggle.syncState();
                        toolbar.setNavigationOnClickListener(new View.OnClickListener() {
                            @Override
                            public void onClick(View v) {
                                drawer.openDrawer(GravityCompat.START);
                            }
                        });
                    }
                }
            });
        }
    }

    @Override
    public void onBackPressed() {
        if(fragmentManager.getBackStackEntryCount() > 0) {
            setTitle(getString(R.string.home));
        }

        super.onBackPressed();
    }

    private void initGoogleADS(Boolean isShow){
        AdView mAdView = (AdView) findViewById(R.id.adView);
        if (!isShow) {
            MobileAds.initialize(getApplicationContext(), "ca-app-pub-3932761366188106~2301594871");
            AdRequest adRequest = new AdRequest.Builder().build();
            mAdView.loadAd(adRequest);
        } else {
            ViewGroup.LayoutParams params = mAdView.getLayoutParams();
            params.height = 0;
            mAdView.setLayoutParams(params);
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

    private void initMainTabView(){
////        Toolbar toolbar = (Toolbar) findViewById(R.id.toolbar);
////        setSupportActionBar(toolbar);
//
//        tabLayout = (TabLayout) findViewById(R.id.tab_layout);
//        tabLayout.addTab(tabLayout.newTab().setText("Home").setIcon(R.drawable.home_action));
//        tabLayout.addTab(tabLayout.newTab().setText("Logs").setIcon(R.drawable.logs_action));
//        tabLayout.addTab(tabLayout.newTab().setText("Keys").setIcon(R.drawable.keys_action));
//        tabLayout.addTab(tabLayout.newTab().setText("Menu").setIcon(R.drawable.settings_action));
//        tabLayout.setTabGravity(TabLayout.GRAVITY_FILL);
//
//        // Locate the viewpager in gluu_activity_main.xmln.xml
//        final GluuPagerView viewPager = (GluuPagerView) findViewById(R.id.pager);
//        viewPager.setSwipeLocked(true);
//
//        // Set the ViewPagerAdapter into ViewPager
//        viewPager.setAdapter(new ViewPagerAdapter(getSupportFragmentManager()));//, tabLayout.getTabCount()
//        viewPager.addOnPageChangeListener(new TabLayout.TabLayoutOnPageChangeListener(tabLayout));
//        final int tabIconColor = ContextCompat.getColor(context, R.color.greenColor);
//        final int tabIconColorBlack = ContextCompat.getColor(context, R.color.blackColor);
//        tabLayout.getTabAt(0).getIcon().setColorFilter(tabIconColor, PorterDuff.Mode.SRC_IN);
//        tabLayout.getTabAt(1).getIcon().setColorFilter(tabIconColorBlack, PorterDuff.Mode.SRC_IN);
//        tabLayout.getTabAt(2).getIcon().setColorFilter(tabIconColorBlack, PorterDuff.Mode.SRC_IN);
//        tabLayout.getTabAt(3).getIcon().setColorFilter(tabIconColorBlack, PorterDuff.Mode.SRC_IN);
//        tabLayout.setOnTabSelectedListener(new TabLayout.OnTabSelectedListener() {
//            @Override
//            public void onTabSelected(TabLayout.Tab tab) {
//                int position = tab.getPosition();
////                isShowMenu = position == 3 ? true : false;
//                settings.setForLogs(position == 1 ? true : false);
//                settings.setForKeys(position == 2 ? true : false);
//                reloadLogs();
//                viewPager.setCurrentItem(position);
//                tab.getIcon().setColorFilter(tabIconColor, PorterDuff.Mode.SRC_IN);
//            }
//
//            @Override
//            public void onTabUnselected(TabLayout.Tab tab) {
//                tab.getIcon().setColorFilter(tabIconColorBlack, PorterDuff.Mode.SRC_IN);
//            }
//
//            @Override
//            public void onTabReselected(TabLayout.Tab tab) {
//
//            }
//        });
    }

    @Override
    protected void onNewIntent(Intent intent) {
        super.onNewIntent(intent);
    }

    @Override
    public void onSaveInstanceState( Bundle outState ) {
        //skip it at all
    }

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        //Customize the ActionBar
        return true;
    }

    private void setBackArrowForButton(Button button){
        Drawable img = ContextCompat.getDrawable(this, R.drawable.back_arrow);
        img.setBounds( 0, 0, 26, 26 );
        button.setCompoundDrawables(img, null, null,null);
    }

    private void reloadLogs(){
        Intent intent = new Intent("reload-logs");
        LocalBroadcastManager.getInstance(this).sendBroadcast(intent);
//        Settings.setIsButtonVisible(context, dataStore.getLogs().size() != 0);
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
        Settings.setPushDataEmpty(getApplicationContext());
        NotificationManager nMgr = (NotificationManager) getSystemService(Context.NOTIFICATION_SERVICE);
        nMgr.cancel(GluuMainActivity.MESSAGE_NOTIFICATION_ID);
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
        //To hide tabs
        //tabLayout.getLayoutParams().height = 0;
    }

    @Override
    public void onQrRequest(final OxPush2Request oxPush2Request) {
        if (!this.isDestroyed()) {

            toolbar.setVisibility(View.GONE);

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
                //Init GoogleMobile AD
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
                //Init GoogleMobile AD
                initGoogleADS(true);
            }
        }
    }

    public void loadPinCodeFragment() {
        PinCodeFragment pinCodeFragment = new PinCodeFragment();
        pinCodeFragment.setIsSettings(false);
        pinCodeFragment.setIsSetNewPinCode(false);

        fragmentManager.beginTransaction().replace(R.id.main_frame_layout, pinCodeFragment).addToBackStack(null).commit();

        //To hide tabs
        //tabLayout.getLayoutParams().height = 0;
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

            @Override
            public void onAdFreeButtonClick(){}

            @Override
            public void onPurchaseRestored() {}
        });

        return processManager;
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
                result = isCredManager ? isCredManager : false;
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
                ((InputMethodManager) this.getSystemService(Activity.INPUT_METHOD_SERVICE))
                        .toggleSoftInput(InputMethodManager.SHOW_IMPLICIT, 0);
                this.onBackPressed();
                doQrRequest(oxPush2RequestProtected);
                isOXRequestProtected = false;
            } else {
                showAlertView("New Pin Added!");
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
//        onBackButtonClicked();
        settings.setEditingModeLogs(false);
        reloadLogs();
//        Intent intent = new Intent("editing-mode-logs");
//        intent.putExtra("isEditingMode", false);
//        LocalBroadcastManager.getInstance(getApplicationContext()).sendBroadcast(intent);
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
        // BEGIN_INCLUDE(camera_permission)
        // Check if the Camera permission is already available.
        if (ActivityCompat.checkSelfPermission(this, android.Manifest.permission.CAMERA)
                != PackageManager.PERMISSION_GRANTED) {
            // Camera permission has not been granted.

            requestCameraPermission();

        } else {

            // Camera permissions is already available, show the camera preview.
            Log.i(TAG,
                    "CAMERA permission has already been granted. Displaying camera preview.");
//            showCameraPreview();
        }
        // END_INCLUDE(camera_permission)
    }

    private void requestCameraPermission() {
        Log.i(TAG, "CAMERA permission has NOT been granted. Requesting permission.");

        // BEGIN_INCLUDE(camera_permission_request)
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
        // END_INCLUDE(camera_permission_request)
    }

    //region drawer specific code
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

        org.gluu.super_gluu.app.fragments.PageRootFragment rootFragment = new org.gluu.super_gluu.app.fragments.PageRootFragment();

        switch(menuItem.getItemId()) {
            case R.id.nav_keys:
                closeDrawerAfterItemSelected(new org.gluu.super_gluu.app.fragments.KeysFragment.KeyFragmentListFragment(), menuItem);
                break;
            case R.id.nav_logs:
                closeDrawerAfterItemSelected(new org.gluu.super_gluu.app.fragments.LogsFragment.LogsFragment(), menuItem);
                break;
            case R.id.nav_pin_code:
                closeDrawerAfterItemSelected(new org.gluu.super_gluu.app.fragments.SettingsFragment.SettingsPinCode(), menuItem);
                break;
            case R.id.nav_touch_id:
                closeDrawerAfterItemSelected(createSettingsFragment("FingerprintSettings"), menuItem);
                break;
            case R.id.nav_ssl:
                closeDrawerAfterItemSelected(createSettingsFragment("SSLConnectionSettings"), menuItem);
                break;
            case R.id.nav_user_guide:
                closeDrawerAfterItemSelected(null, menuItem, false);
                Uri uri = Uri.parse("https://gluu.org/docs/supergluu/3.0.0/user-guide/");
                Intent intent = new Intent(Intent.ACTION_VIEW, uri);
                startActivity(intent);
                break;
            case R.id.nav_privacy_policy:
                LicenseFragment licenseFragment = new LicenseFragment();
                licenseFragment.setForFirstLoading(false);
                closeDrawerAfterItemSelected(licenseFragment, menuItem);
                break;
            case R.id.nav_version:
                break;
            default:
                closeDrawerAfterItemSelected(rootFragment.newInstance(FragmentType.FRAGMENT_TYPE.MAIN_FRAGMENT), menuItem);
        }

    }

    public void closeDrawerAfterItemSelected(Fragment fragment, MenuItem menuItem) {
        closeDrawerAfterItemSelected(fragment, menuItem, true);
    }

    public void closeDrawerAfterItemSelected(Fragment fragment, MenuItem menuItem, boolean setTitle) {
        if(fragment != null) {
            // Insert the fragment by replacing any existing fragment
            fragmentManager.beginTransaction().replace(R.id.main_frame_layout, fragment).addToBackStack(null).commit();
        }

        if(setTitle) {
            // Set action bar title
            setTitle(menuItem.getTitle());
        }
        // Close the navigation drawer
        drawer.closeDrawers();
    }

    Fragment createSettingsFragment(String settingsId){
        Fragment sslFragment = new org.gluu.super_gluu.app.fragments.SettingsFragment.SettingsFragment();
        Bundle bundle = new Bundle();
        bundle.putString("settingsId", settingsId);
        sslFragment.setArguments(bundle);
        return sslFragment;
    }

    public void sendFakeBroadcast() {
        String message = "{\"app\":\"https://cred3.gluu.org/cred-manager\",\"method\":\"authenticate\",\"req_ip\":\"38.142.29.4\",\"created\":\"2018-03-14T19:41:29.094000\",\"issuer\":\"https://cred3.gluu.org\",\"req_loc\":\"United%20States%2C%20Texas%2C%20Houston\",\"state\":\"00f14ff3-e153-4f1f-a4c4-4587241b3b4d\",\"username\":\"eric3\"}\n";

        Intent intent = new Intent(QR_CODE_PUSH_NOTIFICATION);
        intent.putExtra(QR_CODE_PUSH_NOTIFICATION_MESSAGE, message);
        LocalBroadcastManager.getInstance(this).sendBroadcast(intent);
    }

    public OxPush2Request getFakeOXRequest() {
        OxPush2Request oxPush2Request =
                new OxPush2Request("eric3",
                        "https://cred3.gluu.org", "https://cred3.gluu.org/cred-manager", "00f14ff3-e153-4f1f-a4c4-4587241b3b4d", "authenticate", "2018-03-14T19:41:29.094000", null);
        oxPush2Request.setLocationCity("United%20States%2C%20Texas%2C%20Houston");
        oxPush2Request.setLocationIP("38.142.29.4");
        return oxPush2Request;
    }
    //endregion

}
