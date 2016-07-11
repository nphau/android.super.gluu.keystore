package org.gluu.super_gluu.app.Activities;

import android.app.NotificationManager;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.os.Bundle;
import android.support.v4.app.FragmentTransaction;
import android.support.v7.app.AppCompatActivity;

import org.gluu.super_gluu.app.CustomGluuAlertView.CustomGluuAlert;
import org.gluu.super_gluu.app.Fragments.LicenseFragment.LicenseFragment;
import org.gluu.super_gluu.app.Fragments.LockFragment.LockFragment;
import org.gluu.super_gluu.app.Fragments.PinCodeFragment.PinCodeFragment;
import org.gluu.super_gluu.app.Fragments.PinCodeFragment.PinCodeSettingFragment;
import org.gluu.super_gluu.app.GluuMainActivity;
import org.gluu.super_gluu.app.KeyHandleInfoFragment;
import com.github.simonpercic.rxtime.RxTime;

import SuperGluu.app.R;
import rx.android.schedulers.AndroidSchedulers;
import rx.functions.Action1;

/**
 * Created by nazaryavornytskyy on 3/22/16.
 */
public class MainActivity extends AppCompatActivity implements LicenseFragment.OnMainActivityListener, PinCodeFragment.PinCodeViewListener {


    public static final String TIME_SERVER = "time-a.nist.gov";

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        setContentView(R.layout.activity_main);

        // Check if we get push notification
        Intent intent = getIntent();
        if (intent.hasExtra(GluuMainActivity.QR_CODE_PUSH_NOTIFICATION_MESSAGE)) {
            String requestJson = intent.getStringExtra(GluuMainActivity.QR_CODE_PUSH_NOTIFICATION_MESSAGE);
            Bundle answerBundle = intent.getExtras();
            int userAnswer = answerBundle.getInt("requestType");
            if (userAnswer == 0 ){//deny action
                saveUserDecision("deny", requestJson);
            } else if (userAnswer == 1 ){//approve action
                saveUserDecision("approve", requestJson);
            }
            if (isAppLocked()){
                loadLockedFragment(true);
            } else {
                checkPinCodeEnabled();
            }
            NotificationManager nMgr = (NotificationManager) getSystemService(Context.NOTIFICATION_SERVICE);
            nMgr.cancel(GluuMainActivity.MESSAGE_NOTIFICATION_ID);
        }

