package org.gluu.super_gluu.app.activities;

import android.app.NotificationManager;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.os.Bundle;
import android.support.v4.app.FragmentManager;
import android.support.v4.app.FragmentTransaction;
import android.view.View;

import org.gluu.super_gluu.app.GluuApplication;
import org.gluu.super_gluu.app.customview.CustomToast;
import org.gluu.super_gluu.app.fingerprint.Fingerprint;
import org.gluu.super_gluu.app.fragment.LockFragment;
import org.gluu.super_gluu.app.fragment.PinCodeFragment;
import org.gluu.super_gluu.app.fragment.PinCodeSettingFragment;
import org.gluu.super_gluu.app.fragment.SecureEntryFragment;
import org.gluu.super_gluu.app.fragment.SecureEntrySetupFragment;
import org.gluu.super_gluu.app.listener.EntryActivityListener;
import org.gluu.super_gluu.app.listener.EntrySelectedListener;
import org.gluu.super_gluu.app.services.AppFirebaseMessagingService;
import org.gluu.super_gluu.app.services.FingerPrintManager;
import org.gluu.super_gluu.app.settings.Settings;

import SuperGluu.app.R;

/**
 * Created by nazaryavornytskyy on 3/22/16.
 */
public class EntryActivity extends BaseActivity implements
        EntryActivityListener, PinCodeFragment.PinCodeViewListener, EntrySelectedListener {

    public static final String TIME_SERVER = "time-a.nist.gov";

    public static String APPROVE_PUSH = "approve";
    public static String DENY_PUSH = "deny";
    public static String NO_ACTION_PUSH = "no action";

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        setContentView(R.layout.activity_main);

        GluuApplication.isTrustAllCertificates = Settings.getSSLEnabled(this);

        // Check if we get push notification
        Intent intent = getIntent();
        Boolean isAppLocked = Settings.isAppLocked(getApplicationContext());
        //Check if user tap on Approve/Deny button or just on push body

        if(intent.getAction() != null) {
            if (intent.getAction().equalsIgnoreCase(AppFirebaseMessagingService.APPROVE_ACTION)) {
                userComingFromPush(APPROVE_PUSH, intent);
                return;
            } else if (intent.getAction().equalsIgnoreCase(AppFirebaseMessagingService.DENY_ACTION)) {
                userComingFromPush(DENY_PUSH, intent);
                return;
            } else if (intent.getAction().equalsIgnoreCase(AppFirebaseMessagingService.PUSH_NO_ACTION)) {
                userComingFromPush(NO_ACTION_PUSH, intent);
                return;
            }
        }

        if(isAppLocked) {
            loadLockedFragment(true);
        } else {
            advanceToNextScreen();
        }

        Settings.setIsBackButtonVisibleForKey(getBaseContext(), false);
        Settings.setIsBackButtonVisibleForLog(getBaseContext(), false);
        Settings.setIsBackButtonVisibleForKey(getBaseContext(), false);

    }

    @Override
    protected void onResume() {
        super.onResume();
        GluuApplication.setWentThroughLauncherActivity(true);
    }

    private void userComingFromPush(String answer, Intent intent){
        Boolean isAppLocked = Settings.isAppLocked(getApplicationContext());
        String requestJson = intent.getStringExtra(MainNavDrawerActivity.QR_CODE_PUSH_NOTIFICATION_MESSAGE);
        saveUserDecision(answer, requestJson);
        if (isAppLocked) {
            loadLockedFragment(true);
        } else {
            checkPinCodeEnabled();
        }
        NotificationManager nMgr = (NotificationManager) getSystemService(Context.NOTIFICATION_SERVICE);
        nMgr.cancel(MainNavDrawerActivity.MESSAGE_NOTIFICATION_ID);
    }


    @Override
    public void onNavigateToMainNavDrawerActivity() {
        loadNavDrawerActivity();
    }

    @Override
    public void onShowPinFragment(boolean enterPinCode) {
        FragmentTransaction fragmentTransaction = getSupportFragmentManager().beginTransaction();

        PinCodeFragment.EntryType entryType = enterPinCode ? PinCodeFragment.EntryType.ENTERING_NORMAL : PinCodeFragment.EntryType.SETTING_NEW;

        PinCodeFragment pinCodeFragment = PinCodeFragment.newInstance(entryType);

        fragmentTransaction.setTransition(FragmentTransaction.TRANSIT_FRAGMENT_OPEN);
        fragmentTransaction.replace(R.id.fragment_container, pinCodeFragment);
        fragmentTransaction.commit();
    }

    public void checkPinCodeEnabled() {
        if (Settings.getFirstLoad(getApplicationContext())) {
            Settings.saveFirstLoad(getApplicationContext());
            loadPinCodeFragment();
        } else {
            if (Settings.getPinCodeEnabled(getApplicationContext())) {
                loadPinCodeFragment();
            } else {
                loadNavDrawerActivity();
            }
        }
    }

    public void advanceToNextScreen() {
        if (Settings.getFirstLoad(getApplicationContext())) {
            Settings.saveFirstLoad(getApplicationContext());
            loadSecureEntrySetupFragment();
        } else {
            Boolean isFingerprint = Settings.getFingerprintEnabled(getApplicationContext());
            if (isFingerprint){
                FingerPrintManager fingerPrintManager = new FingerPrintManager(this);
                fingerPrintManager.onFingerPrint(isSuccess -> {
                    if(isSuccess) {
                        loadNavDrawerActivity();
                    } else {
                        navigateToSecureEntryScreen();
                    }
                });
            } else if (Settings.getPinCodeEnabled(getApplicationContext())) {
                loadPinCodeFragment();
            } else {
                loadNavDrawerActivity();
            }
        }
    }

    public void loadNavDrawerActivity() {
        Intent intent = new Intent(this, MainNavDrawerActivity.class);
        intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK | Intent.FLAG_ACTIVITY_TASK_ON_HOME);
        startActivity(intent);
        this.finish();
    }

    public void loadPinCodeFragment() {
        FragmentTransaction fragmentTransaction = getSupportFragmentManager().beginTransaction();
        PinCodeSettingFragment pinCodeFragmentSetting = new PinCodeSettingFragment();

        fragmentTransaction.setTransition(FragmentTransaction.TRANSIT_FRAGMENT_OPEN);
        fragmentTransaction.replace(R.id.fragment_container, pinCodeFragmentSetting);
        fragmentTransaction.commit();

        setTitle(getString(R.string.pin_code));
    }

    public void loadSecureEntrySetupFragment() {
        FragmentTransaction fragmentTransaction = getSupportFragmentManager().beginTransaction();
        SecureEntrySetupFragment secureEntrySetupFragment = new SecureEntrySetupFragment();

        fragmentTransaction.setTransition(FragmentTransaction.TRANSIT_FRAGMENT_OPEN);
        fragmentTransaction.replace(R.id.fragment_container, secureEntrySetupFragment);
        fragmentTransaction.commit();
    }

    public void saveUserDecision(String userChoose, String oxRequest) {
        SharedPreferences preferences = getApplicationContext().getSharedPreferences("oxPushSettings", Context.MODE_PRIVATE);
        SharedPreferences.Editor editor = preferences.edit();
        editor.putString("userChoose", userChoose);
        editor.putString("oxRequest", oxRequest);
        editor.apply();
        Settings.setPushData(getApplicationContext(), null);
    }

    @Override
    public void onCorrectPinCode(boolean isPinCodeCorrect) {
        if (isPinCodeCorrect) {
            /**
             * entered pin code is correct. DO something here.
             * */
            loadNavDrawerActivity();
        } else {
            /**
             * entered pin code is INCORRECT. DO something here.
             * */
            loadLockedFragment(false);

            setTitle("Application is locked");
            Settings.setAppLocked(getApplicationContext(), true);
        }
    }

    @Override
    public void onCancel(PinCodeFragment.EntryType entryType) {
        if(entryType == PinCodeFragment.EntryType.SETTING_NEW) {
            loadNavDrawerActivity();
        } else {
            navigateToSecureEntryScreen();
        }
    }

    private void loadLockedFragment(Boolean isRecover) {
        FragmentTransaction fragmentTransaction = getSupportFragmentManager().beginTransaction();
        LockFragment lockFragment = new LockFragment();
        OnLockAppTimerOver timeOverListener = (EntryActivity.OnLockAppTimerOver) () -> {
            if (GluuApplication.isIsAppInForeground()) {
                Settings.setAppLocked(getApplicationContext(), false);
                loadPinCodeFragment();
            }
        };
        lockFragment.setIsRecover(isRecover);
        lockFragment.setListener(timeOverListener);
        fragmentTransaction.setTransition(FragmentTransaction.TRANSIT_FRAGMENT_OPEN);
        fragmentTransaction.replace(R.id.fragment_container, lockFragment);
//            fragmentTransaction.addToBackStack(null);
        fragmentTransaction.commit();
    }

    private void setAppLockedTime(String lockedTime) {
        SharedPreferences preferences = getApplicationContext().getSharedPreferences(Settings.PIN_CODE_SETTINGS, Context.MODE_PRIVATE);
        SharedPreferences.Editor editor = preferences.edit();
        editor.putString("appLockedTime", lockedTime);
        editor.commit();
    }

    @Override
    public void onPinCodeSelected() {
        loadPinCodeFragment();
    }

    @Override
    public void setupFingerprintAuthentication() {
        Fingerprint fingerprint = new Fingerprint(EntryActivity.this);
        //Fingerprint Service should handle checking if fingerprint is available and messaging the user if it failed
        if(fingerprint.startFingerprintService()) {
            Settings.setFingerprintEnabled(EntryActivity.this, true);
            loadNavDrawerActivity();
        }
    }

    @Override
    public void startFingerprintAuthentication() {
        Boolean isFingerprint = Settings.getFingerprintEnabled(getApplicationContext());
        if (isFingerprint) {
            FingerPrintManager fingerPrintManager = new FingerPrintManager(this);
            fingerPrintManager.onFingerPrint(isSuccess -> loadNavDrawerActivity());
        } else {
            showToast(getString(R.string.fingerprint_protection_off));
        }
    }

    @Override
    public void onSkipSelected() {
        loadNavDrawerActivity();
    }

    public interface OnLockAppTimerOver {
        void onTimerOver();
    }

    public void showToast(String text) {
        CustomToast customToast = new CustomToast(EntryActivity.this);
        View view = getLayoutInflater().inflate(R.layout.custom_toast, null);
        customToast.showGluuToastWithText(view, text);
    }

    public void navigateToSecureEntryScreen() {
        boolean showPinCode = Settings.getPinCodeEnabled(getBaseContext());
        boolean showFingerprint = Settings.getFingerprintEnabled(getBaseContext());

        FragmentManager fragmentManager = getSupportFragmentManager();
        SecureEntryFragment secureEntryFragment = SecureEntryFragment.newInstance(showPinCode, showFingerprint);
        fragmentManager
                .beginTransaction()
                .setTransition(FragmentTransaction.TRANSIT_FRAGMENT_FADE)
                .replace(R.id.fragment_container, secureEntryFragment)
                .commit();
    }

}
