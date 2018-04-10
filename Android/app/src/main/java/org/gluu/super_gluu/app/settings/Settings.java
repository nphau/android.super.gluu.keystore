package org.gluu.super_gluu.app.settings;

import android.content.Context;
import android.content.SharedPreferences;

import org.gluu.super_gluu.app.fragment.SettingsFragment;

/**
 * Created by nazaryavornytskyy on 7/12/16.
 */
public class Settings {

    public static final String PIN_CODE_SETTINGS = "PinCodeSettings";

    private Boolean isEditingModeLogs = false;
    private Boolean isForLogs = false;
    private Boolean isForKeys = false;


    public static boolean isAuthEnabled(Context context) {
        return getFingerprintEnabled(context) || getPinCodeEnabled(context);
    }

    //Pin code Settings
    public static void setPinCodeEnabled(Context context, Boolean isEnabled) {
        SharedPreferences preferences = context.getSharedPreferences(PIN_CODE_SETTINGS, Context.MODE_PRIVATE);
        SharedPreferences.Editor editor = preferences.edit();
        editor.putBoolean(Constant.IS_PIN_ENABLED, isEnabled);
        editor.commit();
    }

    public static Boolean getPinCodeEnabled(Context context){
        SharedPreferences preferences = context.getSharedPreferences(PIN_CODE_SETTINGS, Context.MODE_PRIVATE);
        Boolean isPinEnabled = preferences.getBoolean(Constant.IS_PIN_ENABLED, false);
        return isPinEnabled;
    }

    public static String getPinCode(Context context){
        SharedPreferences preferences = context.getSharedPreferences(PIN_CODE_SETTINGS, Context.MODE_PRIVATE);
        String pinCode = preferences.getString(Constant.PIN_CODE, null);
        return pinCode;
    }

    public static void savePinCode(Context context, String password){
        SharedPreferences preferences = context.getSharedPreferences(PIN_CODE_SETTINGS, Context.MODE_PRIVATE);
        SharedPreferences.Editor editor = preferences.edit();
        editor.putString(Constant.PIN_CODE, password);
        editor.commit();
    }

    public static void clearPinCode(Context context){
        SharedPreferences preferences = context.getSharedPreferences(PIN_CODE_SETTINGS, Context.MODE_PRIVATE);
        SharedPreferences.Editor editor = preferences.edit();
        editor.putString(Constant.PIN_CODE, null);
        editor.commit();
    }

    public static void setPinCodeAttempts(Context context, String attempts){
        SharedPreferences preferences = context.getSharedPreferences(PIN_CODE_SETTINGS, Context.MODE_PRIVATE);
        SharedPreferences.Editor editor = preferences.edit();
        editor.putString(Constant.PIN_CODE_ATTEMPTS, attempts);
        editor.commit();
    }

    public static int getPinCodeAttempts(Context context){
        if (context != null) {
            SharedPreferences preferences = context.getSharedPreferences(PIN_CODE_SETTINGS, Context.MODE_PRIVATE);
            String pinCode = preferences.getString(Constant.PIN_CODE_ATTEMPTS, "5");
            return Integer.parseInt(pinCode);
        }
        return 5;
    }

    public static int getCurrentPinCodeAttempts(Context context){
        SharedPreferences preferences = context.getSharedPreferences(PIN_CODE_SETTINGS, Context.MODE_PRIVATE);
        String pinCode = preferences.getString(Constant.CURRENT_PIN_CODE_ATTEMPTS, String.valueOf(Settings.getPinCodeAttempts(context)));
        return Integer.parseInt(pinCode);
    }

    public static void setCurrentPinCodeAttempts(Context context, int attempts){
        SharedPreferences preferences = context.getSharedPreferences(PIN_CODE_SETTINGS, Context.MODE_PRIVATE);
        SharedPreferences.Editor editor = preferences.edit();
        editor.putString(Constant.CURRENT_PIN_CODE_ATTEMPTS, String.valueOf(attempts));
        editor.commit();
    }


    public static void resetCurrentPinAttempts(Context context){
        Settings.saveIsReset(context);
        SharedPreferences preferences = context.getSharedPreferences(PIN_CODE_SETTINGS, Context.MODE_PRIVATE);
        SharedPreferences.Editor editor = preferences.edit();
        editor.putString(Constant.CURRENT_PIN_CODE_ATTEMPTS, String.valueOf(getPinCodeAttempts(context)));
        editor.commit();
    }

