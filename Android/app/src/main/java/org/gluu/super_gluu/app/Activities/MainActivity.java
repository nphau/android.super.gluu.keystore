package org.gluu.super_gluu.app.activities;

import android.app.NotificationManager;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.os.Bundle;
import android.support.v4.app.FragmentManager;
import android.support.v4.app.FragmentTransaction;
import android.support.v7.app.AppCompatActivity;
import android.view.View;

import org.gluu.super_gluu.app.SecureEntryFragment;
import  org.gluu.super_gluu.app.gluuToast.GluuToast;

import org.gluu.super_gluu.app.GluuMainActivity;
import org.gluu.super_gluu.app.SecureEntrySetupFragment;
import org.gluu.super_gluu.app.fingerprint.Fingerprint;
import org.gluu.super_gluu.app.fragments.KeysFragment.KeyHandleInfoFragment;
import org.gluu.super_gluu.app.fragments.LockFragment.LockFragment;
import org.gluu.super_gluu.app.fragments.PinCodeFragment.PinCodeFragment;
import org.gluu.super_gluu.app.fragments.PinCodeFragment.PinCodeSettingFragment;
import org.gluu.super_gluu.app.listener.EntrySelectedListener;
import org.gluu.super_gluu.app.listener.OnMainActivityListener;
import org.gluu.super_gluu.app.services.FingerPrintManager;
import org.gluu.super_gluu.app.settings.Settings;

import SuperGluu.app.R;

/**
 * Created by nazaryavornytskyy on 3/22/16.
 */
public class MainActivity extends AppCompatActivity implements OnMainActivityListener, PinCodeFragment.PinCodeViewListener, EntrySelectedListener {

    public static final String TIME_SERVER = "time-a.nist.gov";
    private static final String DENY_ACTION = "DENY_ACTION";
    private static final String APPROVE_ACTION = "APPROVE_ACTION";

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        setContentView(R.layout.activity_main);

        GluuApplication.isTrustAllCertificates = Settings.getSSLEnabled(this);

        // Check if we get push notification
        Intent intent = getIntent();
        Boolean isAppLocked = Settings.isAppLocked(getApplicationContext());
        //Check if user tap on Approve/Deny button or just on push body
        if (intent.getAction() != null && intent.getAction().equalsIgnoreCase(APPROVE_ACTION)){
            userChossed("approve", intent);
            return;
        } else if (intent.getAction() != null && intent.getAction().equalsIgnoreCase(DENY_ACTION)){
            userChossed("deny", intent);
            return;
        }

