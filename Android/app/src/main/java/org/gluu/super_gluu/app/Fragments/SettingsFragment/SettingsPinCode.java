package org.gluu.super_gluu.app.fragments.SettingsFragment;

import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.support.v4.app.Fragment;
import android.support.v4.app.FragmentTransaction;
import android.support.v4.content.LocalBroadcastManager;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.LinearLayout;
import android.widget.Switch;
import android.widget.TextView;

import com.hrules.horizontalnumberpicker.HorizontalNumberPicker;
import com.hrules.horizontalnumberpicker.HorizontalNumberPickerListener;

import org.gluu.super_gluu.app.GluuMainActivity;
import org.gluu.super_gluu.app.customGluuAlertView.CustomGluuAlert;
import org.gluu.super_gluu.app.fingerprint.Fingerprint;
import org.gluu.super_gluu.app.fragments.PinCodeFragment.PinCodeFragment;
import org.gluu.super_gluu.app.settings.Settings;

import SuperGluu.app.R;

/**
 * Created by nazaryavornytskyy on 5/17/17.
 */

public class SettingsPinCode extends Fragment implements HorizontalNumberPickerListener {

    Button setResetPinButton;
    private Context context;
    private LayoutInflater inflater;
    private PinCodeFragment pinCodeFragment;
    private LinearLayout attemptsLayout;
    private TextView attemptsLabel;

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {

        View view = inflater.inflate(R.layout.settings_pincode, container, false);
        context = getContext();
        this.inflater = inflater;
        setResetPinButton = (Button) view.findViewById(R.id.set_reset_pin_button);
        setResetPinButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                GluuMainActivity.GluuAlertCallback listener = new GluuMainActivity.GluuAlertCallback() {
                    @Override
                    public void onPositiveButton() {
                        Settings.saveIsReset(context);
                        loadPinCodeView(true);
                    }

                    @Override
                    public void onNegativeButton() {
                        //Skip here
                    }
                };
                CustomGluuAlert gluuAlert = new CustomGluuAlert(getActivity());
                gluuAlert.setMessage(getContext().getString(R.string.change_pin));
                gluuAlert.setYesTitle(getContext().getString(R.string.yes));
                gluuAlert.setNoTitle(getContext().getString(R.string.no));
                gluuAlert.setmListener(listener);
                gluuAlert.show();
            }
        });
        attemptsLayout = (LinearLayout) view.findViewById(R.id.numbers_attempts_view);
        attemptsLabel = (TextView) view.findViewById(R.id.numbers_attempts_label);

        final Switch turOn = (Switch) view.findViewById(R.id.switch_pin_code);
        turOn.setChecked(Settings.getPinCodeEnabled(context));
        setPinCode(turOn.isChecked());
        turOn.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                setPinCode(turOn.isChecked());
                if (turOn.isChecked()) {
                    Settings.setFingerprintEnabled(context, !turOn.isChecked());
                }
            }
        });
        if (Settings.getPinCodeEnabled(context)) {
            setResetPinButton.setVisibility(View.VISIBLE);
        } else {
            setResetPinButton.setVisibility(View.GONE);
        }
        HorizontalNumberPicker numberPicker = (HorizontalNumberPicker) view.findViewById(R.id.horizontal_number_picker);
        numberPicker.setMaxValue(10);
        numberPicker.setMinValue(5);
        numberPicker.setValue(Settings.getPinCodeAttempts(context));
        numberPicker.setListener(this);
        checkPinCode();

        view.findViewById(R.id.button_ad_free).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Intent intent = new Intent("on-ad-free-flow");
                LocalBroadcastManager.getInstance(context).sendBroadcast(intent);
            }
        });

        return view;
    }

    public void checkPinCode() {
        String pinCode = Settings.getPinCode(context);
        if (!pinCode.equalsIgnoreCase("null")) {
            setResetPinButton.setText(R.string.reset_pin_code);
        } else {
            setResetPinButton.setText(R.string.set_new_pin_code);
        }
    }

    private void setPinCode(Boolean isTurnOn) {
        Settings.setPinCodeEnabled(context, isTurnOn);
        if (isTurnOn) {
            setResetPinButton.setVisibility(View.VISIBLE);
            attemptsLayout.setVisibility(View.VISIBLE);
            attemptsLabel.setVisibility(View.VISIBLE);
        } else {
            setResetPinButton.setVisibility(View.GONE);
            attemptsLayout.setVisibility(View.GONE);
            attemptsLabel.setVisibility(View.GONE);
        }
        checkPinCode();
    }

    private void loadPinCodeView(Boolean isBackStack) {
        pinCodeFragment = new PinCodeFragment();
        pinCodeFragment.setIsSettings(true);
        pinCodeFragment.setIsSetNewPinCode(true);
        FragmentTransaction transaction = getFragmentManager().beginTransaction();
        transaction.replace(R.id.root_frame, pinCodeFragment);
        if (isBackStack) {
            transaction.addToBackStack(null);
        }
        transaction.commit();
    }


    @Override
    public void onHorizontalNumberPickerChanged(HorizontalNumberPicker horizontalNumberPicker, int value) {
        Settings.setPinCodeAttempts(context, String.valueOf(value));
    }
}
