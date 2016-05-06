package org.gluu.oxpush2.app.Fragments.SettingsFragment;

import android.content.Context;
import android.content.SharedPreferences;
import android.os.Bundle;
import android.support.v4.app.Fragment;
import android.support.v4.app.FragmentTransaction;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.Switch;

import com.hrules.horizontalnumberpicker.HorizontalNumberPicker;
import com.hrules.horizontalnumberpicker.HorizontalNumberPickerListener;

import org.gluu.oxpush2.app.Fragments.PinCodeFragment.PinCodeFragment;
import org.gluu.oxpush2.app.R;

/**
 * Created by nazaryavornytskyy on 3/23/16.
 */
public class SettingsFragment extends Fragment implements View.OnClickListener, HorizontalNumberPickerListener {

    Button setResetPinButton;

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {

        View view = inflater.inflate(R.layout.fragment_settings, container, false);

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

        return view;
    }

    public static SettingsFragment createInstance(){
        return new SettingsFragment();
    }

    public void checkPinCode(){
        String pinCode = getPinCode();
        if (!pinCode.equalsIgnoreCase("0000")){
            setResetPinButton.setText(R.string.reset_pin_code);
        } else {
            setResetPinButton.setText(R.string.set_new_pin_code);
        }
    }

    public Boolean getPincodeEnabled(){
        SharedPreferences preferences = getContext().getSharedPreferences("PinCodeSettings", Context.MODE_PRIVATE);
        Boolean isPinEnabled = preferences.getBoolean("isPinEnabled", false);
        return isPinEnabled;
    }

    public void setPincodeEnabled(Boolean isEnabled){
        SharedPreferences preferences = getContext().getSharedPreferences("PinCodeSettings", Context.MODE_PRIVATE);
        SharedPreferences.Editor editor = preferences.edit();
        editor.putBoolean("isPinEnabled", isEnabled);
        editor.commit();
    }

    public String getPinCode(){
        SharedPreferences preferences = getContext().getSharedPreferences("PinCodeSettings", Context.MODE_PRIVATE);
        String pinCode = preferences.getString("PinCode", "0000");
        return pinCode;
    }

    public void setPinCodeAttempts(String attempts){
        SharedPreferences preferences = getContext().getSharedPreferences("PinCodeSettings", Context.MODE_PRIVATE);
        SharedPreferences.Editor editor = preferences.edit();
        editor.putString("pinCodeAttempts", attempts);
        editor.commit();
    }

    public int getPinCodeAttempts(){
        SharedPreferences preferences = getContext().getSharedPreferences("PinCodeSettings", Context.MODE_PRIVATE);
        String pinCode = preferences.getString("pinCodeAttempts", "5");
        return Integer.parseInt(pinCode);
    }

    @Override
    public void onClick(View v) {
        saveIsReset();
        loadPinCodeView(true);
    }

    private void loadPinCodeView(Boolean isBackStack){
        PinCodeFragment pinCodeFragment = new PinCodeFragment();
        FragmentTransaction transaction = getFragmentManager().beginTransaction();
        transaction.replace(R.id.root_frame, pinCodeFragment);
        if (isBackStack) {
            transaction.addToBackStack(null);
        }
        transaction.commit();
    }

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
