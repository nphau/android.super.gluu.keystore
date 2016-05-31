package org.gluu.oxpush2.app.Fragments.SettingsFragment;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.content.SharedPreferences;
import android.os.Bundle;
import android.support.v4.app.Fragment;
import android.support.v4.app.FragmentTransaction;
import android.support.v4.content.LocalBroadcastManager;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.Switch;

import com.hrules.horizontalnumberpicker.HorizontalNumberPicker;
import com.hrules.horizontalnumberpicker.HorizontalNumberPickerListener;

import org.gluu.oxpush2.app.Activities.MainActivity;
import org.gluu.oxpush2.app.CustomGluuAlertView.CustomGluuAlert;
import org.gluu.oxpush2.app.Fragments.LockFragment.LockFragment;
import org.gluu.oxpush2.app.Fragments.PinCodeFragment.PinCodeFragment;
import org.gluu.oxpush2.app.Fragments.PinCodeFragment.PinCodeSettingFragment;
import org.gluu.oxpush2.app.GluuMainActivity;
import org.gluu.oxpush2.app.R;

/**
 * Created by nazaryavornytskyy on 3/23/16.
 */
public class SettingsFragment extends Fragment implements View.OnClickListener, HorizontalNumberPickerListener {

    Button setResetPinButton;
    private Context context;
    private PinCodeFragment pinCodeFragment;

    private BroadcastReceiver mReceiver = new BroadcastReceiver() {
        @Override
        public void onReceive(Context context, Intent intent) {
//            String message = intent.getStringExtra("message");
            loadLockedFragment(true);
        }
    };

    @Override
    public void onDestroy() {
        // Unregister since the activity is about to be closed.
        LocalBroadcastManager.getInstance(getActivity()).unregisterReceiver(mReceiver);
        super.onDestroy();
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {

        View view = inflater.inflate(R.layout.fragment_settings, container, false);
        context = getContext();
        setResetPinButton = (Button) view.findViewById(R.id.set_reset_pin_button);
        setResetPinButton.setOnClickListener(this);

        final Switch turOn = (Switch) view.findViewById(R.id.switch_pin_code);
        turOn.setChecked(getPincodeEnabled());
        turOn.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                setPincodeEnabled(turOn.isChecked());
                if (turOn.isChecked()) {
                    setResetPinButton.setVisibility(View.VISIBLE);
                } else {
                    setResetPinButton.setVisibility(View.GONE);
                }
                checkPinCode();
            }
        });
        if (getPincodeEnabled()) {
            setResetPinButton.setVisibility(View.VISIBLE);
        } else {
            setResetPinButton.setVisibility(View.GONE);
        }
        HorizontalNumberPicker numberPicker = (HorizontalNumberPicker) view.findViewById(R.id.horizontal_number_picker);
        numberPicker.setMaxValue(10);
        numberPicker.setMinValue(5);
        numberPicker.setValue(getPinCodeAttempts());
        numberPicker.setListener(this);
        checkPinCode();

        LocalBroadcastManager.getInstance(getActivity()).registerReceiver(mReceiver,
                new IntentFilter("pin_code-event"));

        return view;
    }

    public static SettingsFragment createInstance(){
        return new SettingsFragment();
    }

    public void checkPinCode(){
        String pinCode = getPinCode();
        if (!pinCode.equalsIgnoreCase("null")){
            setResetPinButton.setText(R.string.reset_pin_code);
        } else {
            setResetPinButton.setText(R.string.set_new_pin_code);
        }
    }

    public Boolean getPincodeEnabled(){
        SharedPreferences preferences = context.getSharedPreferences("PinCodeSettings", Context.MODE_PRIVATE);
        Boolean isPinEnabled = preferences.getBoolean("isPinEnabled", false);
        return isPinEnabled;
    }

    public void setPincodeEnabled(Boolean isEnabled){
        SharedPreferences preferences = context.getSharedPreferences("PinCodeSettings", Context.MODE_PRIVATE);
        SharedPreferences.Editor editor = preferences.edit();
        editor.putBoolean("isPinEnabled", isEnabled);
        editor.commit();
    }

    public String getPinCode(){
        SharedPreferences preferences = context.getSharedPreferences("PinCodeSettings", Context.MODE_PRIVATE);
        String pinCode = preferences.getString("PinCode", "null");
        return pinCode;
    }

    public void setPinCodeAttempts(String attempts){
        SharedPreferences preferences = context.getSharedPreferences("PinCodeSettings", Context.MODE_PRIVATE);
        SharedPreferences.Editor editor = preferences.edit();
        editor.putString("pinCodeAttempts", attempts);
        editor.commit();
    }

    public int getPinCodeAttempts(){
        SharedPreferences preferences = context.getSharedPreferences("PinCodeSettings", Context.MODE_PRIVATE);
        String pinCode = preferences.getString("pinCodeAttempts", "5");
        return Integer.parseInt(pinCode);
    }

    @Override
    public void onClick(View v) {
        GluuMainActivity.GluuAlertCallback listener = new GluuMainActivity.GluuAlertCallback(){
            @Override
            public void onPositiveButton() {
                saveIsReset();
                loadPinCodeView(true);
            }
        };
        CustomGluuAlert gluuAlert = new CustomGluuAlert(getActivity());
        gluuAlert.setMessage(getContext().getString(R.string.change_pin));
        gluuAlert.setYesTitle(getContext().getString(R.string.yes));
        gluuAlert.setNoTitle(getContext().getString(R.string.no));
        gluuAlert.setmListener(listener);
        gluuAlert.show();
    }

    private void loadPinCodeView(Boolean isBackStack){
        pinCodeFragment = new PinCodeFragment();
        pinCodeFragment.setIsSettings(true);
//        if (!getPinCode().equalsIgnoreCase("null")){
        pinCodeFragment.setIsSetNewPinCode(true);
//        }
        FragmentTransaction transaction = getFragmentManager().beginTransaction();
        transaction.replace(R.id.root_frame, pinCodeFragment);
        if (isBackStack) {
            transaction.addToBackStack(null);
        }
        transaction.commit();
    }

    private void loadLockedFragment(Boolean isRecover){
//        FragmentTransaction fragmentTransaction = getFragmentManager().beginTransaction();
//        LockFragment lockFragment = new LockFragment();
//        MainActivity.OnLockAppTimerOver timeOverListener = new MainActivity.OnLockAppTimerOver() {
//            @Override
//            public void onTimerOver() {
//                setAppLocked(false);
//                loadPinCodeView(true);
//            }
//        };
//        lockFragment.setIsRecover(isRecover);
////        lockFragment.setListener(timeOverListener);
//        fragmentTransaction.replace(R.id.root_frame, lockFragment);
////            fragmentTransaction.addToBackStack(null);
//        fragmentTransaction.commit();
    }

//    private void setAppLocked(Boolean isLocked){
//        SharedPreferences preferences = context.getSharedPreferences("PinCodeSettings", Context.MODE_PRIVATE);
//        SharedPreferences.Editor editor = preferences.edit();
//        editor.putBoolean("isAppLocked", isLocked);
//        editor.commit();
//    }

    public void saveIsReset(){
        SharedPreferences preferences = getContext().getSharedPreferences("PinCodeSettings", Context.MODE_PRIVATE);
        SharedPreferences.Editor editor = preferences.edit();
        editor.putBoolean("isReset", true);
        editor.commit();
    }

    @Override
    public void onHorizontalNumberPickerChanged(HorizontalNumberPicker horizontalNumberPicker, int value) {
        setPinCodeAttempts(String.valueOf(value));
    }

}