        Boolean isFingerprint = Settings.getFingerprintEnabled(getApplicationContext());
        if (isFingerprint){
            FingerPrintManager fingerPrintManager = new FingerPrintManager(this);
            fingerPrintManager.onFingerPrint(isSuccess -> loadGluuMainActivity());
        } else {
            if (isAppLocked) {
                loadLockedFragment(true);
            } else {
                advanceToNextScreen();
            }
        }
        Settings.setIsBackButtonVisibleForKey(getBaseContext(), false);
        Settings.setIsBackButtonVisibleForLog(getBaseContext(), false);
        Settings.setIsBackButtonVisibleForKey(getBaseContext(), false);

    }

    private void userChossed(String answer, Intent intent){
        Boolean isAppLocked = Settings.isAppLocked(getApplicationContext());
        String requestJson = intent.getStringExtra(GluuMainActivity.QR_CODE_PUSH_NOTIFICATION_MESSAGE);
        saveUserDecision(answer, requestJson);
        if (isAppLocked) {
            loadLockedFragment(true);
        } else {
            checkPinCodeEnabled();
        }
        NotificationManager nMgr = (NotificationManager) getSystemService(Context.NOTIFICATION_SERVICE);
        nMgr.cancel(GluuMainActivity.MESSAGE_NOTIFICATION_ID);
    }


    @Override
    public void onMainActivity() {
        loadGluuMainActivity();
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

    @Override
    public void onShowKeyInfo(KeyHandleInfoFragment fragment) {
//        FragmentTransaction fragmentTransaction = getSupportFragmentManager().beginTransaction();
//
//        fragmentTransaction.setTransition(FragmentTransaction.TRANSIT_FRAGMENT_OPEN);
//        fragmentTransaction.replace(R.id.fragment_container, fragment);
//        fragmentTransaction.addToBackStack(null);
//        fragmentTransaction.commit();
    }

    public void checkPinCodeEnabled() {
        SharedPreferences preferences = getApplicationContext().getSharedPreferences(Settings.PIN_CODE_SETTINGS, Context.MODE_PRIVATE);
        Boolean isDestroyed = preferences.getBoolean("isMainActivityDestroyed", false);
        if (isDestroyed) {
            loadGluuMainActivity();
        } else {
            if (Settings.getFirstLoad(getApplicationContext())) {
                Settings.saveFirstLoad(getApplicationContext());
                loadPinCodeFragment();
            } else {
                if (Settings.getPinCodeEnabled(getApplicationContext())) {
                    loadPinCodeFragment();
                } else {
                    loadGluuMainActivity();
                }
            }
        }
    }

    public void advanceToNextScreen() {
        SharedPreferences preferences = getApplicationContext().getSharedPreferences(Settings.PIN_CODE_SETTINGS, Context.MODE_PRIVATE);
        Boolean isDestroyed = preferences.getBoolean("isMainActivityDestroyed", false);
        if (isDestroyed) {
            loadGluuMainActivity();
        } else {
            if (Settings.getFirstLoad(getApplicationContext())) {
                Settings.saveFirstLoad(getApplicationContext());
                loadSecureEntrySetupFragment();
            } else {
                if (Settings.getPinCodeEnabled(getApplicationContext())) {
                    loadPinCodeFragment();
                } else {
                    loadGluuMainActivity();
                }
            }
        }
    }

    public void loadGluuMainActivity() {
        SharedPreferences preferences = getApplicationContext().getSharedPreferences(Settings.PIN_CODE_SETTINGS, Context.MODE_PRIVATE);
        SharedPreferences.Editor editor = preferences.edit();
        editor.putBoolean("isMainActivityDestroyed", false);
        editor.apply();
        Intent intent = new Intent(this, GluuMainActivity.class);
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
            loadGluuMainActivity();
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
            loadGluuMainActivity();
        } else {
            navigateToSecureEntryScreen();
        }
    }

    private void loadLockedFragment(Boolean isRecover) {
        FragmentTransaction fragmentTransaction = getSupportFragmentManager().beginTransaction();
        LockFragment lockFragment = new LockFragment();
        OnLockAppTimerOver timeOverListener = (org.gluu.super_gluu.app.activities.MainActivity.OnLockAppTimerOver) () -> {
            if (org.gluu.super_gluu.app.activities.GluuApplication.isIsAppInForeground()) {
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
    protected void onPause() {
        GluuApplication.applicationPaused();
        super.onPause();
    }

    @Override
    protected void onResume() {
        GluuApplication.applicationResumed();
        super.onResume();
    }

    @Override
    public void onPinCodeSelected() {
        loadPinCodeFragment();
    }

    @Override
    public void setupFingerprintAuthentication() {
        Fingerprint fingerprint = new Fingerprint(MainActivity.this);
            //Fingerprint Service should handle checking if fingerprint is available and messaging the user if it failed
        if(fingerprint.startFingerprintService()) {
            Settings.setFingerprintEnabled(MainActivity.this, true);
            loadGluuMainActivity();
        }
    }

    @Override
    public void startFingerprintAuthentication() {
        Boolean isFingerprint = Settings.getFingerprintEnabled(getApplicationContext());
        if (isFingerprint) {
            FingerPrintManager fingerPrintManager = new FingerPrintManager(this);
            fingerPrintManager.onFingerPrint(isSuccess -> loadGluuMainActivity());
        } else {
            showToast(getString(R.string.fingerprint_protection_off));
        }
    }

    @Override
    public void onSkipSelected() {
        loadGluuMainActivity();
    }

    public interface OnLockAppTimerOver {
        void onTimerOver();
    }

    public void showToast(String text) {
        GluuToast gluuToast = new GluuToast(MainActivity.this);
        View view = getLayoutInflater().inflate(R.layout.gluu_toast, null);
        gluuToast.showGluuToastWithText(view, text);
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
