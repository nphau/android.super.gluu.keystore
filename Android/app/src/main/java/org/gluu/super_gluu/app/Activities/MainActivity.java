package org.gluu.super_gluu.app.activities;

import android.app.NotificationManager;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.os.Bundle;
import android.support.v4.app.FragmentTransaction;
import android.support.v7.app.AppCompatActivity;
import org.gluu.super_gluu.app.fragments.LicenseFragment.LicenseFragment;
import org.gluu.super_gluu.app.fragments.LockFragment.LockFragment;
import org.gluu.super_gluu.app.fragments.PinCodeFragment.PinCodeFragment;
import org.gluu.super_gluu.app.fragments.PinCodeFragment.PinCodeSettingFragment;
import org.gluu.super_gluu.app.GluuMainActivity;
import org.gluu.super_gluu.app.KeyHandleInfoFragment;
import org.gluu.super_gluu.app.fingerprint.Fingerprint;
import org.gluu.super_gluu.app.settings.Settings;
import com.github.simonpercic.rxtime.RxTime;
import SuperGluu.app.R;
import rx.android.schedulers.AndroidSchedulers;
import rx.functions.Action1;

/**
 * Created by nazaryavornytskyy on 3/22/16.
 */
public class MainActivity extends AppCompatActivity implements LicenseFragment.OnMainActivityListener, PinCodeFragment.PinCodeViewListener {


    public static final String TIME_SERVER = "time-a.nist.gov";
    private static final String DENY_ACTION = "DENY_ACTION";
    private static final String APPROVE_ACTION = "APPROVE_ACTION";
    private Fingerprint fingerprint;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        setContentView(R.layout.activity_main);
        fingerprint = new Fingerprint(getApplicationContext());
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
        //Check is fingerprint secure enabled in settings
        Boolean isFingerprint = Settings.getFingerprintEnabled(getApplicationContext());
        if (fingerprint != null && isFingerprint && fingerprint.startFingerprintService()){
            loadGluuMainActivity();
        } else {
            if (isAppLocked) {
                loadLockedFragment(true);
            } else {
                if (Settings.getAccept(getApplicationContext())) {
                    checkPinCodeEnabled();
                } else {
                    FragmentTransaction fragmentTransaction = getSupportFragmentManager().beginTransaction();
                    LicenseFragment licenseFragment = new LicenseFragment();

                    fragmentTransaction.setTransition(FragmentTransaction.TRANSIT_FRAGMENT_OPEN);
                    fragmentTransaction.replace(R.id.fragment_container, licenseFragment);
//            fragmentTransaction.addToBackStack(null);
                    fragmentTransaction.commit();
                }
            }
        }
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
    public void onLicenseAgreement() {
        Settings.saveAccept(getApplicationContext());
        checkPinCodeEnabled();
    }

    @Override
    public void onMainActivity() {
        loadGluuMainActivity();
    }

    @Override
    public void onShowPinFragment() {
        FragmentTransaction fragmentTransaction = getSupportFragmentManager().beginTransaction();
        PinCodeFragment pinCodeFragment = new PinCodeFragment();

        fragmentTransaction.setTransition(FragmentTransaction.TRANSIT_FRAGMENT_OPEN);
        fragmentTransaction.replace(R.id.fragment_container, pinCodeFragment);
//        fragmentTransaction.addToBackStack(null);
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
        SharedPreferences preferences = getApplicationContext().getSharedPreferences("PinCodeSettings", Context.MODE_PRIVATE);
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

    public void loadGluuMainActivity() {
        SharedPreferences preferences = getApplicationContext().getSharedPreferences("PinCodeSettings", Context.MODE_PRIVATE);
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
//        fragmentTransaction.addToBackStack(null);
        fragmentTransaction.commit();

        setTitle("Pin Code");
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
    public void onNewPinCode(String pinCode) {
        Settings.savePinCode(getApplicationContext(), pinCode);
        loadGluuMainActivity();
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
            setCurrentNetworkTime();
            loadLockedFragment(false);

            setTitle("Application is locked");
            Settings.setAppLocked(getApplicationContext(), true);
        }
    }

    private void setCurrentNetworkTime() {
        // a singleton
        RxTime rxTime = new RxTime();
        rxTime.currentTime()
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(new Action1<Long>() {
                    @Override
                    public void call(Long time) {
                        // use time
                        setAppLockedTime(String.valueOf(time));
                    }
                });
    }

    private void loadLockedFragment(Boolean isRecover) {
        FragmentTransaction fragmentTransaction = getSupportFragmentManager().beginTransaction();
        LockFragment lockFragment = new LockFragment();
        OnLockAppTimerOver timeOverListener = new OnLockAppTimerOver() {
            @Override
            public void onTimerOver() {
                if (GluuApplication.isIsAppInForeground()) {
                    Settings.setAppLocked(getApplicationContext(), false);
                    loadPinCodeFragment();
                }
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
        SharedPreferences preferences = getApplicationContext().getSharedPreferences("PinCodeSettings", Context.MODE_PRIVATE);
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
//
//    @Override
//    protected void onDestroy() {1
//        super.onDestroy();
//    }

    public interface OnLockAppTimerOver {
        void onTimerOver();
    }

}
