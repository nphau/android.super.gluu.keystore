package org.gluu.super_gluu.app.fragments.SettingsFragment;

import android.content.Intent;
import android.graphics.Typeface;
import android.os.Bundle;
import android.support.v4.app.FragmentTransaction;
import android.support.v4.content.LocalBroadcastManager;
import android.support.v7.widget.Toolbar;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.CompoundButton;
import android.widget.LinearLayout;
import android.widget.Switch;
import android.widget.TextView;
import org.gluu.super_gluu.app.fragments.PinCodeFragment.PinCodeFragment;
import org.gluu.super_gluu.app.GluuMainActivity;
import org.gluu.super_gluu.app.NotificationType;
import org.gluu.super_gluu.app.base.ToolbarFragment;
import org.gluu.super_gluu.app.customGluuAlertView.CustomGluuAlert;
import org.gluu.super_gluu.app.settings.Settings;

import SuperGluu.app.R;
import butterknife.BindView;
import butterknife.ButterKnife;

/**
 * Created by nazaryavornytskyy on 5/17/17.
 */

public class SettingsPinCode extends ToolbarFragment {

    @BindView(R.id.nav_drawer_toolbar)
    Toolbar toolbar;
    @BindView(R.id.set_reset_pin_button)
    Button setResetPinButton;
    @BindView(R.id.numbers_attempts_view)
    LinearLayout attemptsLayout;
    @BindView(R.id.numbers_attempts_description)
    TextView attemptsDescription;
    @BindView(R.id.switch_pin_code)
    Switch pinCodeSwitch;
    @BindView(R.id.button_ad_free)
    Button adFreeButton;

    @BindView(R.id.settings_textView1)
    TextView textView1;
    @BindView(R.id.settings_textView2)
    TextView textView2;
    @BindView(R.id.numbers_attempts_label)
    TextView numberOfAttemptsLabel;
    @BindView(R.id.number_of_attempts)
    TextView numberOfAttemptsText;

    GluuMainActivity.GluuAlertCallback listener;

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {

        View view = inflater.inflate(R.layout.settings_pincode, container, false);
        ButterKnife.bind(this, view);

        setupHomeAsUpEnabledToolbar(toolbar, getString(R.string.pin_code));
        setHasOptionsMenu(true);

        listener = new GluuMainActivity.GluuAlertCallback() {
            @Override
            public void onPositiveButton() {
                Settings.saveIsReset(getContext());
                loadPinCodeView(true, true);
            }

            @Override
            public void onNegativeButton() {
                String pinCode = Settings.getPinCode(getContext());
                if(pinCode == null) {
                    setPinCode(false);
                    pinCodeSwitch.setChecked(false);
                }
            }
        };
        setResetPinButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                String pinCode = Settings.getPinCode(getContext());
                if(pinCode == null) {
                    Settings.saveIsReset(getContext());
                    loadPinCodeView(true, true);
                } else {
                    showLoadPinCodeAlert();
                }
            }
        });


        pinCodeSwitch.setChecked(Settings.getPinCodeEnabled(getContext()));
        setPinCode(pinCodeSwitch.isChecked());

        pinCodeSwitch.setOnCheckedChangeListener(new CompoundButton.OnCheckedChangeListener() {
            @Override
            public void onCheckedChanged(CompoundButton compoundButton, boolean checked) {
                setPinCode(checked);
                if (checked) {
                    Settings.setFingerprintEnabled(getContext(), !pinCodeSwitch.isChecked());
                }

                String pinCode = Settings.getPinCode(getContext());
                if(checked && pinCode == null) {
                    showLoadPinCodeAlert();
                }
            }
        });

        if (Settings.getPinCodeEnabled(getContext())) {
            setResetPinButton.setVisibility(View.VISIBLE);
        } else {
            setResetPinButton.setVisibility(View.GONE);
        }

        checkPinCode();

        adFreeButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Intent intent = new Intent("on-ad-free-flow");
                LocalBroadcastManager.getInstance(getContext()).sendBroadcast(intent);
            }
        });

        //setup fonts
        Typeface face = Typeface.createFromAsset(getActivity().getAssets(), "ProximaNova-Regular.otf");
        Typeface faceBold = Typeface.createFromAsset(getActivity().getAssets(), "ProximaNova-Semibold.otf");
        textView1.setTypeface(face);
        textView2.setTypeface(face);
        numberOfAttemptsLabel.setTypeface(face);
        setResetPinButton.setTypeface(faceBold);
        numberOfAttemptsText.setTypeface(face);

        return view;
    }

    public void checkPinCode() {
        String pinCode = Settings.getPinCode(getContext());
        if (pinCode != null) {
            setResetPinButton.setText(R.string.reset_pin_code);
        } else {
            setResetPinButton.setText(R.string.set_new_pin_code);
        }
    }

    private void setPinCode(Boolean isTurnOn) {
        Settings.setPinCodeEnabled(getContext(), isTurnOn);
        if (isTurnOn) {
            setResetPinButton.setVisibility(View.VISIBLE);
            attemptsLayout.setVisibility(View.VISIBLE);
            attemptsDescription.setVisibility(View.VISIBLE);
        } else {
            setResetPinButton.setVisibility(View.GONE);
            attemptsLayout.setVisibility(View.GONE);
            attemptsDescription.setVisibility(View.GONE);
        }
        checkPinCode();
    }

    private void loadPinCodeView(Boolean isBackStack, boolean isNewPinCode) {
        PinCodeFragment pinCodeFragment =
                PinCodeFragment.newInstance(PinCodeFragment.Constant.SET_CODE, isNewPinCode, true);
        FragmentTransaction transaction = getFragmentManager().beginTransaction();
        transaction.replace(R.id.main_frame_layout, pinCodeFragment);
        if (isBackStack) {
            transaction.addToBackStack(null);
        }
        transaction.commit();
    }

    private void showLoadPinCodeAlert() {
        CustomGluuAlert loadPinCodeAlert = new CustomGluuAlert(getActivity());

        String pinCode = Settings.getPinCode(getContext());

        if(pinCode == null) {
            loadPinCodeAlert.setSub_title(getContext().getString(R.string.set_pin));
        } else {
            loadPinCodeAlert.setSub_title(getContext().getString(R.string.change_pin));
        }

        loadPinCodeAlert.setYesTitle(getContext().getString(R.string.yes));
        loadPinCodeAlert.setNoTitle(getContext().getString(R.string.no));
        loadPinCodeAlert.setmListener(listener);
        loadPinCodeAlert.type = NotificationType.RENAME_KEY;
        loadPinCodeAlert.show();
    }

}
