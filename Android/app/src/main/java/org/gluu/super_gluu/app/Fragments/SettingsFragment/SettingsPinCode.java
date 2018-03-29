package org.gluu.super_gluu.app.fragments.SettingsFragment;

import android.content.Context;
import android.content.DialogInterface;
import android.os.Bundle;
import android.support.v4.app.FragmentTransaction;
import android.support.v7.widget.Toolbar;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.RelativeLayout;
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
    @BindView(R.id.set_reset_pin_text_view)
    TextView setResetTextView;
    @BindView(R.id.numbers_attempts_description)
    TextView attemptsDescription;
    @BindView(R.id.switch_pin_code)
    Switch pinCodeSwitch;

    @BindView(R.id.pin_code_title)
    TextView pinCodeTitle;
    @BindView(R.id.pin_code_description)
    TextView pinCodeDescription;

    @BindView(R.id.set_pin_code_container)
    RelativeLayout setPinCodeContainer;

    GluuMainActivity.GluuAlertCallback listener;

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {

        View view = inflater.inflate(R.layout.settings_pincode, container, false);
        ButterKnife.bind(this, view);

        setDefaultToolbar(toolbar, getString(R.string.pin_code), true);
        setHasOptionsMenu(true);

        listener = new GluuMainActivity.GluuAlertCallback() {
            @Override
            public void onPositiveButton() {
                Settings.saveIsReset(getContext());
                String pinCode = Settings.getPinCode(getContext());

                loadPinCodeView(true, pinCode != null);
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
        setPinCodeContainer.setOnClickListener(v -> {
            String pinCode = Settings.getPinCode(getContext());
            if(pinCode == null) {
                Settings.saveIsReset(getContext());
                loadPinCodeView(true, true);
            } else {
                showLoadPinCodeAlert();
            }
        });


        pinCodeSwitch.setOnCheckedChangeListener((compoundButton, checked) -> {

            if(pinCodeSwitch.isPressed()) {
                setPinCode(checked);

                String pinCode = Settings.getPinCode(getContext());
                if (checked && pinCode == null) {
                    showLoadPinCodeAlert();
                }
            }
        });

        return view;
    }

    @Override
    public void onResume() {
        super.onResume();
        if (Settings.getPinCodeEnabled(getContext())) {
            setPinCodeContainer.setVisibility(View.VISIBLE);
            pinCodeSwitch.setChecked(true);
            setPinCode(true);
        } else {
            setPinCodeContainer.setVisibility(View.GONE);
            pinCodeSwitch.setChecked(false);
            setPinCode(false);
        }
    }



    private void setPinCode(Boolean isTurnOn) {
        if(getContext() == null) {
            return;
        }

        if (isTurnOn) {
            setPinCodeContainer.setVisibility(View.VISIBLE);
            attemptsDescription.setVisibility(View.VISIBLE);
        } else {
            setPinCodeContainer.setVisibility(View.GONE);
            attemptsDescription.setVisibility(View.GONE);
            Settings.setPinCodeEnabled(getContext(), false);
            Settings.clearPinCode(getContext());
        }
    }

    private void loadPinCodeView(Boolean isBackStack, boolean isNewPinCode) {

        PinCodeFragment.EntryType entryType = isNewPinCode ? PinCodeFragment.EntryType.CHANGING_CURRENT : PinCodeFragment.EntryType.SETTING_NEW;

        PinCodeFragment pinCodeFragment = PinCodeFragment.newInstance(entryType);
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
        loadPinCodeAlert.setOnCancelListener(dialogInterface -> listener.onNegativeButton());
        loadPinCodeAlert.setmListener(listener);
        loadPinCodeAlert.type = NotificationType.RENAME_KEY;
        loadPinCodeAlert.show();
    }

}