    public static void saveIsReset(Context context){
        if (context != null) {
            SharedPreferences preferences = context.getSharedPreferences(PIN_CODE_SETTINGS, Context.MODE_PRIVATE);
            SharedPreferences.Editor editor = preferences.edit();
            editor.putBoolean("isReset", true);
            editor.commit();
        }
    }

    public static void setAppLockedTime(Context context, String lockedTime){
        SharedPreferences preferences = context.getSharedPreferences(PIN_CODE_SETTINGS, Context.MODE_PRIVATE);
        SharedPreferences.Editor editor = preferences.edit();
        editor.putString("appLockedTime", lockedTime);
        editor.commit();
    }

    public static void setAppLocked(Context context, Boolean isLocked){
        SharedPreferences preferences = context.getSharedPreferences(PIN_CODE_SETTINGS, Context.MODE_PRIVATE);
        SharedPreferences.Editor editor = preferences.edit();
        editor.putBoolean("isAppLocked", isLocked);
        editor.commit();
    }

    public static Boolean isAppLocked(Context context){
        SharedPreferences preferences = context.getSharedPreferences(PIN_CODE_SETTINGS, Context.MODE_PRIVATE);
        return preferences.getBoolean("isAppLocked", false);
    }

    //todo delete both save accept and get accept if it is confirmed there is no plan to force user to accept license
    public static void saveAccept(Context context){
        SharedPreferences preferences = context.getSharedPreferences("IsAcceptLicense", Context.MODE_PRIVATE);
        SharedPreferences.Editor editor = preferences.edit();
        editor.putBoolean("isAccept", true);
        editor.commit();
    }

    public static Boolean getAccept(Context context){
        SharedPreferences preferences = context.getSharedPreferences("IsAcceptLicense", Context.MODE_PRIVATE);
        Boolean isAccept = preferences.getBoolean("isAccept", false);
        return isAccept;
    }

    public static Boolean getFirstLoad(Context context){
        SharedPreferences preferences = context.getSharedPreferences(PIN_CODE_SETTINGS, Context.MODE_PRIVATE);
        Boolean isFirstLoad = preferences.getBoolean("isFirstLoad", false);
        return !isFirstLoad;
    }

    public static void saveFirstLoad(Context context){
        SharedPreferences preferences = context.getSharedPreferences(PIN_CODE_SETTINGS, Context.MODE_PRIVATE);
        SharedPreferences.Editor editor = preferences.edit();
        editor.putBoolean("isFirstLoad", true);
        editor.commit();
    }

    //END Pin code Settings

    public static void setPushData(Context context, String pushData) {
        SharedPreferences preferences = context.getSharedPreferences("PushNotification", Context.MODE_PRIVATE);
        SharedPreferences.Editor editor = preferences.edit();
        editor.putString("PushData", pushData);
        editor.commit();
    }

    public static void setPushDataEmpty(Context context) {
        setPushData(context, null);
    }

    //SSL Connection Settings
    public static void setSSLEnabled(Context context, Boolean isEnabled) {
        SharedPreferences preferences = context.getSharedPreferences(SettingsFragment.Constant.SSL_CONNECTION_TYPE, Context.MODE_PRIVATE);
        SharedPreferences.Editor editor = preferences.edit();
        editor.putBoolean(SettingsFragment.Constant.SSL_CONNECTION_TYPE, isEnabled);
        editor.apply();
    }

    public static Boolean getSSLEnabled(Context context){
        SharedPreferences preferences = context.getSharedPreferences(SettingsFragment.Constant.SSL_CONNECTION_TYPE, Context.MODE_PRIVATE);
        Boolean isSSLEnabled = preferences.getBoolean(SettingsFragment.Constant.SSL_CONNECTION_TYPE, false);
        return isSSLEnabled;
    }

    //Fingerprint settings
    public static void setFingerprintEnabled(Context context, Boolean isEnabled) {
        SharedPreferences preferences = context.getSharedPreferences(SettingsFragment.Constant.FINGERPRINT_TYPE, Context.MODE_PRIVATE);
        SharedPreferences.Editor editor = preferences.edit();
        editor.putBoolean(SettingsFragment.Constant.FINGERPRINT_TYPE, isEnabled);
        editor.apply();
    }

