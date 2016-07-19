package org.gluu.super_gluu.app.settings;

import android.content.Context;
import android.content.SharedPreferences;

/**
 * Created by nazaryavornytskyy on 7/12/16.
 */
public class Settings {

    //Pin code Settings

    public static void setPinCodeEnabled(Context context, Boolean isEnabled) {
        SharedPreferences preferences = context.getSharedPreferences("PinCodeSettings", Context.MODE_PRIVATE);
        SharedPreferences.Editor editor = preferences.edit();
        editor.putBoolean("isPinEnabled", isEnabled);
        editor.commit();
    }

    public static Boolean getPinCodeEnabled(Context context){
        SharedPreferences preferences = context.getSharedPreferences("PinCodeSettings", Context.MODE_PRIVATE);
        Boolean isPinEnabled = preferences.getBoolean("isPinEnabled", false);
        return isPinEnabled;
    }

    public static String getPinCode(Context context){
        SharedPreferences preferences = context.getSharedPreferences("PinCodeSettings", Context.MODE_PRIVATE);
        String pinCode = preferences.getString("PinCode", "null");
        return pinCode;
    }

    public static void savePinCode(Context context, String password){
        SharedPreferences preferences = context.getSharedPreferences("PinCodeSettings", Context.MODE_PRIVATE);
        SharedPreferences.Editor editor = preferences.edit();
        editor.putString("PinCode", password);
        editor.commit();
    }

    public static void setPinCodeAttempts(Context context, String attempts){
        SharedPreferences preferences = context.getSharedPreferences("PinCodeSettings", Context.MODE_PRIVATE);
        SharedPreferences.Editor editor = preferences.edit();
        editor.putString("pinCodeAttempts", attempts);
        editor.commit();
    }

    public static int getPinCodeAttempts(Context context){
        SharedPreferences preferences = context.getSharedPreferences("PinCodeSettings", Context.MODE_PRIVATE);
        String pinCode = preferences.getString("pinCodeAttempts", "5");
        return Integer.parseInt(pinCode);
    }

    public static int getCurrentPinCodeAttempts(Context context){
        SharedPreferences preferences = context.getSharedPreferences("PinCodeSettings", Context.MODE_PRIVATE);
        String pinCode = preferences.getString("currentPinCodeAttempts", String.valueOf(Settings.getPinCodeAttempts(context)));
        return Integer.parseInt(pinCode);
    }

    public static void setCurrentPinCodeAttempts(Context context, int attempts){
        SharedPreferences preferences = context.getSharedPreferences("PinCodeSettings", Context.MODE_PRIVATE);
        SharedPreferences.Editor editor = preferences.edit();
        editor.putString("currentPinCodeAttempts", String.valueOf(attempts));
        editor.commit();
    }

    public static void saveIsReset(Context context){
        SharedPreferences preferences = context.getSharedPreferences("PinCodeSettings", Context.MODE_PRIVATE);
        SharedPreferences.Editor editor = preferences.edit();
        editor.putBoolean("isReset", true);
        editor.commit();
    }

    public static void setAppLockedTime(Context context, String lockedTime){
        SharedPreferences preferences = context.getSharedPreferences("PinCodeSettings", Context.MODE_PRIVATE);
        SharedPreferences.Editor editor = preferences.edit();
        editor.putString("appLockedTime", lockedTime);
        editor.commit();
    }

    public static void setAppLocked(Context context, Boolean isLocked){
        SharedPreferences preferences = context.getSharedPreferences("PinCodeSettings", Context.MODE_PRIVATE);
        SharedPreferences.Editor editor = preferences.edit();
        editor.putBoolean("isAppLocked", isLocked);
        editor.commit();
    }

    public static Boolean isAppLocked(Context context){
        SharedPreferences preferences = context.getSharedPreferences("PinCodeSettings", Context.MODE_PRIVATE);
        return preferences.getBoolean("isAppLocked", false);
    }

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
        SharedPreferences preferences = context.getSharedPreferences("PinCodeSettings", Context.MODE_PRIVATE);
        Boolean isFirstLoad = preferences.getBoolean("isFirstLoad", false);
        return !isFirstLoad;
    }

    public static void saveFirstLoad(Context context){
        SharedPreferences preferences = context.getSharedPreferences("PinCodeSettings", Context.MODE_PRIVATE);
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

}
