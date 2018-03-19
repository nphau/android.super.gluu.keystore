package org.gluu.super_gluu.app.fragments.PinCodeFragment;

import android.content.Context;
import android.content.SharedPreferences;
import android.graphics.Typeface;
import android.os.Bundle;
import android.support.v4.app.Fragment;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.TextView;

import org.gluu.super_gluu.app.fragments.LicenseFragment.LicenseFragment;
import org.gluu.super_gluu.app.settings.Settings;

import SuperGluu.app.R;
import butterknife.BindView;
import butterknife.ButterKnife;

/**
 * Created by nazaryavornytskyy on 3/24/16.
 */
public class PinCodeSettingFragment extends Fragment {

    @BindView(R.id.yes_button_pin)
    Button yesButton;
    @BindView(R.id.no_button_pin)
    Button noButton;
    @BindView(R.id.pinCodeTitle)
    TextView textSettingsTitle;
    @BindView(R.id.pinSubCodeTitle)
    TextView textSettingsSubTitle;

    LicenseFragment.OnMainActivityListener mainActivityListener;

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {

        View view = inflater.inflate(R.layout.fragment_pin_code_setting, container, false);

        ButterKnife.bind(this, view);

        if (!isPin()){
            mainActivityListener.onShowPinFragment(true);
        }

        yesButton.setOnClickListener(v -> {
            mainActivityListener.onShowPinFragment(false);
            Settings.setPinCodeEnabled(getContext(), true);
        });
        noButton.setOnClickListener(v -> {
            mainActivityListener.onMainActivity();
            Settings.setPinCodeEnabled(getContext(), false);
        });

        Typeface faceLight = Typeface.createFromAsset(getActivity().getAssets(), "ProximaNova-Regular.otf");
        textSettingsTitle.setTypeface(faceLight);
        textSettingsSubTitle.setTypeface(faceLight);
        yesButton.setTypeface(faceLight);
        noButton.setTypeface(faceLight);

        return view;
    }

    @Override
    public void onAttach(Context context) {
        super.onAttach(context);
        if (context instanceof LicenseFragment.OnMainActivityListener) {
            mainActivityListener = (LicenseFragment.OnMainActivityListener) context;
        } else {
            throw new RuntimeException(context.toString()
                    + " must implement OnMainActivityListener");
        }
    }

    public boolean isPin() {
        return Settings.getPinCode(getContext()) == null;
    }
}