    public static Boolean getFingerprintEnabled(Context context){
        SharedPreferences preferences = context.getSharedPreferences(SettingsFragment.Constant.FINGERPRINT_TYPE, Context.MODE_PRIVATE);
        Boolean isFingerprintEnabled = preferences.getBoolean(SettingsFragment.Constant.FINGERPRINT_TYPE, false);
        return isFingerprintEnabled;
    }

    public static Boolean getSettingsValueEnabled(Context context, String key){
        SharedPreferences preferences = context.getSharedPreferences(key, Context.MODE_PRIVATE);
        Boolean isValue = preferences.getBoolean(key, false);
        return isValue;
    }

    public static void setSettingsValueEnabled(Context context, String key, Boolean isEnabled) {
        SharedPreferences preferences = context.getSharedPreferences(key, Context.MODE_PRIVATE);
        SharedPreferences.Editor editor = preferences.edit();
        editor.putBoolean(key, isEnabled);
        editor.apply();
    }

    //For purchases
    public static void setPurchase(Context context, Boolean isEnabled) {
        SharedPreferences preferences = context.getSharedPreferences("PurchaseSettings", Context.MODE_PRIVATE);
        SharedPreferences.Editor editor = preferences.edit();
        editor.putBoolean("isPurchased", isEnabled);
        editor.apply();
    }

    public static Boolean getPurchase(Context context){
        SharedPreferences preferences = context.getSharedPreferences("PurchaseSettings", Context.MODE_PRIVATE);
        Boolean isFingerprintEnabled = preferences.getBoolean("isPurchased", false);
        return isFingerprintEnabled;
    }

    //For actions bar menu
    public static Boolean getIsSettingsMenuVisible(Context context){
        SharedPreferences preferences = context.getSharedPreferences("CleanLogsSettings", Context.MODE_PRIVATE);
        Boolean isVisible = preferences.getBoolean("isCleanButtonVisible", false);
        return isVisible;
    }

    public static void setIsSettingsMenuVisible(Context context, Boolean isVisible){
        SharedPreferences preferences = context.getSharedPreferences("CleanLogsSettings", Context.MODE_PRIVATE);
        SharedPreferences.Editor editor = preferences.edit();
        editor.putBoolean("isCleanButtonVisible", isVisible);
        editor.apply();
        editor.commit();
    }

    public static Boolean getIsBackButtonVisibleForKey(Context context){
        SharedPreferences preferences = context.getSharedPreferences("CleanLogsSettings", Context.MODE_PRIVATE);
        Boolean isVisible = preferences.getBoolean("isBackButtonVisibleForKey", false);
        return isVisible;
    }

    public static void setIsBackButtonVisibleForKey(Context context, Boolean isVsible){
        SharedPreferences preferences = context.getSharedPreferences("CleanLogsSettings", Context.MODE_PRIVATE);
        SharedPreferences.Editor editor = preferences.edit();
        editor.putBoolean("isBackButtonVisibleForKey", isVsible);
        editor.apply();
    }

    public static Boolean getIsBackButtonVisibleForLog(Context context){
        SharedPreferences preferences = context.getSharedPreferences("CleanLogsSettings", Context.MODE_PRIVATE);
        Boolean isVisible = preferences.getBoolean("isBackButtonVisibleForLog", false);
        return isVisible;
    }

    public static void setIsBackButtonVisibleForLog(Context context, Boolean isVsible){
        SharedPreferences preferences = context.getSharedPreferences("CleanLogsSettings", Context.MODE_PRIVATE);
        SharedPreferences.Editor editor = preferences.edit();
        editor.putBoolean("isBackButtonVisibleForLog", isVsible);
        editor.apply();
    }

    public Boolean getEditingModeLogs() {
        return isEditingModeLogs;
    }

    public void setEditingModeLogs(Boolean editingModeLogs) {
        isEditingModeLogs = editingModeLogs;
    }

    public Boolean getForLogs() {
        return isForLogs;
    }

    public void setForLogs(Boolean forLogs) {
        isForLogs = forLogs;
    }

    public Boolean getForKeys() {
        return isForKeys;
    }

    public void setForKeys(Boolean forKeys) {
        isForKeys = forKeys;
    }

    public static class Constant {
        public static final String PIN_CODE = "PinCode";
        public static final String IS_PIN_ENABLED = "isPinEnabled";
        public static final String PIN_CODE_ATTEMPTS = "pinCodeAttempts";
        public static final String CURRENT_PIN_CODE_ATTEMPTS = "currentPinCodeAttempts";
    }
}
