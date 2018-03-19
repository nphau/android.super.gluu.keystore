package org.gluu.super_gluu.app.fragments.PinCodeFragment;

import android.annotation.SuppressLint;
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

/**
 * Created by nazaryavornytskyy on 3/24/16.
 */
public class PinCodeSettingFragment extends Fragment {

    LicenseFragment.OnMainActivityListener mainActivityListener;

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {

        View view = inflater.inflate(R.layout.fragment_pin_code_setting, container, false);

        if (!isPin()){
            mainActivityListener.onShowPinFragment(true);
        }

        TextView textSettingsTitle = (TextView)view.findViewById(R.id.pinCodeTitle);
        TextView textSettingsSubTitle = (TextView)view.findViewById(R.id.pinSubCodeTitle);
        Button yesButton = (Button)view.findViewById(R.id.yes_button_pin);
        yesButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                mainActivityListener.onShowPinFragment(false);
                Settings.setPinCodeEnabled(getContext(), true);
            }
        });
        Button noButton = (Button)view.findViewById(R.id.no_button_pin);
        noButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                mainActivityListener.onMainActivity();
                Settings.setPinCodeEnabled(getContext(), false);
            }
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


    public Boolean isPin(){
        SharedPreferences preferences = getContext().getSharedPreferences(Settings.PIN_CODE_SETTINGS, Context.MODE_PRIVATE);
        String pinCode = preferences.getString(Settings.Constant.PIN_CODE, null);
        return pinCode == null;
    }
}