        if (isAppLocked()){
            loadLockedFragment(true);
        } else {
            if (getAccept()) {
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

    @Override
    public void onLicenseAgreement() {
        saveAccept();
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

    public void checkPinCodeEnabled(){
        SharedPreferences preferences = getApplicationContext().getSharedPreferences("PinCodeSettings", Context.MODE_PRIVATE);
        Boolean isDestroyed = preferences.getBoolean("isMainActivityDestroyed", false);
        if (isDestroyed){
            loadGluuMainActivity();
        } else {
            if (getFirstLoad()) {
                saveFirstLoad();
                loadPinCodeFragment();
            } else {
                if (getPincodeEnabled()) {
                    loadPinCodeFragment();
                } else {
                    loadGluuMainActivity();
                }
            }
        }
    }

    public void loadGluuMainActivity(){
        SharedPreferences preferences = getApplicationContext().getSharedPreferences("PinCodeSettings", Context.MODE_PRIVATE);
        SharedPreferences.Editor editor = preferences.edit();
        editor.putBoolean("isMainActivityDestroyed", false);
        editor.commit();
        Intent intent = new Intent(this, GluuMainActivity.class);
        intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK | Intent.FLAG_ACTIVITY_TASK_ON_HOME);
        startActivity(intent);
        this.finish();
    }

    public void loadPinCodeFragment(){
        FragmentTransaction fragmentTransaction = getSupportFragmentManager().beginTransaction();
        PinCodeSettingFragment pinCodeFragmentSetting = new PinCodeSettingFragment();

        fragmentTransaction.setTransition(FragmentTransaction.TRANSIT_FRAGMENT_OPEN);
        fragmentTransaction.replace(R.id.fragment_container, pinCodeFragmentSetting);
//        fragmentTransaction.addToBackStack(null);
        fragmentTransaction.commit();

        setTitle("Pin Code");
    }

    public void saveAccept(){
        SharedPreferences preferences = getApplicationContext().getSharedPreferences("IsAcceptLicense", Context.MODE_PRIVATE);
        SharedPreferences.Editor editor = preferences.edit();
        editor.putBoolean("isAccept", true);
        editor.commit();
    }

    public Boolean getAccept(){
        SharedPreferences preferences = getApplicationContext().getSharedPreferences("IsAcceptLicense", Context.MODE_PRIVATE);
        Boolean isAccept = preferences.getBoolean("isAccept", false);
        return isAccept;
    }

    public Boolean getPincodeEnabled(){
        SharedPreferences preferences = getApplicationContext().getSharedPreferences("PinCodeSettings", Context.MODE_PRIVATE);
        Boolean isPinEnabled = preferences.getBoolean("isPinEnabled", false);
        return isPinEnabled;
    }

    public Boolean getFirstLoad(){
        SharedPreferences preferences = getApplicationContext().getSharedPreferences("PinCodeSettings", Context.MODE_PRIVATE);
        Boolean isFirstLoad = preferences.getBoolean("isFirstLoad", false);
        return !isFirstLoad;
    }

    public void saveFirstLoad(){
        SharedPreferences preferences = getApplicationContext().getSharedPreferences("PinCodeSettings", Context.MODE_PRIVATE);
        SharedPreferences.Editor editor = preferences.edit();
        editor.putBoolean("isFirstLoad", true);
        editor.commit();
    }

    public void savePinCode(String newPinCode){
        SharedPreferences preferences = getApplicationContext().getSharedPreferences("PinCodeSettings", Context.MODE_PRIVATE);
        SharedPreferences.Editor editor = preferences.edit();
        editor.putString("PinCode", newPinCode);
        editor.commit();
    }

    public void saveUserDecision(String userChoose, String oxRequest){
        SharedPreferences preferences = getApplicationContext().getSharedPreferences("oxPushSettings", Context.MODE_PRIVATE);
        SharedPreferences.Editor editor = preferences.edit();
        editor.putString("userChoose", userChoose);
        editor.putString("oxRequest", oxRequest);
        editor.commit();
        setPushData("");
    }

    public void setPushData(String message){
        SharedPreferences preferences = getApplicationContext().getSharedPreferences("PushNotification", Context.MODE_PRIVATE);
        SharedPreferences.Editor editor = preferences.edit();
        editor.putString("PushData", message);
        editor.commit();
    }

    @Override
    public void onNewPinCode(String pinCode) {
        savePinCode(pinCode);
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
            setAppLocked(true);
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

    private void loadLockedFragment(Boolean isRecover){
        FragmentTransaction fragmentTransaction = getSupportFragmentManager().beginTransaction();
        LockFragment lockFragment = new LockFragment();
        OnLockAppTimerOver timeOverListener = new OnLockAppTimerOver() {
            @Override
            public void onTimerOver() {
                if (GluuApplication.isIsAppInForeground()) {
                    setAppLocked(false);
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

    private void setAppLocked(Boolean isLocked){
        SharedPreferences preferences = getApplicationContext().getSharedPreferences("PinCodeSettings", Context.MODE_PRIVATE);
        SharedPreferences.Editor editor = preferences.edit();
        editor.putBoolean("isAppLocked", isLocked);
        editor.commit();
    }

    private Boolean isAppLocked(){
        SharedPreferences preferences = getApplicationContext().getSharedPreferences("PinCodeSettings", Context.MODE_PRIVATE);
        return preferences.getBoolean("isAppLocked", false);
    }

    private void setAppLockedTime(String lockedTime){
        SharedPreferences preferences = getApplicationContext().getSharedPreferences("PinCodeSettings", Context.MODE_PRIVATE);
        SharedPreferences.Editor editor = preferences.edit();
        editor.putString("appLockedTime", lockedTime);
        editor.commit();
    }

    private void showAlertView(String message){
        CustomGluuAlert gluuAlert = new CustomGluuAlert(this);
        gluuAlert.setMessage(message);
        gluuAlert.show();
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

    public interface OnLockAppTimerOver{
        void onTimerOver();
    }

}
